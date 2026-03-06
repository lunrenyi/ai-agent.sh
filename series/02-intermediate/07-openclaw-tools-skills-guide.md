# OpenClaw 工具与技能完全指南：25 个工具 + 53 个技能详解

> 安装了 OpenClaw 后该做什么？本文是作者配置 OpenClaw 后的研究笔记，详细介绍 25 个工具和 53 个官方技能的作用、是否启用、如何配置以及配置理由。

---

## 开篇：安装 OpenClaw 后该做什么？

工具散落在不同的文档中。技能默认自动加载——有些已经启用，但你可能根本不知道。全部启用则暴露风险，全部禁用则浪费安装。从文档和源代码中拼凑完整信息需要花费不少功夫。

这是我在设置 OpenClaw 后的研究笔记——每个工具和 53 个官方技能的作用、是否启用、如何配置以及配置理由。安全分析见单独的安全指南。本文专注于每个工具和技能的功能以及如何根据需求配置。

（ClawHub 上有 3000+ 第三方技能，不在本文范围内。）

---

## 首先：理解工具与技能的区别

很多人混淆这两者，其实很容易理解。

**工具是器官**——决定 OpenClaw *能否* 做某事。`read` 和 `write` 让它访问文件，`exec` 让它运行系统命令，`web_search` 让它像 Google 一样搜索，`web_fetch` 让它读取网页内容，`browser` 让它与页面交互（点击按钮、填写表单、截图）。没有启用工具，就像没有手——什么都做不了。

**技能是教科书**——教会 OpenClaw *如何组合工具* 来完成任务。`gog` 教它如何使用 Google Workspace 处理邮件和日历，`obsidian` 教它如何整理笔记，`github` 教它如何操作代码仓库，`slack` 教它如何向频道发送消息。53 个官方技能覆盖笔记、邮件、社交媒体、开发、智能家居等领域。

安装技能会赋予 OpenClaw 新权限吗？**不会。**

举例：你安装了 `obsidian` 技能。OpenClaw 现在知道如何整理笔记——但如果没有启用 `write` 工具，它根本写不了文件。技能是手册。真正的开关在工具那里。

对于 OpenClaw 通过技能实际完成某事，需要满足三个条件。以"读取 Gmail"为例：

1. **配置**：你允许 OpenClaw 运行命令了吗？（没有 `exec`，它连程序都启动不了）
2. **安装**：机器上安装了 `gog` 桥接工具了吗？（没有它，OpenClaw 知道该做什么但连不上 Google）
3. **授权**：你登录 Google 账户并授权了吗？（没有授权，Google 不会让它进入）

三者缺一不可。技能是手册——某事是否真正有效取决于这三个条件。

---

## 同心圆架构：从核心到外围

将 25 个工具和 53 个技能平铺展示会让人无从下手。我用同心圆来组织：

* **第一层——核心能力（8 个工具）**：文件访问、命令执行、网络访问。几乎所有人都会启用这些。
* **第二层——进阶能力（17 个工具）**：浏览器控制、内存、多会话、自动化。按需启用。
* **第三层——知识层（53 个技能）**：教 OpenClaw 使用 Google、Obsidian、Slack 等。根据你使用的工具安装相应技能。

---

## 第一层：核心能力（8 个工具）

这 8 个工具是 OpenClaw 的基石。只启用这些，OpenClaw 是被动的——你问，它答。它可以读取文件、运行命令、搜索网页，但它不会跨会话记住你的偏好，也不会主动推送通知。把 OpenClaw 从"聊天机器人"变成"助手"的是第二层。但没有第一层，第二层无法运作。

### 文件操作：read、write、edit、apply_patch

`read` 是只读的。`write` 和 `edit` 可以修改文件，`apply_patch` 应用代码更改。这四个是基础——大多数人会全部启用。

### 执行与进程管理：exec、process

`exec` 让 OpenClaw 运行任何 shell 命令——安装依赖、运行脚本、管理系统。"任何"是关键词：它可以帮你安装依赖，但也可以 `rm -rf` 你的整个机器。没有 `exec`，大多数任务都会失败。有了 `exec` 但没有防护措施，你已经把 root 权限交给了 AI。

这就是为什么我强烈建议在启用 `exec` 的同时启用审批——每个命令都会先展示给你，只有确认后才会运行：

```json
{
  "approvals": {
    "exec": { "enabled": true }
  }
}
```

麻烦吗？诚实的说，是的。但这是最基本的防护——如果 AI 判断失误或受到提示注入攻击，这道门是你最后的防线。

`process` 管理后台进程——列出任务、检查输出、终止卡住的进程。通常与 `exec` 一起启用。

### 网络访问：web_search、web_fetch

`web_search` 执行关键词搜索，`web_fetch` 读取网页内容。两者结合让 OpenClaw 可以浏览互联网获取信息。

---

## 第二层：进阶能力（17 个工具）

第一层是"能否工作"。第二层是"是否好用"。这些工具将 OpenClaw 从命令执行器变成真正的助手——一个记得你的偏好、控制浏览器、发送定时通知的助手。但每个额外工具都扩大了攻击面，所以要权衡是否值得。

### 浏览器：browser、canvas、image

`browser` 让 OpenClaw 控制 Chrome——点击按钮、填写表单、截图。我用它做价格对比、规格研究、加入购物车。但我自己结账。最后一公里涉及付款的永远不交给 AI——这是我的底线。

`canvas` 是图表和流程图的视觉工作空间。`image` 让 OpenClaw"理解"图像。

### 内存：memory_search、memory_get

让 OpenClaw 跨会话记住信息。使用一周后，它知道我用 Astro 搭建博客，部署在 Azure 上，偏好繁体中文——无需每次重新解释。使用时间越长，它越了解你。

### 多会话：sessions 系列（5 个工具）

为不同任务同时运行多个会话——一个讨论产品创意，另一个研究旅行计划，互不干扰。

`sessions_list` 和 `sessions_history` 查看会话。`session_status` 检查状态。`sessions_send` 和 `sessions_spawn` 实现会话间通信和生成子任务。

### 消息：message

让 OpenClaw 向 Discord、Slack、Telegram、WhatsApp、iMessage 发送消息。

我启用了这个功能，但只用于给自己发消息——从不代表我与他人沟通。原因很简单：AI 以你的名义发送的消息无法撤回。如果它误解了上下文、用错了语气、或被提示注入欺骗发送了什么，后果由你承担。

我把 OpenClaw 作为我的 AI 目标管理系统 的通信层——启用 `message` 让它主动推送通知给我：每日简报、任务提醒、待办事项警报，全部发给我自己。

### 硬件控制：nodes

跨设备硬件控制——远程截图、GPS 位置、相机访问。

我第一次看到这个工具时问自己：什么时候需要 AI 自己打开相机？我想不出场景。截图的话，我可以直接通过 Telegram 发送——多一步但更安心。禁用。

### 自动化：cron、gateway

`cron` 设置定时任务。`gateway` 让 OpenClaw 重启自己。

每天早上 6:47，我的 Telegram 收到 OpenClaw 准备的每日简报——今天需要做什么、待回复的消息、天气预报。这是 `cron` 加 `message` 的组合，也是我的 AI 目标管理系统 的核心。

### Agent 通信：agents_list

列出可用的 Agent ID。OpenClaw 支持多 Agent 架构，但官方文档没有详细介绍。如果你只运行单个 OpenClaw 实例，不需要这个。

### 扩展工具：llm_task、lobster

`lobster` 是定义多步骤流程的工作流引擎。`llm_task` 在工作流中插入 LLM 处理步骤。

如果你不使用工作流引擎，两个都跳过。

---

## 第三层：知识层（53 个官方技能）

53 个听起来很多，但浏览后你会发现可能只有十几个与你相关。其他的——外卖、智能家居、语音通话——不是不好，只是与你的使用场景无关。

**重要：捆绑技能默认自动加载**——如果系统上安装了相应的 CLI 工具，技能就会自动激活。不是"安装后才生效"而是"默认全部开启除非禁用"。要控制哪些技能活跃，在白名单模式下使用 `skills.allowBundled`（配置示例见下文"我的配置"部分）。

ClawHub 有 3000+ 第三方技能，但它们的安全风险是另一个问题（见单独的安全指南）。

下面按使用场景组织。

### 笔记

4 个笔记技能：`obsidian`、`notion`、`apple-notes`、`bear-notes`。是否能用取决于你的部署方式。

`apple-notes` 和 `bear-notes` 只在 Mac 本地有效——如果 OpenClaw 运行在虚拟机上，就不能用。`obsidian` 操作本地文件。我用 Obsidian，但保险库在我的 Mac 上，而 OpenClaw 在 Azure 虚拟机上，所以我用本地 Claude Code 处理笔记，而不是通过 OpenClaw。如果你想让 OpenClaw 直接管理笔记，而且它运行在虚拟机上，`notion` 是云端没有部署限制——最省事的方案。

### 生产力

两个邮件技能：`gog` 和 `himalaya`。`gog` 集成整个 Google Workspace（Gmail、日历、任务、云端硬盘、文档、表格）。`himalaya` 只用 IMAP/SMTP 收发邮件。如果你在用 Google，选 `gog`——更完整，而且你可以随时从 Google 账户撤销访问权限。

任务管理有 `things-mac`（Things 3）、`apple-reminders`、`trello`。如果已经用了 `gog`，Google 任务已经包含——无需额外安装。

### 消息与社交媒体

`wacli`（WhatsApp）、`imsg`（iMessage）、`bird`（X/Twitter）、`slack`、`discord`——这些技能让 OpenClaw 深度访问各平台，包括搜索消息历史、同步对话、管理频道。与 `message` 工具（只发消息）不同，安装这些让它完全访问你在该平台的数据。

我都没有安装。外向沟通的最后一步永远是手动的。

### 开发工具

* `github`：通过 `gh` CLI 操作 GitHub，需要 OAuth，权限可控
* `tmux`：管理多个终端会话
* `session-logs`：搜索和分析过去的对话日志
* `coding-agent`：在后台调用其他 AI 编码助手（Codex、Claude Code 等）

我安装了 `github`、`tmux` 和 `session-logs`。我本地用 Claude Code 写代码，但 OpenClaw 总能通过 Telegram 访问——如果我不在时 CI/CD 坏了，只需在手机上问"检查为什么这个 PR 构建失败"，它就会拉取 GitHub Actions 错误日志并告诉我原因。

我还没安装 `coding-agent`，但潜力很大——你可以在 OpenClaw 的虚拟机上安装 Claude Code，让它在后台分发编码任务。想象一下通过 Telegram 告诉 OpenClaw："我在 GitHub 上发现了个有趣的仓库——克隆它，研究它，建个演示站点。"它启动 Claude Code，自主执行，完成后推送通知。AI 编排 AI。我还没深入探索，但在我的清单上。

### 密码管理

`1password` 让 OpenClaw 访问你的 1Password 保险库——查找密码、自动登录、填写表单。用例比如："帮我登录 AWS Console"或"这个网站的密码是什么？"

但权限模型是全有或全无：一旦授权，它就访问整个保险库。你无法限制它只能访问特定条目——你存储的它都能读。我选择不安装。如果真的需要，考虑创建一个"仅 AI"保险库，只包含你愿意分享给 AI 的密码。

### 其他类别

上面是我积极使用或认真考虑过的。其余的——音乐播放、智能家居、图像生成、语音转文字、外卖——我没安装。完整列表见附录。

---

## 我的 OpenClaw 配置：工具和技能设置

我的 OpenClaw 运行在 Azure 虚拟机上，通过 Telegram 操作。配合桌面上的 Claude Code，形成移动端 + 桌面端双工作流——移动端用于讨论、研究、随时捕捉想法（对话历史自动同步），桌面端用于执行。我还日常用于邮件、日历、研究和早上每日简报。

以下是我当前的配置及每个选择的原因。

### 工具（25 个中启用 21 个）

我的规则很简单：**如果我想不出使用场景，就保持关闭。**

```json
{
  "tools": {
    "allow": [
      "read", "write", "edit", "apply_patch",
      "exec", "process",
      "web_search", "web_fetch",
      "browser", "image",
      "memory_search", "memory_get",
      "sessions_list", "sessions_history", "sessions_send", "sessions_spawn", "session_status",
      "message", "cron", "gateway", "agents_list"
    ],
    "deny": ["nodes", "canvas", "llm_task", "lobster"]
  },
  "approvals": {
    "exec": { "enabled": true }
  }
}
```

**启用 21 个，禁用 4 个**：`nodes`（想不出场景）、`canvas`（不需要）、`llm_task` / `lobster`（不使用工作流引擎）。`exec` 启用了审批。`message` 只发给自己。

### 技能（53 个中启用 9 个）

如前所述，捆绑技能默认自动加载。我用 `allowBundled` 白名单限制只需要的：

```json
{
  "skills": {
    "allowBundled": [
      "gog", "github", "tmux", "session-logs",
      "weather", "summarize", "clawhub",
      "healthcheck", "skill-creator"
    ]
  }
}
```

简而言之：`gog` 用于邮件和日历，`github` 用于仓库，其余是每日简报和系统管理的工具。

---

## 如何用 AI Agent 自动化任务

这是 OpenClaw 从聊天机器人变成基础设施的时刻。`cron`（定时）+ `message`（推送通知）的组合让它变成在你睡觉时工作的自动化引擎。

模式总是一样的：**触发 + 行动 + 交付**。定义它何时运行、做什么、结果发到哪里。以下是我实际使用的自动化：

**每日简报**——每天早上 6:47，我的 Telegram 收到简报：今日日历、需要回复的待处理邮件、天气预报、一夜间 CI/CD 故障。这个自动化取代了我喝咖啡前检查五个不同应用的习惯。

**邮件分类**——每天两次，OpenClaw 扫描我的收件箱，按紧急程度分类邮件，并给我发送摘要。 Newsletter 归档。需要处理的事项附上一行摘要。我从 30 分钟的收件箱管理变成 5 分钟。

**CI/CD 监控**——当 GitHub Actions 工作流失败时，OpenClaw 读取错误日志，找出可能原因，然后推送带诊断结果的 Telegram 消息。我曾在排队买咖啡时用手机修复了生产问题。

**内容研究**——每天，OpenClaw 从特定的 subreddit、Hacker News 主题和我关注的 RSS 订阅中收集热门讨论，然后编译成潜在写作主题的摘要。它不是帮我写——而是找出值得写的内容。

设置不难。每个自动化是一个 `cron` 条目触发一个提示，提示告诉 OpenClaw 使用哪些工具以及结果发到哪里。难点不是配置——而是弄清楚日常中哪些部分值得自动化。从一个能节省你最多日常摩擦的开始，跑通后，再加更多。

---

## 下一步：开始配置你的 OpenClaw

你不需要全部 25 个工具。53 个捆绑技能默认全开——用 `allowBundled` 只保留你需要的。打开你的 `openclaw.json`，从三个原则开始：

1. **想不出使用场景，就保持关闭**
2. **能力越大，控制越多**——对 `exec` 启用审批，消息只发给自己
3. **最后一公里永远是手动的**——结账、发送消息、公开发帖——任何不可逆的操作都保留给你

我的配置可作为起点。复制它，然后根据你的需要裁剪。安全设置请配合单独的安全指南阅读。

---

## 常见问题

### 技能会改变 OpenClaw 的权限吗？

不会。技能只是指令手册。实际能力由 `tools.allow` 控制。

### 1password 技能能读我所有的密码吗？

能。一旦授权，它就能访问你的整个保险库——你存储的它都能读。

### 如何撤销 OpenClaw 的 Google 访问权限？

[Google 账户](https://myaccount.google.com/) → 安全 → 有账户访问权限的第三方应用 → 找到 gog → 移除访问权限。

### ClawHub 上的第三方技能安全吗？

不要假设它们安全。安装前务必查看 GitHub 仓库。详见单独的安全指南中的详细审查清单和提示。

### 为什么是 25 个工具？

官方文档列出 18 个。我通过浏览代码库找到了 25 个。额外的包括会话相关工具、`agents_list` 和未文档化的工作流引擎工具（`llm_task`、`lobster`）。

### OpenClaw 和 ChatGPT 有什么区别？

ChatGPT 是聊天工具。OpenClaw 是智能体。区别在于对话结束后会发生什么：

* **ChatGPT**：讨论后，你手动复制内容粘贴到别处。它只能说。
* **OpenClaw**：讨论后，它行动——搜索网页、读写文件、管理日历、读取 Gmail 并起草回复、同步到电脑让 Claude Code 继续处理。

"同步"含义也不同：LLM 应用同步意味着你在手机和桌面都能看到对话历史。 OpenClaw 同步意味着对话变成电脑文件夹中的文件，其他工具可以直接读取并继续工作。一个是"可查看"。另一个是"可执行"。

如果你只是想聊天，ChatGPT 就够了。如果你想让 AI 在对话结束后继续工作，你需要像 OpenClaw 这样的智能体。

### 如何用 OpenClaw 自动化 AI 任务？

结合 `cron`（定时）和 `message`（推送通知）。OpenClaw 按计划运行任务并将结果发送到你的消息平台。每天早上 6:47，我收到每日简报——今日任务、待回复、天气预报。

除了定时推送通知，常见自动化场景还有：带优先摘要的邮件分类、CI/CD 故障监控、定时收集写作素材的热门话题、行业新闻摘要。基本上，任何能分解为"触发 + 步骤"的任务都可以自动化。

### 没有编程能力能使用 OpenClaw 吗？

日常使用不需要编程——用自然语言跟它对话。"查一下我今天的邮件"、"设一个明天早上 9 点的提醒"——说出来就行。

但 OpenClaw 是开源项目，安装和配置有学习曲线。你可以部署到云虚拟机或本地安装——安全起见，建议专用机器而不是日常使用的电脑。如果你使用 AI CLI 工具如 Claude Code，它可以协助设置过程，节省大量时间。

配合本指南推荐阅读：部署成本指南了解费用、安全指南了解防护、本指南了解配置。

---

## 附录：完整参考

### 全部 25 个工具

| 层级 | 工具 | 功能 | 风险 |
|------|------|------|------|
| 1 | `read` | 读取文件 | 低 |
| 1 | `write` | 写入文件 | 中 |
| 1 | `edit` | 结构化编辑 | 中 |
| 1 | `apply_patch` | 应用补丁 | 中 |
| 1 | `exec` | 执行命令 | 极高 |
| 1 | `process` | 管理进程 | 中 |
| 1 | `web_search` | 网络搜索 | 低 |
| 1 | `web_fetch` | 获取网页 | 中 |
| 2 | `browser` | 浏览器控制 | 高 |
| 2 | `canvas` | 视觉工作空间 | 低 |
| 2 | `image` | 图像分析 | 低 |
| 2 | `memory_search` | 搜索记忆 | 中 |
| 2 | `memory_get` | 获取记忆 | 中 |
| 2 | `sessions_list` | 列出会话 | 低 |
| 2 | `sessions_history` | 会话历史 | 中 |
| 2 | `sessions_send` | 发送消息 | 高 |
| 2 | `sessions_spawn` | 生成子代理 | 高 |
| 2 | `session_status` | 检查状态 | 低 |
| 2 | `message` | 跨平台消息 | 极高 |
| 2 | `nodes` | 硬件控制 | 极高 |
| 2 | `cron` | 定时任务 | 高 |
| 2 | `gateway` | 网关管理 | 高 |
| 2 | `agents_list` | 列出代理 | 低 |
| 扩展 | `llm_task` | 工作流 LLM 步骤 | 中 |
| 扩展 | `lobster` | 工作流引擎 | 中 |

### 全部 53 个技能

| 类别 | 技能 | 平台/功能 | 风险 |
|------|------|----------|------|
| 笔记 | `obsidian` | Obsidian | 低 |
| 笔记 | `notion` | Notion | 中 |
| 笔记 | `apple-notes` | Apple Notes | 低 |
| 笔记 | `bear-notes` | Bear | 低 |
| 任务 | `things-mac` | Things 3 | 低 |
| 任务 | `apple-reminders` | Reminders | 低 |
| 任务 | `trello` | Trello | 中 |
| 工作 | `gog` | Google Workspace | 中 |
| 工作 | `himalaya` | IMAP/SMTP | 高 |
| 聊天 | `slack` | Slack | 中 |
| 聊天 | `discord` | Discord | 中 |
| 聊天 | `wacli` | WhatsApp | 极高 |
| 聊天 | `imsg` | iMessage | 极高 |
| 聊天 | `bluebubbles` | iMessage（外部） | 高 |
| 社交 | `bird` | X (Twitter) | 极高 |
| 开发 | `github` | GitHub | 中 |
| 开发 | `coding-agent` | AI 编码 | 中 |
| 开发 | `tmux` | 终端 | 低 |
| 开发 | `session-logs` | 日志搜索 | 低 |
| 音乐 | `spotify-player` | Spotify | 低 |
| 音乐 | `sonoscli` | Sonos | 低 |
| 音乐 | `blucli` | BluOS | 低 |
| 家居 | `openhue` | Philips Hue | 低 |
| 家居 | `eightctl` | Eight Sleep | 低 |
| 外卖 | `food-order` | 多平台 | 高 |
| 外卖 | `ordercli` | Foodora | 中 |
| 创意 | `openai-image-gen` | OpenAI 图片 | 低 |
| 创意 | `nano-banana-pro` | Gemini 图片 | 低 |
| 创意 | `video-frames` | 视频帧 | 低 |
| 创意 | `gifgrep` | GIF 搜索 | 低 |
| 语音 | `sag` | ElevenLabs TTS | 低 |
| 语音 | `openai-whisper` | 语音转文字 | 低 |
| 语音 | `openai-whisper-api` | 云端 STT | 低 |
| 语音 | `sherpa-onnx-tts` | 离线 TTS | 低 |
| 安全 | `1password` | 1Password | 极高 |
| AI | `gemini` | Gemini | 低 |
| AI | `oracle` | Oracle CLI | 低 |
| AI | `mcporter` | MCP 集成 | 中 |
| 系统 | `clawhub` | 技能管理 | 低 |
| 系统 | `skill-creator` | 创建技能 | 低 |
| 系统 | `healthcheck` | 健康检查 | 低 |
| 系统 | `summarize` | 摘要 | 低 |
| 系统 | `weather` | 天气 | 低 |
| 地点 | `goplaces` | Google Places | 低 |
| 地点 | `local-places` | 本地代理 | 低 |
| 媒体 | `camsnap` | RTSP 摄像头 | 中 |
| 新闻 | `blogwatcher` | RSS 监控 | 低 |
| 文档 | `nano-pdf` | PDF 编辑 | 低 |
| 监控 | `model-usage` | 使用量追踪 | 低 |
| 系统 | `peekaboo` | macOS UI | 高 |
| 通讯 | `voice-call` | 语音通话 | 高 |
| 创意 | `canvas` | Canvas 操作 | 低 |
| 音乐 | `songsee` | 音频可视化 | 低 |

### 工具组（快捷方式）

| 组 | 包含 |
|------|------|
| `group:fs` | read, write, edit, apply_patch |
| `group:web` | web_search, web_fetch |
| `group:ui` | browser, canvas |
| `group:memory` | memory_search, memory_get |
| `group:sessions` | sessions_list, sessions_history, sessions_send, sessions_spawn, session_status |
| `group:messaging` | message |
| `group:nodes` | nodes |
| `group:automation` | cron, gateway |

---

## 延伸阅读

* OpenClaw 部署成本指南：每月 0-8 美元构建你的个人 AI 助手
* Claude Code 教程：5 分钟安装并完成第一个任务

---

*原文：[WenHao Yu](https://yu-wenhao.com/en/)，译者：AI Agent 学习仓库*
