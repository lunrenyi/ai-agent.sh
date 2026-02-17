# CLAUDE.md

> 本项目是 AI Agent 学习仓库，用于探索和收集 AI Agent 的资料，提升对 AI Agent 的认知。

---

## 项目结构

```
.
├── learn/                   # AI Agent 学习脚本（渐进式演进）
│   ├── v0_bash_agent.sh    # V0: 极简单工具代理 (~150行)
│   ├── v1_basic_agent.sh   # V1: 4个基础工具代理 (~250行)
│   ├── v2_todo_agent.sh    # V2: 待办事项管理 (~350行)
│   ├── v3_subagent.sh      # V3: 子代理机制 (~450行)
│   ├── v4_skills_agent.sh  # V4: 技能系统 (~550行)
│   ├── .env                # 环境变量配置
│   └── README.md           # 学习指南
│
├── cos/                     # 角色化 AI Agent（花火/Sparkle）
│   ├── sparkle.sh          # 火花主脚本 (~605行)
│   ├── Sparkle.md          # 角色设定
│   └── Sparkle/            # ASCII 表情艺术
│
├── series/                  # AI 学习系列文章
│   ├── 01-ai-usage-guide.md
│   ├── 02-shell-skills-compaction-tips.md
│   ├── 03-openai-2025-developer-report.md
│   ├── 04-eval-skills-guide.md
│   ├── 05-chatgpt-apps-15-lessons.md
│   ├── 06-how-i-use-claude-code.md
│   └── 07-claude-code-beginner-playbook.md
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
```

### 上下文管理三原则

| 原则 | 说明 |
|------|------|
| 可见性 | 计划必须可见，状态必须可跟踪 |
| 隔离性 | 进程隔离 = 上下文隔离 |
| 渐进式 | 按需加载，优先元数据 |

---

## 工作流规范

### 核心原则：先思考再打字

**永远不要让 Claude 写代码，直到你审查并批准了书面计划。**

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

## 上下文管理

### 关键原则

- **作用域对话**：一个对话一个功能，不要混合任务
- **外部记忆**：复杂工作使用 `plan.md` 或 `SCRATCHPAD.md`
- **复制粘贴重置**：当上下文膨胀时 /compact + /clear + 粘贴重要内容
- **知道什么时候 clear**：失控时直接 /clear 开始新的

### 上下文退化

上下文质量在 **20-40%** 时就开始下降，不是等到 100%。用外部记忆和作用域对话来缓解。

---

## Prompt 规范

### 核心原则

- **具体 > 模糊**：详细说明你想要什么
- **约束 > 开放式**：告诉它不要做什么
- **例子 > 描述**：给出最小示例

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

### 工具定义

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

## 文件命名规范

- Series 文章: `序号-标题.md` (如 `01-ai-usage-guide.md`)
- 计划文件: `plan.md`
- 研究文件: `research.md`
- 临时笔记: `SCRATCHPAD.md`

---

## 持续更新

> 每次纠正同样的问题两次，就记录到本文件。

本 CLAUDE.md 随着项目发展持续更新。按 # 键可以让 Claude 自动添加指令。
