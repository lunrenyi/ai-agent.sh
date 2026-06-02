# AI 技术日报

*AI 行业关键动态速览 — 2026 年 6 月 1 日（周一）*

---

> 本期看点：黄仁勋 GTC 台北宣布"有用 AI"时代到来；OpenAI 时隔六年重启机器人；软银 €750 亿押注法国 AI 基建；Anthropic 企业采用率首超 OpenAI。

---

## 🔥 头条新闻

### 黄仁勋 GTC 台北演讲：Agentic AI 时代正式到来

6 月 1 日，NVIDIA CEO 黄仁勋在 COMPUTEX/GTC 台北发表主题演讲，宣告**"有用的 AI 已经到来"**。核心发布包括：

**Vera Rubin 平台全面投产**：NVIDIA 史上最大规模项目，4 万名工程师参与。全新 **Vera CPU** 专为 AI Agent 工作负载设计，SQL 性能达现有平台约 3 倍，流处理最高提升 6 倍。黄仁勋提出新口号：*"计算即收入，Token 即利润单位"*。

**重新定义 AI PC**：与微软联手推出 **N1X AI 芯片**和 **RTX Spark 超级芯片**，目标是在 Windows PC 上实现完全本地运行的 AI Agent。AI PC 不再依附云端——每个设备都是一座微型"Token 工厂"。

**Nemotron 3 Ultra 开源发布**：全球首个 **SSM（Mamba）+ MoE + Transformer 三合一混合架构**，约 500B 参数，100 万 token 上下文窗口。创新点包括 Latent MoE（同成本下 4 倍专家数）和 Multi-Token Prediction（单次前向预测多个 token）。推理速度提升 5 倍，运行成本降低 30%，在 Artificial Analysis 智能指数上得分 48，位居美国开源模型第一。

**Physical AI 三连发**：
- **Cosmos 3** — 开放世界基础模型，面向机器人和自动驾驶
- **Isaac GR00T** — 开源人形机器人参考设计
- **NVIDIA Robot Studio** — 机器人仿真与训练平台

当被问及"AI 是否会取代人类工作"时，黄仁勋直言："完全胡说八道。AI 会刺激企业招聘更多工程师。"作为佐证，GitHub 代码提交量从 2023 年的 3 亿次飙升至 2026 年初的约 14 亿次。

📎 [TechOrange](https://techorange.com/2026/06/01/ai-agent-nvidia-computex-gtc-taipei-keynote/) | [36氪](https://36kr.com/p/3834277983610753) | [21经济网](https://www.21jingji.com/article/20260601/herald/f0eca53300e3043d2a5403397b1764ce.html) | [NVIDIA 技术博客](https://developer.nvidia.com/blog/inside-nvidia-nemotron-3-techniques-tools-and-data-that-make-it-efficient-and-accurate/)

---

### OpenAI 正式进军机器人：时隔六年重启硬件之路

Sam Altman 于 6 月 1 日正式宣布组建 **OpenAI Robotics** 事业部，由 DALL-E 系列和 Sora 的核心缔造者 **Aditya Ramesh** 领导。该团队由过去一年内部"世界模拟（Worldsim）"研究项目孵化而来。

**双轨战略**：
- **短期**：开发协助型机器人，辅助建筑、管道、电气等技工完成基础设施建设——强调"协作"而非"替代"
- **长期**：让每个人拥有一台通用个人机器人，能处理任何任务

OpenAI 正在全面招聘硬件、系统运维和 ML 工程师。此次回归标志着 OpenAI 在 2020 年解散原机器人团队（集中精力做 GPT）后的战略转向。触发因素之一是 2025 年初与 Figure AI 合作破裂——双方在技术路线上存在根本分歧（Figure 坚持垂直整合端到端模型 vs OpenAI 倾向通用模型）。

**上市前夜的战略拼图**：OpenAI 预计最早于 2026 年 9 月 IPO，估值瞄准 $1 万亿。机器人和实体 AI 被视为支撑其增长叙事的关键支柱。

📎 [东方财富](https://finance.eastmoney.com/a/202606013756006288.html) | [Economic Times](http://widget.economictimes.indiatimes.com/tech/technology/openai-wants-you-to-have-a-personal-robot-starts-hiring-for-robotics-division/articleshow/131434679.cms) | [36氪英文](https://eu.36kr.com/en/p/3834849321546882)

---

### 软银 €750 亿押注法国：AI 基建军备竞赛白热化

6 月 1 日，在马克龙主持的"Choose France"峰会上，孙正义宣布软银将投资 **高达 €750 亿（约 $870 亿）** 在法国建设 **5GW AI 数据中心容量**。一期投资 €450 亿（2031 年前），在敦刻尔克、Bosquel、Bouchain 三地建设 3.1GW 容量。

核心合作伙伴包括法国电力集团 **EDF**（利用低碳核电）和 **施耐德电气**（在敦刻尔克港建设机器人化制造集群）。

孙正义的愿景令人震撼："法国一直在出口电力。我们可以将电力这种原材料转化为更高价值的智能——让法国出口智能。"他补充说，€750 亿只是数据中心建设成本，若计入芯片和系统，整个生态系统投入可能接近 **$7500 亿**。

此次 Choose France 峰会共吸引 **€930 亿**投资承诺（71 个项目），软银独占其中 80% 以上。这是欧洲有史以来最大单笔 AI 基础设施投资，也是软银继 OpenAI（$300 亿+投资）和美国 Stargate 项目（$5000 亿）后的又一次巨额押注。

📎 [Yahoo Finance](https://uk.finance.yahoo.com/news/france-secures-93-billion-investment-084427184.html) | [Investment Monitor](https://www.investmentmonitor.ai/news/softbank-e75bn-french-ai-data-centre-network/) | [IndexBox](https://www.indexbox.io/blog/softbank-to-build-5-gw-ai-data-centre-capacity-in-france-with-75-billion-investment/)

---

## ⚡ 快讯

- **Ramp AI 指数：Anthropic 企业采用率首超 OpenAI** — 根据追踪 5 万家美国企业支出的 Ramp AI Index（5 月报告），Anthropic 企业付费采用率达 **34.4%**，首次超越 OpenAI 的 **32.3%**。一年前 Anthropic 仅 9%。在新 AI 采购中，**65%** 选择 Anthropic，**70%** 的首次直接对决最终签单 Claude。但风险同样存在：Uber 透露其 2026 年 AI 预算仅 4 个月就花完，AI 成本控制成为企业级竞争的下一个战场。 [Ramp](https://ramp.com/leading-indicators/ai-index-may-2026) | [VentureBeat](https://venturebeat.com/ai/anthropic-finally-beat-openai-in-business-ai-adoption-but-3-big-threats-could-erase-its-lead) | [IT之家](https://m.ithome.com/html/950068.htm)

- **Microsoft Build 2026 今日开幕（6 月 2–3 日）** — 旧金山 Fort Mason Center。最大看点：Mustafa Suleyman 将发布微软首个**完全自研推理模型 MAI-Thinking-1**（未使用任何外部模型蒸馏）。此外，"One Copilot"超级应用概念图将首次展示，Windows 本地 AI 能力（与 NVIDIA RTX Spark 芯片配合）也是重点。但超级应用测试版预计要到夏末才能发布。 [IT之家](https://www.ithome.com/0/958/480.htm) | [TipRanks](https://www.tipranks.com/news/heres-everything-microsoft-msft-plans-to-announce-at-its-build-conference)

- **中国两模型包揽 WorldArena 世界模型榜前二** — 智元创新的 GenieEnvisioner-Sim 2.0（仅 20 亿参数）和考拉悠然世界模型在 WorldArena"感知与动作响应"赛道排名前二，击败 NVIDIA DreamDojo、清华-斯坦福 Ctrl-World 等。小参数模型的出色表现再次验证了"架构创新比参数规模更重要"的趋势。 [新浪财经](https://finance.sina.com.cn/jjxw/2026-06-01/doc-inhzwisr8495190.shtml)

- **AI 成本反弹：企业叫苦，计费模式争议升级** — Microsoft 取消大部分 Claude Code 许可证、Uber 年度 AI 预算 4 个月耗尽、某客户因忘记设置使用上限单月花费 **$5 亿**。与此同时 GitHub Copilot 于 6 月 1 日起全面转向 Token 计量计费，开发者抱怨成本不可预测。AI 行业正从"不计成本地采用"进入"精打细算地优化"的新阶段。 [Digital Today](https://www.digitaltoday.co.kr/en/view/59637/apple-microsoft-ai-strategies-put-to-the-test-as-ai-costs-surge-row-brews)

- **Google AI Overviews 冲击新闻业** — 世界新闻媒体大会在马赛开幕，AI 成核心议题。数据显示 Google AI Overviews 导致新闻网站点击率从 15% 暴跌至 **8%**，Google 搜索引荐流量同比下降 **33%**。Deepfake 视频从 2023 年的约 50 万个激增至 2025 年的约 **800 万个**（16 倍增长）。Europol 估计到 2026 年 **90%** 的在线内容可能由 AI 合成。 [AJU Press](https://m.ajupress.com/view/20260601161830165)

- **PolyBench：多数大模型不会"赚钱"** — 在预测市场交易测试中，7 个顶级 LLM 仅 2 个实现正收益——**MiMo-V2-Flash**（17.6% 回报）和 **Gemini-3-Flash**（6.2%）。其余模型过度自信导致亏损。这暴露了语言流畅性与真正概率推理能力之间的鸿沟。 [Dev.to](https://dev.to/richard_dillon_b9c238186e/ai-weekly-digest-memory-wars-model-upgrades-and-the-trading-benchmark-that-humbled-five-llms-2f66)

- **NVIDIA 联手中国机器人公司** — 在 GTC 台北演讲中，黄仁勋宣布 NVIDIA 正与中国机器人企业合作推进实体 AI 落地。结合同一天 OpenAI 官宣机器人业务，行业共识已经明确：**下一个战场是 Physical AI**。 [凤凰网](https://news.ifeng.com/c/8tbYuXze881?ch=ttsearch)

---

## 🛠️ 工具与资源

- **[Nemotron 3 Ultra (HuggingFace)](https://developer.nvidia.com/blog/building-nvidia-nemotron-3-agents-for-reasoning-multimodal-rag-voice-and-safety/)** — NVIDIA 最新开源旗舰模型，SSM+MoE+Transformer 混合架构，500B 参数，全面开放权重和训练配方。适合长上下文推理、Agent 工具调用和多模态 RAG 场景。

- **[NVIDIA Cosmos 3](https://developer.nvidia.com/blog/building-nvidia-nemotron-3-agents-for-reasoning-multimodal-rag-voice-and-safety/)** — 面向 Physical AI 的开放世界基础模型，支持机器人和自动驾驶的场景理解与仿真。

- **[PolyBench 基准测试](https://dev.to/richard_dillon_b9c238186e/ai-weekly-digest-memory-wars-model-upgrades-and-the-trading-benchmark-that-humbled-five-llms-2f66)** — 评估 LLM 在真实预测市场中交易盈利能力的基准。如果你想测试模型的概率推理而非语言能力，这是一个值得关注的新维度。

---

## 📊 今日数据

> **€750 亿** — 软银在法国的 AI 数据中心投资，相当于法国 2025 年 GDP 的约 2.5%。5GW 的规划容量约等于 5 座大型核电站的发电量——AI 正在成为重塑全球能源格局的力量。

> **34.4% vs 32.3%** — Anthropic 与 OpenAI 的企业采用率对比。从一年前的 9% vs 32% 到如今的首次反超，Claude Code 驱动的增长只用了 12 个月。AI 行业的权力重心正在从"第一个做出来"转向"第一个把商业闭环跑通"。

> **14 亿次** — 2026 年初 GitHub 年代码提交量，是 2023 年的近 5 倍。黄仁勋以此论证 AI 非但没有减少编程工作，反而极大刺激了软件生产。

---

## 🔭 明日关注

- **Microsoft Build 2026 主题演讲（6 月 2 日 9:30 AM PT）** — Satya Nadella 和 Mustafa Suleyman 主讲。重点关注 MAI-Thinking-1 推理模型的具体能力、Copilot 超级应用的路线图，以及 Windows 本地 AI 开发者工具链。
- **Apple WWDC 2026 倒计时（6 月 8–12 日）** — 苹果能否在端侧 AI 上打出差异化牌，回答"15 年芯片设计积累如何转化为 AI 竞争力"。
- **OpenAI IPO 前哨战** — 随机器人业务官宣和 9 月 IPO 传闻升温，OpenAI 接下来每个动作都会被市场放大解读。
