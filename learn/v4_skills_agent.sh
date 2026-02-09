#!/usr/bin/env bash
#
# v4_skills_agent.sh - Mini Agent: Skills Mechanism (~550 lines)
#
# 核心哲学: "Knowledge Externalization" (知识外部化)
# ==========================================
# v3 给了我们用于任务分解的子代理。但有一个更深层次的问题:
#
#     模型如何知道 HOW 处理领域特定任务？
#
# - 处理 PDF？它需要知道 pdftotext vs PyMuPDF
# - 构建 MCP 服务器？它需要协议规范和最佳实践
# - 代码审查？它需要系统性检查清单
#
# 这些知识不是工具 - 它是专业知识。技能通过让模型按需加载领域知识来解决这个问题。
#
# 范式转变: 知识外部化
# ----------------------
# 传统 AI: 知识锁定在模型参数中
#   - 教授新技能: 收集数据 -> 训练 -> 部署
#   - 成本: $10K-$1M+, 时间: 数周
#   - 需要 ML 专业知识、GPU 集群
#
# 技能: 知识存储在可编辑文件中
#   - 教授新技能: 编写一个 SKILL.md 文件
#   - 成本: 免费, 时间: 几分钟
#   - 任何人都能做
#
# 这就像附加一个可热插拔的 LoRA 适配器而无需任何训练！
#
# 工具 vs 技能:
# -------------
#     | 概念      | 它是什么              | 示例                       |
#     |----------|----------------------|---------------------------|
#     | **工具**  | 模型 CAN 做什么       | bash, read_file, write    |
#     | **技能**  | 模型 KNOWS 怎么做     | PDF 处理, MCP 开发         |
#
# 工具是能力。技能是知识。
#
# 渐进式披露:
# ------------
#     第 1 层: 元数据 (始终加载)      ~100 tokens/技能
#              只有名称 + 描述
#
#     第 2 层: SKILL.md 正文 (触发时加载)  ~2000 tokens
#              详细说明
#
#     第 3 层: 资源 (按需)             无限制
#              scripts/, references/, assets/
#
# 这保持上下文精简同时允许任意深度。
#
# SKILL.md 标准:
# ---------------
#     skills/
#     |-- pdf/
#     |   |-- SKILL.md          # 必需: YAML frontmatter + Markdown 正文
#     |-- mcp-builder/
#     |   |-- SKILL.md
#     |   |-- references/       # 可选: 文档、规范
#     |-- code-review/
#         |-- SKILL.md
#         |-- scripts/          # 可选: 辅助脚本
#
# 缓存保留注入:
# ------------
# 关键洞察: 技能内容进入 tool_result (用户消息)，
# 而不是系统提示。这保留了提示缓存！
#
#     错误: 每次编辑系统提示 (缓存失效，20-50x 成本)
#     正确: 将技能附加为工具结果 (前缀不变，缓存命中)
#
# 这就是生产级 Claude Code 的工作方式 - 以及它成本效益高的原因。

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

API_KEY="${DEEPSEEK_API_KEY}"
BASE_URL="${DEEPSEEK_BASE_URL:-https://api.deepseek.com/anthropic}"
MODEL="${MODEL_ID:-deepseek-chat}"
WORKDIR="${WORKDIR:-$(pwd)}"
MEMORY_DIR="${MEMORY_DIR:-$WORKDIR/.ai-memory}"
SKILLS_DIR="${WORKDIR}/skills"

mkdir -p "$MEMORY_DIR"

# =============================================================================
# 代理类型定义
# =============================================================================

declare -A AGENT_TYPES=(
    [explore_desc]="Read-only agent"
    [explore_tools]="bash,read_file"
    [explore_prompt]="You are an exploration agent. Search and analyze, but never modify files."
    [code_desc]="Full agent"
    [code_tools]="*"
    [code_prompt]="You are a coding agent. Implement the requested changes efficiently."
    [plan_desc]="Planning agent"
    [plan_tools]="bash,read_file"
    [plan_prompt]="You are a planning agent. Analyze and output a plan. Do NOT make changes."
)

TODO="[]"

BASE_TOOLS='[
    {"name":"bash","input_schema":{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}},
    {"name":"read_file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"limit":{"type":"integer"}},"required":["path"]}},
    {"name":"write_file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"content":{"type":"string"}},"required":["path","content"]}},
    {"name":"edit_file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"old_text":{"type":"string"},"new_text":{"type":"string"}},"required":["path","old_text","new_text"]}},
    {"name":"TodoWrite","input_schema":{"type":"object","properties":{"items":{"type":"array","items":{"type":"object","properties":{"content":{"type":"string"},"status":{"type":"string"},"activeForm":{"type":"string"}},"required":["content","status","activeForm"]}}},"required":["items"]}}
]'

# =============================================================================
# SkillLoader - v4 的核心新增
# =============================================================================
#
# 技能是包含以下内容的文件夹:
# - SKILL.md (必需): YAML frontmatter + markdown 说明
# - scripts/ (可选): 模型可以运行的辅助脚本
# - references/ (可选): 额外文档
# - assets/ (可选): 模板、输出文件
#
# SKILL.md 格式:
# ---------------
#     ---
#     name: pdf
#     description: Process PDF files. Use when reading, creating, or merging PDFs.
#     ---
#
#     # PDF Processing Skill
#
#     ## Reading PDFs
#
#     Use pdftotext for quick extraction:
#     ```bash
#     pdftotext input.pdf -
#     ```
#     ...
#
# YAML frontmatter 提供元数据 (名称、描述)。
# Markdown 正文提供详细说明。

# 解析 SKILL.md 文件
# 返回: name|description|body|dir
parse_skill_md() {
    local path="$1"
    local content
    content=$(cat "$path")
    
    # 匹配 --- 标记之间的 YAML frontmatter
    if [[ "$content" =~ ^---[[:space:]]*$'
'(.*)$'
'---[[:space:]]*$'
'(.*)$ ]]; then
        local frontmatter="${BASH_REMATCH[1]}"
        local body="${BASH_REMATCH[2]}"
        local name="" description=""
        while IFS= read -r line; do
            [[ "$line" =~ ^name:[[:space:]]*(.+)$ ]] && name="${BASH_REMATCH[1]}"
            [[ "$line" =~ ^description:[[:space:]]*(.+)$ ]] && description="${BASH_REMATCH[1]}"
        done <<< "$frontmatter"
        [[ -n "$name" && -n "$description" ]] && echo "${name}|${description}|${body}|$(dirname "$path")"
    fi
}

# 加载所有技能
# 只在启动时加载元数据 - 正文按需加载
load_skills() {
    local skills="{}"
    [[ ! -d "$SKILLS_DIR" ]] && echo "$skills" && return
    
    for skill_dir in "$SKILLS_DIR"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_md="${skill_dir}/SKILL.md"
        [[ ! -f "$skill_md" ]] && continue
        
        local parsed
        parsed=$(parse_skill_md "$skill_md")
        [[ -z "$parsed" ]] && continue
        
        local name desc body dir
        name="${parsed%%|*}"
        local rest="${parsed#*|}"
        desc="${rest%%|*}"
        body="${rest#*|}"
        body="${body%|*}"
        dir="${parsed##*|}"
        
        skills=$(echo "$skills" | jq --arg n "$name" --arg d "$desc" --arg b "$body" --arg dir "$dir" '.[$n] = {name: $n, description: $d, body: $b, dir: $dir}')
    done
    echo "$skills"
}

# 生成技能描述 (用于系统提示)
# 这是第 1 层 - 只有名称和描述，~100 tokens/技能
get_skill_descriptions() {
    local skills="$1"
    local count
    count=$(echo "$skills" | jq 'length')
    [[ "$count" -eq 0 ]] && echo "(no skills)" && return
    echo "$skills" | jq -r 'to_entries[] | "- \(.value.name): \(.value.description)"'
}

# 获取完整技能内容 (用于注入)
# 这是第 2 层 - 完整的 SKILL.md 正文 + 资源提示
get_skill_content() {
    local skills="$1" name="$2"
    local skill
    skill=$(echo "$skills" | jq -r --arg n "$name" '.[$n]')
    [[ "$skill" == "null" ]] && echo "" && return
    
    local body dir
    body=$(echo "$skill" | jq -r '.body')
    dir=$(echo "$skill" | jq -r '.dir')
    
    local content="# Skill: ${name}

${body}"
    
    local resources=""
    for folder in scripts references assets; do
        local folder_path="${dir}/${folder}"
        if [[ -d "$folder_path" ]]; then
            local files
            files=$(ls "$folder_path" 2>/dev/null | tr '\n' ', ' | sed 's/, $//')
            [[ -n "$files" ]] && resources="${resources}${folder}: ${files}\n"
        fi
    done
    
    [[ -n "$resources" ]] && content="${content}

**Resources in ${dir}:**
${resources}"
    
    echo -e "$content"
}

# 初始化技能
SKILLS=$(load_skills)
SKILL_DESC=$(get_skill_descriptions "$SKILLS")

# =============================================================================
# 工具定义
# =============================================================================

TASK_TOOL=$(jq -n '{name: "Task", description: "Spawn a subagent. Types: explore, code, plan.", input_schema: {type: "object", properties: {description: {type: "string"}, prompt: {type: "string"}, agent_type: {type: "string", enum: ["explore", "code", "plan"]}}, required: ["description", "prompt", "agent_type"]}}')

# Skill 工具 - v4 新增
SKILL_TOOL=$(jq -n --arg desc "$SKILL_DESC" '{name: "Skill", description: "Load a skill for specialized knowledge.\n\nAvailable:\n\($desc)", input_schema: {type: "object", properties: {skill: {type: "string"}}, required: ["skill"]}}')

ALL_TOOLS=$(echo "$BASE_TOOLS" | jq --argjson task "$TASK_TOOL" --argjson skill "$SKILL_TOOL" '. + [$task, $skill]')

SYSTEM="You are a coding agent at ${WORKDIR}.

Skills available:
${SKILL_DESC}

Subagents: explore, code, plan

Rules:
- Use Skill tool when task matches a skill description
- Use Task tool for focused subtasks
- Use TodoWrite to track multi-step work
- Prefer tools over prose. Act, don't just explain."

GREEN='\033[32m'
RESET='\033[0m'

# =============================================================================
# 会话管理
# =============================================================================

generate_session_id() {
    date +%Y%m%d_%H%M%S
}

get_session_file() {
    echo "${MEMORY_DIR}/v4_session_${1}.json"
}

get_todo_file() {
    echo "${MEMORY_DIR}/v4_todo_${1}.json"
}

list_sessions() {
    echo -e "${GREEN}Saved sessions:${RESET}"
    if [[ ! -d "$MEMORY_DIR" ]] || [[ -z "$(ls -A "$MEMORY_DIR"/v4_session_*.json 2>/dev/null)" ]]; then
        echo "  (no sessions found)"
        return
    fi
    for f in "$MEMORY_DIR"/v4_session_*.json; do
        [[ -f "$f" ]] || continue
        local basename=$(basename "$f" .json)
        local session_id=${basename#v4_session_}
        local msg_count=$(jq 'length' "$f" 2>/dev/null || echo "0")
        local todo_count=$(jq 'length' "${MEMORY_DIR}/v4_todo_${session_id}.json" 2>/dev/null || echo "0")
        local last_modified=$(stat -c %y "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1 || stat -f %Sm "$f" 2>/dev/null)
        echo "  ${session_id} - ${msg_count} messages, ${todo_count} todos (last: ${last_modified})"
    done
}

load_session() {
    local session_file=$(get_session_file "$1")
    [[ ! -f "$session_file" ]] && return 1
    cat "$session_file"
}

load_todo() {
    local todo_file=$(get_todo_file "$1")
    [[ -f "$todo_file" ]] && cat "$todo_file" || echo "[]"
}

save_session() {
    local session_file=$(get_session_file "$1")
    echo "$2" > "$session_file"
}

save_todo() {
    local todo_file=$(get_todo_file "$1")
    echo "$2" > "$todo_file"
}

# =============================================================================
# 工具实现
# =============================================================================

safe_path() {
    local path="$1"
    local fullpath="${WORKDIR}/${path}"
    local resolved
    resolved=$(realpath "$fullpath" 2>/dev/null) || resolved="$fullpath"
    [[ ! "$resolved" =~ ^"${WORKDIR}" ]] && { echo "Error: Path escapes: $path"; return 1; }
    echo "$resolved"
}

render_todos() {
    local items="$1"
    local count
    count=$(echo "$items" | jq 'length')
    [[ "$count" -eq 0 ]] && echo "No todos." && return
    
    local completed=0
    local lines=""
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        local status content
        status=$(echo "$item" | jq -r '.status')
        content=$(echo "$item" | jq -r '.content')
        case "$status" in
            completed) lines="${lines}[x] ${content}\n"; ((completed++)) ;;
            in_progress) lines="${lines}[>] ${content}\n" ;;
            *) lines="${lines}[ ] ${content}\n" ;;
        esac
    done <<< "$(echo "$items" | jq -c '.[]')"
    echo -e "${lines}\n(${completed}/${count} done)"
}

update_todos() {
    local items="$1"
    local count
    count=$(echo "$items" | jq 'length')
    [[ "$count" -gt 20 ]] && { echo "Error: Max 20 todos"; return 1; }
    local in_progress
    in_progress=$(echo "$items" | jq '[.[] | select(.status == "in_progress")] | length')
    [[ "$in_progress" -gt 1 ]] && { echo "Error: Only one in_progress"; return 1; }
    TODO="$items"
    echo "$TODO"
}

run_bash() {
    local cmd="$1"
    [[ "$cmd" == *"rm -rf /"* || "$cmd" == *"sudo"* ]] && { echo "Error: Dangerous command"; return; }
    timeout 60 bash -c "$cmd" 2>&1 || echo "(exit: $?)"
}

run_read() {
    local path="$1" limit="${2:-0}"
    local fullpath
    fullpath=$(safe_path "$path") || return
    [[ ! -f "$fullpath" ]] && { echo "Error: Not found: $path"; return; }
    [[ "$limit" -gt 0 ]] && head -n "$limit" "$fullpath" || cat "$fullpath"
}

run_write() {
    local path="$1" content="$2"
    local fullpath
    fullpath=$(safe_path "$path") || return
    mkdir -p "$(dirname "$fullpath")"
    echo -n "$content" > "$fullpath"
    echo "Wrote ${#content} bytes to $path"
}

run_edit() {
    local path="$1" old="$2" new="$3"
    local fullpath
    fullpath=$(safe_path "$path") || return
    [[ ! -f "$fullpath" ]] && { echo "Error: Not found: $path"; return; }
    local content
    content=$(cat "$fullpath")
    [[ "$content" != *"$old"* ]] && { echo "Error: Text not found"; return; }
    echo -n "${content/$old/$new}" > "$fullpath"
    echo "Edited $path"
}

run_todo() {
    update_todos "${1:-$TODO}"
}

# =============================================================================
# 技能加载
# =============================================================================
#
# 关键机制:
# 1. 获取技能内容 (SKILL.md 正文 + 资源提示)
# 2. 包装在 <skill-loaded> 标签中返回
# 3. 模型接收此作为 tool_result (用户消息)
# 4. 模型现在"知道"如何完成任务
#
# 为什么使用 tool_result 而不是系统提示？
# - 系统提示更改使缓存失效 (20-50x 成本增加)
# - 工具结果附加到末尾 (前缀不变，缓存命中)

run_skill() {
    local name="$1"
    local content
    content=$(get_skill_content "$SKILLS" "$name")
    [[ -z "$content" ]] && {
        local available
        available=$(echo "$SKILLS" | jq -r 'keys[]' | tr '\n' ', ')
        echo "Error: Unknown skill '${name}'. Available: ${available}"
        return
    }
    echo "<skill-loaded name=\"${name}\">
${content}
</skill-loaded>

Follow the instructions above to complete the task."
}

get_tools_for_agent() {
    local agent_type="$1"
    local allowed="${AGENT_TYPES[${agent_type}_tools]}"
    [[ "$allowed" == "*" ]] && echo "$BASE_TOOLS" && return
    echo "$BASE_TOOLS"
}

# =============================================================================
# 子代理
# =============================================================================

run_task() {
    local desc="$1" prompt="$2" agent_type="$3"
    [[ -z "${AGENT_TYPES[${agent_type}_desc]}" ]] && { echo "Error: Unknown type"; return; }
    
    local config_prompt="${AGENT_TYPES[${agent_type}_prompt]}"
    local sub_system="You are a ${agent_type} subagent at ${WORKDIR}.

${config_prompt}

Complete and return a concise summary."
    
    local sub_tools
    sub_tools=$(get_tools_for_agent "$agent_type")
    local sub_messages
    sub_messages=$(jq -n --arg text "$prompt" '[{role: "user", content: [{type: "text", text: $text}]}]')
    
    echo "  [$agent_type] $desc"
    local start_time tool_count
    start_time=$(date +%s)
    tool_count=0
    
    while true; do
        local json_body response stop_reason content
        json_body=$(jq -n --arg model "$MODEL" --arg system "$sub_system" --argjson messages "$sub_messages" --argjson tools "$sub_tools" \
            '{model: $model, system: $system, messages: $messages, tools: $tools, max_tokens: 8000}')
        
        response=$(curl -s "${BASE_URL}/v1/messages" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${API_KEY}" \
            -H "anthropic-version: 2023-06-01" \
            -d "$json_body")
        
        if [[ $(echo "$response" | jq -r 'has("error")') == "true" ]]; then
            echo "API Error"
            return
        fi
        
        stop_reason=$(echo "$response" | jq -r '.stop_reason')
        content=$(echo "$response" | jq -c '.content')
        
        if [[ "$stop_reason" != "tool_use" ]]; then
            local elapsed
            elapsed=$(($(date +%s) - start_time))
            echo -e "\r  [$agent_type] $desc - done (${tool_count} tools, ${elapsed}s)"
            echo "$content" | jq -r '.[] | select(.type == "text") | .text'
            return
        fi
        
        local assistant_content results tool_calls
        assistant_content=$(echo "$content" | jq -c '[.[] | if .type == "text" then {type: "text", text: .text} else {type: "tool_use", id: .id, name: .name, input: .input} end]')
        results="[]"
        tool_calls=$(echo "$content" | jq -c '.[] | select(.type == "tool_use")')
        
        while IFS= read -r tc; do
            [[ -z "$tc" ]] && continue
            local tool_id tool_name tool_input output
            tool_id=$(echo "$tc" | jq -r '.id')
            tool_name=$(echo "$tc" | jq -r '.name')
            tool_input=$(echo "$tc" | jq -c '.input')
            
            output=""
            case "$tool_name" in
                bash) output=$(run_bash "$(echo "$tool_input" | jq -r '.command')") ;;
                read_file) output=$(run_read "$(echo "$tool_input" | jq -r '.path')" "$(echo "$tool_input" | jq -r '.limit // 0')") ;;
                write_file) output=$(run_write "$(echo "$tool_input" | jq -r '.path')" "$(echo "$tool_input" | jq -r '.content')") ;;
                edit_file) output=$(run_edit "$(echo "$tool_input" | jq -r '.path')" "$(echo "$tool_input" | jq -r '.old_text')" "$(echo "$tool_input" | jq -r '.new_text')") ;;
                TodoWrite) output=$(run_todo "$(echo "$tool_input" | jq -c '.items')") ;;
                *) output="Unknown: $tool_name" ;;
            esac
            
            ((tool_count++))
            local elapsed
            elapsed=$(($(date +%s) - start_time))
            printf "\r  [%s] %s ... %d tools, %ds" "$agent_type" "$desc" "$tool_count" "$elapsed"
            
            local result
            result=$(jq -n --arg id "$tool_id" --arg out "$output" '{type: "tool_result", tool_use_id: $id, content: $out}')
            results=$(echo "$results" | jq --argjson r "$result" '. + [$r]')
        done <<< "$tool_calls"
        
        local assistant_msg user_msg
        assistant_msg=$(jq -n --argjson content "$assistant_content" '{role: "assistant", content: $content}')
        user_msg=$(jq -n --argjson content "$results" '{role: "user", content: $content}')
        sub_messages=$(echo "$sub_messages [$assistant_msg, $user_msg]" | jq -s 'add')
    done
}

# =============================================================================
# 工具分发
# =============================================================================

execute_tool() {
    local name="$1" args="$2"
    case "$name" in
        bash) run_bash "$(echo "$args" | jq -r '.command')" ;;
        read_file) run_read "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.limit // 0')" ;;
        write_file) run_write "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.content')" ;;
        edit_file) run_edit "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.old_text')" "$(echo "$args" | jq -r '.new_text')" ;;
        TodoWrite) run_todo "$(echo "$args" | jq -c '.items')" ;;
        Task) run_task "$(echo "$args" | jq -r '.description')" "$(echo "$args" | jq -r '.prompt')" "$(echo "$args" | jq -r '.agent_type')" ;;
        Skill) run_skill "$(echo "$args" | jq -r '.skill')" ;;
        *) echo "Unknown: $name" ;;
    esac
}

call_api() {
    local messages="$1"
    local json_body
    json_body=$(jq -n --arg model "$MODEL" --arg system "$SYSTEM" --argjson messages "$messages" --argjson tools "$ALL_TOOLS" \
        '{model: $model, system: $system, messages: $messages, tools: $tools, max_tokens: 8000}')
    
    curl -s "${BASE_URL}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_body"
}

# =============================================================================
# 主代理循环
# =============================================================================

agent_loop() {
    local history="$1"
    local session_id="$2"
    
    while true; do
        local response stop_reason content assistant_content results tool_calls
        response=$(call_api "$history")
        
        if [[ $(echo "$response" | jq -r 'has("error")') == "true" ]]; then
            echo "API Error: $(echo "$response" | jq -r '.error.message')"
            return 1
        fi
        
        stop_reason=$(echo "$response" | jq -r '.stop_reason')
        content=$(echo "$response" | jq -c '.content')
        
        echo "$content" | jq -r '.[] | select(.type == "text") | .text'
        
        if [[ "$stop_reason" != "tool_use" ]]; then
            local new_history
            new_history=$(echo "$history" | jq --argjson content "$content" '. + [{role: "assistant", content: $content}]')
            [[ -n "$session_id" ]] && save_session "$session_id" "$new_history"
            echo "$new_history"
            return 0
        fi
        
        assistant_content=$(echo "$content" | jq -c '[.[] | if .type == "text" then {type: "text", text: .text} else {type: "tool_use", id: .id, name: .name, input: .input} end]')
        results="[]"
        tool_calls=$(echo "$content" | jq -c '.[] | select(.type == "tool_use")')
        
        while IFS= read -r tc; do
            [[ -z "$tc" ]] && continue
            local tool_id tool_name tool_input output
            tool_id=$(echo "$tc" | jq -r '.id')
            tool_name=$(echo "$tc" | jq -r '.name')
            tool_input=$(echo "$tc" | jq -c '.input')
            
            echo ""
            case "$tool_name" in
                Task) echo "> Task: $(echo "$tool_input" | jq -r '.description')" ;;
                Skill) echo "> Loading skill: $(echo "$tool_input" | jq -r '.skill')" ;;
                *) echo "> $tool_name" ;;
            esac
            
            output=$(execute_tool "$tool_name" "$tool_input")
            case "$tool_name" in
                Skill) echo "  Skill loaded (${#output} chars)" ;;
                Task) ;;
                *) echo "  $(echo "$output" | head -c 200)" ;;
            esac
            
            local result
            result=$(jq -n --arg id "$tool_id" --arg out "$output" '{type: "tool_result", tool_use_id: $id, content: $out}')
            results=$(echo "$results" | jq --argjson r "$result" '. + [$r]')
        done <<< "$tool_calls"
        
        local assistant_msg user_msg
        assistant_msg=$(jq -n --argjson content "$assistant_content" '{role: "assistant", content: $content}')
        user_msg=$(jq -n --argjson content "$results" '{role: "user", content: $content}')
        history=$(echo "$history [$assistant_msg, $user_msg]" | jq -s 'add')
        
        [[ -n "$session_id" ]] && save_session "$session_id" "$history"
        [[ -n "$session_id" ]] && save_todo "$session_id" "$TODO"
    done
}

# =============================================================================
# 主入口
# =============================================================================

main() {
    local session_id=""
    
    if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
        list_sessions
        exit 0
    fi
    
    if [[ "${1:-}" == "--resume" || "${1:-}" == "-r" ]]; then
        if [[ -z "${2:-}" ]]; then
            echo "Error: Session ID required"
            exit 1
        fi
        session_id="$2"
    fi
    
    local history="[]"
    
    if [[ -n "$session_id" ]]; then
        history=$(load_session "$session_id") || {
            echo "Session not found: $session_id, starting new"
            history="[]"
            session_id=$(generate_session_id)
        }
        TODO=$(load_todo "$session_id")
        echo -e "${GREEN}Session: ${session_id}${RESET}"
    else
        session_id=$(generate_session_id)
        echo -e "${GREEN}New session: ${session_id}${RESET}"
    fi
    
    local skill_list
    skill_list=$(echo "$SKILLS" | jq -r 'keys[]' | tr '\n' ', ' | sed 's/, $//')
    [[ -z "$skill_list" ]] && skill_list="none"
    echo "Skills: ${skill_list}"
    echo "Type 'exit' to quit, 'todos' to show todos, 'clear' to clear history."
    echo ""
    
    while true; do
        echo -n "You: "
        read -r user_input || break
        
        [[ -z "$user_input" ]] && continue
        [[ "$user_input" =~ ^(exit|quit|q)$ ]] && break
        
        if [[ "$user_input" == "todos" ]]; then
            render_todos "$TODO"
            continue
        fi
        
        if [[ "$user_input" == "clear" ]]; then
            history="[]"
            TODO="[]"
            save_session "$session_id" "$history"
            save_todo "$session_id" "$TODO"
            echo -e "${GREEN}History and todos cleared.${RESET}"
            continue
        fi
        
        local user_msg
        user_msg=$(jq -n --arg text "$user_input" '{role: "user", content: [{type: "text", text: $text}]}')
        history=$(echo "$history [$user_msg]" | jq -s 'add')
        
        history=$(agent_loop "$history" "$session_id") || {
            echo "Error in agent loop"
            history="[]"
            continue
        }
        echo ""
    done
    
    save_session "$session_id" "$history"
    save_todo "$session_id" "$TODO"
    echo -e "${GREEN}Session saved: ${session_id}${RESET}"
}

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required."
    exit 1
fi

main "$@"
