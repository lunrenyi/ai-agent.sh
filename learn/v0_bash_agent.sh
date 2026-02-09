#!/usr/bin/env bash
#
# v0_bash_agent.sh - Mini Agent: Bash is All You Need (~150 lines)
#
# 核心哲学: "Bash is All You Need"
# ================================
# 这是编码代理的终极简化。在构建 v1-v3 之后，我们问：代理的本质是什么？
#
# 答案：一个工具(bash) + 一个循环 = 完整的代理能力
#
# 为什么 Bash 足够:
# ----------------
# Unix 哲学说一切皆文件，一切都可以管道化。Bash 是通往这个世界的门户:
#
#     | 你需要      | Bash 命令                              |
#     |-------------|----------------------------------------|
#     | 读取文件    | cat, head, tail, grep                  |
#     | 写入文件    | echo '...' > file, sed -i              |
#     | 搜索        | find, grep, rg, ls                     |
#     | 执行        | python, npm, make, 任何命令            |
#     | **子代理**  | ./v0_bash_agent.sh "task"              |
#
# 最后一行是关键洞察：通过 bash 调用自身实现了子代理！
# 不需要 Task 工具，不需要代理注册表 - 只需通过进程派生实现递归。
#
# 子代理如何工作:
# --------------
#     主代理
#       |-- bash: ./v0_bash_agent.sh "分析架构"
#            |-- 子代理 (隔离进程，全新历史)
#                 |-- bash: find . -name "*.py"
#                 |-- bash: cat src/main.py
#                 |-- 通过 stdout 返回摘要
#
# 进程隔离 = 上下文隔离:
# - 子进程有自己的 history=[]
# - 父进程捕获 stdout 作为工具结果
# - 递归调用支持无限嵌套
#
# 使用方法:
#     # 交互模式 (新会话)
#     ./v0_bash_agent.sh
#
#     # 子代理模式 (由父代理调用或直接调用)
#     ./v0_bash_agent.sh "探索 src/ 并总结"
#
#     # 列出所有保存的会话
#     ./v0_bash_agent.sh --list
#
#     # 恢复会话
#     ./v0_bash_agent.sh --resume <session_id>

set -e

# 加载环境配置
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

# 颜色定义
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RESET='\033[0m'

# 创建记忆目录
mkdir -p "$MEMORY_DIR"

# =============================================================================
# 工具定义
# =============================================================================
# 只有一个工具：bash - 却能做所有事情
# 描述中教导模型常见模式和如何生成子代理
TOOL='[{
    "name": "bash",
    "description": "Execute shell command. Read: cat/grep/find. Write: echo > file. Subagent: ./v0_bash_agent.sh 'task'",
    "input_schema": {
        "type": "object",
        "properties": {"command": {"type": "string"}},
        "required": ["command"]
    }
}]'

# =============================================================================
# 系统提示
# =============================================================================
# 教导模型如何有效使用 bash
# 包含子代理指导 - 这是我们获得分层任务分解的方式
SYSTEM="You are a CLI agent at ${WORKDIR}. Solve problems using bash commands.

Rules:
- Prefer tools over prose. Act first, explain briefly after.
- Read files: cat, grep, find, ls, head, tail
- Write files: echo '...' > file, sed -i, or cat << 'EOF' > file
- Subagent: For complex subtasks: ./v0_bash_agent.sh 'task description'

When to use subagent:
- Task requires reading many files (isolate the exploration)
- Task is independent and self-contained
- You want to avoid polluting current conversation with intermediate details

The subagent runs in isolation and returns only its final summary."

# =============================================================================
# 会话管理函数
# =============================================================================

# 生成会话ID (格式: YYYYMMDD_HHMMSS)
generate_session_id() {
    date +%Y%m%d_%H%M%S
}

# 获取会话文件路径
# $1: 会话ID
get_session_file() {
    local session_id="$1"
    echo "${MEMORY_DIR}/v0_session_${session_id}.json"
}

# 列出所有保存的会话
list_sessions() {
    echo -e "${GREEN}Saved sessions:${RESET}"
    if [[ ! -d "$MEMORY_DIR" ]] || [[ -z "$(ls -A "$MEMORY_DIR"/v0_session_*.json 2>/dev/null)" ]]; then
        echo "  (no sessions found)"
        return
    fi
    
    for f in "$MEMORY_DIR"/v0_session_*.json; do
        [[ -f "$f" ]] || continue
        local basename=$(basename "$f" .json)
        local session_id=${basename#v0_session_}
        local msg_count=$(jq 'length' "$f" 2>/dev/null || echo "0")
        local last_modified=$(stat -c %y "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1 || stat -f %Sm "$f" 2>/dev/null)
        echo "  ${session_id} - ${msg_count} messages (last: ${last_modified})"
    done
}

# 加载会话
# $1: 会话ID
load_session() {
    local session_id="$1"
    local session_file=$(get_session_file "$session_id")
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session not found: $session_id"
        return 1
    fi
    
    cat "$session_file"
}

# 保存会话
# $1: 会话ID
# $2: 历史记录(JSON)
save_session() {
    local session_id="$1"
    local history="$2"
    local session_file=$(get_session_file "$session_id")
    
    echo "$history" > "$session_file"
}

# =============================================================================
# 工具实现
# =============================================================================

# 执行 bash 命令
# $1: 命令字符串
execute_bash() {
    local cmd="$1"
    echo -e "${YELLOW}\$ ${cmd}${RESET}"
    
    # 安全检查 - 阻止危险命令
    if [[ "$cmd" == *"rm -rf /"* ]] || [[ "$cmd" == *"sudo"* ]]; then
        echo "Error: Dangerous command blocked"
        return
    fi
    
    # 执行命令
    local output
    output=$(eval "$cmd" 2>&1) || output="${output}
(exit code: $?)"
    output=$(echo "$output" | head -c 50000)
    
    echo "$output"
    echo ""
}

# =============================================================================
# API 调用
# =============================================================================

# 调用 DeepSeek API
# $1: messages (JSON数组)
call_api() {
    local messages="$1"
    
    # 构建请求体
    local json_body
    json_body=$(jq -n \
        --arg model "$MODEL" \
        --arg system "$SYSTEM" \
        --argjson messages "$messages" \
        --argjson tools "$TOOL" \
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
# 代理循环
# =============================================================================

# 执行工具调用
# $1: 工具名
# $2: 输入参数(JSON)
execute_tool() {
    local name="$1"
    local input_json="$2"
    
    if [[ "$name" == "bash" ]]; then
        local cmd
        cmd=$(echo "$input_json" | jq -r '.command')
        local output
        output=$(execute_bash "$cmd" 2>&1)
        echo "$output"
    else
        echo "Unknown tool: $name"
    fi
}

# 主对话函数
# 这是完整的代理循环:
#   while not done:
#       response = model(messages, tools)
#       if no tool calls: return
#       execute tools, append results
#
# $1: 用户输入
# $2: 历史记录(JSON)
# $3: 会话ID (可选，用于保存)
chat() {
    local prompt="$1"
    local history="${2:-[]}"
    local session_id="$3"
    
    # 添加用户消息 - 使用 jq 进行正确的 JSON 转义
    local user_msg
    user_msg=$(jq -n --arg text "$prompt" '[{role: "user", content: [{type: "text", text: $text}]}]')
    
    if [[ "$history" == "[]" ]]; then
        history="$user_msg"
    else
        history=$(echo "$history $user_msg" | jq -s 'add')
    fi
    
    # 主循环
    while true; do
        local response
        response=$(call_api "$history")
        
        # 检查错误
        if [[ $(echo "$response" | jq -r 'has("error")') == "true" ]]; then
            echo "API Error: $(echo "$response" | jq -r '.error.message')"
            return 1
        fi
        
        local stop_reason
        stop_reason=$(echo "$response" | jq -r '.stop_reason')
        
        # 打印文本内容
        echo "$response" | jq -r '.content[] | select(.type == "text") | .text'
        
        # 检查是否完成
        if [[ "$stop_reason" != "tool_use" ]]; then
            # 保存会话
            if [[ -n "$session_id" ]]; then
                save_session "$session_id" "$history"
            fi
            return 0
        fi
        
        # 构建助手消息(包含工具调用)
        local assistant_content
        assistant_content=$(echo "$response" | jq -c '[.content[] | if .type == "text" then {type: "text", text: .text} else {type: "tool_use", id: .id, name: .name, input: .input} end]')
        
        # 执行工具调用并收集结果
        local results="[]"
        local tool_calls
        tool_calls=$(echo "$response" | jq -c '.content[] | select(.type == "tool_use")')
        
        while IFS= read -r tc; do
            [[ -z "$tc" ]] && continue
            
            local tool_id tool_name tool_input
            tool_id=$(echo "$tc" | jq -r '.id')
            tool_name=$(echo "$tc" | jq -r '.name')
            tool_input=$(echo "$tc" | jq -c '.input')
            
            # 执行工具
            local output
            output=$(execute_tool "$tool_name" "$tool_input")
            output=$(echo "$output" | head -c 50000)
            
            # 构建结果
            local result
            result=$(jq -n --arg id "$tool_id" --arg out "$output" '{type: "tool_result", tool_use_id: $id, content: $out}')
            results=$(echo "$results" | jq --argjson r "$result" '. + [$r]')
        done <<< "$tool_calls"
        
        # 更新历史记录
        local assistant_msg user_results_msg
        assistant_msg=$(jq -n --argjson content "$assistant_content" '{role: "assistant", content: $content}')
        user_results_msg=$(jq -n --argjson content "$results" '{role: "user", content: $content}')
        
        history=$(echo "$history [$assistant_msg, $user_results_msg]" | jq -s 'add')
        
        # 每轮后保存会话
        if [[ -n "$session_id" ]]; then
            save_session "$session_id" "$history"
        fi
    done
}

# =============================================================================
# 交互模式
# =============================================================================

# 交互式对话模式 (带历史保存)
# $1: 会话ID (可选)
interactive_mode() {
    local session_id="$1"
    local history="[]"
    
    # 如果没有提供会话ID，创建新的
    if [[ -z "$session_id" ]]; then
        session_id=$(generate_session_id)
        echo -e "${GREEN}New session: ${session_id}${RESET}"
    else
        # 加载现有会话
        history=$(load_session "$session_id") || {
            echo "Starting new session with ID: $session_id"
            history="[]"
        }
        echo -e "${GREEN}Resumed session: ${session_id}${RESET}"
    fi
    
    echo "Type 'exit' to quit, 'save' to force save, 'clear' to clear history."
    echo ""
    
    while true; do
        echo -en "${CYAN}>> ${RESET}"
        read -r query || break
        
        [[ -z "$query" ]] && break
        [[ "$query" == "q" ]] && break
        [[ "$query" == "exit" ]] && break
        
        # 特殊命令
        if [[ "$query" == "save" ]]; then
            save_session "$session_id" "$history"
            echo -e "${GREEN}Session saved.${RESET}"
            continue
        fi
        
        if [[ "$query" == "clear" ]]; then
            history="[]"
            save_session "$session_id" "$history"
            echo -e "${GREEN}History cleared.${RESET}"
            continue
        fi
        
        # 调用对话函数
        chat "$query" "$history" "$session_id"
        # 重新加载历史(以防被更新)
        history=$(load_session "$session_id")
        echo ""
    done
    
    # 最终保存
    save_session "$session_id" "$history"
    echo -e "${GREEN}Session saved: ${session_id}${RESET}"
}

# =============================================================================
# 主入口
# =============================================================================

main() {
    # 处理参数
    if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
        list_sessions
        exit 0
    fi
    
    if [[ "${1:-}" == "--resume" || "${1:-}" == "-r" ]]; then
        if [[ -z "${2:-}" ]]; then
            echo "Error: Session ID required"
            echo "Usage: $0 --resume <session_id>"
            exit 1
        fi
        interactive_mode "$2"
        exit 0
    fi
    
    if [[ $# -gt 0 ]]; then
        # 子代理模式 (一次性，不保存历史)
        chat "$*" "[]" ""
    else
        # 交互模式
        interactive_mode ""
    fi
}

# 检查依赖
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Please install jq."
    exit 1
fi

main "$@"
