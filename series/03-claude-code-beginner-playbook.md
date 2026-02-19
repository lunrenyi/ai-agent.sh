# Claude Code 入门指南：7 年资深工程师的实战心得

> 作者是一位有 7 年经验的软件工程师，曾在 Amazon、Disney、Capital One 工作，现任构建企业 Agent 的初创公司 CTO

---

## TL;DR

| 原则 | 核心要点 |
|------|----------|
| 先思考 | 规划产生的结果远优于直接开干 |
| CLAUDE.md | 简短、具体、说原因、持续更新 |
| 上下文 | 30% 就会退化，用外部记忆作用域对话 |
| 架构 | 不能跳过规划，结构决定输出 |
| 输入输出 | 输出差就是输入差 |
| 工具实验 | MCP、hooks、slash commands 都试试 |
| 卡住时 | 改变策略，不要循环 |
| 构建系统 | 自动化、Headless 模式、持续改进 |

---

## 一、Think First（先思考）

> 10 次中有 10 次，规划模式下的输出明显优于直接开干。

### 核心原则

大多数人的最大误区是：**一上来就开干**（打字或说话）。但这是最大的错误。

正确的做法是：
1. **先思考** — 想清楚要做什么
2. **进入规划模式** — Shift + Tab 两次
3. **再开始对话**

### 两种建议

如果你没有多年软件工程经验自己思考：

1. **持续学习** — 即使一点点积累，也比不学好
2. **与 LLM 深度对话** — 描述你想构建的东西，让 LLM 提供各种系统设计选项，最终双方商定解决方案

> 你和 LLM 应该互相提问，而不是单向输出。

### 适用场景

- 写代码前 → 思考架构
- 重构前 → 思考最终状态
- Debug 前 → 思考你对问题的已知信息

**规律**：先思考再打字，比先打字希望 Claude 自己搞清楚，产出好得多。

### 架构的重要性

| 模糊指令 | 清晰指令 |
|----------|----------|
| "build me an auth system" | "Build email/password authentication using the existing User model, store sessions in Redis with 24-hour expiry, and add middleware that protects all routes under /api/protected." |

> 按两下 Shift + Tab 进入规划模式。这会花 5 分钟，但能节省后面数小时的调试时间。

---

## 二、CLAUDE.md

> 这是你最大的杠杆点。

### 什么是 CLAUDE.md

当你开始 Claude Code 会话时，Claude 首先读取的就是这个文件。它是项目的"入职培训材料"。

### 常见误区

- **完全忽略它** — 错失杠杆
- **塞满垃圾** — 让 Claude 变得更差

### 最佳实践

| 原则 | 说明 |
|------|------|
| 保持简短 | Claude 只能可靠遵循约 150-200 条指令，系统 prompt 已用约 50 条 |
| 特定于项目 | 解释奇怪的 stuff，比如真正重要的 bash 命令 |
| 说原因，不只是说什么 | "Use TypeScript strict mode" vs "Use TypeScript strict mode because we've had production bugs from implicit any types" |
| 持续更新 | 工作时按 # 让 Claude 自动添加指令，每次纠正同样的问题两次就记录进去 |

### 好 vs 坏的 CLAUDE.md

| 类型 | 特点 |
|------|------|
| 坏的 CLAUDE.md | 像是给新员工的文档 |
| 好的 CLAUDE.md | 像是给自己留的笔记（如果你知道自己会失忆的话） |

---

## 三、Context Windows 的局限性

### 关键发现

- Opus 4.5 有 200,000 token 上下文窗口
- 但质量在 **20-40%** 时就开始下降，不是等到 100%
- 压缩不能奇迹般恢复质量，因为压缩前模型已经退化了

### 解决策略

#### 1. 作用域对话

一个对话一个功能或任务。不要用同一个对话构建 auth 系统又重构数据库层，Claude 会混淆。

#### 2. 使用外部记忆

复杂工作时，让 Claude 把计划和进度写到实际文件中（如 `SCRATCHPAD.md` 或 `plan.md`）。这些跨会话持久化。

#### 3. 复制粘贴重置

当上下文膨胀时：
1. 复制终端中重要的东西
2. 运行 `/compact` 获取摘要
3. `/clear` 清除上下文
4. 只粘贴回重要的东西

#### 4. 知道什么时候该 clear

如果对话已经失控或累积了无关上下文，直接 `/clear` 开始新的。Claude 仍有你的 CLAUDE.md，所以不会丢失项目上下文。

> **心智模型**：Claude 是无状态的。每个会话从零开始，除了你明确给它的东西。

---

## 四、Prompts Are Everything

> 人们花数周学习框架和工具，却花零时间学习如何与生成代码的东西沟通。

### 核心原则

Prompting 不是神秘艺术。它是最基本的沟通形式。**清晰**总是比**模糊**得到更好的结果。

### 有效做法

| 做法 | 示例 |
|------|------|
| 具体说明你想要什么 | "Build auth system" vs "Build email/password authentication using this existing User model, store sessions in Redis, add middleware that protects routes under /api/protected" |
| 告诉它 **不要** 做什么 | "Keep this simple. Don't add abstractions I didn't ask for. One file if possible." |
| 给出背景原因 | "We need this to be fast because it runs on every request" / "This is a prototype we'll throw away" |

### 记住

- AI 是为了加速我们，不是完全取代我们
- Claude 仍然会犯错
- 能够识别这些错误能解决很多问题

> **输出 = 输入**。如果输出烂，输入就烂。没有捷径。

---

## 五、Bad Input == Bad Output

> 如果你用 Opus 4.5 这样的好模型得到坏结果，那就是你的输入和 prompting 烂。

### 瓶颈几乎总是在人这边

| 方面 | 改进方向 |
|------|----------|
| 如何写 prompts | 具体 > 模糊；约束 > 开放式；例子 > 描述 |
| 如何结构化请求 | 复杂任务分步骤；实施前先架构；审查输出并迭代 |
| 如何提供上下文 | Claude 需要知道什么才能做好？你做了什么假设 Claude 看不到？ |

### 模型选择

| 模型 | 适用场景 |
|------|----------|
| **Sonnet** | 更快更便宜，适合路径清晰的任务：写样板、根据计划重构、实现已做架构决策的功能 |
| **Opus** | 更慢更贵，适合复杂推理、规划、需要 Claude 深入思考权衡的任务 |

### 推荐工作流

用 **Opus** 规划和做架构决策，然后切换到 **Sonnet**（Claude Code 中 Shift+Tab）进行实施。

---

## 六、MCP、Tools 和配置

### 你不需要全部

Claude 有超多功能：MCP 服务器、Hooks、自定义斜杠命令、settings.json 配置、Skills、插件。

**但你应该尝试和实验。**

### MCP (Model Context Protocol)

让 Claude 连接到外部服务：Slack、GitHub、数据库、API。

如果你经常把信息从一处复制到 Claude，很可能有 MCP 能自动做这件事。

### Hooks

在 Claude 更改前后自动运行代码：
- 每次 Claude 触及时文件运行 Prettier
- 每次编辑后运行类型检查

这能立即发现问题，而不是让它们堆积。

### 自定义斜杠命令

把重复使用的 prompts 打包成命令：
1. 创建 `.claude/commands` 文件夹
2. 添加 markdown 文件写你的 prompts
3. 现在可以用 `/commandname` 运行

---

## 七、当 Claude 卡住时

### 症状

- Claude 循环：尝试同样的事，失败，再试
- 自信地实现完全错误的东西

### 解决策略

| 策略 | 说明 |
|------|------|
| **简单开始** | 清除对话，累积的上下文可能让它困惑 |
| **简化任务** | 如果 Claude 应对复杂任务困难，拆成小块 |
| **展示而非告诉** | 写一个最小例子："输出应该像这样，现在把这个模式应用到其余部分" |
| **有创意** | 换个角度，有时你框定问题的方式和 Claude 的思考方式不匹配 |

### 元技能

> 如果你解释了同样的事三次 Claude 还不明白，解释更多没帮助。改变点什么。

---

## 八、Build Systems

### 核心观点

从 Claude 获得最大价值的人不是用它做一次性任务，而是把它作为组件构建系统。

### Headless 模式

Claude Code 有 `-p` 标志用于无头模式：运行你的 prompt 并输出结果，而不进入交互界面。

**这意味着**：
- 可以脚本化
- 输出管道传给其他工具
- 与 bash 命令链式组合
- 集成到自动化工作流

### 企业用法

| 场景 | 说明 |
|------|------|
| 自动 PR 审查 | 自动审查代码 |
| 自动工单响应 | 处理支持工单 |
| 自动日志和文档更新 | 持续记录和改进 |

### 飞轮效应

```
Claude 犯错 → 你审查日志 → 改进 CLAUDE.md 或工具 → 下次 Claude 更好 → 累积
```

> 如果你只用 Claude 交互式使用，你就在桌子上留了价值。想想你工作中有哪些地方可以让 Claude 在你不看的情况下运行。

---

## 总结

使用 Claude 构建——无论是你自己的项目还是生产系统——这些因素决定你是与工具搏斗还是流畅使用：

1. **先思考再打字** — 规划比直接开干好得多
2. **CLAUDE.md 是杠杆点** — 简短、具体、说原因、持续更新
3. **上下文 30% 就退化** — 用外部记忆、作用域对话、不怕 clear
4. **架构比什么都重要** — 不能跳过规划
5. **输出来自输入** — 坏结果往往是 prompting 问题
6. **实验工具和配置** — MCP、hooks、slash commands
7. **卡住时改变方法** — 不要循环
8. **构建系统，不是一次性任务** — 自动化、持续改进
