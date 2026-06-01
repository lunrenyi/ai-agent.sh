# AI 技术日报

*AI 行业关键动态速览 — 2026 年 5 月 31 日（周日）*

---

> 本期看点：Anthropic 估值近万亿超越 OpenAI；Kog AI 标准 GPU 突破 3000 token/s 推理；OpenAI 进军生物防御；微软 Copilot 超级应用浮出水面。

---

## 🔥 头条新闻

### Anthropic 完成 $650 亿 H 轮融资，估值 $9650 亿超越 OpenAI

Anthropic 于 5 月 28 日宣布完成 **$650 亿 H 轮融资**，投后估值达 **$9650 亿**，首次超越 OpenAI（$8520 亿），成为全球估值最高的生成式 AI 公司。本轮由 Altimeter Capital、Dragoneer、Greenoaks Capital 和 Sequoia Capital 联合领投，三星电子、SK 海力士、美光等半导体巨头作为战略投资者参投，Google 和 Amazon 也追加了数十亿美元。

这轮融资预计是 Anthropic **IPO 前的最后一轮私募**。与此同时，其年化收入已突破 **$470 亿**，Q2 营收预计达 $109 亿，有望实现首次季度运营盈利。增长的核心驱动力来自 Claude Code 在企业中的大规模采用。

同步发布的还有 **Claude Opus 4.8**，主打更强的智能体编程、自我纠错和诚实性。更值得关注的是，Anthropic 宣布此前仅向约 50 家机构开放的 **"Mythos"级 AI 模型**将在"未来数周"向所有客户广泛发布——该模型专注于检测软件漏洞，具备高级网络攻防能力。

**为什么重要：** AI 行业的权力格局正在重塑。OpenAI 的先发优势正在被 Anthropic 的工程实力和商业化速度追赶。而半导体巨头作为战略投资者的入场，预示着"算力-模型"深度绑定的行业趋势。

📎 [AP News](https://apnews.com/article/anthropic-ai-claude-openai-valuation-86c432fa375548fd4f111f8164d6ffc1) | [TechCrunch](https://techcrunch.com/2026/05/28/anthropic-raises-65-billion-nears-1t-valuation-ahead-of-ipo/) | [Yahoo Finance](https://finance.yahoo.com/sectors/technology/articles/anthropic-leapfrogs-openai-record-965-163454686.html)

---

### Kog AI 在标准 GPU 上实现 3000 token/s 实时推理——软件才是瓶颈

Kog AI 于 5 月 29 日发布 **Kog Inference Engine (KIE)** 技术预览版，在 8 张 **AMD MI300X** 上实现单请求 **3000–3300 token/s** 的推理速度，在 NVIDIA H200 上也达到 2100 token/s。所有测试均在 **FP16、batch size=1、无投机解码、无量化** 的条件下完成——相当于把 5 万 token 的智能体工作流从约 8 分钟缩短到 **不到 20 秒**。

核心技术突破是 **"Monokernel"架构**：将整个解码循环（prefill → decode → sampling）融合为一个 GPU 常驻程序，消除 kernel 启动开销和 CPU/GPU 同步延迟，同时利用自定义通信库 KCCL 将跨 GPU 延迟压至约 4 微秒。Kog 的方法论核心是：自回归推理的瓶颈不在算力（FLOPS），而在**内存带宽利用率（MBU）**——8 张 MI300X 合计约 33.6 TB/s 的带宽，现有方案远未充分利用。

**为什么重要：** 这证明了 AI 推理的瓶颈在软件而非硬件。如果 Kog 的方案能够推广到更大规模的 MoE 模型（预计在 DeepSeek-V4-Flash 上可达 3560 token/s），将彻底改变实时 AI 应用的体验边界。

📎 [Kog AI 官方](https://playground.kog.ai) | [SquaredTech](https://www.squaredtech.co/3000-tokenss-llm-inference-the-fastest-gpu-speed-yet) | [80aj 中文报道](https://www.80aj.com/2026/05/29/gpu-ai-inference-3000-tokens/)

---

### OpenAI 推出 Rosalind Biodefense：AI 进军生物安全

5 月 29 日，OpenAI 正式启动 **Rosalind Biodefense** 计划，发布专为生命科学领域打造的推理模型 **GPT-Rosalind**（以 DNA 结构发现者 Rosalind Franklin 命名）。该模型聚焦于流行病防备、生物威胁检测、诊断和医疗对策开发。

Rosalind 采用**"可信访问"模式**，不对外开放，仅面向经过审查的开发者、美国政府及盟友公共卫生机构。首批合作伙伴包括劳伦斯利弗莫尔国家实验室（LLNL）、约翰霍普金斯应用物理实验室、流行病防范创新联盟（CEPI）等。

**值得关注的背景：** 此次发布恰逢特朗普政府推迟一项原本会建立 AI 模型发布审查流程的行政令后约一周。分析人士认为 OpenAI 实质上是在**自行设定政府 AI 访问的游戏规则**，建立了一种"政策护城河"。

📎 [OpenAI 官方](https://openai.com/index/strengthening-societal-resilience-with-rosalind-biodefense/) | [RD World Online](https://www.rdworldonline.com/openai-launches-rosalind-biodefense-offers-federal-agencies-early-access-to-its-life-sciences-model/) | [阿里云开发者](https://developer.aliyun.com/article/1738694)

---

## ⚡ 快讯

- **微软 Copilot 超级应用曝光** — 据 Fortune 独家报道，微软正打造代号 "One Copilot" 的超级应用，将 GitHub Copilot、Copilot Chat、Copilot Cowork 和自主工作流引擎 Autopilot 整合为统一入口。项目由前 Snap 高管 Jacob Andreou（直接向 Nadella 汇报）主导，目标今夏末发布。目前 M365 Copilot 付费渗透率不到 4.5%，超级应用被视为扭转局面的关键一役。 [Fortune](https://tech.yahoo.com/ai/copilot/articles/exclusive-microsoft-building-super-app-171403358.html) | [The Verge](https://www.theverge.com/tech/940058/microsoft-is-reportedly-working-on-its-own-ai-super-app)

- **GitHub Copilot 从"副驾驶"变身"自动驾驶"** — GitHub 于 5 月 14 日推出 Copilot 独立桌面应用技术预览版，AI Agent 从 IDE 插件升级为**原生智能体开发环境**：支持并行多任务隔离会话、规划/自动驾驶双模式、自动合并 PR。同时 GPT-5.3-Codex 成为企业版首个 LTS 基础模型，6 月 1 日起全面转向使用量计费。 [阿里云开发者](https://developer.aliyun.com/article/1735065) | [WebProNews](https://www.webpronews.com/github-unleashes-coding-agent-as-ai-takes-on-real-software-tasks/)

- **国内大模型商业化提速：MiniMax 冲刺 A+H 双平台** — MiniMax 于 5 月 31 日公告聘请中信证券筹备**科创板上市**（已在港股上市，市值约 2635 亿港元）。同时 DeepSeek 面对算力瓶颈实施临时限流，中国日均 Token 使用量超 140 万亿但推理算力供不应求。行业正在从"烧钱换流量"转向"先赚钱"的拐点。 [北京商报](https://m.bbtnews.com.cn/article/230549) | [证券时报](https://www.stcn.com/article/detail/3895851.html)

- **Meta/Biohub 开源 ESMFold2，正面对标 AlphaFold** — 由扎克伯格资助的 Biohub 团队在 *Nature* 发表 ESMFold2，预测 **11 亿**蛋白质结构（比 AlphaFold 数据库多 8 亿），在蛋白质互作预测上超越 AlphaFold3，且**完全开源无商业限制**。技术路线采用"蛋白质语言模型"方法——把蛋白质序列当成自然语言处理，与 DeepMind 的扩散式结构预测属于不同范式。 [36氪英文版](https://eu.36kr.com/en/p/3830290697414528)

- **Cohere 发布 Command A+：主打"主权 AI"的开源模型** — 5 月 20 日，Cohere 发布 Command A+，采用 Apache 2.0 许可，218B 总参数仅激活 25B，可运行在 2 张 H100 上。最大卖点是面向政府/关键基础设施部署的**完全数据主权**：支持本地、VPC 和气隙部署，48 种语言多模态能力。 [BusinessWire](https://secure.businesswire.com/news/home/20260520121796/en/Cohere-Releases-Command-A-An-Open-Source-Enterprise-AI-Model-Built-for-Sovereign-Critical-Infrastructure)

- **法国 Mistral AI 大举扩张，定位"AI 主权"** — Mistral 于 5 月 29 日举办首届官方大会，宣布三大策略：推出工业工程 AI 平台（与空客、BMW 合作）、在巴黎南部建设 10MW 推理数据中心、AI 助理从 "Le Chat" 升级为 **Vibe 代理平台**。欧洲正在开辟"AI 主权"的第三战场。 [TechOrange](https://techorange.com/2026/05/29/mistral-ai-launches-vibe-expands-into-industrial/)

- **Google DeepMind WeatherNext 投入飓风季实战** — WeatherNext AI 在 2025 年成功提前 5 天预测飓风 Melissa 将达到 5 级强度（从 1 级风速起步预测），被美国国家飓风中心确认为 2025 赛季表现最优的单一模型，**2026 年飓风季起将投入业务化运行**，与 NOAA 和 ECMWF 模型并列使用。 [Google DeepMind](https://deepmind.google/blog/how-weathernext-helped-the-national-hurricane-center-better-predict-hurricane-melissas-historic-landfall-in-jamaica/)

---

## 🛠️ 工具与资源

- **[playground.kog.ai](https://playground.kog.ai)** — Kog AI 的在线体验环境，可自身体验 3000+ token/s 的 2B 编程模型实时推理速度。直接在浏览器中感受"瞬间输出"是什么体验。

- **[InclusionAI Ring-2.6-1T](https://openrouter.ai/inclusionai/ring-2.6-1t:free/activity)** — 1T 参数的思考模型（63B 激活），在 OpenRouter 上**免费使用**，每周 150B token 配额，262K 上下文窗口，针对编程 Agent 和长程任务优化。

- **[X Square WALL-WM](https://www.tipranks.com/news/private-companies/x-square-robot-open-sources-event-centric-world-action-model-wall-wm-for-general-purpose-robotics)** — 面向通用机器人的开源世界动作模型，以"语义事件"为建模单位（而非固定时长片段），支持多视角、多形态感知和免标定部署，FP8 量化支持边缘设备。

---

## 📊 今日数据

> **$9650 亿** — Anthropic 最新估值，超越 OpenAI（$8520 亿），约等于英特尔 + AMD + 美光三家公司市值之和。从 2023 年初的 $50 亿到如今逼近万亿，仅用了不到 4 年——这是人类商业史上从未有过的估值增长速度。

> **3000 token/s** — Kog AI 在 8 张标准 AMD MI300X GPU 上实现的单请求推理速度，相当于每秒生成约 4500 个英文单词。一张 4090 通常跑同样的 2B 模型只能做到约 80–120 token/s。

---

## 🔭 明日关注

- **微软 Build 2026（6 月 2–3 日）** — 旧金山开幕。业界密切关注是否会提前透露 Copilot 超级应用的更多细节，以及 Azure AI 和 Microsoft Foundry 的更新。
- **6 月"模型大战"前夜** — 业界传闻 GPT-5.6（代号 iris-alpha）支持 150 万 token 上下文窗口、Claude Sonnet 4.8、Gemini 3.5 Pro 均瞄准 6 月发布。准备好迎接可能是 AI 史上最密集的模型发布月。
- **WWDC 2026 临近** — 苹果的 AI 策略至今相对沉默，WWDC 能否给出答案成为悬念。

---
