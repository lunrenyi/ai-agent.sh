# CLAUDE.md 最佳实践：让 AI 真正理解你的项目

> 本文整合了官方文档、HumanLayer 实践和社区经验，系统讲解如何编写高效的 CLAUDE.md 文件

---

## TL;DR

| 原则 | 核心要点 |
|------|----------|
| 少即是多 | 指令越少越好，最多 150-200 条 |
| 普遍适用 | 只写每次对话都需要的规则 |
| 渐进式披露 | 任务特定信息放在单独文件 |
| 别让 Claude 当 linter | 用工具而非人工检查代码风格 |
| 持续迭代 | 定期修剪，删除已失效的规则 |

---

## 一、CLAUDE.md 的本质

### 1.1 核心问题：LLM 是无状态的

LLM 是无状态函数——它们的权重在使用时已经冻结，不会随着时间学习。模型只知道你输入的 token。

**这意味着三个关键事实：**

1. **编码 Agent 在每个会话开始时对你的代码库一无所知**
2. **必须每次告诉 Agent 代码库的重要信息**
3. **CLAUDE.md 是完成这一任务的首选方式**

Claude Code 会注入系统提醒：「此上下文可能与你的任务相关，也可能不相关。你不应该回复此上下文，除非它与你的任务高度相关。」

这解释了为什么：**CLAUDE.md 越长，Claude 越容易忽略它**。

### 1.2 CLAUDE.md 应该包含什么

CLAUDE.md 负责将 Claude 接入你的代码库，应涵盖：

| 维度 | 内容示例 |
|------|----------|
| **WHAT** | 技术栈、项目结构、代码库地图（对 monorepo 尤为重要） |
| **WHY** | 项目的目的、各部分的功能 |
| **HOW** | 如何运行项目（用 bun 还是 node？如何验证修改？如何运行测试？） |

---

## 二、核心原则：指令越少越好

### 2.1 研究表明

- 前沿思维模型可以一致遵循约 **150-200 条指令**
- 小模型表现下降呈**指数级衰退**
- LLM 对提示**开头和结尾**的指令偏重
- 指令数量增加时，遵循质量会**均匀下降**
- Claude Code 系统提示已包含约 **50 条指令**

### 2.2 实践建议

| ✅ 应该 | ❌ 不应该 |
|--------|----------|
| Bash 命令（Claude 无法猜测的） | Claude 可以从代码中推断的内容 |
| 代码风格规则（与默认不同的） | 标准语言约定 |
| 测试说明和首选测试运行器 | 详细 API 文档（链接到文档即可） |
| 仓库规范（分支命名、PR 约定） | 频繁变化的信息 |
| 项目特定的架构决策 | 代码库的逐文件描述 |
| 开发者环境怪癖（必需的环境变量） | 长篇解释或教程 |
| 常见陷阱或非显而易见的行为 | 不言自明的实践（如「写干净代码」） |

### 2.3 简单示例

```markdown
# 代码风格
- 使用 ES modules (import/export) 语法，不用 CommonJS (require)
- 尽量解构导入 (如 import { foo } from 'bar')

# 工作流
- 完成后务必进行类型检查
- 为性能考虑，优先运行单个测试而非整个测试套件
```

---

## 三、高级技巧

### 3.1 层级文件结构

为大型项目在子目录创建独立的 CLAUDE.md 文件，Claude 仅在相关子目录工作时加载对应规则。

```
project/
├── CLAUDE.md              # 根目录规则
├── frontend/
│   └── CLAUDE.md          # 前端特定规则
├── backend/
│   └── CLAUDE.md          # 后端特定规则
└── docs/
    └── CLAUDE.md          # 文档相关规则
```

**加载优先级**：
- 根目录 CLAUDE.md 总是被加载
- 子目录 CLAUDE.md 在 Claude 处理该目录文件时自动加载

### 3.2 渐进式披露

将任务特定指令保存在单独的文件中：

```
agent_docs/
  |- building_the_project.md
  |- running_tests.md
  |- code_conventions.md
  |- service_architecture.md
  |- database_schema.md
  └- service_communication_patterns.md
```

在 CLAUDE.md 中列出这些文件及简要描述，让 Claude 自行判断需要读取哪些。

```markdown
# 项目文档
- 构建项目: @docs/building.md
- 运行测试: @docs/testing.md
- 代码规范: @docs/conventions.md
```

### 3.3 使用 @ 引用文件

不要描述文件在哪里，用 `@` 直接引用：

| ❌ 不好 | ✅ 更好 |
|--------|--------|
| "查看 src/auth 目录下的登录逻辑" | "查看 @src/auth/login.ts 中的登录逻辑" |

### 3.4 别让 Claude 当 linter

**核心原则**：绝不要把代码风格指南放进 CLAUDE.md

原因：
- LLM 比传统 linter 和格式化工具**昂贵且缓慢得多**
- LLM 是**上下文学习者**，会自然遵循现有代码模式
- 使用 Claude Code 的 **Stop hook** 运行格式化工具和 linter

正确做法：
```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matchers": ["Edit", "Write"],
        "hooks": [{ "type": "command", "command": "prettier --write" }]
      }
    ]
  }
}
```

### 3.5 导入外部文件

CLAUDE.md 可以使用 `@path/to/file` 语法导入其他文件：

```markdown
项目概述见 @README.md，npm 命令见 @package.json。

# 额外说明
- Git 工作流: @docs/git-instructions.md
- 个人覆盖: @~/.claude/my-project-instructions.md
```

### 3.6 自定义斜杠命令

将复杂常用指令存为 Markdown 文件，用 `/命令名` 触发。

在 `.claude/skills/` 目录创建 skill 文件：

```markdown
---
name: fix-issue
description: 修复 GitHub issue
disable-model-invocation: true
---
分析并修复 GitHub issue: $ARGUMENTS。

1. 使用 `gh issue view` 获取 issue 详情
2. 理解问题描述
3. 搜索相关文件
4. 实现修复
5. 编写并运行测试验证
6. 确保代码通过 lint 和类型检查
7. 创建描述性提交信息
8. 推送并创建 PR
```

运行 `/fix-issue 123` 即可触发。

### 3.7 定义专业 AI 代理

在 `.claude/agents/` 目录创建专业代理：

```markdown
---
name: security-reviewer
description: 代码安全审查
tools: Read, Grep, Glob, Bash
model: opus
---
你是资深安全工程师。审查代码中的：
- 注入漏洞（SQL、XSS、命令注入）
- 认证和授权缺陷
- 代码中的密钥或凭证
- 不安全的数据处理

提供具体行号引用和建议修复方案。
```

---

## 四、常见错误

### 4.1 过度冗长的 CLAUDE.md

如果你的 CLAUDE.md 太长，Claude 会忽略一半内容，因为重要规则在噪音中丢失了。

**修复**：无情修剪。如果 Claude 在没有指令的情况下已经正确做了某事，删除该指令或将其转换为 hook。

### 4.2 包含频繁变化的信息

不要在 CLAUDE.md 中放经常变化的内容（如依赖版本、配置值），这会导致每次会话都要更新。

### 4.3 过度依赖自动生成

不要直接使用 `/init` 自动生成的 CLAUDE.md 而不加修改。/init 只是起点，应该仔细斟酌每一行内容，因为 CLAUDE.md 影响工作流的每个阶段和每个产物——它是**最高杠杆点**。

---

## 五、验证与迭代

### 5.1 如何判断 CLAUDE.md 是否有效

| 现象 | 说明 |
|------|------|
| Claude 持续做你不想做的事 | 规则可能被淹没在噪音中 |
| Claude 问 CLAUDE.md 中已回答的问题 | 表述可能不清晰 |

### 5.2 迭代建议

1. **像对待代码一样对待 CLAUDE.md**——当出问题时要审查
2. **定期修剪**——删除已失效的规则
3. **测试变化**——通过观察 Claude 的行为是否真正改变来验证
4. **提交到 git**——让团队成员也能贡献

### 5.3 长度参考

| 项目类型 | 推荐行数 |
|----------|----------|
| 小型项目 | < 30 行 |
| 中型项目 | 30-60 行 |
| 大型项目 | < 100 行（使用渐进式披露） |

---

## 六、总结

1. **CLAUDE.md 是接入 Claude 的入口**，定义项目的 WHAT、WHY 和 HOW
2. **指令越少越好**——LLM 遵循能力有限
3. **保持简洁且普遍适用**——只在每次对话都需要时使用
4. **渐进式披露**——告诉 Claude 如何找到信息，而非一次性告知
5. **用工具而非人工**——linter 和格式化工具更高效
6. **CLAUDE.md 是最高杠杆点**，值得仔细编写，持续迭代

---

## 参考来源

- [Claude Code 官方文档](https://code.claude.com/docs/en/best-practices#write-an-effective-claude-md)
- [HumanLayer: Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Kuanhao Huang: CLAUDE.md 高级技巧](https://kuanhaohuang.com/claude-code-claude-md-advanced-tips/)
