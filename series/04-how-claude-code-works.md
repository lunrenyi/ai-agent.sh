# Claude Code 工作原理

> 来源：Anthropic 官方文档
> 原文：How Claude Code works

## 核心概念

Claude Code 是一个运行在终端中的智能代理助手。本文介绍其核心架构、内置能力和有效使用技巧。

---

## 1. 智能循环（Agentic Loop）

当给 Claude 一个任务时，它会经历三个阶段：**收集上下文 → 采取行动 → 验证结果**。这三个阶段相互交织。

```
┌─────────────────────────────────────────────────────────┐
│                    智能循环                              │
│                                                         │
│   你的 prompt → 收集上下文 → 采取行动 → 验证结果         │
│       ↑                                      ↓          │
│       └──────── 循环迭代，直到任务完成 ──────┘          │
│                                                         │
│ 你可以在任何时候中断，引导 Claude 转向不同方向           │
└─────────────────────────────────────────────────────────┘
```

### 循环的适应性
- **问题查询**：可能只需要收集上下文
- **Bug 修复**：需要反复循环所有三个阶段
- **重构**：可能涉及大量验证

Claude 根据前一步学到的东西决定每一步需要什么，将数十个动作串联起来，并在此过程中不断调整。

---

## 2. 模型（Models）

Claude Code 使用 Claude 模型来理解代码和推理任务。Claude 可以：
- 阅读任何语言的代码
- 理解组件之间的连接
- 找出需要如何改变来实现目标

### 可用模型

| 模型 | 适用场景 |
|------|----------|
| **Sonnet** | 处理大多数编码任务 |
| **Opus** | 复杂架构决策的更强推理 |

使用 `/model` 切换模型，或启动时 `claude --model <name>`

---

## 3. 工具（Tools）

工具是 Claude Code 具有代理能力的关键。没有工具，Claude 只能以文本回复；有了工具，Claude 就可以行动。

### 内置工具分类

| 类别 | 功能 |
|------|------|
| **文件操作** | 读取、编辑、创建、重命名 |
| **搜索** | 按模式查找文件、正则搜索、探索代码库 |
| **执行** | 运行 shell 命令、启动服务器、运行测试、使用 git |
| **网络** | 搜索网页、获取文档、查找错误信息 |
| **代码智能** | 查看类型错误和警告、跳转到定义、查找引用 |

### 工具使用示例

当你说 "修复失败的测试" 时，Claude 可能会：

1. 运行测试套件查看失败情况
2. 读取错误输出
3. 搜索相关源文件
4. 阅读这些文件以理解代码
5. 编辑文件修复问题
6. 再次运行测试验证

---

## 4. Claude 可以访问什么

在目录中运行 `claude` 时，Claude Code 可以访问：

- **你的项目**：目录及子目录中的文件
- **你的终端**：任何你可以从命令行运行的命令
- **你的 git 状态**：当前分支、未提交的更改、最近提交历史
- **你的 CLAUDE.md**：项目特定指令、约定和上下文
- **你配置的扩展**：MCP 服务器、skills、子代理等

---

## 5. 执行环境

Claude Code 在三种环境中运行：

| 环境 | 代码运行位置 | 用途 |
|------|-------------|------|
| **本地** | 你的机器 | 默认，完全访问文件、工具和环境 |
| **云端** | Anthropic 管理的 VM | 卸载任务，处理没有本地副本的仓库 |
| **远程控制** | 你的机器，由浏览器控制 | 使用 Web UI，同时保持本地运行 |

---

## 6. 会话管理

### 会话独立性
每个新会话从全新的上下文窗口开始，不保留之前会话的对话历史。Claude 可以通过 auto memory 跨会话保持学习，也可以在 CLAUDE.md 中添加持久指令。

### 恢复和分支会话

```bash
# 恢复会话
claude --continue
claude --resume

# 分支会话（尝试不同方法而不影响原会话）
claude --continue --fork-session
```

### 上下文窗口

Claude 的上下文窗口包含：
- 对话历史
- 文件内容
- 命令输出
- CLAUDE.md 内容
- 加载的 skills
- 系统指令

#### 上下文满时

Claude 自动管理上下文：
- 先清除旧的工具输出
- 如需要则总结对话
- 保留你的请求和关键代码片段

**建议**：将持久规则放在 CLAUDE.md 中，而不是依赖对话历史。

---

## 7. 安全机制

### 检查点（Checkpoints）

**每个文件编辑都是可逆的。** 在 Claude 编辑任何文件之前，它会对当前内容进行快照。如果出了问题，按 `Esc` 两次回滚到之前的状态。

### 权限控制

按 `Shift+Tab` 循环切换权限模式：

| 模式 | 说明 |
|------|------|
| **Default** | Claude 编辑文件和运行命令前都会询问 |
| **Auto-accept edits** | 自动编辑文件，但仍会询问命令 |
| **Plan mode** | 只使用只读工具，创建计划供你批准后再执行 |

---

## 8. 高效使用技巧

### 1. 把 Claude 当作对话

不需要完美的 prompt。从你想要的结果开始，然后迭代：

```
> Fix the login bug
[Claude 调查并尝试]

> That's not quite right. The issue is in the session handling.
[Claude 调整方法]
```

### 2. 提前具体说明

初始 prompt 越精确，需要的修正就越少：

```
> Checkout flow for users with expired cards is broken.
> Check src/payments/ for the issue, especially token refresh.
> Write a failing test first, then fix it.
```

### 3. 给 Claude 验证依据

当有测试用例、预期 UI 截图或明确定义输出时，Claude 表现更好：

```
> Implement validateEmail. Test cases:
> '[email protected]' → true, 'invalid' → false,
> '[email protected]' → false. Run the tests after.
```

### 4. 实现前先探索

对于复杂问题，将研究与编码分开。使用 plan mode（两次 `Shift+Tab`）先分析代码库：

```
> Read src/auth/ and understand how we handle sessions.
> Then create a plan for adding OAuth support.
```

### 5. 授权而不是指令

把委托给一个能干的同事一样思考。给出背景和方向，然后信任 Claude 找出细节：

```
> The checkout flow is broken for users with expired cards.
> The relevant code is in src/payments/.
> Can you investigate and fix it?
```

---

## 总结

Claude Code 的核心是一个**智能循环**：收集上下文 → 采取行动 → 验证结果。通过内置工具，它能够阅读、编辑、搜索和执行命令。关键在于：

1. **把它当作对话**：迭代而非重来
2. **具体说明**：越精确越好
3. **提供验证依据**：测试用例、截图、期望输出
4. **先研究后实现**：使用 plan mode
5. **授权而非指令**：给出方向，信任它的能力
