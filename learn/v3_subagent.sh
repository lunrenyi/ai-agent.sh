#!/usr/bin/env bash
#
# v3_subagent.sh - Mini Agent: Subagent Mechanism (~450 lines)
#
# 核心哲学: "Divide and Conquer with Context Isolation" (分而治之，上下文隔离)
# ==============================================================================
# v2 添加了规划。但对于"探索代码库然后重构 auth"这样的大任务，单个代理会遇到问题:
#
# 问题 - 上下文污染:
# ------------------
#     单代理历史:
#       [探索中...] cat file1.py -> 500 行
#       [探索中...] cat file2.py -> 300 行
#       ... 15 个更多文件 ...
#       [现在重构中...] "等等，file1 包含什么？"
#
# 模型的上下文被探索细节填满，几乎没有空间留给实际任务。
# 这就是"上下文污染"。
#
# 解决方案 - 带隔离上下文的子代理:
# ---------------------------------
#     主代理历史:
#       [任务: 探索代码库]
#         -> 子代理探索 20 个文件 (在它自己的上下文中)
#         -> 只返回: "Auth 在 src/auth/, DB 在 src/models/"
#       [现在用干净上下文重构]
#
# 每个子代理有:
#   1. 自己的全新消息历史
#   2. 过滤后的工具 (探索不能写入)
#   3. 专门的系统提示
#   4. 只向父代理返回最终摘要
#
# 关键洞察:
# ---------
#     进程隔离 = 上下文隔离
#
# 通过生成子任务，我们获得:
#   - 主代理的干净上下文
#   - 可能的并行探索
#   - 自然任务分解
#   - 相同的代理循环，不同的上下文
#
# 代理类型注册表:
# ----------------
#     | 类型    | 工具               | 目的                     |
#     |---------|--------------------|-------------------------|
#     | explore | bash, read_file    | 只读探索                 |
#     | code    | 所有工具            | 完整实现访问             |
#     | plan    | bash, read_file    | 不做修改的设计           |
#
# 典型流程:
# ----------
#     用户: "将 auth 重构为使用 JWT"
#
#     主代理:
#       1. Task(explore): "找到所有 auth 相关文件"
#          -> 子代理读取 10 个文件
#          -> 返回: "Auth 在 src/auth/login.py..."
#
#       2. Task(plan): "设计 JWT 迁移"
#          -> 子代理分析结构
#          -> 返回: "1. 添加 jwt lib 2. 创建 utils..."
#
#       3. Task(code): "实现 JWT 令牌"
#          -> 子代理编写代码
#          -> 返回: "创建了 jwt_utils.py, 更新了 login.py"
#
#       4. 向用户总结更改

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

API_KEY="${DEEPSEEK_API_KEY}"
BASE_URL="${DEEPSEEK_BASE_URL:-https://api.deepseek.com/anthropic}"
MODEL="${MODEL_ID:-deepseek-chat}"
WORKDIR="${WORKDIR:-$(pwd)}"
MEMORY_DIR="${MEMORY_DIR:-$WORKDIR/.ai-memory}"

mkdir -p "$MEMORY_DIR"

# =============================================================================
# 代理类型注册表 - 子代理机制的核心
# =============================================================================
#
# 每个代理类型有一个工具白名单。
# '*' 表示所有工具 (但子代理不获得 Task 以防止无限递归)。

declare -A AGENT_TYPES=(
    [explore_desc]="Read-only agent for exploring code"
    [explore_tools]="bash,read_file"
    [explore_prompt]="You are an exploration agent. Search and analyze, but never modify files. Return a concise summary."
    [code_desc]="Full agent for implementing features"
    [code_tools]="*"
    [code_prompt]="You are a coding agent. Implement the requested changes efficiently."
    [plan_desc]="Planning agent for designing strategies"
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
# Task 工具 - v3 的核心新增
# =============================================================================
#
# 子代理在隔离上下文中运行。
# 用于保持主对话干净。

TASK_TOOL=$(jq -n '{
    name: "Task",
    description: "Spawn a subagent. Types: explore (read-only), code (full), plan (design).",
    input_schema: {
        type: "object",
        properties: {
            description: {type: "string"},
            prompt: {type: "string"},
            agent_type: {type: "string", enum: ["explore", "code", "plan"]}
        },
        required: ["description", "prompt", "agent_type"]
    }
}')

ALL_TOOLS=$(echo "$BASE_TOOLS" | jq --argjson task "$TASK_TOOL" '. + [$task]')

SYSTEM="You are a coding agent at ${WORKDIR}.

You can spawn subagents: explore (read-only), code (full), plan (design).

Rules:
- Use Task tool for subtasks needing focused work
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
    echo "${MEMORY_DIR}/v3_session_${1}.json"
}

get_todo_file() {
    echo "${MEMORY_DIR}/v3_todo_${1}.json"
}

list_sessions() {
    echo -e "${GREEN}Saved sessions:${RESET}"
    if [[ ! -d "$MEMORY_DIR" ]] || [[ -z "$(ls -A "$MEMORY_DIR"/v3_session_*.json 2>/dev/null)" ]]; then
        echo "  (no sessions found)"
        return
    fi
    for f in "$MEMORY_DIR"/v3_session_*.json; do
        [[ -f "$f" ]] || continue
        local basename=$(basename "$f" .json)
        local session_id=${basename#v3_session_}
        local msg_count=$(jq 'length' "$f" 2>/dev/null || echo "0")
        local todo_count=$(jq 'length' "${MEMORY_DIR}/v3_todo_${session_id}.json" 2>/dev/null || echo "0")
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
    
    local completed=0 lines=""
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

# 根据代理类型获取允许的工具
get_tools_for_agent() {
    local agent_type="$1"
    local allowed="${AGENT_TYPES[${agent_type}_tools]}"
    [[ "$allowed" == "*" ]] && echo "$BASE_TOOLS" && return
    echo "$BASE_TOOLS"
}

# =============================================================================
# 子代理执行 - v3 的核心
# =============================================================================
#
# 这是子代理机制的核心:
#
# 1. 创建隔离的消息历史 (关键: 没有父上下文!)
# 2. 使用代理特定的系统提示
# 3. 根据代理类型过滤可用工具
# 4. 运行与主代理相同的查询循环
# 5. 只返回最终文本 (不是中间细节)
#
# 父代理只看到摘要，保持其上下文干净。
#
# 进度显示:
# ----------
# 运行时，我们显示:
#   [explore] find auth files ... 5 tools, 3.2s
#
# 这提供了可见性而不污染主对话。

run_task() {
    local desc="$1" prompt="$2" agent_type="$3"
    [[ -z "${AGENT_TYPES[${agent_type}_desc]}" ]] && { echo "Error: Unknown type: $agent_type"; return; }
    
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

execute_tool() {
    local name="$1" args="$2"
    case "$name" in
        bash) run_bash "$(echo "$args" | jq -r '.command')" ;;
        read_file) run_read "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.limit // 0')" ;;
        write_file) run_write "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.content')" ;;
        edit_file) run_edit "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.old_text')" "$(echo "$args" | jq -r '.new_text')" ;;
        TodoWrite) run_todo "$(echo "$args" | jq -c '.items')" ;;
        Task) run_task "$(echo "$args" | jq -r '.description')" "$(echo "$args" | jq -r '.prompt')" "$(echo "$args" | jq -r '.agent_type')" ;;
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
# 主代理循环 (带子代理支持)
# =============================================================================
#
# 与 v1/v2 相同的模式，但现在包含 Task 工具。
# 当模型调用 Task 时，生成隔离上下文的子代理。

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
            [[ "$tool_name" == "Task" ]] && echo "> Task: $(echo "$tool_input" | jq -r '.description')" || echo "> $tool_name"
            
            output=$(execute_tool "$tool_name" "$tool_input")
            [[ "$tool_name" != "Task" ]] && echo "  $(echo "$output" | head -c 200)"
            
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
