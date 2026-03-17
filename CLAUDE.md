> 本项目是 AI Agent 学习仓库。

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
├── series/                   # AI 学习系列文章 (26篇)
│   ├── 01-beginner/          # 入门阶段 (5篇)
│   ├── 02-intermediate/      # 进阶阶段 (11篇)
│   ├── 03-advanced/         # 高级阶段 (10篇)
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

## 文件命名规范

- Series 文章: `序号-标题.md`
- 计划文件: `plan.md`
- 研究文件: `research.md`

## 附加规则

### 1. 默认进入规划模式（Plan Mode）
- 对于任何非简单任务（3 个以上步骤或涉及架构决策）必须进入规划模式
- 如果事情偏离方向，立即停止并重新规划 —— 不要硬推
- 规划模式不仅用于构建，也用于验证步骤
- 事先写出详细规格说明，减少歧义

### 2. 子代理策略（Subagent Strategy）
- 大量使用子代理，保持主上下文窗口干净
- 将调研、探索和并行分析任务交给子代理
- 对于复杂问题，通过子代理投入更多计算资源
- 每个子代理只处理一个任务，确保专注执行

### 3. 自我改进循环（Self-Improvement Loop）
- 每次用户提出任何修正后：按照模式更新 `tasks/lessons.md`
- 为自己编写规则，防止重复犯同样的错误
- 持续严格迭代这些经验，直到错误率下降
- 在每次会话开始时，回顾与当前项目相关的经验
