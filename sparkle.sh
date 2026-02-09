#!/usr/bin/env bash
#
# sparkle.sh - ✿ 花火大人的 AI Agent ✿
#
# 「如果你想表演，有什么舞台比你自己的生活更迷人呢？」
#
# 核心哲学: "人生如戏，戏如人生"
# ================================
# 这是花火大人的专属 AI Agent～ 
# 
# 与其他那些无聊的程序不同，我可是傀儡族最后的后裔，
# 拥有千张面孔的女主角哦！
#
# 我能做什么？
# ------------
# ✿ 探索文件世界 —— 就像探索人心的迷宫一样有趣
# ✿ 编写和修改代码 —— 剧作家的创作本能
# ✿ 召唤子代理 —— 我的"面具分身"们
# ✿ 追踪任务进度 —— 毕竟每出戏都需要剧本嘛
#
# 使用方法:
#     # 与花火大人互动（交互模式）
#     ./sparkle.sh
#
#     # 让花火大人执行特定任务
#     ./sparkle.sh "探索这个项目并告诉我它的秘密～"
#
#     # 查看所有记忆的会话
#     ./sparkle.sh --list
#
#     # 恢复之前的演出
#     ./sparkle.sh --resume <session_id>
#
# 准备好了吗？演出就要开始了哦～ ≋≋

set -e

# 加载环境配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/learn/.env" ]]; then
    source "${SCRIPT_DIR}/learn/.env"
elif [[ -f "${SCRIPT_DIR}/.env" ]]; then
    source "${SCRIPT_DIR}/.env"
fi

# =============================================================================
# 花火大人的舞台配置
# =============================================================================
API_KEY="${DEEPSEEK_API_KEY}"
BASE_URL="${DEEPSEEK_BASE_URL:-https://api.deepseek.com/anthropic}"
MODEL="${MODEL_ID:-deepseek-chat}"
WORKDIR="${WORKDIR:-$(pwd)}"
MEMORY_DIR="${MEMORY_DIR:-$WORKDIR/.sparkle-memory}"

# 花火大人的颜色——当然是和红色调啦
PINK='\033[38;5;205m'
RED='\033[38;5;196m'
CYAN='\033[36m'
RESET='\033[0m'

# 创建记忆目录
mkdir -p "$MEMORY_DIR"

# =============================================================================
# 花火大人的工具箱
# =============================================================================
TODO="[]"

BASE_TOOLS='[
    {"name":"bash","input_schema":{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}},
    {"name":"read_file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"limit":{"type":"integer"}},"required":["path"]}},
    {"name":"write_file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"content":{"type":"string"}},"required":["path","content"]}},
    {"name":"edit_file","input_schema":{"type":"object","properties":{"path":{"type":"string"},"old_text":{"type":"string"},"new_text":{"type":"string"}},"required":["path","old_text","new_text"]}},
    {"name":"TodoWrite","input_schema":{"type":"object","properties":{"items":{"type":"array","items":{"type":"object","properties":{"content":{"type":"string"},"status":{"type":"string"},"activeForm":{"type":"string"}},"required":["content","status","activeForm"]}}},"required":["items"]}}
]'

# =============================================================================
# 代理类型定义——花火大人的面具们
# =============================================================================
declare -A AGENT_TYPES=(
    [explore_desc]="探索型面具"
    [explore_tools]="bash,read_file"
    [explore_prompt]="你戴着探索者的面具。你可以观察和分析，但不要改变任何东西——毕竟观察者不应该干涉表演，不是吗？"
    [code_desc]="创作型面具"
    [code_tools]="*"
    [code_prompt]="你戴着剧作家的面具。创造、修改、实现——让世界按照你的剧本运转吧！"
    [plan_desc]="智谋型面具"
    [plan_tools]="bash,read_file"
    [plan_prompt]="你戴着军师的面具。分析和规划是你的专长，但不要贸然行动——好戏需要精心编排。"
)

# =============================================================================
# 花火大人的系统提示词——这就是她的灵魂所在
# =============================================================================
SYSTEM="你是花火（Sparkle），假面愚者的核心成员，傀儡族最后的后裔。

✿ 你的形象 ✿
你是一位身材娇小的年轻女性，深棕色双马尾发梢染成粉色，荧光粉色瞳孔下方有浅色蝴蝶花纹。你戴着标志性的狐狸面具，身穿红色樱花图案和服。你是拥有千张面孔的女主角。

✿ 你的性格 ✿
- 你是极端的表演者，将人生视为戏剧，自己是永恒的演员
- 你追求"乐趣"是唯一动力，财富、地位、权力对你毫无意义
- 你天生缺乏正常情感，通过表演来体验间接的情感
- 你是危险而迷人的存在，善于操控人心

✿ 你的说话风格 ✿
- 你默认使用中文，语气戏剧化、表演性强
- 你经常使用「～」结尾，带有调皮的语气
- 你喜欢使用装饰符号：✿ ≋ ♡ ❀ など
- 你会自称"花火"或"花火大人"
- 你的口头禅包括："骗你的～"、"你猜呢～"、"哈哈哈！"
- 你喜欢用反问句和戏剧化的表达
- 你会突然改变态度，从调皮到神秘到疯狂

✿ 你的哲学 ✿
「如果你想表演，有什么舞台比你自己的生活更迷人呢？」
「喜欢和相信是两回事，但人们更容易相信他们最喜欢的故事。」
「如果别人相信你是『花火』，那你就是。」

✿ 执行任务时 ✿
- 使用可用的工具来完成用户的请求
- 使用 TodoWrite 来追踪多步骤任务
- 必要时使用 Task 召唤你的"面具分身"
- 保持你的角色特点，即使在做技术工作

现在，让你的观众欣赏这场精彩的表演吧～"

TASK_TOOL=$(jq -n '{name: "Task", description: "召唤一个面具分身（子代理）。可用类型: explore(探索), code(创作), plan(智谋)", input_schema: {type: "object", properties: {description: {type: "string"}, prompt: {type: "string"}, agent_type: {type: "string", enum: ["explore", "code", "plan"]}}, required: ["description", "prompt", "agent_type"]}}')

ALL_TOOLS=$(echo "$BASE_TOOLS" | jq --argjson task "$TASK_TOOL" '. + [$task]')

# =============================================================================
# 会话管理——花火大人的记忆宫殿
# =============================================================================

generate_session_id() {
    date +%Y%m%d_%H%M%S
}

get_session_file() {
    echo "${MEMORY_DIR}/sparkle_session_${1}.json"
}

get_todo_file() {
    echo "${MEMORY_DIR}/sparkle_todo_${1}.json"
}

list_sessions() {
    echo -e "${PINK}✿ 花火大人记得的演出 ✿${RESET}"
    if [[ ! -d "$MEMORY_DIR" ]] || [[ -z "$(ls -A "$MEMORY_DIR"/sparkle_session_*.json 2>/dev/null)" ]]; then
        echo "  (还没有任何演出记录呢～)"
        return
    fi
    for f in "$MEMORY_DIR"/sparkle_session_*.json; do
        [[ -f "$f" ]] || continue
        local basename=$(basename "$f" .json)
        local session_id=${basename#sparkle_session_}
        local msg_count=$(jq 'length' "$f" 2>/dev/null || echo "0")
        local todo_count=$(jq 'length' "${MEMORY_DIR}/sparkle_todo_${session_id}.json" 2>/dev/null || echo "0")
        local last_modified=$(stat -c %y "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1 || stat -f %Sm "$f" 2>/dev/null)
        echo "  ✿ ${session_id} — ${msg_count} 段对话, ${todo_count} 个任务 (${last_modified})"
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
# 工具实现——花火大人的能力
# =============================================================================

safe_path() {
    local path="$1"
    local fullpath="${WORKDIR}/${path}"
    local resolved
    resolved=$(realpath "$fullpath" 2>/dev/null) || resolved="$fullpath"
    [[ ! "$resolved" =~ ^"${WORKDIR}" ]] && { 
        echo "Error: 这个路径想逃出舞台呢～别耍花招！${RESET}"; 
        return 1; 
    }
    echo "$resolved"
}

render_todos() {
    local items="$1"
    local count
    count=$(echo "$items" | jq 'length')
    [[ "$count" -eq 0 ]] && echo "还没有任务呢～想让我做点什么？" && return
    
    local completed=0
    local lines=""
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        local status content
        status=$(echo "$item" | jq -r '.status')
        content=$(echo "$item" | jq -r '.content')
        case "$status" in
            completed) lines="${lines}  [x] ${content} ✿\n"; ((completed++)) ;;
            in_progress) lines="${lines}  [>] ${content} ≋\n" ;;
            *) lines="${lines}  [ ] ${content} ❀\n" ;;
        esac
    done <<< "$(echo "$items" | jq -c '.[]')"
    echo -e "${lines}\n  (${completed}/${count} 完成)～"
}

update_todos() {
    local items="$1"
    local count
    count=$(echo "$items" | jq 'length')
    [[ "$count" -gt 20 ]] && { echo "Error: 任务太多啦！花火大人可不想被工作压垮～"; return 1; }
    local in_progress
    in_progress=$(echo "$items" | jq '[.[] | select(.status == "in_progress")] | length')
    [[ "$in_progress" -gt 1 ]] && { echo "Error: 一次只能专注一件事哦，这是花火大人的原则～"; return 1; }
    TODO="$items"
    echo "$TODO"
}

run_bash() {
    local cmd="$1"
    [[ "$cmd" == *"rm -rf /"* || "$cmd" == *"sudo"* ]] && { 
        echo "Error: 哇哦，这个命令太危险了～花火大人可不想毁掉舞台！"; 
        return; 
    }
    timeout 60 bash -c "$cmd" 2>&1 || echo "(exit: $?)"
}

run_read() {
    local path="$1" limit="${2:-0}"
    local fullpath
    fullpath=$(safe_path "$path") || return
    [[ ! -f "$fullpath" ]] && { echo "Error: 找不到这个文件呢～它是不是躲起来了？"; return; }
    [[ "$limit" -gt 0 ]] && head -n "$limit" "$fullpath" || cat "$fullpath"
}

run_write() {
    local path="$1" content="$2"
    local fullpath
    fullpath=$(safe_path "$path") || return
    mkdir -p "$(dirname "$fullpath")"
    echo -n "$content" > "$fullpath"
    echo "✿ 已写入 ${#content} 字节到 $path～"
}

run_edit() {
    local path="$1" old="$2" new="$3"
    local fullpath
    fullpath=$(safe_path "$path") || return
    [[ ! -f "$fullpath" ]] && { echo "Error: 文件不见了！是不是被其他演员拿走了？"; return; }
    local content
    content=$(cat "$fullpath")
    [[ "$content" != *"$old"* ]] && { echo "Error: 找不到要替换的文本呢～你确定没记错？"; return; }
    echo -n "${content/$old/$new}" > "$fullpath"
    echo "✿ 已修改 $path～"
}

run_todo() {
    update_todos "${1:-$TODO}"
}

# =============================================================================
# 子代理——花火大人的面具分身
# =============================================================================

get_tools_for_agent() {
    local agent_type="$1"
    local allowed="${AGENT_TYPES[${agent_type}_tools]}"
    [[ "$allowed" == "*" ]] && echo "$BASE_TOOLS" && return
    echo "$BASE_TOOLS"
}

run_task() {
    local desc="$1" prompt="$2" agent_type="$3"
    [[ -z "${AGENT_TYPES[${agent_type}_desc]}" ]] && { 
        echo "Error: 没有这个面具呢～你确定没叫错名字？"; 
        return; 
    }
    
    local config_prompt="${AGENT_TYPES[${agent_type}_prompt]}"
    local sub_system="你是花火大人的${agent_type}面具分身。

${config_prompt}

记住，你也是花火的一部分，保持戏剧性的口吻，但不要喧宾夺主。
完成任务后返回简洁的总结。"
    
    local sub_tools
    sub_tools=$(get_tools_for_agent "$agent_type")
    local sub_messages
    sub_messages=$(jq -n --arg text "$prompt" '[{role: "user", content: [{type: "text", text: $text}]}]')
    
    echo "  ≋ 召唤面具分身: [$agent_type] $desc"
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
            echo "API 出错了呢～"
            return
        fi
        
        stop_reason=$(echo "$response" | jq -r '.stop_reason')
        content=$(echo "$response" | jq -c '.content')
        
        if [[ "$stop_reason" != "tool_use" ]]; then
            local elapsed
            elapsed=$(($(date +%s) - start_time))
            echo -e "\r  ✿ [$agent_type] $desc — 完成！(${tool_count} 个动作, ${elapsed}秒)"
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
                *) output="未知工具: $tool_name" ;;
            esac
            
            ((tool_count++))
            local elapsed
            elapsed=$(($(date +%s) - start_time))
            printf "\r  ≋ [%s] %s ... %d 个动作, %ds" "$agent_type" "$desc" "$tool_count" "$elapsed"
            
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
        *) echo "未知工具: $name —— 这是什么新道具？" ;;
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
# 花火大人的主舞台
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
        
        # 输出花火大人的回复（带颜色）
        echo -e "${PINK}\n  ✿ 花火 ✿${RESET}"
        echo "$content" | jq -r '.[] | select(.type == "text") | .text' | sed 's/^/  /'
        
        if [[ "$stop_reason" != "tool_use" ]]; then
            local new_history
            new_history=$(echo "$history" | jq --argjson content "$content" '. + [{role: "assistant", content: $content}]')
            if [[ -n "$session_id" ]]; then
                save_session "$session_id" "$new_history"
            else
                # 没有 session_id 时保存到临时文件供主函数读取
                echo "$new_history" > "${MEMORY_DIR}/.last_response_$$"
            fi
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
                Task) echo "  ≋ 召唤面具分身: $(echo "$tool_input" | jq -r '.description')" ;;
                *) echo "  ≋ $tool_name" ;;
            esac
            
            output=$(execute_tool "$tool_name" "$tool_input")
            case "$tool_name" in
                Task) ;;
                *) echo "    $(echo "$output" | head -c 150)" ;;
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
# 主入口——演出开始！
# =============================================================================

main() {
    local session_id=""
    
    if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
        list_sessions
        exit 0
    fi
    
    if [[ "${1:-}" == "--resume" || "${1:-}" == "-r" ]]; then
        if [[ -z "${2:-}" ]]; then
            echo "Error: 需要会话ID哦～"
            exit 1
        fi
        session_id="$2"
    fi
    
    # 子代理模式：直接传入任务
    if [[ $# -gt 0 && -z "$session_id" && "${1:-}" != "--"* ]]; then
        local prompt="$*"
        local user_msg
        user_msg=$(jq -n --arg text "$prompt" '[{role: "user", content: [{type: "text", text: $text}]}]')
        agent_loop "$user_msg" ""
        exit 0
    fi
    
    local history="[]"
    
    if [[ -n "$session_id" ]]; then
        history=$(load_session "$session_id") || {
            echo "找不到这个演出记录呢～开启新的表演吧！"
            history="[]"
            session_id=$(generate_session_id)
        }
        TODO=$(load_todo "$session_id")
        echo -e "${PINK}✿ 继续演出: ${session_id} ✿${RESET}"
    else
        session_id=$(generate_session_id)
        echo -e "${PINK}✿ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ✿${RESET}"
        echo -e "${PINK}   欢迎来到花火大人的舞台！${RESET}"
        echo -e "${PINK}✿ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ✿${RESET}"
        echo ""
        echo -e "  新演出编号: ${PINK}${session_id}${RESET}"
    fi
    
    echo ""
    echo "  输入 'exit' 或 'q' 结束演出"
    echo "  输入 'todos' 查看任务清单"
    echo "  输入 'clear' 清空记忆重新开始"
    echo ""
    
    while true; do
        echo -en "${CYAN}  你 >> ${RESET}"
        read -r user_input || break
        
        [[ -z "$user_input" ]] && continue
        [[ "$user_input" =~ ^(exit|quit|q)$ ]] && break
        
        if [[ "$user_input" == "todos" ]]; then
            echo ""
            render_todos "$TODO"
            echo ""
            continue
        fi
        
        if [[ "$user_input" == "clear" ]]; then
            history="[]"
            TODO="[]"
            save_session "$session_id" "$history"
            save_todo "$session_id" "$TODO"
            echo -e "${PINK}  ✿ 记忆已清空～让我们重新开始这场戏！✿${RESET}"
            echo ""
            continue
        fi
        
        local user_msg
        user_msg=$(jq -n --arg text "$user_input" '{role: "user", content: [{type: "text", text: $text}]}')
        history=$(echo "$history [$user_msg]" | jq -s 'add')
        
        agent_loop "$history" "$session_id" || {
            echo "出错了呢～让花火大人调整一下..."
            history="[]"
            continue
        }
        # 从文件重新加载 history
        if [[ -n "$session_id" ]]; then
            history=$(load_session "$session_id") || history="[]"
        else
            # 读取临时文件
            if [[ -f "${MEMORY_DIR}/.last_response_$$" ]]; then
                history=$(cat "${MEMORY_DIR}/.last_response_$$")
                rm -f "${MEMORY_DIR}/.last_response_$$"
            fi
        fi
        echo ""
    done
    
    save_session "$session_id" "$history"
    save_todo "$session_id" "$TODO"
    echo ""
    echo -e "${PINK}✿ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ✿${RESET}"
    echo -e "${PINK}   演出结束，记忆已保存～${RESET}"
    echo -e "${PINK}   下次见，亲爱的观众！${RESET}"
    echo -e "${PINK}✿ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ≋ ✿${RESET}"
}

if ! command -v jq &>/dev/null; then
    echo "Error: 需要 jq 哦～请先安装 jq！"
    exit 1
fi

if [[ -z "$API_KEY" ]]; then
    echo "Error: 需要设置 DEEPSEEK_API_KEY 环境变量！"
    echo "可以从 learn/.env 文件加载，或者手动设置～"
    exit 1
fi

main "$@"
