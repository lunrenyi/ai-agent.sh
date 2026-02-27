# AGENT.md

> 本项目是 AI Agent 学习仓库。

---

## 项目概述

- 技术栈: Pure Bash + DeepSeek API
- 核心理念: "模型即代理" —— 代理系统的核心不是代码，而是模型本身

---

## 项目结构

```
.
├── CLAUDE.md                  # Claude 项目配置文件
├── claude-code-quick-start.md # Claude Code 快速入门
├── claude_md_experience/     # Claude Code 使用经验收集
│   ├── cn.md
│   └── en.md
├── learn/                    # AI Agent 学习脚本（渐进式演进）
│   ├── v0_bash_agent.sh
│   ├── v1_basic_agent.sh
│   ├── v2_todo_agent.sh
│   ├── v3_subagent.sh
│   ├── v4_skills_agent.sh
│   └── README.md
├── series/                   # AI 学习系列文章
│   ├── 01-xx.md ~ 16-xx.md
│   └── README.md
├── news/                     # 新闻/报告系列
│   ├── 01-xx.md ~ 07-xx.md
│   └── README.md
├── cos/                      # 角色化 AI Agent（花火）
│   ├── sparkle.sh
│   ├── Sparkle.md
│   └── Sparkle/
└── idea/                     # 设计文档
    └── ai-agent.v1.md
```

---

## 工作流规范

**核心原则**: 先思考再打字

> 永远不要让 AI 写代码，直到你审查并批准了书面计划。

- **简单优先**: 让每一次改动尽可能简单，影响最小代码范围
- **拒绝懒惰**: 找到根本原因，避免临时修补，遵循资深工程师标准
- **最小影响**: 只修改必要部分，避免引入新的 bug

**标准流程**: `研究 → 规划 → 注解循环 → 实现 → 反馈`

- **研究**: 深入阅读相关代码，理解工作原理，将发现写入 `research.md`
- **规划**: 计划写入 `plan.md`，包含方法解释、代码片段、文件路径
- **注解循环**: 在计划中添加内联注释，迭代直到正确
- **实现**: 在计划文档中标记完成

**补充规则**:

- **规划模式**: 非简单任务（3+ 步骤或涉及架构决策）默认进入规划模式
- **子代理策略**: 复杂任务使用子代理处理调研和并行分析
- **完成前验证**: 问自己"资深工程师会批准吗？"——未证明可用前不标记完成
- **自主修复**: 收到 bug 报告直接修复，不要求手把手指导

---

## 上下文管理

| 原则 | 说明 |
|------|------|
| 可见性 | 计划必须可见，状态必须可跟踪 |
| 隔离性 | 进程隔离 = 上下文隔离 |
| 渐进式 | 按需加载，优先元数据 |

---

## 文件命名规范

- Series 文章: `序号-标题.md`
- 计划文件: `plan.md`
- 研究文件: `research.md`

---

## 渐进式披露

详细说明请参考:
- `@learn/README.md` - 学习指南
- `@series/08-claude-md-best-practices.md` - CLAUDE.md 最佳实践
