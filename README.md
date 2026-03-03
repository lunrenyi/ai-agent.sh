# AI Agent 学习仓库

> 用 Shell 脚本探索 AI Agent 的构建与进化之路

---

## 前沿

> [!TIP]
> 在开始学习 AI Agent 之前，不妨先读一读：[AI 使用八荣八耻](/series/01-ai-usage-guide.md)

> [!IMPORTANT]
> **核心原则**：永远不要让 AI 写代码，直到你审查并批准了书面计划。

---

## 项目简介

这是一个用于学习和研究 AI Agent 的实践仓库。通过编写一系列逐步进化的 AI 编码代理，深入理解 AI Agent 的核心概念、设计理念和实现技术。

**核心理念**: "模型即代理" —— 代理系统的核心不是代码，而是模型本身。代码只提供工具集合、运行循环和执行环境。

---

## 目录结构

```
.
├── CLAUDE.md                  # Claude 项目配置文件 (重要!)
├── claude-code-quick-start.md # Claude Code 快速入门
├── claude_md_experience/     # Claude Code 使用经验收集
│   ├── cn.md
│   └── en.md
├── series/                   # AI 学习系列文章
│   ├── 01-ai-usage-guide.md                    # AI 使用八荣八耻
│   ├── 02-how-to-design-ai-agent.md            # 如何设计AI Agent系统
│   ├── 03-claude-code-beginner-playbook.md     # Claude Code 入门指南
│   ├── 04-claude-md-best-practices.md          # CLAUDE.md 最佳实践
│   ├── 05-building-skill-for-claude.md         # 构建 Claude Skill 指南
│   ├── 06-shell-skills-compaction-tips.md      # OpenAI 实战技巧
│   ├── 07-extend-claude-code.md                # 扩展 Claude Code
│   ├── 08-eval-skills-guide.md                 # Evals 测试指南
│   ├── 09-how-i-use-claude-code.md             # 工作流：研究→规划→实现
│   ├── 10-claude-code-agent-teams.md           # Agent Teams 团队协作
│   ├── 11-ai-productivity-critique.md          # AI 生产力批判
│   ├── 12-ai-vampire.md                        # AI 吸血鬼
│   ├── 13-anthropic-hive-mind.md               # Anthropic 蜂巢思维
│   ├── 14-how-claude-code-works.md             # Claude Code 工作原理
│   ├── 15-ai-agent-guidance.md                 # AI Agent 指导术
│   ├── 16-openclaw-tools-skills-guide.md      # OpenClaw 工具技能指南
│   ├── 17-claude-code-memory-management.md     # 内存管理指南
│   ├── 18-ralph-wiggum-autonomous-loop.md      # AI 自主循环编程范式
│   ├── 19-ai-prompt-design-analysis.md        # Prompt 设计分析
│   └── README.md                               # 系列文章索引
│
├── news/                     # 新闻/报告系列
│   ├── 01-openai-2025-developer-report.md
│   ├── 02-chatgpt-apps-15-lessons.md
│   ├── 03-cognitive-debt.md
│   ├── 04-claude-code-founder-interview.md
│   ├── 05-skillsbench-paper-insights.md
│   ├── 06-detecting-distillation-attacks.md
│   ├── 07-agentic-engineering-patterns.md
│   └── README.md
│
├── learn/                    # AI Agent 学习脚本（渐进式演进）
│   ├── v0_bash_agent.sh    # V0: 极简单工具代理
│   ├── v1_basic_agent.sh   # V1: 4个基础工具代理
│   ├── v2_todo_agent.sh    # V2: 待办事项管理
│   ├── v3_subagent.sh      # V3: 子代理机制
│   ├── v4_skills_agent.sh  # V4: 技能系统
│   └── README.md           # 学习指南
│
├── cos/                     # 角色化 AI Agent（花火/Sparkle）
│   ├── sparkle.sh          # 火花主脚本
│   ├── Sparkle.md          # 角色设定
│   └── Sparkle/            # ASCII 表情艺术
│
└── idea/                    # 设计文档
    └── ai-agent.v1.md      # AI Agent v1.0 设计
```

---

## 核心工作流

> **先思考再打字。规划产生的结果远优于直接开干。**

### 标准流程

```
研究 → 规划 → 注解循环 → 实现 → 反馈
```

### 研究阶段

```
深入阅读这个文件夹，深刻理解它的工作原理、功能和所有特性。
完成后，将你的学习和发现写成详细报告，写入 research.md
```

### 规划阶段

- 按 `Shift + Tab` 进入规划模式
- 计划写入 `plan.md`，包含：方法解释、代码片段、文件路径、注意事项

### 注解循环

- 在计划中添加内联注释，纠正假设
- 使用 "先不要实现" 明确守卫
- 迭代直到计划正确

### 实现阶段

```
全部实现。当任务完成时，在计划文档中标记为完成。
不要添加不必要的注释，不要使用 any 或 unknown 类型。
持续运行类型检查。
```

---

## 快速开始

### 1. 配置环境变量

```bash
cd learn
cp .env.example .env  # 或手动创建 .env 文件
```

编辑 `.env` 文件，配置以下变量：

```bash
export DEEPSEEK_API_KEY="your-api-key"
export DEEPSEEK_BASE_URL="https://api.deepseek.com/anthropic"
export MODEL_ID="deepseek-chat"
```

### 2. 运行 Agent

```bash
# V0: 极简版本（只有一个 bash 工具）
./learn/v0_bash_agent.sh

# V1: 基础版本（4个工具：bash/read/write/edit）
./learn/v1_basic_agent.sh

# V2: 待办管理版本
./learn/v2_todo_agent.sh

# V3: 子代理版本
./learn/v3_subagent.sh

# V4: 技能系统版本
./learn/v4_skills_agent.sh
```

### 3. 火花版本（角色扮演）

```bash
# 交互模式
./cos/sparkle.sh

# 直接执行任务
./cos/sparkle.sh "帮我写一个 hello world 程序"
```

---

## 版本演进

| 版本 | 核心特性 | 代码行数 | 适用场景 |
|------|---------|---------|---------|
| V0 | 单工具 (bash)、子代理递归 | ~150 | 极简任务、快速原型 |
| V1 | 4个基础工具 (bash/read/write/edit) | ~250 | 日常编码任务 |
| V2 | 待办事项管理、多步骤规划 | ~350 | 复杂任务、多阶段工作 |
| V3 | 子代理机制、上下文隔离 | ~450 | 大型项目、任务分解 |
| V4 | 技能系统、领域知识外置 | ~550 | 专业领域、复杂工作流 |

---

## 关键技术概念

### 1. 工具系统

Agent 通过工具与外界交互：

- **bash**: 执行 shell 命令
- **read_file**: 读取文件内容
- **write_file**: 创建或覆盖文件
- **edit_file**: 精确修改文件

### 2. 上下文管理三原则

| 原则 | 说明 |
|------|------|
| **可见性** | 计划必须可见，状态必须可跟踪 |
| **隔离性** | 进程隔离 = 上下文隔离 |
| **渐进式** | 按需加载，优先元数据 |

### 3. 上下文退化

> 上下文质量在 **20-40%** 时就开始下降，不是等到 100%。

**缓解策略**：
- **作用域对话**：一个对话一个功能
- **外部记忆**：使用 `plan.md` 或 `SCRATCHPAD.md`
- **复制粘贴重置**：`/compact` + `/clear` + 粘贴重要内容
- **知道什么时候 clear**：失控时直接 `/clear`

### 4. 子代理机制

将复杂任务分解为子任务，每个子代理独立运行在独立进程中，只返回摘要结果，避免上下文污染。

### 5. 技能系统

将领域知识外置为独立文件，按需加载，使 Agent 能够处理专业领域问题。

---

## Prompt 最佳实践

### 核心原则

| 原则 | 说明 |
|------|------|
| **具体 > 模糊** | 详细说明你想要什么 |
| **约束 > 开放式** | 告诉它不要做什么 |
| **例子 > 描述** | 给出最小示例 |
| **说原因** | 告诉它为什么，有助于理解上下文 |

### 示例对比

| 模糊 | 清晰 |
|------|------|
| "帮我写个功能" | "Build email/password authentication using the existing User model, store sessions in Redis with 24-hour expiry" |
| - | "Keep this simple. Don't add abstractions I didn't ask for." |

### 记住

> **输出 = 输入**。如果输出烂，输入就烂。没有捷径。

---

## 学习资源

### 知识文章系列（推荐学习路径）

| 序号 | 标题 | 核心要点 | 阶段 |
|:---:|------|----------|------|
| 01 | [AI 使用八荣八耻](/series/01-ai-usage-guide.md) | AI 时代的正确使用姿势 | 入门 |
| 02 | [如何设计一个 AI Agent 系统](/series/02-how-to-design-ai-agent.md) | 淘宝技术团队深度好文 | 基础理论 |
| 03 | [Claude Code 入门指南](/series/03-claude-code-beginner-playbook.md) | 7年资深工程师心得 | 工具入门 |
| 04 | [CLAUDE.md 最佳实践](/series/04-claude-md-best-practices.md) | 官方文档 + 社区经验整合 | 项目配置 |
| 05 | [构建 Claude Skill 完整指南](/series/05-building-skill-for-claude.md) | Anthropic 官方 Skill 构建教程 | 技能构建 |
| 06 | [Shell + Skills + Compaction 实战技巧](/series/06-shell-skills-compaction-tips.md) | OpenAI 官方长时运行 Agent 技巧 | 效率提升 |
| 07 | [扩展 Claude Code](/series/07-extend-claude-code.md) | MCP 服务器、第三方集成 | 进阶扩展 |
| 08 | [Evals 系统化测试指南](/series/08-eval-skills-guide.md) | 使用 Evals 测试 Skills | 高级技能 |
| 09 | [我是如何使用 Claude Code](/series/09-how-i-use-claude-code.md) | 研究→规划→注解循环→实现 | 实践参考 |
| 10 | [Claude Code Agent Teams 完整指南](/series/10-claude-code-agent-teams.md) | 多智能体协作实战手册 | 团队协作 |
| 11 | [AI 生产力的残酷真相](/series/11-ai-productivity-critique.md) | Dax Raad 对 AI 生产力的冷静批判 | 深度思考 |
| 12 | [AI 吸血鬼](/series/12-ai-vampire.md) | Steve Yegge：AI 正在"吸取"开发者生命 | 行业洞察 |
| 13 | [Anthropic 蜂巢思维](/series/13-anthropic-hive-mind.md) | Steve Yegge：软件开发的未来 | 前沿趋势 |
| 14 | [Claude Code 工作原理](/series/14-how-claude-code-works.md) | 官方文档：智能循环、工具系统 | 核心原理 |
| 15 | [AI Agent 指导术：从「不会问」到「问得好」](/series/15-ai-agent-guidance.md) | 认知差距、Prompt 框架、迭代优化、人机协作 | 能力提升 |
| 16 | [OpenClaw 工具技能指南](/series/16-openclaw-tools-skills-guide.md) | Claude Code 工具技能系统、官方指南解读 | 技能提升 |
| 17 | [Claude Code 内存管理完全指南](/series/17-claude-code-memory-management.md) | 自动记忆、CLAUDE.md、模块化规则 | 项目配置 |
| 18 | [Ralph Wiggum：AI 自主循环编程范式](/series/18-ralph-wiggum-autonomous-loop.md) | 从社区 hack 到官方插件的演进史 | 前沿趋势 |
| 19 | [AI 图像生成 Prompt 设计分析](/series/19-ai-prompt-design-analysis.md) | 结构化「规格说明书」范式 | 能力提升 |

### 其他文档

- `CLAUDE.md` - Claude 项目配置文件（重要!）
- `learn/README.md` - 详细的 AI Agent 学习指南
- `learn/.env` - 环境变量配置
- `idea/ai-agent.v1.md` - AI Agent v1.0 设计文档
- `cos/Sparkle.md` - 火花角色设定分析

---

## 技术栈

- **语言**: Pure Bash
- **API**: DeepSeek (Anthropic 兼容格式)
- **依赖**: jq, curl

---

## License

MIT License - see [LICENSE](LICENSE) file
