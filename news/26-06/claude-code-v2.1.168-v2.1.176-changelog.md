# 🤖 Claude Code 更新日报

*追踪 Claude Code 每个版本的变更，精选开发者最该关注的特性与修复 — 2026年6月14日*

---

**今日看点：本期覆盖 Claude Code `2.1.168 → 2.1.176` 共九个版本（`2.1.171` 未在 CHANGELOG 中单独发布，已跳过）。一句话概括这九版的三个核心信号——① 旗舰模型登场：`2.1.170` 首发 **Claude Fable 5**，Anthropic 把内部 Mythos 级模型"安全化"后首次面向公众发布，并宣称能力超越以往任何公开发布的模型；② 多 Agent 架构升级：`2.1.172` 起**子代理可嵌套生成、最深 5 层**，从扁平调度进化为树状编排；③ 企业治理全面收紧：`2.1.174 / 2.1.175 / 2.1.176` 连续三版围绕 `availableModels` 白名单打补丁，新增 `enforceAvailableModels` 管理设置，防止用户绕过模型限制。此外，`--safe-mode` 安全模式、`/cd` 目录切换、`post-session` 钩子、VSCode 使用量归因等一批面向"调试与可观测"的新工具也值得上手。**

> 注：Fable 5 在 `2.1.170` 引入后，于 6/12–6/13 因美国出口管制被全球停用（详见 6/13 日报）。本期日报聚焦 changangelog 本身的产品变更，文末"一日一评"会把这条戏剧性反差单拎出来。

---

## 🔥 头条深度

### 1. Claude Fable 5 首发（2.1.170）——Anthropic 迄今"公开发布"的最强模型

`2.1.170` 的 changelog 只有两行，但第一行就分量十足：

> **Introducing Claude Fable 5: a Mythos-class model that we've made safe for general use. Fable's capabilities exceed those of any model we've ever made generally available.**

拆解这句官方措辞，藏着三个关键信息：

- **"Mythos-class"**：Fable 5 属于 Anthropic 内部的 *Mythos* 级模型线——也就是能力上限最高的那一档。此前 Mythos 多停留在内部/受限访问，并未大规模公开。
- **"made safe for general use"**：Fable 5 是把 Mythos 这个"大杀器"做了一层**安全对齐/降敏**后的公开发布版本。命名也呼应了这层关系——*Mythos*（神话）是原型，*Fable*（寓言）是其"可讲述的、安全的"衍生物。
- **"exceed those of any model we've ever made generally available"**：明确宣称其能力**超越以往任何公开发布过的模型**。这是一个相当强的官方表态。

**对开发者的实际影响**：必须升级到 `2.1.170` 及以上才能访问 Fable 5。随后三个版本（`2.1.173 / 2.1.174 / 2.1.176`）围绕 Fable 5 密集打补丁，可见它一上线就暴露出不少集成问题：

| 版本 | Fable 5 相关修复 |
|------|------------------|
| 2.1.173 | 模型名 `[1m]` 后缀未归一化——Fable 5 **默认含 1M 上下文**，后缀现被自动剥离 |
| 2.1.174 | "Fable 5 is now consuming usage credits" banner 对**按量计费的企业账号**误显示 |
| 2.1.176 | auto mode 在**未启用 Opus 4.8 的组织**上对 Fable 5 失败——分类器现回退到最佳可用 Opus 模型 |

**大图景**：把 Fable 5 放回本周时间线看，这是一个极具张力的产品故事——一个模型在 changelog 里以"超越历史所有公开发布模型"的姿态震撼登场，却在同一周（6/12–6/13）因出口管制被全球拔插头。它既标志着 Anthropic 模型能力的巅峰，也成为"AI 监管武器化"第一个高调的牺牲品。

📎 [Claude Fable 5 / Mythos 5 官方公告](https://www.anthropic.com/news/claude-fable-5-mythos-5)

---

### 2. 子代理可嵌套生成、最深 5 层（2.1.172）——多 Agent 架构的关键一跃

`2.1.172` 第一条变更只有一句，但它是这九版里**架构层面最重要的升级**：

> **Sub-agents can now spawn their own sub-agents (up to 5 levels deep).**

这意味着什么？此前 Claude Code 的子代理（subagent）是**扁平的**——主代理调度子代理，子代理执行完返回，不能再生子代理。从 `2.1.172` 起，子代理可以**递归地生成自己的子代理，最深嵌套 5 层**，调度结构从"一对一"进化为"树状编排"。

**为什么这很重要**：

- **复杂任务可真正分治**：一个大型重构、跨多模块的代码迁移、或"调研→规划→并行实现→验证"这种多阶段任务，现在可以自然地分解成多层子树，每一层专注自己的粒度，而不是把所有逻辑塞进主上下文。
- **主上下文更干净**：嵌套生成的子代理各自消耗自己的上下文预算，只有摘要回传上层——这与本项目 `CLAUDE.md` 里"大量使用子代理，保持主上下文窗口干净"的策略天然契合。
- **隐含的成本/复杂度权衡**：5 层嵌套意味着最多 5 次独立的 Agent 调用链，token 成本和延迟会叠加。对于简单任务，盲目深嵌套反而是反模式——它适合真正需要分层抽象的复杂工程。

**配套修复**：同版本还修了"一个嵌套子代理被停止后，外层子代理在 agent 面板里一直卡在 active"的问题——可见嵌套调度的状态管理本身就是新难点，团队在同步收紧。

**大图景**：从扁平子代理到 5 层嵌套，Claude Code 正式从"单层任务委派"走向"递归多智能体系统"。这是 Agent 工具从"助手"向"自主工程组织"演进的一个明确信号。

---

### 3. `--safe-mode` 安全模式 + `/cd` 目录切换 + `post-session` 钩子（2.1.169）

`2.1.169` 是这九版里**面向开发者日常"调试与工作流"的新功能最密集**的一版，三个新能力都直接解决真实痛点：

**① `--safe-mode`（及 `CLAUDE_CODE_SAFE_MODE` 环境变量）**

一键启动 Claude Code，同时**禁用所有定制项**：`CLAUDE.md`、插件、技能、钩子、MCP 服务器全部不加载。用途是排查问题时的"最小复现环境"——当行为异常时，用它快速判断"是我的配置/插件/MCP 出了问题，还是 Claude Code 本身的问题"。这是运维排障的经典套路（类比浏览器的无痕模式、IDE 的禁用所有插件启动），补齐后体验完整了一大块。

**② `/cd` 命令**

允许**在会话进行中移动工作目录，而不破坏 prompt 缓存**。此前要切换项目目录，基本得重开会话，等于丢掉已经累积的上下文缓存（缓存重建既慢又费钱）。`/cd` 让"在多个相关项目/模块间无缝切换"成为可能——比如从单体仓库的 `frontend/` 跳到 `backend/` 继续同一个任务，缓存不中断。

**③ `post-session` 生命周期钩子（自托管 runner）**

在自托管 runner 上，新增一个**会话结束后、工作区被删除前**运行的钩子。典型用途是：快照未提交的代码改动、导出日志、做善后清理。这对 CI/批处理场景下"防止成果随工作区一起被销毁"非常关键。

**配套**：同版还加了 `disableBundledSkills` 设置（及 `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS`），可向模型隐藏内置技能、工作流和内置斜杠命令——配合 `--safe-mode`，给了用户对"模型能看到哪些能力"的精细控制权。

**大图景**：`2.1.169` 这一版的主题是"把控制权还给用户"——安全模式让你隔离问题，`/cd` 让你保留上下文，`post-session` 让你留住成果。三者合起来，显著提升了在真实工程流水线里使用 Claude Code 的可控性。

---

## 📊 趋势与深度分析

### 4. 企业模型治理连续三版收紧（2.1.174 / 2.1.175 / 2.1.176）

如果你是企业 IT/平台管理员，这九版里最该盯的是连续三个版本围绕 `availableModels`（模型白名单）打的补丁——它清晰反映了"管理员想收紧、用户想绕过"的攻防在产品层面持续上演。

**演进时间线**：

- **2.1.172**（打地基）：修复 `availableModels` 限制**未应用于子代理模型覆盖、agent 调度模型选择器、advisor 模型**的漏洞；修复用版本特定 ID（如 `claude-opus-4-8`）时，白名单错误隐藏 `/model` 选择器的 Opus/Sonnet 1M 行。*——白名单此前存在多个"侧门"。*
- **2.1.174**（堵选择器）：修复 `/advisor` 对话预选一个被白名单屏蔽的 advisor 模型；修复 `/model` 选择器在 Bedrock 上列出 provider 根本不提供的模型（选中后静默切换且多行高亮）。
- **2.1.175**（新增硬开关）：**新增 `enforceAvailableModels` 管理设置**——启用后，白名单**也约束 Default 模型**（Default 若解析到不允许的模型，回退到第一个允许的模型），且**用户/项目设置再也不能扩大一个被管理的 `availableModels` 列表**。*——这是"只许收、不许放"的单向阀门。*
- **2.1.176**（堵环境变量）：修复别名模型选择可通过 `ANTHROPIC_DEFAULT_*_MODEL` 环境变量被**重定向到被屏蔽的模型**；`/fast` 在会切到白名单外模型时**直接拒绝切换**。

**为什么这个趋势重要**：

1. **企业落地的真实需求**：当 Claude Code 进入大型组织，IT 必须能强制"只许用某几个批准过的模型"（合规、成本、数据驻留）。这九版密集修补，恰恰说明此前白名单有不少绕过路径。
2. **"可观测 → 可限制"的治理成熟度曲线**：从 `2.1.174` 的 VSCode 使用量归因（见下文），到 `2.1.175` 的强制白名单，Anthropic 在系统性地补齐"企业级模型治理"这一层。
3. **对普通开发者的副作用**：如果你在公司环境里发现 `/fast` 突然不让切、或 Default 模型被强制回退——多半是你的组织启用了 `enforceAvailableModels`，不是 bug。

**大图景**：模型治理的收紧，与 Fable 5 的发布、出口管制的发生，发生在同一周——三者拼在一起，构成了一个完整叙事：**当模型能力（Fable 5）和监管压力（出口管制）同时升级，工具侧必须同步给出"谁能用哪个模型"的精细管控能力。** `availableModels` 这条线，正是 Anthropic 在产品层面对"模型即受管控资源"这一现实的工程回应。

---

### 5. 1M 上下文 + Fable 5 的一系列稳定性修复（2.1.172 / 2.1.173 / 2.1.174）

长上下文是 2026 年模型的主战场，而这几版暴露出 1M 上下文在实际使用中的若干"硬伤"被逐一修复——值得每一个重度用户关注。

**关键修复**：

- **2.1.172（最严重的一个）**：**使用 1M 上下文但没有 usage credits 的会话会永久卡死**——现在会**自动压缩回标准上下文上限**。*——此前这是个"无声陷阱"：你以为只是慢，其实是死锁。*
- **2.1.172**：修复模型 ID 出现**双重 1M 后缀**（如 `[1M][1m]`）——当 `ANTHROPIC_DEFAULT_OPUS_MODEL` 已含后缀时叠加。
- **2.1.172**：修复 `opusplan` 模型设置在 plan 模式下不附带 1M 上下文；`opusplan[1m]` 现也能正确在 plan 模式切到 Opus。
- **2.1.173**：Fable 5 模型名的 `[1m]` 后缀未归一化——**Fable 5 默认就含 1M 上下文**，后缀现自动剥离。
- **2.1.174**：修复"按量计费企业账号"误显示 Fable 5 消耗额度 banner。

**配套性能改进（2.1.172）**：

- **长对话性能提升**：移除冗余的消息归一化；当流式 tool-use 状态未变时，避免对全部消息历史做 transform。
- **降低空闲 CPU**：`/goal` 状态徽章不再以 5Hz 重渲染终端；子代理并行运行时减少 UI 重渲染。
- **Claude in Chrome 工具加载**：浏览器工具改为**单次批量调用**加载，而非每个工具一次。

**大图景**：1M 上下文不是"模型能吃下多少 token"那么简单——它牵动会话状态管理、模型 ID 归一化、压缩/降级策略、UI 渲染频率一整条链路。这九版密集修复说明：**长上下文的工程化（让它在真实会话里稳定、不卡死、不费 CPU）才刚刚成熟。**

---

### 6. VSCode 使用量归因：把"钱花在哪"说清楚（2.1.174）

`2.1.174` 里有一条容易被 changelog 淹没、但对成本敏感的开发者很实用的更新：

> **[VSCode] Added usage attribution to the Account & usage dialog (`/usage`) showing cache misses, long context, subagents, and per-skill/agent/plugin/MCP breakdowns over the last 24h or 7d.**

`/usage` 对话框现在能展示过去 24 小时 / 7 天的**使用量分解**：

- **缓存未命中**（cache misses）——直接影响成本，命中率低意味着钱在浪费
- **长上下文**（long context）——1M 上下文消耗
- **子代理**（subagents）——嵌套调度的开销（配合 `2.1.172` 的 5 层嵌套，这条尤其关键）
- **按技能 / 代理 / 插件 / MCP 的分解**——精确到"哪个能力在烧钱"

**为什么重要**：当子代理可以嵌套 5 层、技能和插件越来越多、MCP 服务器持续接入，成本会快速分散到各个角落。没有归因，你只能看到一个总账单；有了归因，才能定位"是哪个 skill、哪个 MCP、哪层子代理在吃 token"。这是从"能跑"到"能算清楚账"的必要一跃。

---

## ⚡ 版本速览（逐版精要）

把其余值得知道的变更按版本快速过一遍：

**2.1.176**

- **会话标题按对话语言生成**（可用 `language` 设置锁定语言）——中文会话不再被起英文标题。
- 新增 `footerLinksRegexes` 设置：底部行支持正则匹配的链接徽章，可由用户/管理设置配置。
- **Bedrock 凭证缓存改进**：`awsCredentialExport` 凭证缓存到其 `Expiration`，而非固定 1 小时。
- **hook `if` 条件修复**：`Edit(src/**)`、`Read(~/.ssh/**)`、`Read(.env)` 等文档化路径模式现在能正确匹配。
- Linux sandbox 在 `.claude/settings.json` 是带绝对目标的符号链接时启动失败——已修。
- **tmux over SSH 复制修复**：`/copy` 和鼠标选中内容能正确进系统剪贴板；旧版 tmux（<3.2）粘贴缓冲加载修复。
- **Remote Control 一组修复**：从 web/mobile 连接不再静默切换会话模型；断开通知显示人类可读原因而非裸数字码；换账号登录时正确断开已有会话。
- 后台会话/`claude agents` 一组修复：PR URL 搜索、Windows 光标、`--bg -cn` 会话名、daemon 启动等。

**2.1.175**

- 新增 `enforceAvailableModels` 管理设置（详见趋势分析 §4）。

**2.1.174**

- 新增 `wheelScrollAccelerationEnabled` 设置：可在全屏模式禁用鼠标滚轮加速。
- 退出 Claude Code 时（macOS/Linux，刚中断/杀死 shell 命令后）的 1–2 秒暂停——已修。
- **git commit co-author 归因显示错误模型名**——已修。
- **skill 热重载修复**：单个 skill 变更不再重新推送整个 skill 列表，只重新通知变更项。
- Workflow 工具 `agent()` 子代理缺少 per-agent 归因 header——已修。
- Bedrock GovCloud 区域（`us-gov-*`）推断错误的 inference profile 前缀（`global` 而非 `us-gov`）导致 400 错误——已修。

**2.1.173**

- Fable 5 `[1m]` 后缀归一化（详见 §5）。
- Windows 上启用 sandbox 时误报"sandbox dependencies missing"——已修。

**2.1.172**（除 §2、§5 外的要点）

- **Amazon Bedrock 从 `~/.aws` 配置文件读取 region**（`AWS_REGION` 未设时），匹配 AWS SDK 优先级；`/status` 显示 region 来源。
- `/plugin` 浏览市场插件时新增搜索栏。
- `claude_code.lines_of_code.count` OTEL 指标新增 `model` 属性。
- **`WebFetch(domain:*.example.com)` 通配符域名规则此前从不匹配子域**（allow/deny/ask 位置均失效）；文件权限中间通配符（如 `Read(secrets-*/config.json)`）启动时被错误拒绝——均已修。
- **memory recall 在远程会话找不到挂载的团队记忆库**（`CLAUDE_MEMORY_STORES`）——已修。
- `/code-review` 的 `ultra` 选项在未登录 claude.ai 时保持可见并附说明（云审查需 claude.ai 账号）。
- Remote Control footer 简化为 `/rc active`，窄终端隐藏。
- [VSCode] PowerShell 工具调用此前渲染成原始 JSON——已修。

**2.1.170**

- Claude Fable 5 发布（详见 §1）。
- 从 VS Code 集成终端（或任何继承了 Claude Code 环境变量的 shell）启动的会话**不保存 transcript、不出现在 `--resume`**——已修。

**2.1.169**（除 §3 外的要点）

- **企业 MCP 策略修复**：`allowedMcpServers`/`deniedMcpServers` 此前在重连、IDE 类型配置、`--mcp-config` 首次会话、远程设置加载前均**未生效**；同时修复无远程设置组织的慢冷启动。
- macOS 上用 claude.ai 凭证登录的用户，每轮开始有 30–50ms UI 卡顿——已修。
- **Vertex/Foundry 恢复默认 5 分钟空闲超时**：停滞的流会中止而非永久挂起（`API_FORCE_IDLE_TIMEOUT=0` 可关闭）。
- **`CLAUDE.md is too long` 警告阈值现随模型上下文窗口缩放**——长上下文模型允许更长的 CLAUDE.md。
- `claude agents --json` 修复（此前省略 blocked 和刚调度的后台会话）；新增 `--all` 及 `id`/`state` 字段。
- `TaskCreate` 可靠性提升：畸形输入自动修复，未加载工具的校验错误附 schema。
- 后台会话跨 retire→wake 保留 `--ide`/`--chrome`/`--bare`/`--remote-control` 等标志。

**2.1.168**

- 仅"Bug fixes and reliability improvements"（无显式特性）。

**2.1.171**

- **CHANGELOG 中缺失，未单独发布**（版本号跳过）。

---

## 🛠️ 开发者该知道的新设置 / 命令 / 标志（本期清单）

把本期新增的"可操作开关"集中起来，方便快速上手：

| 类型 | 名称 | 版本 | 作用 |
|------|------|------|------|
| 标志 | `--safe-mode` / `CLAUDE_CODE_SAFE_MODE` | 2.1.169 | 启动时禁用所有定制（CLAUDE.md/插件/技能/钩子/MCP），用于排障 |
| 命令 | `/cd` | 2.1.169 | 会话中切换工作目录，不破坏 prompt 缓存 |
| 设置 | `disableBundledSkills` / `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` | 2.1.169 | 向模型隐藏内置技能/工作流/斜杠命令 |
| 钩子 | `post-session`（自托管 runner） | 2.1.169 | 会话结束、工作区删除前运行，可快照成果/导出日志 |
| 设置 | `enforceAvailableModels`（managed） | 2.1.175 | 白名单约束 Default 模型，且用户/项目不可扩大被管理的白名单 |
| 设置 | `wheelScrollAccelerationEnabled` | 2.1.174 | 全屏模式禁用鼠标滚轮加速 |
| 设置 | `language` | 2.1.176 | 锁定会话标题/UI 语言 |
| 设置 | `footerLinksRegexes` | 2.1.176 | 底部行正则匹配的链接徽章 |
| 命令 | `/usage`（VSCode 归因增强） | 2.1.174 | 24h/7d 使用量按 缓存未命中/长上下文/子代理/skill/agent/plugin/MCP 分解 |

---

## 💬 一日一评

> 把 `2.1.168 → 2.1.176` 这九个版本叠在 6/12–6/13 的出口管制事件上看，会得到本周最戏剧性的一个反差：
>
> **同一个 Fable 5，在 changelog 里以"超越历史所有公开发布模型"的姿态震撼登场（`2.1.170`），却在同周的日报里"被全球拔插头"。** 一个产品能力登顶的瞬间，恰好也是它被监管切断的瞬间——这种巧合本身就解释了为什么这九版里有**整整三版（2.1.174/2.1.175/2.1.176）在收紧 `availableModels` 模型治理**。当模型变成"受管控资源"，工具侧必须同步给出精细的"谁能用哪个模型"的管控——这不是锦上添花，而是企业落地的入场券。
>
> 抽掉 Fable 5 的戏剧性，这九版真正的主线其实是两条**工程能力**的成熟：
>
> 1. **多 Agent 架构从扁平走向递归**——子代理可嵌套 5 层（`2.1.172`），Claude Code 正式具备"树状多智能体编排"能力。配合 `2.1.174` 的 VSCode 使用量归因（精确到"哪层子代理在烧钱"），这套架构才真正可观测、可控。
> 2. **长上下文的工程化刚刚过关**——1M 上下文会话永久卡死（`2.1.172`）、模型 ID 双重后缀、Fable 5 默认含 1M 却带 `[1m]` 后缀……这些"硬伤"被密集修复，说明**"模型支持 1M 上下文"和"1M 上下文在真实会话里稳定跑"是两回事**，后者才刚刚达标。
>
> 如果只能记住本期三件事，那就是：**Fable 5 登场即谢幕（产品+监管双重里程碑）、子代理可递归 5 层（多 Agent 架构升级）、企业模型治理连续三版收紧（`availableModels` 体系成型）。**

---

*Claude Code 更新日报 · 2026年6月14日 · 整理自 [anthropics/claude-code](https://github.com/anthropics/claude-code) 的 CHANGELOG.md（版本 2.1.168 → 2.1.176）。所有产品变更均来自官方 changangelog，背景评论为原创分析。*

*如对某个版本的解读有疑问，欢迎反馈。建议对照官方 CHANGELOG 原文核对。*
