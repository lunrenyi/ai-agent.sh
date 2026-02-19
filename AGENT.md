# AGENT.md

> 本项目是 AI Agent 学习仓库，用于探索和收集 AI Agent 的资料，提升对 AI Agent 的认知。

---

## 项目结构

```
.
├── AGENT.md                  # Agent 配置文件（本文件）
├── learn/                    # AI Agent 学习脚本（渐进式演进）
│   ├── v0_bash_agent.sh    # V0: 极简单工具代理 (~150行)
│   ├── v1_basic_agent.sh    # V1: 4个基础工具代理 (~250行)
│   ├── v2_todo_agent.sh    # V2: 待办事项管理 (~350行)
│   ├── v3_subagent.sh      # V3: 子代理机制 (~450行)
│   ├── v4_skills_agent.sh  # V4: 技能系统 (~550行)
│   └── README.md            # 学习指南
│
├── cos/                     # 角色化 AI Agent（花火/Sparkle）
│   ├── sparkle.sh           # 火花主脚本
│   ├── Sparkle.md           # 角色设定
│   └── Sparkle/             # ASCII 表情艺术
│
├── series/                  # AI 学习系列文章
│   ├── 01-ai-usage-guide.md                   # AI 使用八荣八耻
│   ├── 02-claude-code-beginner-playbook.md    # Claude Code 入门指南
│   ├── 03-how-i-use-claude-code.md            # 工作流
│   ├── 04-how-to-design-ai-agent.md            # 如何设计 AI Agent 系统
│   ├── 05-building-skill-for-claude.md         # 构建 Claude Skill 指南
│   ├── 06-shell-skills-compaction-tips.md     # OpenAI 实战技巧
│   ├── 07-openai-2025-developer-report.md      # 2025 开发者年度报告
│   ├── 08-chatgpt-apps-15-lessons.md          # 构建 ChatGPT Apps 经验
│   ├── 09-eval-skills-guide.md                # Evals 测试指南
│   └── 10-cognitive-debt.md                  # 认知债务
│
└── idea/                    # 设计文档
    └── ai-agent.v1.md      # AI Agent v1.0 设计
```

---

## 核心理念

### 模型即代理 (The Model IS the Agent)

代理系统的核心不是代码，而是**模型本身**。代码只提供工具集合、运行循环和执行环境。

```
代理系统: 用户 → 模型 → [工具 → 结果]* → 响应
                          ^________|
```

### Agent 核心公式

```
AI Agent = LLM (大脑) + Planning (规划) + Memory (记忆) + Tools (工具)
```

### Agent vs LLM

| 特性 | LLM | AI Agent |
|------|-----|----------|
| 能力 | 回答问题 | 完成任务的 |
| 行动 | 只能说话 | 能操作电脑 |
| 记忆 | 有限上下文 | 可长期记忆 |
| 模式 | 你问我答 | 自主规划执行 |

---

## 上下文管理三原则

| 原则 | 说明 |
|------|------|
| 可见性 | 计划必须可见，状态必须可跟踪 |
| 隔离性 | 进程隔离 = 上下文隔离 |
| 渐进式 | 按需加载，优先元数据 |

### 上下文退化

上下文质量在 **20-40%** 时就开始下降，不是等到 100%。用外部记忆和作用域对话来缓解。

---

## 工作流规范

### 核心原则：先思考再打字

> **永远不要让 Claude 写代码，直到你审查并批准了书面计划。**

### 标准工作流

```
研究 → 规划 → 注解循环 → 实现 → 反馈
```

### 研究阶段

- 要求深入阅读相关代码，深刻理解工作原理
- 必须将发现写入 `research.md`
- 使用 "deeply"、"in great details"、"intricacies" 等词汇，否则会 skim

### 规划阶段

- 使用 Shift + Tab 进入规划模式
- 计划写入 `plan.md`，包含：
  - 方法的详细解释
  - 代码片段
  - 将被修改的文件路径
  - 注意事项和权衡

### 注解循环

- 在计划中添加内联注释
- 使用 "先不要实现" 明确守卫
- 纠正假设、拒绝方法、添加约束
- 迭代直到计划正确

### 实现阶段

- 标准提示："全部实现，在计划文档中标记为完成"
- 不要添加不必要的注释或 jsdocs
- 不要使用 any 或 unknown 类型
- 持续运行类型检查

---

## Prompt 规范

### 核心原则

| 原则 | 说明 |
|------|------|
| 具体 > 模糊 | 详细说明你想要什么 |
| 约束 > 开放式 | 告诉它不要做什么 |
| 例子 > 描述 | 给出最小示例 |
| 说原因 | 告诉它为什么，有助于理解上下文 |

### 示例

| 模糊 | 清晰 |
|------|------|
| "帮我写个功能" | "Build email/password authentication using the existing User model, store sessions in Redis with 24-hour expiry" |
| - | "Keep this simple. Don't add abstractions I didn't ask for. One file if possible." |

### 输出 = 输入

如果输出烂，输入就烂。没有捷径。

---

## 代码规范

### 本项目使用

- **语言**: Pure Bash + DeepSeek API
- **JSON 处理**: jq
- **API**: DeepSeek (Anthropic 兼容格式)

### 四个基本工具

| 工具 | 用途 |
|------|------|
| bash | 执行 shell 命令 |
| read_file | 读取文件内容 |
| write_file | 创建或覆盖文件 |
| edit_file | 精确修改文件 |

### 安全机制

- 路径隔离 (`safe_path()`)
- 危险命令过滤
- 输出截断 (50KB)
- 命令超时控制 (60秒)

---

## Agent 设计范式

### 范式一：最小可用

- 单轮触发、线性流程、无状态
- 适合：简单问答、资料查询

### 范式二：工作流式

- 预定义流程、确定性执行、适合复杂业务
- 适合：客服对话、审批流程

### 范式三：动态规划

- 运行时决策、灵活应变、可能失控
- 适合：复杂任务、探索性工作

---

## 工程实践要点

1. **从最小可用范式开始** - 渐进式复杂，遵循奥卡姆剃刀
2. **混合架构更稳** - 工作流外壳 + 智能内核 + 知识管理
3. **稳定比智能更重要** - 准确率 85% 但可预测 > 95% 但随机
4. **无评估不迭代** - 不能凭感觉，要数据说话

---

## 文件命名规范

- Series 文章: `序号-标题.md` (如 `01-ai-usage-guide.md`)
- 计划文件: `plan.md`
- 研究文件: `research.md`
- 临时笔记: `SCRATCHPAD.md`

---

## 持续更新

> 每次纠正同样的问题两次，就记录到本文件。

本 AGENT.md 随着项目发展持续更新。按 # 键可以让 Claude 自动添加指令。
