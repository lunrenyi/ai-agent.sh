# 🤖 Claude Code 更新日报

*追踪 Claude Code 每个版本的变更，精选开发者最该关注的特性与修复 — 2026年6月29日*

---

**今日看点：本期覆盖 Claude Code `2.1.178 → 2.1.195` 共 11 个已发布版本（`2.1.180 / 2.1.182 / 2.1.184 / 2.1.188 / 2.1.189 / 2.1.192 / 2.1.194` 未单独发布，已跳过）。一句话概括这十一版的四个核心信号——① Agent Teams 架构从"手动建队"进化为**隐式团队**，spawn 即用；② Auto Mode 安全边界全面升级：**破坏性 git 命令默认拦截**，且可覆盖全部 Shell 命令；③ `/rewind` 登场 + 流式渲染 CPU **降低 ~37%**，交互体验大幅跃升；④ MCP 工具链走向成熟：CLI 登录/登出、远程超时保护、OAuth 自动重连，不再只依赖 TUI。此外，`Tool(param:value)` 细粒度权限、`/config key=value` 命令行设配置、`!` bash 自动回复、背景子代理权限提示等一批"日常提效"功能也值得立即上手。**

> 文末附 **"新版 Claude Code 还能接 DeepSeek 吗？"** 专题解答。

---

## 🔥 头条深度

### 1. Agent Teams 简化 + 细粒度权限（v2.1.178）——"建队"这件事从两步变零步

`2.1.178` 是本期版本跨度最大的一版（25+ 项变更），头两条就改变了 Agent 协作的基本范式：

**① Agent Teams：从显式创建到隐式就绪**

> Agent teams: removed the `TeamCreate` and `TeamDelete` tools. With `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, every session now has one implicit team — spawn teammates directly with the Agent tool's `name` parameter.

此前要使用 Agent Teams，必须先调 `TeamCreate` 创建团队、再 spawn 成员——两步操作。现在设置环境变量后，每个会话自动拥有一个隐式团队，直接用 `Agent(name:xxx)` spawn 队友即可。这是从"手动搭架子"到"开箱即用"的关键简化。

**② `Tool(param:value)` 细粒度权限规则**

> Added `Tool(param:value)` syntax for permission rules to match a tool's input parameters (with `*` wildcard), e.g. `Agent(model:opus)` to block Opus subagents.

权限规则现在可以匹配工具的**输入参数**，不只是工具名。比如：
- `Agent(model:opus)` — 禁止用 Opus 模型 spawn 子代理
- `Bash(command:rm *)` — 禁止 Bash 执行 rm 命令

这比之前只能按工具类型做 deny/allow 精细了一个维度。

**③ 嵌套 `.claude/` 目录支持**

子目录中的 `.claude/skills/` 和 `.claude/` 配置现在会被自动加载。名称冲突时，离工作目录最近的优先，嵌套 skill 以 `<dir>:<name>` 区分。这对 monorepo 场景——每个子项目有自己的 CLAUDE.md/skills/workflows——非常实用。

**④ 其他亮点**：
- 子代理 spawn 现在**先过 auto mode 分类器**再启动——堵住了"子代理绕过权限检查"的侧门
- `/doctor` 全面改版：统一平面树布局、更清晰的状态图标
- workflow 触发词改为**紫色微光高亮**，只在显式短语（如 "run a workflow"）时触发
- 大量修复：OOM crash（stale websocket fd）、Claude in Chrome OAuth 不匹配、vim `u` 撤销粒度、compaction 不遵循 `--fallback-model` 等

📎 [GitHub Release v2.1.178](https://github.com/anthropics/claude-code/releases/tag/v2.1.178)

---

### 2. Auto Mode 安全三连升级（v2.1.183 / v2.1.193）——从"选择性拦截"到"全量覆盖"

这是本期对**所有用户**影响最大的一条安全线：

**v2.1.183：破坏性命令默认拦截**

Auto mode 下以下命令**自动拦截**，除非用户明确要求：
| 场景 | 拦截的命令 |
|------|-----------|
| 丢弃本地修改 | `git reset --hard`, `git checkout -- .`, `git clean -fd`, `git stash drop` |
| 修改他人 commit | `git commit --amend`（commit 不是当前会话的 agent 创建的） |
| 销毁基础设施 | `terraform destroy`, `pulumi destroy`, `cdk destroy`（除非指定了具体 stack） |

这些拦截不需要你配置任何规则——Claude Code 内置了对"高危操作用户意图不匹配"的判断逻辑。这对开着 auto mode 跑后台任务的用户尤其关键——不会一觉醒来发现 `git clean -fd` 把未提交代码全删了。

**v2.1.183 配套**：
- 模型弃用警告：当请求的模型已被弃用或自动升级到新模型时，`-p` 模式输出到 stderr，且覆盖 agent frontmatter 中设置的模型
- `/config` 交互改进：Enter/Space 切换，**Esc 保存并关闭**（不再是放弃修改）
- `/config --help` 列出所有缩写键

**v2.1.193：所有 Shell 命令过分类器**

> Added `autoMode.classifyAllShell` setting to route all Bash/PowerShell commands through the auto-mode classifier instead of only arbitrary-code-execution patterns.

此前 auto mode 只对"看起来像代码执行"的 shell 命令走分类器。现在可以配置为**所有 Bash/PowerShell 命令**都过分类器——这意味着即使是非代码执行的命令（如 `curl`、`cat ~/.ssh/id_rsa`）也会被审查。

**同时 v2.1.193 把拒绝原因写进了 transcript、toast 通知和 `/permissions` 面板**——以前只知道"被拒绝了"，现在知道"为什么被拒绝"。

**大图景**：从 v2.1.183 的"硬编码高危命令拦截"到 v2.1.193 的"可配置全量覆盖 + 拒绝原因透明化"，Claude Code 的 auto mode 安全模型在两周内从 v0.5 走到了 v2.0。

📎 [GitHub Release v2.1.183](https://github.com/anthropics/claude-code/releases/tag/v2.1.183) · [v2.1.193](https://github.com/anthropics/claude-code/releases/tag/v2.1.193)

---

### 3. `/rewind` 登场 + CPU 降低 ~37%（v2.1.191）——本期交互体验最大的一个版本

`2.1.191` 是本期的"暗藏大招"版本——没有新模型、没有架构变更，但每一项都直接提升日常使用体验：

**① `/rewind`：从 `/clear` 前恢复会话**

> Added `/rewind` support for resuming a conversation from before `/clear` was run.

`/clear` 之后发现"其实还需要刚才的上下文"？`/rewind` 一键回到 `/clear` 之前。这是一个高频痛点——误清上下文后只能重开会话的痛苦终于有了后悔药。

**② 流式渲染 CPU 降低 ~37%**

> Reduced CPU usage during streaming responses by ~37% by coalescing text updates to 100ms.

文本更新合并到 100ms 间隔，在长对话流式输出时风扇消停了——对笔记本用户尤其明显。

**③ 其他体验修复**：
- 滚动位置在流式输出中不再跳到底部——可以安心翻看历史输出
- 后台 agent 被 stop 后不再"复活"——停止是永久的
- 沙箱网络权限同一 host 批准一次后整个会话记住——不再重复弹窗
- MCP 能力发现增加短暂重试（网络瞬断不再直接失败）
- MCP OAuth 在 headless 环境下跳过浏览器弹窗，直接提示粘贴 URL
- vim 模式 NORMAL `/` 搜索增加 slash command 的提示
- 修复 hooks 中逗号分隔匹配器（如 `"Bash,PowerShell"`）完全不触发的问题
- 长会话内存增长缓解（终端输出缓存优化）

📎 [GitHub Release v2.1.191](https://github.com/anthropics/claude-code/releases/tag/v2.1.191)

---

### 4. MCP 工具链成熟（v2.1.186 / v2.1.187 / v2.1.191 / v2.1.193）——从"能用"到"好用"

这四个版本围绕 MCP 形成了一条完整的工具链成熟曲线：

**CLI 管理（v2.1.186）**：
- `claude mcp login <name>` / `claude mcp logout <name>` ——不再需要进入交互式 `/mcp` 菜单
- `--no-browser` 支持 stdin 重定向，SSH 远程也能完成 MCP OAuth
- `claude mcp get`/`remove` 输错名字时自动建议最近的服务器名

**可靠性（v2.1.187 / v2.1.191 / v2.1.193）**：
- **远程 MCP 工具调用超时保护**：无响应 5 分钟后自动 abort（v2.1.187）
- `headersHelper` auth 在工具返回 401/403 时**自动重运行并重连**（v2.1.193）
- 能力发现（`tools/list` 等）网络瞬断自动重试（v2.1.191）
- HTTP 404 错误现在显示完整 URL 并指向 MCP 配置（v2.1.191）
- 需要认证的 MCP 服务器启动时显示通知（v2.1.193）
- `claude mcp get`/`list` 在 tools/list 失败时显示 `! Connected · tools fetch failed` 而非虚假的 `✓ Connected`（v2.1.181）

**沙箱凭证保护（v2.1.187）**：
- 新增 `sandbox.credentials` 设置，阻止沙箱命令读取凭证文件和敏感环境变量

**大图景**：MCP 从此前的"配置靠手写、登录取向于 TUI、出问题靠猜"进化为"CLI 可脚本化管理、超时有保护、认证有自动恢复"的工程化水平。

---

## 📊 趋势与深度分析

### 5. `!` bash 自动回复 + 子代理权限提示（v2.1.186）——后台 Agent 的体验断层被填上了

`2.1.186` 有两条容易被忽略但对日常工作流影响很大的变更：

**`!` bash 命令自动触发回复**：
> `!` bash commands now trigger Claude to respond to the output automatically.

以前 `!` 只是把命令输出塞进上下文，Claude 不会主动分析——你需要再发一条消息去问它。现在 Claude 自动分析输出并给出回复。不需要这个行为的可以设置 `"respondToBashCommands": false`。

**后台子代理弹出权限提示**：
> Background subagents now surface permission prompts in the main session instead of auto-denying.

此前后台子代理遇到权限请求直接 auto-deny，任务静默失败——你甚至不知道它卡在了哪。现在弹回主会话，你知道哪个 agent 在请求什么权限，Esc 键只拒绝该工具。

**配套**：
- `/review <pr>` 现在和 `/code-review medium` 使用同一审查引擎
- `CLAUDE_CODE_MAX_RETRIES` 上限改为 15，无人值守用 `CLAUDE_CODE_RETRY_WATCHDOG`
- memory 的 `MEMORY.md` 索引接近大小限制时提示压缩
- `/btw` 支持 ←/→ 箭头键翻看历史回答
- `/plugin` 列出最近未使用的插件方便清理

📎 [GitHub Release v2.1.186](https://github.com/anthropics/claude-code/releases/tag/v2.1.186)

---

### 6. 从 v2.1.181 的 30+ 项修复看长尾体验的补齐

`2.1.181` 是本期限**单个版本修复数量最多**的一版（30+ 项），值得拎出来的几条"反映产品成熟度"的修复：

| 修复项 | 痛点场景 |
|--------|---------|
| **prompt caching 在自定义 `ANTHROPIC_BASE_URL` 和 Foundry 上不工作** | 每次请求的 attestation token 变了导致缓存失效——非 Anthropic API 用户的首轮延迟凭空增加 |
| **Write/Edit 在网络驱动器上产生 0 字节文件** | 云同步文件夹（Dropbox/OneDrive/SMB）上的文件编辑坏了 |
| **macOS `-600` 错误导致 open/osascript/browser auth 失败** | 新增 Apple Events entitlement 修复 |
| **启动慢 ~120ms**（2.1.169 回归） | 无 MCP 服务器时也在等托管设置拉取 |
| **启动空白终端 15 秒** | 账户设置拉取在弱网下阻塞启动 |
| **前台子代理无限嵌套** | 现在也遵守 5 层深度限制 |
| **`/recap` 模型切换后仍用旧模型** | 切模型后 fork 会话模型不一致 |
| **AWS 凭证剩余时间短导致每分钟刷新** | `awsCredentialExport` 接受 `aws configure export-credentials` 的 JSON 格式 |

**性能与体验改进**：
- 长段落流式输出逐行显示，不再等待第一个换行符
- API 连接在 thinking 过程中断开**自动重试**，不再显示 "Connection closed while thinking"
- 子代理面板空闲 30 秒自动隐藏，列表上限 5 行带滚动提示
- Bun 运行时升级到 1.4

📎 [GitHub Release v2.1.181](https://github.com/anthropics/claude-code/releases/tag/v2.1.181)

---

## ⚡ 版本速览

其余值得关注的变更按版本过一遍：

**2.1.195**（最新，6/29 左右）

- 新增 `CLAUDE_CODE_DISABLE_MOUSE_CLICKS`：全屏模式禁用鼠标点击/拖拽/悬停，保留滚轮
- Hook 匹配器中 `code-reviewer`、`mcp__brave-search` 等含连字符的标识不再被错误**子串匹配**——现在是精确匹配
- macOS 语音听写修复：长时间会话中默认输入设备变更后不再录到静音；中日泰等无空格语言自动提交现在正常触发
- 后台任务修复：被新版 Claude Code 写入后丢失数据；崩溃后重新打开不再白屏 5 秒
- Linux 语音模式改进：区分"无麦克风"和"SoX 未安装"
- 远程会话启动增加**配置清单**（provisioning checklist）

**2.1.193**

- OTEL 新增 `claude_code.assistant_response` 日志事件（默认脱敏，`OTEL_LOG_ASSISTANT_RESPONSES=1` 开启）
- `!` bash 模式新增**实时文件路径自动补全**
- 空闲后台 shell 命令可根据内存压力自动回收（`CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` 关闭）
- 后台化（←←）在有正在运行任务时误报"N 个任务将被放弃"——已修
- 固定后台 agent 每次自动更新后被重新提示 "Continue from where you left off"——已修

**2.1.187**

- 组织配置的模型限制应用到模型选择器、`--model`、`/model`、`ANTHROPIC_MODEL`
- 全屏模式选择菜单（权限提示、`/model`、`/config` 等）支持**鼠标点击**
- CJK 文本粘贴变乱码——已修
- `/btw` ←/→ 箭头翻看历史回答
- subagent 深度跟踪修复：恢复的子代理恢复原始深度，fork 的子代理计入深度上限
- 被 kill 的 agent 的工作树注册泄漏——现自动清理

**2.1.179**

- 流中连接断开：部分响应保留而非原始错误，spinner 不再卡在 "running tool"
- WSL2 鼠标滚轮修复（2.1.172 回归）
- 沙箱 denyRead/allowRead 在大目录树上导致 Bash tool 描述膨胀——已修
- 欢迎页多个推广 banner 堆叠——最多显示一个

**2.1.185**

- 流停滞提示改为 "Waiting for API response · will retry in …"，触发的静默时间从 10s 改为 20s

**2.1.190**

- Bug 修复和可靠性改进（无显式特性）

---

## 🛠️ 开发者该知道的新设置 / 命令 / 标志（本期清单）

| 类型 | 名称 | 版本 | 作用 |
|------|------|------|------|
| 设置 | `Tool(param:value)` 权限语法 | 2.1.178 | 按工具输入参数匹配权限规则，如 `Agent(model:opus)` |
| 设置 | `autoMode.classifyAllShell` | 2.1.193 | 所有 Bash/PowerShell 命令过 auto mode 分类器 |
| 设置 | `sandbox.credentials` | 2.1.187 | 阻止沙箱命令读取凭证文件和敏感环境变量 |
| 设置 | `sandbox.allowAppleEvents` | 2.1.181 | 允许沙箱命令发送 Apple Events（macOS） |
| 设置 | `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` | 2.1.195 | 全屏模式禁用鼠标点击，保留滚轮 |
| 设置 | `CLAUDE_CLIENT_PRESENCE_FILE` | 2.1.181 | 标记文件路径 → 抑制手机推送通知 |
| 设置 | `respondToBashCommands` | 2.1.186 | 设为 false 保持 `!` 只添加上下文不自动分析 |
| 设置 | `attribution.sessionUrl` | 2.1.183 | 从 commit/PR 中省略 claude.ai 会话链接 |
| 命令 | `/rewind` | 2.1.191 | 从 `/clear` 前恢复会话 |
| 命令 | `/config key=value` | 2.1.181 | 从 prompt 直接设配置，如 `/config thinking=false` |
| 命令 | `claude mcp login/logout <name>` | 2.1.186 | CLI 管理 MCP 认证，支持 `--no-browser` |
| 命令 | `/config --help` | 2.1.183 | 列出所有 `/config` 缩写键 |
| 环境变量 | `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` | 2.1.193 | 关闭空闲后台 shell 的内存压力回收 |
| 环境变量 | `OTEL_LOG_ASSISTANT_RESPONSES` | 2.1.193 | 控制 OTEL 响应体日志（0=关, 1=开, 未设=跟随 prompt 日志策略） |

---

## 💬 一日一评

> 把 `2.1.178 → 2.1.195` 这 11 个版本放在一起看，会发现它们恰好覆盖了 Claude Code 在 Fable 5 出口管制事件**之后**的两周——也就是 6/15 到 6/29。这段时间没有新模型发布、没有爆炸性架构变更，甚至连 changelog 行数都比之前版本少。但恰恰是这种"安静"，折射出一个产品从"快速铺功能"到"系统性打磨"的阶段转换。
>
> 看这 11 版的三个核心主题：
>
> 1. **安全从"能用"到"敢用"**——v2.1.183 拦截破坏性 git 命令，v2.1.193 覆盖全部 Shell 命令，v2.1.187 保护沙箱凭证。这不是在加功能，而是在给 auto mode 这个"自动驾驶"装刹车和保险带。只有安全边界足够清晰，用户才敢把 Claude Code 放进 CI/CD、放进后台无人值守——这才是企业落地的前提。
>
> 2. **MCP 从"配置地狱"到"可运维"**——CLI 登录、超时保护、自动重连、网络瞬断重试……这些都是运维向的功能，不是终端用户的痒点。但当 MCP 服务器数量从 1 个变成 10 个，这些"无聊"的可靠性补丁就决定了 MCP 生态能不能过工程化的及格线。
>
> 3. **交互体验的"最后一公里"**——`/rewind` 给误清上下文的人后悔药，CPU ~37% 降低让笔记本风扇不再狂转，滚动位置不再在流式输出时乱跳，`!` 自动分析输出省了一步操作……这些不是什么"重磅功能"，但它们的共同点是：**每一个都直接消解了一个日常使用中的真实烦躁点。**
>
> 如果只能记住本期三件事，那就是：**Auto Mode 安全全面升级（破坏性命令拦截 + 全量 Shell 覆盖）、`/rewind` 来了 + CPU 降 ~37%、MCP 工具链从"能用"走向"可运维"。**


---

*Claude Code 更新日报 · 2026年6月29日 · 整理自 [anthropics/claude-code](https://github.com/anthropics/claude-code) 的 CHANGELOG.md（版本 2.1.178 → 2.1.195）。所有产品变更均来自官方 changelog，背景评论为原创分析。*

*如对某个版本的解读有疑问，欢迎反馈。建议对照官方 CHANGELOG 原文核对。*
