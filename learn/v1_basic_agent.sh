#!/usr/bin/env bash
#
# v1_basic_agent.sh - Mini Agent: 4 Essential Tools (~250 lines)
#
# 核心哲学: "The Model IS the Agent" (模型就是代理)
# ==========================================
# Claude Code、Cursor Agent、Codex CLI 的秘密？其实没有秘密。
#
# 剥离 CLI 的润色、进度条、权限系统后，剩下的惊人地简单：
# 一个让模型循环调用工具直到完成的 LOOP。
#
# 传统助手:
#     用户 -> 模型 -> 文本响应
#
# 代理系统:
#     用户 -> 模型 -> [工具 -> 结果]* -> 响应
#                       ^________|
#
# 星号(*)很重要！模型会**重复**调用工具直到任务完成。
# 这将聊天机器人转变为自主代理。
#
# 关键洞察: 模型是决策者。代码只提供工具和运行循环。
# 模型决定:
#   - 调用哪些工具
#   - 调用顺序
#   - 何时停止
#
# 四个基本工具:
# ---------------
# Claude Code 有约 20 个工具。但这 4 个覆盖了 90% 的用例:
#
#     | 工具        | 目的              | 示例                     |
#     |------------|-------------------|--------------------------|
#     | bash       | 运行任何命令       | npm install, git status |
#     | read_file  | 读取文件内容       | 查看 src/index.ts       |
#     | write_file | 创建/覆盖文件      | 创建 README.md          |
#     | edit_file  | 精确修改           | 替换函数                |
#
# 只用这 4 个工具，模型可以:
#   - 探索代码库 (bash: find, grep, ls)
#   - 理解代码 (read_file)
#   - 做出改变 (write_file, edit_file)
#   - 运行任何东西 (bash: python, npm, make)
#
# 使用方法:
#     # 交互模式
#     ./v1_basic_agent.sh
#
#     # 列出会话
#     ./v1_basic_agent.sh --list
#
#     # 恢复会话
#     ./v1_basic_agent.sh --resume <session_id>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

# =============================================================================
# 配置
# =============================================================================
API_KEY="${DEEPSEEK_API_KEY}"
BASE_URL="${DEEPSEEK_BASE_URL:-https://api.deepseek.com/anthropic}"
MODEL="${MODEL_ID:-deepseek-chat}"
WORKDIR="${WORKDIR:-$(pwd)}"
MEMORY_DIR="${MEMORY_DIR:-$WORKDIR/.ai-memory}"

mkdir -p "$MEMORY_DIR"

# =============================================================================
# 工具定义 - 4 个工具覆盖 90% 的编码任务
# =============================================================================

TOOLS='[
    {
        "name": "bash",
        "description": "Run shell command. Use for: ls, find, grep, git, npm, python, etc.",
        "input_schema": {
            "type": "object",
            "properties": {"command": {"type": "string"}},
            "required": ["command"]
        }
    },
    {
        "name": "read_file",
        "description": "Read file contents. Returns UTF-8 text.",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "limit": {"type": "integer"}
            },
            "required": ["path"]
        }
    },
    {
        "name": "write_file",
        "description": "Write content to a file. Creates parent directories if needed.",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "content": {"type": "string"}
            },
            "required": ["path", "content"]
        }
    },
    {
        "name": "edit_file",
        "description": "Replace exact text in a file. Use for surgical edits.",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "old_text": {"type": "string"},
                "new_text": {"type": "string"}
            },
            "required": ["path", "old_text", "new_text"]
        }
    }
]'

# =============================================================================
# 系统提示 - 模型唯一需要的"配置"
# =============================================================================

SYSTEM="You are a coding agent at ${WORKDIR}.

Loop: think briefly -> use tools -> report results.

Rules:
- Prefer tools over prose. Act, don't just explain.
- Never invent file paths. Use bash ls/find first if unsure.
- Make minimal changes. Don't over-engineer.
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
    local session_id="$1"
    echo "${MEMORY_DIR}/v1_session_${session_id}.json"
}

list_sessions() {
    echo -e "${GREEN}Saved sessions:${RESET}"
    if [[ ! -d "$MEMORY_DIR" ]] || [[ -z "$(ls -A "$MEMORY_DIR"/v1_session_*.json 2>/dev/null)" ]]; then
        echo "  (no sessions found)"
        return
    fi
    for f in "$MEMORY_DIR"/v1_session_*.json; do
        [[ -f "$f" ]] || continue
        local basename=$(basename "$f" .json)
        local session_id=${basename#v1_session_}
        local msg_count=$(jq 'length' "$f" 2>/dev/null || echo "0")
        local last_modified=$(stat -c %y "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1 || stat -f %Sm "$f" 2>/dev/null)
        echo "  ${session_id} - ${msg_count} messages (last: ${last_modified})"
    done
}

load_session() {
    local session_id="$1"
    local session_file=$(get_session_file "$session_id")
    [[ ! -f "$session_file" ]] && return 1
    cat "$session_file"
}

save_session() {
    local session_id="$1"
    local history="$2"
    local session_file=$(get_session_file "$session_id")
    echo "$history" > "$session_file"
}

# =============================================================================
# 工具实现
# =============================================================================

# 确保路径在工作区内 (安全措施)
# 防止模型通过 '../' 访问项目目录外的文件
safe_path() {
    local path="$1"
    local fullpath="${WORKDIR}/${path}"
    local resolved
    resolved=$(realpath "$fullpath" 2>/dev/null) || resolved="$fullpath"
    if [[ ! "$resolved" =~ ^"${WORKDIR}" ]]; then
        echo "Error: Path escapes workspace: $path" >&2
        return 1
    fi
    echo "$resolved"
}

# 执行 shell 命令 (带安全检查)
run_bash() {
    local cmd="$1"
    local dangerous=("rm -rf /" "sudo" "shutdown" "reboot")
    for d in "${dangerous[@]}"; do
        if [[ "$cmd" == *"$d"* ]]; then
            echo "Error: Dangerous command blocked: $d"
            return
        fi
    done
    timeout 60 bash -c "$cmd" 2>&1 || echo "(exit code: $?)"
}

# 读取文件 (支持行数限制)
run_read() {
    local path="$1" limit="${2:-0}"
    local fullpath
    fullpath=$(safe_path "$path") || return
    [[ ! -f "$fullpath" ]] && { echo "Error: File not found: $path"; return; }
    if [[ "$limit" -gt 0 ]]; then
        head -n "$limit" "$fullpath"
        local total
        total=$(wc -l < "$fullpath")
        [[ "$total" -gt "$limit" ]] && echo "... ($((total - limit)) more lines)"
    else
        cat "$fullpath"
    fi
}

# 写入文件 (自动创建父目录)
run_write() {
    local path="$1" content="$2"
    local fullpath
    fullpath=$(safe_path "$path") || return
    mkdir -p "$(dirname "$fullpath")"
    echo -n "$content" > "$fullpath"
    echo "Wrote ${#content} bytes to $path"
}

# 精确替换文本 (只替换第一个匹配项)
run_edit() {
    local path="$1" old_text="$2" new_text="$3"
    local fullpath
    fullpath=$(safe_path "$path") || return
    [[ ! -f "$fullpath" ]] && { echo "Error: File not found: $path"; return; }
    local content
    content=$(cat "$fullpath")
    [[ "$content" != *"$old_text"* ]] && { echo "Error: Text not found in $path"; return; }
    local new_content="${content/$old_text/$new_text}"
    echo -n "$new_content" > "$fullpath"
    echo "Edited $path"
}

# 工具分发器
execute_tool() {
    local name="$1"
    local args="$2"
    
    case "$name" in
        bash)
            local cmd
            cmd=$(echo "$args" | jq -r '.command')
            run_bash "$cmd"
            ;;
        read_file)
            local path limit
            path=$(echo "$args" | jq -r '.path')
            limit=$(echo "$args" | jq -r '.limit // 0')
            run_read "$path" "$limit"
            ;;
        write_file)
            local path content
            path=$(echo "$args" | jq -r '.path')
            content=$(echo "$args" | jq -r '.content')
            run_write "$path" "$content"
            ;;
        edit_file)
            local path old_text new_text
            path=$(echo "$args" | jq -r '.path')
            old_text=$(echo "$args" | jq -r '.old_text')
            new_text=$(echo "$args" | jq -r '.new_text')
            run_edit "$path" "$old_text" "$new_text"
            ;;
        *)
            echo "Unknown tool: $name"
            ;;
    esac
}

# =============================================================================
# API 调用
# =============================================================================

call_api() {
    local messages="$1"
    
    local json_body
    json_body=$(jq -n \
        --arg model "$MODEL" \
        --arg system "$SYSTEM" \
        --argjson messages "$messages" \
        --argjson tools "$TOOLS" \
        '{
            model: $model,
            system: $system,
            messages: $messages,
            tools: $tools,
            max_tokens: 8000
        }')
    
    curl -s "${BASE_URL}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_body"
}

# =============================================================================
# 代理循环 - 这是所有编码代理的核心模式
# =============================================================================
#
# 这是所有编码代理共享的模式:
#     while True:
#         response = model(messages, tools)
#         if no tool calls: return
#         execute tools, append results, continue
#
# 模型控制循环:
#   - 持续调用工具直到 stop_reason != "tool_use"
#   - 工具结果作为反馈用于下一步决策
#   - 对话历史自动保持跨轮次上下文
#
# 为什么这样有效:
#   1. 模型决定调用哪些工具、调用顺序、何时停止
#   2. 工具结果为下一次决策提供反馈
#   3. 对话历史跨轮次保持上下文

agent_loop() {
    local history="$1"
    local session_id="$2"
    
    while true; do
        local response content stop_reason
        response=$(call_api "$history")
        
        if [[ $(echo "$response" | jq -r 'has("error")') == "true" ]]; then
            echo "API Error: $(echo "$response" | jq -r '.error.message')"
            return 1
        fi
        
        stop_reason=$(echo "$response" | jq -r '.stop_reason')
        content=$(echo "$response" | jq -c '.content')
        
        # 打印文本内容
        echo "$content" | jq -r '.[] | select(.type == "text") | .text'
        
        # 检查是否完成
        if [[ "$stop_reason" != "tool_use" ]]; then
            local new_history
            new_history=$(echo "$history" | jq --argjson content "$content" '. + [{role: "assistant", content: $content}]')
            # 保存会话
            [[ -n "$session_id" ]] && save_session "$session_id" "$new_history"
            echo "$new_history"
            return 0
        fi
        
        # 构建助手消息
        local assistant_content
        assistant_content=$(echo "$content" | jq -c '[.[] | if .type == "text" then {type: "text", text: .text} else {type: "tool_use", id: .id, name: .name, input: .input} end]')
        
        # 执行工具
        local results="[]"
        local tool_calls
        tool_calls=$(echo "$content" | jq -c '.[] | select(.type == "tool_use")')
        
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
            preview=$(echo "$output" | head -c 200)
            [[ ${#output} -gt 200 ]] && preview="${preview}..."
            echo "  $preview"
            
            local result
            result=$(jq -n --arg id "$tool_id" --arg out "$output" '{type: "tool_result", tool_use_id: $id, content: $out}')
            results=$(echo "$results" | jq --argjson r "$result" '. + [$r]')
        done <<< "$tool_calls"
        
        # 更新历史
        local assistant_msg user_msg
        assistant_msg=$(jq -n --argjson content "$assistant_content" '{role: "assistant", content: $content}')
        user_msg=$(jq -n --argjson content "$results" '{role: "user", content: $content}')
        history=$(echo "$history [$assistant_msg, $user_msg]" | jq -s 'add')
        
        # 每轮后保存
        [[ -n "$session_id" ]] && save_session "$session_id" "$history"
    done
}

# =============================================================================
# 主函数 - 简单的 REPL
# =============================================================================

main() {
    local session_id=""
    
    # 处理参数
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
            echo "Session not found: $session_id, starting new session"
            history="[]"
            session_id=$(generate_session_id)
        }
        echo -e "${GREEN}Session: ${session_id}${RESET}"
    else
        session_id=$(generate_session_id)
        echo -e "${GREEN}New session: ${session_id}${RESET}"
    fi
    
    echo "Type 'exit' to quit, 'clear' to clear history."
    echo ""
    
    while true; do
        echo -n "You: "
        read -r user_input || break
        
        [[ -z "$user_input" ]] && continue
        [[ "$user_input" =~ ^(exit|quit|q)$ ]] && break
        
        if [[ "$user_input" == "clear" ]]; then
            history="[]"
            save_session "$session_id" "$history"
            echo -e "${GREEN}History cleared.${RESET}"
            continue
        fi
        
        # 添加用户消息
        local user_msg
        user_msg=$(jq -n --arg text "$user_input" '{role: "user", content: [{type: "text", text: $text}]}')
        history=$(echo "$history [$user_msg]" | jq -s 'add')
        
        # 运行代理循环
        history=$(agent_loop "$history" "$session_id") || {
            echo "Error in agent loop"
            history="[]"
            continue
        }
        
        echo ""
    done
    
    echo -e "${GREEN}Session saved: ${session_id}${RESET}"
}

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required."
    exit 1
fi

main "$@"
