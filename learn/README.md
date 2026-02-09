# AI Agent Shell 脚本学习指南

> 从 Bash 到 Skills：构建 AI 编码代理的进化之路

## 目录

1. [概述](#概述)
2. [核心理念](#核心理念)
3. [版本演进](#版本演进)
4. [关键技术概念](#关键技术概念)
5. [架构设计](#架构设计)
6. [实践经验](#实践经验)
7. [使用指南](#使用指南)
8. [进阶技巧](#进阶技巧)

---

## 概述

本项目是一系列用 Shell 脚本实现的 AI 编码代理，从最简单的单工具版本逐步进化到支持子代理、技能系统的完整框架。所有版本都使用 DeepSeek API（兼容 Anthropic 格式）。

### 文件说明

| 文件 | 代码行数 | 核心特性 | 适用场景 |
|------|---------|---------|---------|
| `v0_bash_agent.sh` | ~150 | 单工具(bash)、子代理递归 | 极简任务、快速原型 |
| `v1_basic_agent.sh` | ~250 | 4个基本工具 | 日常编码任务 |
| `v2_todo_agent.sh` | ~350 | 待办事项管理 | 多步骤复杂任务 |
| `v3_subagent.sh` | ~450 | 子代理机制 | 大型项目、任务分解 |
| `v4_skills_agent.sh` | ~550 | 技能系统 | 领域专业化工作 |

---

## 核心理念

### 1. 模型即代理 (The Model IS the Agent)

**关键洞察**: 代理系统的核心不是代码，而是**模型本身**。

```
传统助手:  用户 → 模型 → 文本响应

代理系统:  用户 → 模型 → [工具 → 结果]* → 响应
                          ^________|
```

模型决定：
- 调用哪些工具
- 调用顺序
- 何时停止

代码只提供：
- 工具集合
- 运行循环
- 执行环境

### 2. 工具 vs 能力

**工具** = 模型 **CAN** 做什么（能力）
**知识** = 模型 **KNOWS** 怎么做（经验）

| 层级 | 内容 | 作用 |
|------|------|------|
| 系统提示 | 通用规则 | 约束行为 |
| 工具定义 | 可用功能 | 扩展能力 |
| 技能文件 | 领域知识 | 专业指导 |

### 3. 上下文管理三原则

#### 原则一：可见性 (Make Plans Visible)
- 计划必须**可见**（待办列表）
- 状态必须**可跟踪**（进度显示）
- 约束**强制专注**（单任务进行）

#### 原则二：隔离性 (Context Isolation)
- 进程隔离 = 上下文隔离
- 子代理独立运行，不污染父上下文
- 只返回摘要，隐藏中间细节

#### 原则三：渐进式 (Progressive Disclosure)
- 第1层：元数据（始终加载）~100 tokens
- 第2层：详细内容（按需加载）~2000 tokens
- 第3层：资源文件（必要时加载）无限制

---

## 版本演进

### V0: Bash is All You Need

**哲学**: Unix 哲学——一切皆文件，一切皆可管道。

```bash
# 为什么 Bash 足够？
| 需求        | Bash 命令                              |
|-------------|----------------------------------------|
| 读取文件    | cat, head, tail, grep                  |
| 写入文件    | echo '...' > file, sed -i              |
| 搜索        | find, grep, rg, ls                     |
| 执行        | python, npm, make                     |
| 子代理      | ./v0_bash_agent.sh "task"             |
```

**核心代码**（代理循环）：
```bash
while true; do
    response=$(call_api "$history")
    
    if [[ "$stop_reason" != "tool_use" ]]; then
        # 无工具调用，任务完成
        return
    fi
    
    # 执行工具调用
    for tc in $tool_calls; do
        output=$(execute_tool "$tc")
        results+=($output)
    done
    
    # 更新历史，继续循环
    history=$(update_history "$history" "$results")
done
```

**关键经验**:
- 单工具足够实现完整功能
- 子代理通过自身递归调用实现
- 进程隔离天然提供上下文隔离

---

### V1: 四个基本工具

**哲学**: 剥离 CLI 装饰，保留核心能力。

**四个工具覆盖 90% 用例**:

```
┌─────────────┬──────────────────┬─────────────────┐
│ 工具        │ 目的             │ 示例            │
├─────────────┼──────────────────┼─────────────────┤
│ bash        │ 运行任何命令     │ npm install     │
│ read_file   │ 读取文件内容     │ 查看 src/main   │
│ write_file  │ 创建/覆盖文件    │ 创建 README     │
│ edit_file   │ 精确修改         │ 替换函数        │
└─────────────┴──────────────────┴─────────────────┘
```

**设计决策**:

1. **safe_path()** - 路径安全检查
   ```bash
   # 防止通过 ../ 逃离工作目录
   if [[ ! "$resolved" =~ ^"${WORKDIR}" ]]; then
       echo "Error: Path escapes workspace"
   fi
   ```

2. **edit_file** 使用字符串匹配而非行号
   - 更稳定（行号会变化）
   - 自描述（修改意图清晰）
   - 只替换第一个匹配（安全）

3. **输出截断** - 限制 50KB
   - 防止上下文溢出
   - 大文件使用 `limit` 参数

---

### V2: 结构化规划

**哲学**: "结构既约束又赋能" (Structure constrains AND enables)

**问题**: 没有显式计划，模型会：
- 在任务间随机跳转
- 忘记已完成步骤
- 中途失去焦点

**解决方案**: TodoWrite 工具

```
Before: "我要做 A，然后 B，然后 C" (在模型脑海中，不可见)
        10 次工具调用后: "等等，我在做什么？"

After:  [ ] 重构 auth 模块
        [>] 添加单元测试  <- 当前正在进行
        [ ] 更新文档
        
        (1/3 已完成)  <- 进度可见
```

**约束设计**（不是限制，是脚手架）：

| 约束 | 原因 | 效果 |
|------|------|------|
| 最多 20 项 | 防止无限列表 | 强制任务分解 |
| 一个进行中 | 强制单任务 | 提高专注度 |
| 必填 activeForm | 现在时描述 | 实时可见性 |

**代码示例**（待办更新）：
```bash
update_todos() {
    local items="$1"
    
    # 验证
    [[ "$count" -gt 20 ]] && return 1  # 上限检查
    [[ "$in_progress" -gt 1 ]] && return 1  # 单任务检查
    
    # 渲染
    for item in $items; do
        case "$status" in
            completed)  echo "[x] $content" ;;
            in_progress) echo "[>] $content <- $activeForm" ;;
            pending)     echo "[ ] $content" ;;
        esac
    done
}
```

---

### V3: 子代理机制

**哲学**: "分而治之，上下文隔离" (Divide and Conquer with Context Isolation)

**问题 - 上下文污染**:
```
单代理历史:
  [探索...] cat file1.py → 500 行
  [探索...] cat file2.py → 300 行
  ... 15 个文件 ...
  [重构...] "等等，file1 包含什么？"  ← 上下文已满
```

**解决方案**:
```
主代理历史:
  [任务: 探索代码库]
    → 子代理探索 20 个文件 (隔离上下文)
    → 返回: "Auth 在 src/auth/, DB 在 src/models/"
  [重构... 使用干净上下文]
```

**代理类型注册表**:

```
┌─────────┬─────────────────┬─────────────────────────┐
│ 类型    │ 工具            │ 用途                    │
├─────────┼─────────────────┼─────────────────────────┤
│ explore │ bash, read_file │ 只读探索，安全搜索      │
│ code    │ 所有工具        │ 完整实现，可写入        │
│ plan    │ bash, read_file │ 设计规划，只读分析      │
└─────────┴─────────────────┴─────────────────────────┘
```

**子代理执行流程**:
```bash
run_task() {
    # 1. 创建隔离消息历史 (关键: 没有父上下文!)
    sub_messages=[{user: prompt}]
    
    # 2. 获取代理特定的工具集
    sub_tools=get_tools_for_agent($agent_type)
    
    # 3. 运行相同的代理循环
    while not done:
        response = model(sub_messages, sub_tools)
        execute tools
        update sub_messages
    
    # 4. 只返回最终文本
    return summary
}
```

**进度显示**:
```
[explore] find auth files ... 5 tools, 3.2s
[code]    implement JWT ... 12 tools, 8.5s
[plan]    design migration ... done (3 tools, 2.1s)
```

---

### V4: 技能系统

**哲学**: "知识外部化" (Knowledge Externalization)

**范式对比**:

| 方式 | 更新知识 | 成本 | 时间 | 需要 |
|------|---------|------|------|------|
| 传统 AI | 训练模型 | $10K-$1M+ | 数周 | ML 专家、GPU |
| 技能 | 写 Markdown | 免费 | 分钟 | 任何人 |

**工具 vs 技能**:

| 概念 | 本质 | 示例 |
|------|------|------|
| **工具** | 模型 **CAN** 做什么 | bash, read_file |
| **技能** | 模型 **KNOWS** 怎么做 | PDF处理, MCP开发 |

**渐进式披露**:
```
Layer 1: 元数据 (始终加载)
  - name, description
  - ~100 tokens/技能
  
Layer 2: SKILL.md 正文 (触发时)
  - 详细说明、代码示例
  - ~2000 tokens
  
Layer 3: 资源 (按需)
  - scripts/, references/
  - 无限制
```

**SKILL.md 标准格式**:
```yaml
---
name: pdf
description: Process PDF files
---

# PDF Processing Skill

## Reading PDFs
Use pdftotext for quick extraction:
```bash
pdftotext input.pdf -
```
```

**缓存保留注入**（关键优化）：
```
错误方式: 编辑系统提示 → 缓存失效 → 20-50x 成本
正确方式: 工具结果追加 → 缓存命中 → 成本稳定
```

**代码实现**:
```bash
run_skill() {
    content=$(get_skill_content "$skill_name")
    
    # 包装为 tool_result，不是 system prompt!
    echo "<skill-loaded name=\"$name\">
    $content
    </skill-loaded>"
}
```

---

## 关键技术概念

### 1. 代理循环 (The Agent Loop)

所有编码代理共享的核心模式：

```
while True:
    response = model(messages, tools)
    
    if no tool calls:
        return final_answer
    
    for tool_call in response.tool_calls:
        result = execute(tool_call)
        messages.append(result)
```

**为什么有效**:
1. 模型决定调用哪些工具、何时停止
2. 工具结果提供反馈用于下一步决策
3. 对话历史自动保持上下文

### 2. 消息格式 (Anthropic 兼容)

```json
{
  "role": "user",
  "content": [
    {
      "type": "text",
      "text": "user message"
    }
  ]
}
```

工具调用：
```json
{
  "role": "assistant",
  "content": [
    {
      "type": "tool_use",
      "id": "tool_123",
      "name": "bash",
      "input": {"command": "ls -la"}
    }
  ]
}
```

工具结果：
```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "tool_123",
      "content": "total 32..."
    }
  ]
}
```

### 3. JSON 处理最佳实践

**永远不要手动转义**:
```bash
# 错误！
history="[{\"role\": \"user\", \"content\": \"${prompt//\"/\\\"}\"}]"

# 正确！使用 jq
user_msg=$(jq -n --arg text "$prompt" '[{
    role: "user",
    content: [{type: "text", text: $text}]
}]')
```

**合并数组**:
```bash
history=$(echo "$history [$new_msg]" | jq -s 'add')
```

### 4. 会话管理

**文件命名约定**:
```
.ai-memory/
├── v0_session_20250208_234012.json   # 对话历史
├── v2_session_20250208_234015.json
├── v2_todo_20250208_234015.json      # 待办状态
└── v4_session_20250208_234020.json
```

**状态分离**:
- 对话历史：messages 数组
- 待办状态：todos 数组（v2/v3/v4）
- 技能加载：动态，不持久化

---

## 架构设计

### 模块结构

```
┌─────────────────────────────────────────────┐
│                 Main Loop                    │
│  (读取输入 → 调用代理 → 保存历史 → 循环)     │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              Agent Loop                      │
│  (调用API → 检查响应 → 执行工具 → 循环)      │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │ Tool   │ │ Session│ │ Skills │
   │ Execute│ │ Manager│ │ Loader │
   └────────┘ └────────┘ └────────┘
```

### 安全设计

1. **路径隔离**: `safe_path()` 确保文件操作在工作目录内
2. **命令过滤**: 阻止 `rm -rf /`, `sudo` 等危险命令
3. **输出限制**: 50KB 截断防止上下文溢出
4. **超时控制**: 60 秒命令超时

### 扩展点

添加新工具的三步骤：
1. 在 `TOOLS` 数组中添加定义
2. 在 `execute_tool()` 中添加处理逻辑
3. 实现具体的 `run_xxx()` 函数

---

## 实践经验

### 1. 调试技巧

**查看 API 请求**:
```bash
# 添加 -v 查看 curl 详细输出
curl -v -s "${BASE_URL}/v1/messages" ...
```

**检查 JSON 格式**:
```bash
# 验证历史记录是否有效 JSON
echo "$history" | jq . > /dev/null && echo "Valid JSON"
```

**查看会话文件**:
```bash
# 格式化查看保存的会话
jq . .ai-memory/v1_session_*.json | less
```

### 2. 性能优化

**减少 API 调用**:
- 使用 `limit` 参数限制大文件读取
- 子代理汇总结果，不返回原始输出
- 技能系统按需加载知识

**缓存优化**:
- 技能内容放入 tool_result 而非 system prompt
- 保持 system prompt 稳定以利用前缀缓存

### 3. 错误处理

```bash
# 检查 API 错误
if [[ $(echo "$response" | jq -r 'has("error")') == "true" ]]; then
    echo "API Error: $(echo "$response" | jq -r '.error.message')"
    return 1
fi

# 检查命令超时
timeout 60 bash -c "$cmd" || echo "(timeout)"
```

### 4. 设计模式

**装饰器模式**: 工具包装
```bash
run_bash() {
    # 安全检查（前置装饰）
    [[ "$cmd" == *"sudo"* ]] && return 1
    
    # 执行
    output=$(eval "$cmd")
    
    # 截断（后置装饰）
    echo "$output" | head -c 50000
}
```

**策略模式**: 代理类型
```bash
case "$agent_type" in
    explore) tools=(bash read_file) ;;
    code)    tools=(all) ;;
    plan)    tools=(bash read_file) ;;
esac
```

---

## 使用指南

### 快速开始

```bash
# 1. 加载配置
source learn/.env

# 2. 开始新会话
./learn/v1_basic_agent.sh

# 3. 列出保存的会话
./learn/v1_basic_agent.sh --list

# 4. 恢复会话
./learn/v1_basic_agent.sh --resume 20250208_234012
```

### 选择合适的版本

| 场景 | 推荐版本 | 原因 |
|------|---------|------|
| 快速文件操作 | v0 | 极简，单工具足够 |
| 日常开发任务 | v1 | 4个工具，平衡能力 |
| 复杂重构 | v2 | 待办跟踪，不遗漏步骤 |
| 大型项目分析 | v3 | 子代理隔离上下文 |
| 专业领域工作 | v4 | 技能系统，专业指导 |

### 交互命令

所有版本支持：
- `exit` / `q` - 退出并保存
- `clear` - 清空当前会话

v2/v3/v4 额外支持：
- `todos` - 显示待办事项
- `save` - 强制保存（v0）

---

## 进阶技巧

### 1. 自定义技能

创建 `skills/my-skill/SKILL.md`:
```yaml
---
name: my-skill
description: Description for the model
---

# My Skill

## Step 1: Do something
```bash
echo "example"
```

## Step 2: Do next thing
...
```

启动 v4，模型会自动检测并使用。

### 2. 子代理递归

在 v0 中，子代理可以调用自身：
```bash
# 主代理调用子代理
./v0_bash_agent.sh "分析项目结构"

# 子代理可以继续调用孙代理
./v0_bash_agent.sh "分析 src/ 目录"
```

### 3. 会话恢复策略

```bash
# 每天新会话
SESSION=$(date +%Y%m%d)
./learn/v2_todo_agent.sh --resume $SESSION

# 按任务分会话
./learn/v3_subagent.sh --resume refactor-auth
```

### 4. 结合其他工具

```bash
# 将会话历史用于分析
jq -r '.[].content[0].text' .ai-memory/v1_session_*.json | \
    grep -i "error" | \
    sort | uniq -c | sort -rn
```

---

## 设计原则总结

1. **简单优先**: 一个工具 + 一个循环 = 完整代理
2. **可见性**: 让计划、进度、状态都可见
3. **隔离性**: 通过进程隔离实现上下文隔离
4. **渐进式**: 按需加载，保持上下文精简
5. **约束赋能**: 好的约束是脚手架，不是限制

---

## 延伸阅读

- [Anthropic API 文档](https://docs.anthropic.com/)
- [Unix 哲学](https://en.wikipedia.org/wiki/Unix_philosophy)
- [Claude Code 设计](https://www.anthropic.com/research/claude-code)

