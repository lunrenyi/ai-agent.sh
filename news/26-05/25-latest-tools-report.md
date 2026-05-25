# AI 工具与开源项目报告 — 2026年5月25日

> 本报告整合自 OSSInsight 各语言热门趋势数据，聚焦 **近 5 天增量变化**。
> **承接上期**：[20-latest-tools-report.md](./20-latest-tools-report.md)（已覆盖 HelloGitHub 第 121 期及 OSSInsight 五大语言基线数据）。本期不再重复 HelloGitHub（尚无新刊），重点关注 OSSInsight 趋势榜单上的**排名变化与新晋项目**。

---

## 一、OSSInsight 各语言趋势变化（5月20日 → 5月25日）

来源：[OSSInsight](https://ossinsight.io/) 热门趋势数据，对比上期报告（05-20）。

### 1.1 Rust 语言 🦀

| # | 项目 | Stars | 描述 |
|---|------|-------|------|
| 1 | [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code) | 25,930 | 史上最快突破 10 万 Stars 的项目，使用 Rust + oh-my-codex 构建 |
| 2 | [ruvnet/RuView](https://github.com/ruvnet/RuView) | 11,554 | 将普通 WiFi 信号转化为实时空间智能、生命体征监测和存在检测——无需任何摄像头 |
| 3 | [farion1231/cc-switch](https://github.com/farion1231/cc-switch) | 8,699 | 跨平台桌面 AI 助手一体化工具，支持 Claude Code、Codex、OpenCode、Gemini CLI |
| 4 | [rtk-ai/rtk](https://github.com/rtk-ai/rtk) | 7,473 | CLI 代理工具，可将 LLM Token 消耗降低 60-90%，单 Rust 二进制文件、零依赖 |
| 5 | [googleworkspace/cli](https://github.com/googleworkspace/cli) | 5,460 | Google 官方 Workspace CLI，一个命令行工具操作 Drive、Gmail、Calendar、Sheets 等 |

**重点新兴项目：**

1. **[ruvnet/RuView](https://github.com/ruvnet/RuView)**（⭐11,554）
   - **解决的问题**：将无处不在的 WiFi 信号变成空间感知传感器，无需摄像头即可实现人体存在检测和生命体征监测。
   - **技术亮点**：利用商用 WiFi 硬件的信道状态信息（CSI），结合 Rust 的高性能信号处理能力。
   - **适用场景**：智能家居、安防监控、老人跌倒检测、隐私敏感场景。

2. **[rtk-ai/rtk](https://github.com/rtk-ai/rtk)**（⭐7,473）
   - **解决的问题**：LLM 在常见开发命令上消耗大量 Token，导致成本居高不下。
   - **技术亮点**：CLI 代理架构，智能缓存和压缩开发命令的输出，单个二进制部署、零外部依赖。
   - **Token 节省率**：60-90%。

---

### 1.2 Go 语言

| # | 项目 | Stars | 描述 |
|---|------|-------|------|
| 1 | [router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) | 3,930 | 将 Gemini CLI、Codex、Claude Code、Grok Build 包装为兼容 OpenAI/Gemini/Claude 的 API 服务 |
| 2 | [Wei-Shaw/sub2api](https://github.com/Wei-Shaw/sub2api) | 3,284 | 一站式开源中转服务，让 Claude、OpenAI、Gemini 订阅统一接入，支持拼车共享 |
| 3 | [QuantumNous/new-api](https://github.com/QuantumNous/new-api) | 2,766 | 统一 AI 模型中枢，支持将各种 LLM 转为 OpenAI/Claude/Gemini 兼容格式 |
| 4 | [canopy-network/canopy](https://github.com/canopy-network/canopy) | 2,350 | Canopy Network 协议的 Go 官方实现 |
| 5 | [sipeed/picoclaw](https://github.com/sipeed/picoclaw) | 2,152 | 极小、极快、随处可部署——自动化琐事，释放创造力 |

**重点新兴项目：**

1. **[router-for-me/CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)**（⭐3,930）
   - **解决的问题**：多个 AI 编程工具（Gemini CLI、Claude Code、Codex、Grok Build）各自有独立的 API 和计费方式，管理和切换成本高。
   - **技术亮点**：统一代理层，将不同 AI CLI 工具包装为标准 API 接口，兼容 OpenAI/Gemini/Claude 协议。
   - **适用场景**：需要同时使用多个 AI 工具的开发团队、API 网关统一管理。

2. **[Wei-Shaw/sub2api](https://github.com/Wei-Shaw/sub2api)**（⭐3,284）
   - **解决的问题**：AI 订阅服务价格昂贵，个人开发者难以负担多个服务。
   - **技术亮点**：将多种 AI 订阅统一接入并支持"拼车"共享模式，降低使用门槛。
   - **适用场景**：预算有限的个人开发者、小型团队。

---

### 1.3 Python 语言 🐍

| # | 项目 | Stars | 描述 |
|---|------|-------|------|
| 1 | [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) | 25,535 | 自我进化型 AI Agent，越用越聪明的个人 AI 助手 |
| 2 | [karpathy/autoresearch](https://github.com/karpathy/autoresearch) | 15,407 | Karpathy 出品：AI Agent 在单 GPU 上自动运行 nanochat 训练研究 |
| 3 | [anthropics/skills](https://github.com/anthropics/skills) | 11,088 | Anthropic 官方 Agent Skills 公共仓库 |
| 4 | [666ghj/MiroFish](https://github.com/666ghj/MiroFish) | 10,459 | 简洁通用的群体智能引擎，预测万物 |
| 5 | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | 9,370 | Claude Code 技能包：像原始人一样说话，Token 使用量直降 65% |

**重点新兴项目：**

1. **[karpathy/autoresearch](https://github.com/karpathy/autoresearch)**（⭐15,407）
   - **作者**：Andrej Karpathy（前 OpenAI 联合创始人、前 Tesla AI 总监）
   - **解决的问题**：AI 训练研究需要大量人工干预和实验管理，效率低下。
   - **技术亮点**：AI Agent 在单 GPU 上自动运行 nanochat 训练实验，实现训练流程全自动化。
   - **适用场景**：AI 研究人员、想要自动运行训练实验的工程师。

2. **[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)**（⭐25,535）
   - **解决的问题**：现有 AI Agent 大多是"一次性"工具，缺乏学习和记忆能力。
   - **技术亮点**：内置自我进化循环机制，根据过往任务经历自动创建和优化 Skills，实现真正的"越用越聪明"。
   - **适用场景**：需要长期使用的个人 AI 助手、持续优化的自动化工作流。

---

### 1.4 TypeScript 语言

| # | 项目 | Stars | 描述 |
|---|------|-------|------|
| 1 | [openclaw/openclaw](https://github.com/openclaw/openclaw) | 33,402 | 你的个人 AI 助手，全 OS、全平台，龙虾之道 🦞 |
| 2 | [garrytan/gstack](https://github.com/garrytan/gstack) | 16,242 | Garry Tan（Y Combinator CEO）的 Claude Code 配置：23 个工具覆盖 CEO、设计师、工程经理等角色 |
| 3 | [paperclipai/paperclip](https://github.com/paperclipai/paperclip) | 12,070 | 管理工作中 Agent 的开源应用 |
| 4 | [anomalyco/opencode](https://github.com/anomalyco/opencode) | 9,390 | 开源编程 Agent |
| 5 | [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | 7,508 | 跨会话持久化上下文——为每个 Agent 记录一切操作，AI 压缩后注入后续会话 |

**重点新兴项目：**

1. **[garrytan/gstack](https://github.com/garrytan/gstack)**（⭐16,242）
   - **作者**：Garry Tan（Y Combinator CEO）
   - **解决的问题**：个人开发者或小团队缺少多角色协作能力（CEO、设计师、工程经理、QA 等）。
   - **技术亮点**：23 个经过精心设计的 Claude Code 工具，分别扮演不同角色，形成完整的软件开发工作流。
   - **适用场景**：独立开发者、小型创业团队、"一人公司"。

2. **[anomalyco/opencode](https://github.com/anomalyco/opencode)**（⭐9,390）
   - **解决的问题**：大多数编程 Agent 是闭源的，开发者无法自由定制和扩展。
   - **技术亮点**：完全开源的编程 Agent，社区驱动开发。
   - **适用场景**：需要定制化编程 Agent 的团队、希望深入理解 Agent 实现原理的开发者。

---

### 1.5 Shell 语言

| # | 项目 | Stars | 描述 |
|---|------|-------|------|
| 1 | [obra/superpowers](https://github.com/obra/superpowers) | 22,805 | Agentic Skills 框架与软件开发方法论 |
| 2 | [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) | 18,239 | 完整的 AI 机构代理套件：从前端向导到 Reddit 社区运营，每个 Agent 都是具有个性的专家 |
| 3 | [mattpocock/skills](https://github.com/mattpocock/skills) | 11,623 | 真正工程师的 Skills，直接从 .claude 目录共享 |
| 4 | [anthropics/claude-code](https://github.com/anthropics/claude-code) | 8,979 | Anthropic 官方 Claude Code —— 终端里的编程 Agent |
| 5 | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 6,547 | 面向 AI 编程 Agent 的生产级工程 Skills |

**重点新兴项目：**

1. **[obra/superpowers](https://github.com/obra/superpowers)**（⭐22,805）
   - **解决的问题**：将 Agent Skills 从零散的配置提升为有方法论支撑的软件开发范式。
   - **技术亮点**：提供一套完整的 Agentic Skills 框架，覆盖开发全流程。
   - **适用场景**：需要标准化 Agent 工作流的团队。

2. **[msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents)**（⭐18,239）
   - **解决的问题**：AI 机构需要多个专业 Agent 协同工作，但大多数方案只提供单一 Agent。
   - **技术亮点**：提供完整的 AI 机构代理套件，每个 Agent 都有独立的"人设"和专业能力，包括前端开发、社区运营、内容创作等。
   - **适用场景**：数字营销机构、内容团队、需要多角色 AI 协作的场景。

---

## 二、趋势变化与新增项目

### 2.1 本期新晋 / 排名跃升项目

以下项目在上期报告（05-20）中**未进入榜单或排名较低**，本期显著上升：

| 项目 | 语言 | 当前 Stars | 变化 |
|------|------|-----------|------|
| [ultraworkers/claw-code](https://github.com/ultraworkers/claw-code) | Rust | 25,930 | 🆕 新晋榜首（上期未入榜） |
| [openclaw/openclaw](https://github.com/openclaw/openclaw) | TypeScript | 33,402 | 🆕 新晋 TypeScript 榜首 |
| [nexu-io/open-design](https://github.com/nexu-io/open-design) | TypeScript | 51,520 | 🆕 新晋（上期未入榜） |
| [666ghj/MiroFish](https://github.com/666ghj/MiroFish) | Python | 10,459 | 🆕 新晋 Python Top 5 |
| [karpathy/autoresearch](https://github.com/karpathy/autoresearch) | Python | 15,407 | 🆕 新晋（Karpathy 出品） |
| [paperclipai/paperclip](https://github.com/paperclipai/paperclip) | TypeScript | 12,070 | 🆕 新晋 TypeScript Top 3 |

### 2.2 趋势确认与更新

上期报告总结的五大趋势（Agent Skills 生态爆发、AI API 网关井喷、编程 Agent 多元化、Token 优化刚需、Agent 自我进化）本期全部延续。详见 [上期报告](./20-latest-tools-report.md) 第七节。

本期新增观察：

- **claw-code 现象**：ultraworkers/claw-code 以 25,930 stars 空降 Rust 榜首，被称为"史上最快突破 100K stars 的项目"，代表 AI 编程 Agent 的终端化趋势加速。
- **open-design 引爆 TypeScript**：nexu-io/open-design 以 51,520 stars 成为全语言最高星项目，说明"开源版 Claude Design"需求巨大。
- **Karpathy 入局 Agent 研究**：autoresearch 以 15,407 stars 位居 Python 第二，AI 训练自动化的关注度急剧上升。

---

## 信息来源

- [OSSInsight](https://ossinsight.io/) — 开源项目数据分析和趋势洞察平台
  - Trending API: `https://api.ossinsight.io/q/trending-repos`
- 上期参考：[20-latest-tools-report.md](./20-latest-tools-report.md)（HelloGitHub 第 121 期及基线数据）

---

*报告生成时间：2026-05-25 | 由 AI 自动整理生成*
