# AI 资讯综合报告 — 2026年5月25日

> 本报告整合自三个来源：AI 开发者日报（ainews.liduos.com）、量子位（qbitai.com）、宝玉的分享（baoyu.io）。
> **承接上期**：[20-latest-news-report.md](./20-latest-news-report.md)（已覆盖 2026-05-18 ~ 05-20），本期聚焦 **05-22 以来** 的新增内容。

---

## 一、AI 开发者日报 重点摘要（新增）

来源：[AI 开发者日报 RSS](https://ainews.liduos.com/rss.xml)，作者：莫尔索

> 往期已覆盖 05-18 期（Cerebras IPO、Codex 首周百万下载）和 05-19 期（Cursor Composer 2.5、Figure AI 机器人、马斯克诉 OpenAI 败诉），参见 [上期报告](./20-latest-news-report.md)。

### 2026-05-22 期：[AI 开发者日报 2026-05-22](https://ainews.liduos.com/post/2026-05-22)

**模型与研究更新**

- **RAEv2 发布**：视觉表征学习迎来重大更新，收敛速度提升 >10倍，同时改善重建效果和生成能力。研究发现：对最后 K 个编码器层求和（而非仅用最后一层）即可在不增加推理成本的情况下改善效果；RAE 和 REPA 在语义与空间结构维度上互补；REPA 可重新表述为内部自引导机制。
- **NVIDIA Gated DeltaNet-2**：通过通道级门控机制解耦线性注意力中的擦除和写入操作，在 1.3B 参数规模下超越 KDA 和 Mamba-3，在 RULER 上取得显著长上下文检索增益。Sebastian Raschka 称其为混合注意力方向最有趣的探索之一。
- **NousResearch 子词 Tokenization 研究**：在 1.7B 字节级流水线中模拟七种假设的收益机制，发现七种干预中只有三种对验证损失产生影响。
- **DCLM 扩展结果**（@tatsu_hashimoto）：在计算资源充足时，最好的数据过滤器可能是**不过滤**。预测表明对于互联网规模数据池，交叉点约在 1e30 FLOPs。
- **SAE 可解释性新方向**：Goodfire AI 提出通过联合激活模式对 SAE 特征聚类，以特征组而非孤立原子恢复几何结构。解释应从单一特征转向结构化组合。
- **OpenAI 在 Erdős 单位距离问题上的进展**引发社区讨论：数学被认为是目前最适合 AI 辅助研究突破的领域。

**智能体与开发者工具**

- **框架（Harness）仍是能力提升的主要来源**：lvwerra 发布 physics-intern 框架，将 Gemini 3.1 Pro 得分从 17.7 提升至 31.4，超越 GPT 5.5 Pro。但 GPT 5.5 Pro 本身未从该框架受益，表明模型对脚手架技巧的吸收具有特异性。
- **智能体设计模式演进**：从单智能体优先转向显式子智能体编排。Cognition 的 sub-Devin 工作流被描述为阶跃变化——将原本需要 2 个工程师周的工作压缩到几小时。
- **OpenAI Codex 更新**：推出 Appshots（同时捕获 Mac 应用截图和文本）、团队插件共享、组织分析功能。更重要的转变是远程计算机使用——Codex 现在可以在 Mac 锁定状态下从手机安全使用桌面应用，信号智能体产品形态正从聊天 IDE 转向持久的跨设备操作工作流。
- **Gemini 3.5 Flash** 在 APEX-Agents-AA 排行榜排名第一，超越更大模型。

**基础设施与商业**

- Weaviate、LangChain 等工具持续整合，turbopuffer 等公司收入增长。
- **Qwen3.7 Max 引发开源争议**，Meta 下架 Heretic 项目，Cohere 发布开源 MoE 模型。
- **Claude 推出免费 AI 课程**，但曝出劝用户睡觉的 bug。
- **Meta 裁员 8000 人**，与 AI 转型相关。

---

## 二、量子位（qbitai.com）最近 24 小时新闻

来源：[量子位](https://www.qbitai.com/)

### 热点新闻（按时间倒序）

| # | 标题 | 日期 | 链接 |
|---|------|------|------|
| 1 | **未来推理将吃掉70%算力，30%留给训练**丨硅谷投资人张璐@AIGC2026 | 05-25 | [阅读](https://www.qbitai.com/2026/05/423441.html) |
| 2 | **卷到今天，Agent的含金量还在提升**丨AIGC2026圆桌论坛 | 05-24 | [阅读](https://www.qbitai.com/2026/05/423421.html) |
| 3 | **谷歌CEO承认Coding落后了** | 05-24 | [阅读](https://www.qbitai.com/2026/05/423390.html) |
| 4 | **什么！你说胡彦斌也在苦修Vibe Coding** | 05-24 | [阅读](https://www.qbitai.com/2026/05/423213.html) |
| 5 | **OpenAI大神教你如何榨干Codex** | 05-23 | [阅读](https://www.qbitai.com/2026/05/423179.html) |
| 6 | **DeepSeek V4价格打骨折，宁王京东网易抢着入场**，梁文锋：目标是AGI | 05-23 | [阅读](https://www.qbitai.com/2026/05/423162.html) |
| 7 | **"五类人AI替代不了，企业做第二名最稳妥"**丨昆仑万维方汉@AIGC2026 | 05-23 | [阅读](https://www.qbitai.com/2026/05/423202.html) |
| 8 | **美团外卖前负责人入局餐饮具身模型**，元节智能获千万级种子轮融资 | 05-23 | [阅读](https://www.qbitai.com/2026/05/423159.html) |
| 9 | **李飞飞再出手，空间智能的ImageNet来了** | 05-22 | [阅读](https://www.qbitai.com/2026/05/422738.html) |
| 10 | **融资700亿！DeepSeek Code真要来了**，ACM金牌大神崔添翼挂帅 | 05-22 | [阅读](https://www.qbitai.com/2026/05/422624.html) |
| 11 | **狂揽F轮融资+拿下4100万用户！**深圳玩家出手，把企业旧系统变成AI能力库 | 05-22 | [阅读](https://www.qbitai.com/2026/05/422615.html) |
| 12 | **顶流里最快！智谱，你是在「喷」代码吧** — 400 tokens/s | 05-22 | [阅读](https://www.qbitai.com/2026/05/422511.html) |
| 13 | **80集短剧，3天拍完：当电影人下场做Agent**，影视生产迎来"最懂行"的解法 | 05-22 | [阅读](https://www.qbitai.com/2026/05/422455.html) |
| 14 | **龙虾养不动了？周鸿祎给虾搭了个云端办公室**，专业私教在线炼虾 | 05-22 | [阅读](https://www.qbitai.com/2026/05/422811.html) |
| 15 | **国产GPU开始造世界！**国内首个全栈具身智能仿真平台来了 | 近期 | [阅读](https://www.qbitai.com/2026/05/420084.html) |

### 关键要点解读

1. **AIGC 2026 大会焦点**：推理算力将吃掉 70% 算力资源，仅 30% 留给训练；Agent 赛道持续升温，大厂集体下场后创业公司仍在寻找差异化机会。

2. **DeepSeek 大动作**：V4 版本大幅降价，宁德时代、京东、网易等企业抢着接入；梁文锋公开承诺坚持开源路线，目标直指 AGI；DeepSeek Code 即将推出，由 ACM 金牌得主崔添翼挂帅，融资达 700 亿。

3. **谷歌 CEO 承认 Coding 落后**：搜索 25 年来最大改版，但谷歌对全面转向 AI 仍持谨慎态度。

4. **智谱代码生成速度惊人**：达到 400 tokens/s，位居"顶流里最快"。

5. **李飞飞空间智能新基准**：发布专门用于评测具身空间智能的新基准，被称为"空间智能的 ImageNet"。

6. **AI 替代讨论**：昆仑万维方汉提出"五类人 AI 替代不了"，认为 AI 时代经验不再是护城河，企业做第二名最稳妥。

7. **Vibe Coding 出圈**：艺人胡彦斌也在苦修 Vibe Coding，说明 AI 编程已破圈进入大众视野。

---

## 三、宝玉的分享（baoyu.io）最新文章

来源：[宝玉的分享 RSS](https://baoyu.io/feed.xml)，作者：宝玉

### 最新文章（2026年5月）

| # | 标题 | 日期 | 链接 |
|---|------|------|------|
| 1 | **DeepSeek 的 10 万亿美元大战略** | 05-23 | [阅读](https://baoyu.io/blog/2026-05-23/bookwormengr-status-2057909493250539891) |
| 2 | **来自 Codex 官方团队的分享：如何把 Codex 用到极致** | 05-20 | [阅读](https://baoyu.io/blog/2026-05-20/jxnlco-2057153744630890620) |
| 3 | **为什么我不"凭感觉编程"**（译） | 05-17 | [阅读](https://baoyu.io/translations/2026-05-17/i-dont-vibe-code) |
| 4 | **创始人手册：打造 AI 原生初创公司** | 05-16 | [阅读](https://baoyu.io/translations/2026-05-16/the-founders-playbook-building-an-ai-native-startup) |
| 5 | **Forward Deployed Engineer：AI 时代的新宠岗位，到底干什么？** | 05-15 | [阅读](https://baoyu.io/blog/2026-05-15/forward-deployed-engineer) |
| 6 | **AI 时代到底该怎么管一个工程团队** | 05-12 | [阅读](https://baoyu.io/blog/2026-05-12/running-an-ai-native-engineering-org) |
| 7 | **为什么资深开发者讲不清自己的专业能力**（译） | 05-12 | [阅读](https://baoyu.io/translations/2026-05-12/why-senior-developers-fail-to-communicate-their-expertise) |
| 8 | **Codex 的野心，MCP 和 Skill 的下一步** | 05-11 | [阅读](https://baoyu.io/blog/2026-05-11/skill-next-codex) |
| 9 | **深度拆解：AI Agent Harness 的构造**（译） | 05-10 | [阅读](https://baoyu.io/translations/2026-05-10/akshay-pachaar-2041146899319971922) |
| 10 | **裁员潮将持续，直到我们学会发掘 AI 的商业价值**（译） | 05-10 | [阅读](https://baoyu.io/translations/2026-05-10/championswimmer-2051807284691612099) |
| 11 | **机器人的终局：英伟达 Jim Fan 宣告 VLA 时代结束，WAM 登场** | 05-10 | [阅读](https://baoyu.io/blog/robotics-end-game-nvidias-jim-fan) |
| 12 | **使用 Claude Code：HTML 难以置信的奇效**（译） | 05-08 | [阅读](https://baoyu.io/translations/2026-05-08/trq212-status-2052809885763747935) |
| 13 | **Anthropic 兄妹 Dario Amodei 和 Daniela Amodei 最新对话：Claude 为什么一直限速？** | 05-06 | [阅读](https://baoyu.io/blog/a-conversation-with-dario-amodei-daniela-amodei) |
| 14 | **Boris Cherny：Claude Code 之后，写代码正在变成"管理 Agent"** | 05-05 | [阅读](https://baoyu.io/blog/anthropics-boris-cherny-why-coding-is-solved-and-what-comes-next) |
| 15 | **大多数公司根本没有为 AI 做好准备** | 05-03 | [阅读](https://baoyu.io/blog/2026-05-03/danielmiessler-status-2050666594188304484) |

### 关键主题趋势

1. **AI 编程范式转变**：从 Vibe Coding 的争议到 Agentic Engineering 的兴起，编程正在从"写代码"变成"管理 Agent"。Boris Cherny 和 Karpathy 都在强调这一转变。

2. **Claude Code 深度生态**：多篇文章聚焦 Claude Code 的 Skills 机制、会话管理、Token 优化和 HTML 交互，反映出 Claude Code 正成为 AI 编程的事实标准之一。

3. **企业 AI 转型焦虑**：裁员潮、组织重构、AI 经济学——企业用不好 AI 往往不是因为 AI 不够强，而是因为组织自身说不清目标、流程和成本。

4. **机器人与具身智能**：Jim Fan 宣告 VLA（视觉-语言-动作）时代结束，提出以世界动作模型（WAM）为核心的新范式，预测 2040 年到达机器人终局。

5. **DeepSeek 商业模式探讨**：DeepSeek 的 10 万亿美元大战略引发关注，社区开始认真讨论其盈利路径。

---

## 四、综合热点分析

### 4.1 本周 AI 圈五大关键词

1. **Agent 编排**：从 Harness 框架到子智能体拓扑，从 OpenCodex 到 Devin，Agent 正在从单智能体向多智能体编排演进。

2. **推理算力爆发**：硅谷投资人预测推理将吃掉 70% 算力，训练仅占 30%，标志着 AI 产业从"建模型"到"用模型"的关键转折。

3. **DeepSeek 全线出击**：V4 降价、Code 即将发布、700 亿融资、10 万亿美元战略——DeepSeek 正在成为全球 AI 格局中最不可忽视的中国力量。

4. **Vibe Coding 出圈与反思**：从艺人胡彦斌到专业开发者，Vibe Coding 已破圈进入大众视野，但同时也引发关于代码质量、工程责任的深度讨论。

5. **AI 时代的组织重构**：Meta 裁员 8000 人、Anthropic 兄妹谈限速、工程团队管理新范式——AI 不仅改变技术，更在重塑整个行业的组织形态。

### 4.2 值得关注的趋势

- **模型架构创新加速**：RAEv2、Gated DeltaNet-2、Mamba-3 等新型架构正在挑战 Transformer 的统治地位。
- **开源 vs 闭源博弈加剧**：Qwen3.7 Max 引发开源争议，Cohere 发布开源 MoE，Meta 下架 Heretic——开源路线的定义和边界正在被重新协商。
- **Coding Agent 成为新入口**：Codex、Cursor、Claude Code 等编程智能体正在成为开发者日常工作的新入口，竞争从模型能力转向产品体验和生态整合。
- **AI 经济学引发关注**：按量计费、Token 成本、数据中心债务——AI 的经济账正在成为行业焦点。

---

## 信息来源

- [AI 开发者日报](https://ainews.liduos.com/) — 专为中文开发者打造的 AI 技术日报，每日更新 RSS：[https://ainews.liduos.com/rss.xml](https://ainews.liduos.com/rss.xml)
- [量子位](https://www.qbitai.com/) — 追踪人工智能新趋势，报道科技行业新突破 RSS：[https://www.qbitai.com/feed](https://www.qbitai.com/feed)
- [宝玉的分享](https://baoyu.io/) — 大语言模型、Prompt Engineering、软件工程等领域深度内容 RSS：[https://baoyu.io/feed.xml](https://baoyu.io/feed.xml)

---

*报告生成时间：2026-05-25 | 由 AI 自动整理生成*
