# Claude Code 内存管理完全指南

> 官方文档总结：自动记忆、CLAUDE.md、模块化规则、组织级内存管理

---

## TL;DR

| 内存类型 | 位置 | 用途 | 共享范围 |
|----------|------|------|----------|
| 托管策略 | `/etc/claude-code/CLAUDE.md` | IT/DevOps 管理的企业级规范 | 组织内所有用户 |
| 项目内存 | `./CLAUDE.md` 或 `./.claude/CLAUDE.md` | 团队共享的项目规范 | 团队成员（通过版本控制） |
| 项目规则 | `./.claude/rules/*.md` | 模块化的主题规范 | 团队成员 |
| 用户内存 | `~/.claude/CLAUDE.md` | 个人偏好设置 | 仅本人（所有项目） |
| 本地内存 | `./CLAUDE.local.md` | 个人项目偏好 | 仅本人（当前项目） |
| 自动记忆 | `~/.claude/projects/<project>/memory/` | Claude 自动记录的学习内容 | 仅本人（按项目隔离） |

**核心原则**：更具体的指令优先于更宽泛的指令。

---

## 一、两种内存类型

Claude Code 有两种持久化内存：

### 1.1 自动记忆（Auto Memory）

Claude 自动保存的有用上下文，如项目模式、关键命令、你的偏好。**与 CLAUDE.md 不同**，这是 Claude 为自己写的笔记，而非你为 Claude 编写的指令。

### 1.2 CLAUDE.md 文件

你编写和维护的 Markdown 文件，包含供 Claude 遵循的指令、规则和偏好。

> **注意**：CLAUDE.md 文件夹层次结构中高于工作目录的文件会在启动时完全加载。工作目录中的 CLAUDE.md 或 .claude/CLAUDE.md 只在启动时加载，自动记忆只加载 MEMORY.md 的前 200 行。

---

## 二、自动记忆详解

### 2.1 什么是自动记忆

自动记忆是 Claude 记录学习内容、模式和洞察的持久目录。与 CLAUDE.md（你为 Claude 写的指令）不同，自动记忆包含 Claude 基于会话中发现的内容为自己写的笔记。

### 2.2 Claude 会记住什么

* **项目模式**：构建命令、测试约定、代码风格偏好
* **调试洞察**：棘手问题的解决方案、常见错误原因
* **架构笔记**：关键文件、模块关系、重要抽象
* **你的偏好**：沟通风格、工作流程习惯、工具选择

### 2.3 存储位置

每个项目在 `~/.claude/projects/<project>/memory/` 有独立的记忆目录。`<project>` 路径从 Git 仓库根目录派生，因此同一仓库的所有子目录共享一个自动记忆目录。Git worktrees 有独立的记忆目录。

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 简洁索引，每次会话加载
├── debugging.md       # 调试模式详细笔记
├── api-conventions.md # API 设计决策
└── ...                # 其他 Claude 创建的主题文件
```

### 2.4 工作原理

* MEMORY.md 的前 200 行在每次会话开始时加载到 Claude 的系统提示中
* 超过 200 行的内容不会自动加载，Claude 会被指示保持简洁，将详细笔记移至单独的主题文件
* 主题文件（如 debugging.md）在需要时按需读取
* Claude 在会话期间读取和写入记忆文件

### 2.5 管理自动记忆

使用 `/memory` 命令打开文件选择器，可以编辑自动记忆文件或切换功能开关。

**告诉 Claude 记住特定内容**：
> "记住我们用 pnpm，不用 npm"
> "把本地 Redis 是 API 测试必需的记到记忆里"

**通过设置禁用**：

```json
// ~/.claude/settings.json
{
  "autoMemoryEnabled": false
}
```

```json
// .claude/settings.json（单项目）
{
  "autoMemoryEnabled": false
}
```

**环境变量覆盖**：
```bash
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1  # 强制关闭
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0  # 强制开启
```

---

## 三、CLAUDE.md 文件导入

### 3.1 导入语法

使用 `@path/to/import` 语法导入其他文件：

```
# 项目概述
参见 @README 获取项目概述，@package.json 获取可用的 npm 命令。

# 额外指令
- git 工作流 @docs/git-instructions.md
```

### 3.2 路径规则

* 相对路径相对于包含导入的文件解析，而非工作目录
* 递归导入最多 5 层深度

### 3.3 本地偏好文件

`CLAUDE.local.md`：
* 自动加载
* 自动添加到 `.gitignore`
* 适合不应提交到版本控制的个人项目偏好

**跨多个 Git Worktrees**：

使用 home-directory 导入，这样所有 worktrees 共享同一份个人指令：

```
# 个人偏好
- @~/.claude/my-project-instructions.md
```

> **警告**：首次在项目中遇到外部导入时，Claude 会显示批准对话框。批准后加载；拒绝则跳过，且不再显示此对话框。

---

## 四、模块化规则（.claude/rules/）

### 4.1 基础结构

```
your-project/
├── .claude/
│   ├── CLAUDE.md           # 主项目指令
│   └── rules/
│       ├── code-style.md   # 代码风格指南
│       ├── testing.md      # 测试约定
│       └── security.md     # 安全要求
```

`.claude/rules/` 中的所有 .md 文件自动加载为项目记忆，优先级与 `.claude/CLAUDE.md` 相同。

### 4.2 路径特定规则

使用 YAML frontmatter 的 `paths` 字段将规则限定于特定文件：

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API 开发规则

- 所有 API 端点必须包含输入验证
- 使用标准错误响应格式
- 包含 OpenAPI 文档注释
```

### 4.3 Glob 模式支持

| 模式 | 匹配 |
|------|------|
| `**/*.ts` | 任意目录下的所有 TypeScript 文件 |
| `src/**/*` | src/ 目录下的所有文件 |
| `*.md` | 项目根目录的 Markdown 文件 |
| `src/components/*.tsx` | 特定目录下的 React 组件 |

**大括号扩展**：
```markdown
---
paths:
  - "src/**/*.{ts,tsx}"
  - "{src,lib}/**/*.ts"
---
```

### 4.4 子目录组织

```
.claude/rules/
├── frontend/
│   ├── react.md
│   └── styles.md
├── backend/
│   ├── api.md
│   └── database.md
└── general.md
```

### 4.5 符号链接

支持符号链接，允许跨项目共享通用规则：

```bash
# 符号链接共享规则目录
ln -s ~/shared-claude-rules .claude/rules/shared

# 符号链接单个规则文件
ln -s ~/company-standards/security.md .claude/rules/security.md
```

### 4.6 用户级规则

在 `~/.claude/rules/` 创建适用于所有项目的个人规则：

```
~/.claude/rules/
├── preferences.md    # 个人编码偏好
└── workflows.md      # 偏好的工作流程
```

用户级规则在项目规则之前加载，项目规则优先级更高。

---

## 五、组织级内存管理

### 5.1 托管策略

组织可以部署集中管理的 CLAUDE.md 文件，应用于所有用户。

### 5.2 设置步骤

1. 在**托管策略**位置创建托管记忆文件（见上表）
2. 通过配置管理系统（MDM、Group Policy、Ansible 等）部署

---

## 六、最佳实践

| 原则 | 说明 |
|------|------|
| **具体明确** | "使用 2 空格缩进" 比 "正确格式化代码" 更好 |
| **结构化组织** | 每条记忆格式化为项目符号，相关记忆分组到描述性 Markdown 标题下 |
| **定期回顾** | 随着项目演进更新记忆，确保 Claude 始终使用最新信息 |

---

## 七、相关资源

* 官方文档：https://code.claude.com/docs/en/memory
* CLAUDE.md 最佳实践：见本系列第 04 篇文章
* Claude Code 工作原理：见本系列第 14 篇文章

