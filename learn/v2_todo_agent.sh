#!/usr/bin/env bash
#
# v2_todo_agent.sh - Mini Agent: Structured Planning with Todos (~350 lines)
#
# 核心哲学: "Make Plans Visible" (让计划可见)
# ==========================================
# v1 对简单任务工作得很好。但让它"重构 auth，添加测试，更新文档"，
# 看看会发生什么。没有明确的计划，模型会:
#   - 在任务间随机跳转
#   - 忘记已完成步骤
#   - 中途失去焦点
#
# 问题 - "上下文衰减":
# -------------------
# 在 v1 中，计划只存在于模型的"脑海"中:
#
#     v1: "我要做 A，然后 B，然后 C"  (不可见)
#         10 次工具调用后: "等等，我在做什么？"
#
# 解决方案 - TodoWrite 工具:
# -------------------------
# v2 添加了一个改变代理工作方式的新工具:
#
#     v2:
#       [ ] 重构 auth 模块
#       [>] 添加单元测试         <- 当前正在进行
#       [ ] 更新文档
#
# 现在你和模型都能看到计划。模型可以:
#   - 更新状态
#   - 查看已完成和待完成
#   - 一次专注于一个任务
#
# 关键约束 (非任意 - 这些是护栏):
# --------------------------------
#     | 规则              | 原因                      |
#     |-------------------|--------------------------|
#     | 最多 20 项        | 防止无限任务列表          |
#     | 一个 in_progress  | 强制专注一件事            |
#     | 必填字段          | 确保结构化输出            |
#
# 深层洞察:
# ---------
# > "结构既约束又赋能。"
#
# 待办约束 (最多 20 项，一个进行中) 启用 (可见计划，跟踪进度)。
#
# 这个模式在代理设计中无处不在:
#   - max_tokens 约束 -> 启用可管理的响应
#   - 工具模式约束 -> 启用结构化调用
#   - 待办约束 -> 启用复杂任务完成
#
# 好的约束不是限制。它们是脚手架。
#
# 使用方法:
#     ./v2_todo_agent.sh

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
# TodoManager - v2 的核心新增
# =============================================================================
#
# 关键设计决策:
# ---------------
# 1. 最多 20 项: 防止模型创建无尽列表
# 2. 一个 in_progress: 强制专注 - 一次只能做一件事
# 3. 必填字段: 每项需要 content, status, activeForm
#
# activeForm 字段说明:
# - 是正在发生的事情的现在时形式
# - 当状态为 "in_progress" 时显示
# - 示例: content="Add tests", activeForm="Adding unit tests..."
#
# 这提供了代理正在做什么的实时可见性。

TODO="[]"
INITIAL_REMINDER="<reminder>Use TodoWrite for multi-step tasks.</reminder>"
NAG_REMINDER="<reminder>10+ turns without todo update. Please update todos.</reminder>"

# =============================================================================
# 工具定义 (v1 工具 + TodoWrite)
# =============================================================================

TOOLS='[
    {"name":"bash","description":"Run shell command","input_schema":{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}},
    {"name":"read_file","description":"Read file contents","input_schema":{"type":"object","properties":{"path":{"type":"string"},"limit":{"type":"integer"}},"required":["path"]}},
    {"name":"write_file","description":"Write to file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"content":{"type":"string"}},"required":["path","content"]}},
    {"name":"edit_file","description":"Replace text in file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"old_text":{"type":"string"},"new_text":{"type":"string"}},"required":["path","old_text","new_text"]}},
    {"name":"TodoWrite","description":"Update task list. Use to plan and track progress.","input_schema":{"type":"object","properties":{"items":{"type":"array","description":"Complete list of tasks (replaces existing)","items":{"type":"object","properties":{"content":{"type":"string","description":"Task description"},"status":{"type":"string","enum":["pending","in_progress","completed"]},"activeForm":{"type":"string","description":"Present tense action, e.g. 'Reading files'"}},"required":["content","status","activeForm"]}}},"required":["items"]}}
]'

SYSTEM="You are a coding agent at ${WORKDIR}.

Loop: plan -> act with tools -> update todos -> report.

Rules:
- Use TodoWrite to track multi-step tasks
- Mark tasks in_progress before starting, completed when done
- Prefer tools over prose. Act, don't just explain.
- After finishing, summarize what changed."

GREEN='\033[32m'
RESET='\033[0m'

# =============================================================================
# 会话管理
# =============================================================================

generate_session_id() {
    date +%Y%m%d_%H%M%S
}

get_session_file() {
    echo "${MEMORY_DIR}/v2_session_${1}.json"
}

get_todo_file() {
    echo "${MEMORY_DIR}/v2_todo_${1}.json"
}

list_sessions() {
    echo -e "${GREEN}Saved sessions:${RESET}"
    if [[ ! -d "$MEMORY_DIR" ]] || [[ -z "$(ls -A "$MEMORY_DIR"/v2_session_*.json 2>/dev/null)" ]]; then
        echo "  (no sessions found)"
        return
    fi
    for f in "$MEMORY_DIR"/v2_session_*.json; do
        [[ -f "$f" ]] || continue
        local basename=$(basename "$f" .json)
        local session_id=${basename#v2_session_}
        local msg_count=$(jq 'length' "$f" 2>/dev/null || echo "0")
        local todo_count=$(jq 'length' "${MEMORY_DIR}/v2_todo_${session_id}.json" 2>/dev/null || echo "0")
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
# 路径安全
# =============================================================================

safe_path() {
    local path="$1"
    local fullpath="${WORKDIR}/${path}"
    local resolved
    resolved=$(realpath "$fullpath" 2>/dev/null) || resolved="$fullpath"
    [[ ! "$resolved" =~ ^"${WORKDIR}" ]] && { echo "Error: Path escapes: $path"; return 1; }
    echo "$resolved"
}

# =============================================================================
# Todo 管理
# =============================================================================

# 渲染待办列表为可读文本
# 格式:
#     [x] 已完成任务
#     [>] 进行中任务 <- 正在做某事...
#     [ ] 待处理任务
#
#     (2/3 已完成)
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
    echo -e "${lines}\n(${completed}/${count} completed)"
}

# 验证并更新待办列表
#
# 验证规则:
# - 每项必须有: content, status, activeForm
# - 状态必须是: pending | in_progress | completed
# - 最多 20 项
# - 只有一个 in_progress
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

# =============================================================================
# 工具实现 (v1 + TodoWrite)
# =============================================================================

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
    local items="${1:-$TODO}"
    update_todos "$items"
}

execute_tool() {
    local name="$1" args="$2"
    case "$name" in
        bash) run_bash "$(echo "$args" | jq -r '.command')" ;;
        read_file) run_read "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.limit // 0')" ;;
        write_file) run_write "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.content')" ;;
        edit_file) run_edit "$(echo "$args" | jq -r '.path')" "$(echo "$args" | jq -r '.old_text')" "$(echo "$args" | jq -r '.new_text')" ;;
        TodoWrite) run_todo "$(echo "$args" | jq -c '.items')" ;;
        *) echo "Unknown: $name" ;;
    esac
}

# =============================================================================
# API 调用
# =============================================================================

call_api() {
    local messages="$1"
    local json_body
    json_body=$(jq -n --arg model "$MODEL" --arg system "$SYSTEM" --argjson messages "$messages" --argjson tools "$TOOLS" \
        '{model: $model, system: $system, messages: $messages, tools: $tools, max_tokens: 8000}')
    
    curl -s "${BASE_URL}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_body"
}

# =============================================================================
# 代理循环 (带待办跟踪)
# =============================================================================
#
# 与 v1 相同的核心循环，但现在跟踪模型是否使用待办。
# 如果太长时间未更新，向用户消息注入提醒。

ROUNDS_WITHOUT_TODO=0

agent_loop() {
    local history="$1"
    local session_id="$2"
    
    while true; do
        local response stop_reason content
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
        
        local assistant_content
        assistant_content=$(echo "$content" | jq -c '[.[] | if .type == "text" then {type: "text", text: .text} else {type: "tool_use", id: .id, name: .name, input: .input} end]')
        
        local results="[]"
        local tool_calls
        tool_calls=$(echo "$content" | jq -c '.[] | select(.type == "tool_use")')
        local used_todo=false
        
        while IFS= read -r tc; do
            [[ -z "$tc" ]] && continue
            local tool_id tool_name tool_input output
            tool_id=$(echo "$tc" | jq -r '.id')
            tool_name=$(echo "$tc" | jq -r '.name')
            tool_input=$(echo "$tc" | jq -c '.input')
            
            echo ""
            echo "> $tool_name"
            
            output=$(execute_tool "$tool_name" "$tool_input")
            local preview
            preview=$(echo "$output" | head -c 300)
            [[ ${#output} -gt 300 ]] && preview="${preview}..."
            echo "  $preview"
            
            [[ "$tool_name" == "TodoWrite" ]] && used_todo=true
            
            local result
            result=$(jq -n --arg id "$tool_id" --arg out "$output" '{type: "tool_result", tool_use_id: $id, content: $out}')
            results=$(echo "$results" | jq --argjson r "$result" '. + [$r]')
        done <<< "$tool_calls"
        
        # 跟踪待办使用
        if $used_todo; then
            ROUNDS_WITHOUT_TODO=0
        else
            ((ROUNDS_WITHOUT_TODO++))
        fi
        
        # 如果 10+ 轮未使用待办，注入提醒
        if [[ $ROUNDS_WITHOUT_TODO -gt 10 ]]; then
            local nag
            nag=$(jq -n --arg t "$NAG_REMINDER" '{type: "text", text: $t}')
            results=$(echo "[$nag]" | jq --argjson r "$results" '. + $r')
        fi
        
        local assistant_msg user_msg
        assistant_msg=$(jq -n --argjson content "$assistant_content" '{role: "assistant", content: $content}')
        user_msg=$(jq -n --argjson content "$results" '{role: "user", content: $content}')
        history=$(echo "$history [$assistant_msg, $user_msg]" | jq -s 'add')
        
        [[ -n "$session_id" ]] && save_session "$session_id" "$history"
        [[ -n "$session_id" ]] && save_todo "$session_id" "$TODO"
    done
}

# =============================================================================
# 主函数 - 带提醒注入的 REPL
# =============================================================================
#
# 关键的 v2 新增：注入"提醒"消息以鼓励使用待办
#
# - INITIAL_REMINDER: 对话开始时注入
# - NAG_REMINDER: 10+ 轮未使用待办时注入

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
    local first_message=true
    
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
        
        # 构建用户消息内容
        local content="[]"
        if $first_message; then
            local reminder
            reminder=$(jq -n --arg t "$INITIAL_REMINDER" '{type: "text", text: $t}')
            content=$(echo "$content" | jq --argjson r "$reminder" '. + [$r]')
            first_message=false
        fi
        local user_text
        user_text=$(jq -n --arg t "$user_input" '{type: "text", text: $t}')
        content=$(echo "$content" | jq --argjson r "$user_text" '. + [$r]')
        
        local user_msg
        user_msg=$(jq -n --argjson c "$content" '{role: "user", content: $c}')
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
