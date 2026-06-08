# 🔧 Claude Code 更新周报：v2.1.160 → v2.1.167

## 🔥 重点新功能

### 后备模型链（v2.1.166）—— 告别「模型过载」焦虑

这是本周期**最重要的功能更新**。新增 `fallbackModel` 设置，最多可配置 **3 个后备模型**，当主模型过载或不可用时按顺序自动切换。同时 `--fallback-model` 命令行参数现在也适用于交互式会话。

**实际价值**：如果你重度使用 Opus 4.8，高峰期遇到 API 过载不再需要手动切换模型，Claude Code 会自动降级到你指定的备选（比如先切 Opus 4.7，再切 Sonnet 4.6），且一回合后自动重试主模型。


### 强制版本管控（v2.1.163）—— 企业管理员福音

新增 `requiredMinimumVersion` 和 `requiredMaximumVersion` 托管设置。如果 Claude Code 版本不在允许范围内，**启动将被拒绝**并引导用户安装指定版本。对需要统一团队工具链版本的企业或组织来说，这是一个关键的管理能力。


### 工具权限支持 Glob 模式（v2.1.166）

deny 规则的 tool-name 位置现在支持 glob 模式。使用 `"*"` 可**禁用所有工具**（配合精细的 allow 规则使用）。未知的工具名称在 deny 规则中会触发启动警告，防止拼写错误导致安全策略失效。


### Shell 启动文件写入保护（v2.1.160）

写入 `.zshenv`、`.zlogin`、`.bash_login` 和 `~/.config/git/` 等 shell 启动文件前，Claude Code 现在会**弹出确认提示**。在 `acceptEdits` 模式下，对 `.npmrc`、`.yarnrc*`、`bunfig.toml`、`.bazelrc`、`.pre-commit-config.yaml`、`.devcontainer/` 等会触发代码执行的文件也会主动提示——防止 AI 意外修改你的安全边界。


### Thinking 可彻底关闭（v2.1.166）

`MAX_THINKING_TOKENS=0`、`--thinking disabled`、以及按模型的 thinking 开关现在可以**对默认启用 thinking 的模型关闭 thinking**（通过 Claude API 原生支持）。这对于不需要深度推理的场景可以节约大量 token 成本。


## ⚡ 用户体验改进

### 启动体验全面优化（v2.1.162）

一次启动体验的集中整治：

- **启动更快、更安静**：通知按严重程度分组，会话信息和公告共享一行
- **启动警告更短更清晰**，每条附带具体修复建议
- **预填提示词警告**（如深度链接）现在固定显示在输入框下方而不是滚走
- **失败回合**显示紧凑的警告行，不再占据大片红色错误块
- 移除了「Claude in Chrome enabled」「marketplace installed」等冗余启动消息
- 新二进制文件的启动验证会**等待端点安全扫描**完成，而不是 5 秒后直接失败


### 错误重试机制（v2.1.166）

遇到 API 返回非预期的不可重试错误时，Claude Code 现在会**自动在 fallback 模型上重试一次**。认证错误、速率限制、请求过大、传输错误等已知类型仍立即报错（重试无意义）。

### `/btw` 一键复制（v2.1.163）

`/btw` 面板新增 `c to copy` 快捷键，**直接复制原始 Markdown 回答到剪贴板**，粘贴到其他地方时保留完整格式。这解决了一个高频痛点：`/btw` 的好答案想分享给别人需要手动复制。

---

## 🤖 Agent 与后台会话

### `--fallback-model` 覆盖交互式会话（v2.1.166）

此前 `--fallback-model` 仅用于 headless 模式，现在**交互式会话也支持**——启动时指定一次，整个会话受益。

### 并行工具调用独立性修复（v2.1.161）

并行工具调用中，**一个 Bash 命令失败不再取消同一批次的其他调用**——每个工具独立返回结果。对于使用多工具并行执行的复杂 agent 工作流，这大幅提升了鲁棒性。

### Hook 增强：`additionalContext` 反馈（v2.1.163）

Stop 和 SubagentStop hooks 现在可以返回 `hookSpecificOutput.additionalContext`，向 Claude 提供上下文反馈而**不被标记为 hook 错误**，让 hook 和 agent 的交互更加流畅。

### 诸多 Agent 体验修复

- `claude agents --json` 新增 `waitingFor` 字段，显示等待中的会话在等什么（v2.1.162）
- Agent 列表行现在显示 `done/total` 进度（v2.1.161）
- 后台 agent 会话在后台静默更新到新版本，无需冷重启等待（v2.1.163）
- 修复了跨会话消息（`SendMessage`）因深层目录导致静默失败（v2.1.162）
- 修复了从 agents 列表打开运行中的后台会话会卡顿 5 秒（v2.1.162）
- 修复了后台会话重连后丢失对话历史、重跑原始 prompt（v2.1.160）

---

## 🐛 关键 Bug 修复

### 安全与权限

| 修复 | 版本 |
|------|------|
| **跨会话消息安全加固**：从其他 Claude 会话经由 `SendMessage` 转发来的消息不再携带用户权限——接收方拒绝转发来的权限请求，auto 模式直接阻止 | v2.1.166 |
| **WebFetch 权限规则**：显式 `WebFetch(domain:...)` deny/ask/allow 规则现在优先于内置预批准域名自动放行 | v2.1.162 |
| **Windows 权限规则**：反斜杠路径（`~\`、`\\server\share`）和大写变体路径现在正确匹配；Read deny 规则会从 Glob/Grep 结果中隐藏文件 | v2.1.162 |
| **Home 目录 deny 规则**：`Read(~/Desktop/**)` 类 deny 规则现在也会阻止通过 `$HOME` 引用该路径的 Bash 命令 | v2.1.163 |
| **托管设置不合规**：存在无效条目的托管设置不再静默禁用其余有效策略 | v2.1.166 |
| **托管设置 `allowedMcpServers`/`deniedMcpServers`**：现在正确匹配使用 `${VAR}` 引用的谓词 | v2.1.166 |

### 功能可靠性

| 修复 | 版本 |
|------|------|
| **`claude -p` 永久挂起**：当后台命令不退出时不再无限等待，stdin 关闭后约 5 秒自动停止 | v2.1.163 |
| **`claude -p` 非 Anthropic API 失败**：Bedrock/Vertex/Foundry 上 `CI=true` 时不再报 "ANTHROPIC_API_KEY required" | v2.1.163 |
| **`$TMPDIR` 回归修复**：2.1.154 引入的回归问题——`$TMPDIR` 对所有命令都被覆盖为 `/tmp/claude-{uid}` 而不仅仅是沙箱命令——已修复，bazel 和 EDR 保护的 Go 工作流恢复正常 | v2.1.163 |
| **只读配置目录**：不再启动静默挂起，改用内存配置启动并显示错误信息 | v2.1.162 |
| **远程会话「卡死」**：后台服务启动时短暂中断不再导致远程会话永久卡住 | v2.1.166 |
| **工作树后台会话崩溃循环**：从 `claude agents` 重开会话不再因 "No conversation found" 崩溃循环 | v2.1.166 |
| **`/autofix-pr` 工作树误判**：在 git worktree 或别的仓库里不再错误报告 "cannot run on the default branch" | v2.1.161 |
| **voice mode 连接失败**：项目目录或分支名包含非 ASCII/特殊字符时不再连接失败 | v2.1.160 |

### 终端兼容性

| 修复 | 版本 |
|------|------|
| **JetBrains IDE 终端闪烁**（IntelliJ、PyCharm、WebStorm 等 2026.1+）——启用同步输出 | v2.1.166 |
| **Kitty 键盘协议**：`Shift+ä → Ä` 等组合键在 WezTerm、Ghostty、kitty 中不再丢失 | v2.1.166 |
| **PowerShell 命令验证挂起**：Windows 上被 kill 进程的子进程持有输出管道导致的超时 | v2.1.166 |
| **WSL 剪贴板**：复制选中文本现在通过 PowerShell 互操作而非 OSC 52，兼容 MobaXterm | v2.1.160 |
| **CJK IME 组合**：在 `claude agents` 视图中不再出现在屏幕左下角错误位置 | v2.1.160 |


## 💡 升级建议

- **重度用户 / 依赖 Opus 4.8**：v2.1.166 的 `fallbackModel` 值得立即升级，高峰期可用性显著提升
- **企业 / 团队管理员**：v2.1.163 的强制版本管控和 v2.1.166 的托管设置 glob 匹配解决了关键的治理痛点
- **Windows 用户**：v2.1.162 和 v2.1.166 修复了大量 Windows 特有问题（路径匹配、PowerShell 挂起、剪贴板等）
- **关注安全性**：v2.1.160 和 v2.1.166 在多个维度强化了安全边界（启动文件保护、跨会话隔离、权限规则修复）
- **所有用户**：v2.1.166 的 thinking 关闭选项可以帮你省下一大笔 token 费用

---

*本日报整理自 [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)，选取对用户影响较大的变更进行解读。Bug 修复和可靠性改进的完整列表请查阅原 CHANGELOG。*

*🤖 本文由 Claude 辅助整理与撰写*
