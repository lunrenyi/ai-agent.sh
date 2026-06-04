# Claude Code 更新日报：v2.1.160 & v2.1.161

*Claude Code 版本更新速览 — 2026年6月3日*

---

**本期看点：** `workflow` 关键字正式退役，`ultracode` 接棒；安全写入机制全面增强；后台会话稳定性大幅提升；可观测性迎来新维度。

---

## 🔥 头条：Dynamic Workflow 触发词变更（v2.1.160）

**`workflow` → `ultracode`，这是一个破坏性变更。**

如果你想通过关键字触发并行子代理并行执行，以前写 `workflow` 就可以，现在必须写 **`ultracode`**。所有脚本化 prompt 中硬编码了 `workflow` 的地方都需要迁移。

不过别慌——用自然语言说「请并行执行」仍然有效，分类器会正常识别意图。此外，`/effort ultracode` 成为推荐的显式指定方式，并且在 prompt 输入框中 `ultracode` 关键字会以 **紫色（violet）** 高亮显示。

> ⚠️ **迁移建议**：检查你的 `.claude/settings.json`、hook 脚本和自定义 prompt 中是否包含 `workflow` 关键字，替换为 `ultracode`。

📎 [Source: GitHub Release v2.1.160](https://github.com/anthropics/claude-code/releases/tag/v2.1.160)

---

## 🔒 安全强化（v2.1.160）

本次更新对文件写入权限做了两层收紧：

1. **Shell 启动文件写入前需确认** — 向 `.zshenv`、`.zlogin`、`.bash_login` 等 shell 启动文件和 `~/.config/git/` 目录写入前，Claude Code 会弹出确认提示，防止意外的命令注入。

2. **`acceptEdits` 模式也不放过构建配置文件** — 即使在 `acceptEdits` 自动批准编辑模式下，以下文件的写入仍会强制要求人工确认：
   - `.npmrc`、`.yarnrc*`、`bunfig.toml`
   - `.bazelrc`、`.pre-commit-config.yaml`
   - `.devcontainer/` 目录下的所有文件

   这些文件可以注入任意代码执行，现在有了专门的保护。

---

## ⚡ 效率提升

- **grep 后直接编辑，无需 Read**（v2.1.160）— 用 `grep`/`egrep`/`fgrep` 浏览单个文件后，不再需要额外的 `Read` 调用来解锁编辑权限，read-before-edit 校验现在识别 grep 的文件访问记录。

- **并行工具调用容错**（v2.1.161）— 同一批次的并行工具调用中，单个 Bash 命令失败不再取消其他调用，每个工具各自独立返回结果。

- **终端渲染性能优化**（v2.1.161）— 稳定了布局引擎的 JIT 编译配置，大文件写入的渲染性能也得到改善。

- **Auto 模式分类器延迟降低**（v2.1.160）— 减少了日常操作上的推理开销，降低「无法评估此操作」的误拦截概率。

---

## 🤖 后台会话 & Agent 管理

两个版本在后台会话方面集中修复了大量问题：

| 修复项 | 版本 |
|--------|------|
| `claude agents` 完成的会话恢复时聊天历史丢失 | v2.1.160 |
| 后台会话隔夜重连后对话丢失并重新执行原始 prompt | v2.1.160 |
| `claude --bg` 在机器高负载时因 socket 缺失冷启动失败 | v2.1.160 |
| `claude agents` 返回列表时因自动更新检查导致冻结数秒 | v2.1.160 |
| 后台 agent 在工作树隔离模式下无法编辑文件 | v2.1.161 |
| 后台会话从 agents 列表启动时使用了守护进程的过时模型配置 | v2.1.161 |
| 最近非活跃会话的打开性能得到改善 | v2.1.160 |
| 后台会话退出时发送 SIGTERM 后再 SIGKILL，确保清理逻辑运行 | v2.1.160 |

**新增功能：**
- `claude agents` 行展示 **done/total** 进度（v2.1.161）— 当工作被派发到多个子代理时，直接看到完成情况，peek 显示耗时最长的任务。
- `/mcp` 命令现在折叠从未登录过的 claude.ai 连接器（v2.1.161）。

---

## 🖥️ 终端与平台兼容性

### Windows / WSL 修复（v2.1.160）
- WSL 下的复选复制改用 **PowerShell 互操作**代替 OSC 52，解决 MobaXterm 等终端的剪贴板问题
- 高 CPU 负载时，后台会话附加或 agent 视图中的 Esc、方向键、键盘输入不再卡死
- `file:///C:/...` 链接在支持超链接的终端上不再被错误重写

### Linux 剪贴板增强（v2.1.161）
- 全屏模式下剪贴板优先使用 `wl-copy`/`xclip`/`xsel`
- 同时写入剪贴板和 PRIMARY 选区，支持中键粘贴
- 「按住 {key} 使用原生选区」提示现在能正确显示对应终端的按键

### 其他终端修复
- 日语 IME 输入法候选框不再跑到屏幕左下角（v2.1.160）
- 语音模式在非 ASCII 项目路径或分支名中不再连接失败（v2.1.160）
- VSCode 端新增提示：建议禁用终端 GPU 加速来修复乱码问题（v2.1.161）

---

## 📊 可观测性 & 遥测（v2.1.161）

- **`OTEL_RESOURCE_ATTRIBUTES` 值现在作为标签注入到指标数据点** — 这意味着你可以按 `team`、`repo` 等自定义维度切分使用量指标，对于企业级部署和多团队管理非常实用。
- 修复了 OpenTelemetry 日志事件（`user_prompt`、`api_request`、`tool_result`、`tool_decision`）在遥测初始化完成前被静默丢弃的问题。

---

## 🐛 其他值得关注的修复

| 修复项 | 版本 |
|--------|------|
| `/effort ultracode` 在模型不支持 xhigh 时不再错误提示检查 workflow 设置 | v2.1.160 |
| 第三方提供商（Bedrock/Vertex/Foundry）的 auto 模式不可用消息现在正确指向 `CLAUDE_CODE_ENABLE_AUTO_MODE` 开关 | v2.1.160 |
| `forceLoginOrgUUID`/`forceLoginMethod` 托管策略不再错误拦截第三方提供商会话 | v2.1.161 |
| vim 模式 `p` 粘贴从寄存器 `v$` 复制的内容时，现在粘贴到光标位置而非下一行 | v2.1.160 |
| brief 模式关闭后恢复会话时，过去的回复不再从滚动历史中消失 | v2.1.160 |
| `/usage-credits` 对 Team/Enterprise 管理员现在正确跳转到组织的使用量设置页 | v2.1.161 |
| `/autofix-pr` 在非 git 仓库默认分支（如 git worktree 或 jj workspace）中不再误报错误 | v2.1.161 |
| Windows hook 显式调用 bash 脚本不再失败 | v2.1.161 |
| `claude mcp list/get/add` 不再泄露密码：`${VAR}` 引用不再被展开，凭证头和 URL 密钥被遮蔽 | v2.1.161 |
| `EADDRINUSE` 错误在 `CLAUDE_CODE_TMPDIR` 设为深层路径时不再出现 | v2.1.161 |
| `/effort` 对话框、workflow 动画、prompt 关键字闪光现在遵守「减少动画」设置 | v2.1.161 |

---

## 🗑️ 移除项（v2.1.160）

- **`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`** 环境变量变为 no-op（无操作），不再有效
- **JetBrains 插件安装建议** 从启动提示中移除

---

## 📝 升级建议

| 优先级 | 操作 |
|--------|------|
| 🔴 **高** | 检查并迁移所有脚本中的 `workflow` 关键字 → `ultracode` |
| 🟡 **中** | 如果你的团队使用 OpenTelemetry，可配置 `OTEL_RESOURCE_ATTRIBUTES` 实现按团队/仓库的用量切分 |
| 🟢 **低** | 确认 shell 启动文件和构建配置文件（`.npmrc` 等）的写入策略是否受影响 |

---

*本日报整理自 [Claude Code v2.1.160](https://github.com/anthropics/claude-code/releases/tag/v2.1.160) 和 [v2.1.161](https://github.com/anthropics/claude-code/releases/tag/v2.1.161) 官方 Release Notes。*
*所有信息均来自公开的 GitHub Release 记录。*
