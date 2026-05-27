# AI 技术日报

*每日精选 AI 技术前沿动态 — 2026年5月26日（周二）*

---

今日看点：GPT-5.6 意外泄漏、Grok V9 完成训练、Figure 03 机器人 200 小时零故障、Google DeepMind 攻克 9 个 Erdős 难题、vLLM Rust 前端实现 5 倍吞吐提升。

---

## 🔬 头条深度：模型军备竞赛进入"推理效率"新维度

### GPT-5.6（iris-alpha）意外泄漏，1.5M 上下文窗口浮出水面

5月26日，多位开发者在 OpenAI Codex 后端日志中发现了一个代号为 **"iris-alpha"** 的新模型，被广泛认为是 **GPT-5.6** 的预览版本。最引人注目的数据点：**150 万 token 上下文窗口**——相较 GPT-5.5 的 105 万 token 增加了约 43%。

泄漏信息显示，6 月将成为 AI 模型发布的"超级月"：**Claude Sonnet 4.8、Gemini 3.5 Pro、Grok 5** 均预计在此期间亮相。上下文窗口的持续扩展不仅是"更大"的问题——它直接决定了 AI 智能体能够处理的连续任务长度和记忆跨度，是 Agentic AI 场景的核心瓶颈。

> **为什么重要：** 上下文窗口正在成为继模型参数之后的第二战场。从 GPT-5 的 256K → GPT-5.5 的 1.05M → GPT-5.6 的 1.5M，不到一年内翻了近 6 倍。但扩展上下文窗口也带来推理成本的指数增长，需要新的注意力机制来平衡。

📎 [Source: The Neuron — Everything That Happened in AI Today](https://www.theneuron.ai/explainer-articles/everything-that-happened-in-ai-today-tuesday-may-26-2026/)

---

### xAI Grok V9-Medium 完成训练：1.5T 参数，Cursor 数据加持

Elon Musk 宣布 xAI 已完成 **Grok V9-Medium** 的训练，这是一个 **1.5 万亿参数**的超大规模模型。值得关注的一个细节是：训练数据中包含了大量 Cursor 使用数据——这意味着代码编辑行为和工具调用模式被纳入了训练语料。微调正在进行中，预计 2-3 周内公开发布。

与此同时，Anthropic 据报租用了 SpaceX/xAI 位于孟菲斯的 **Colossus 1 超算集群（22万+ GPU）**，用于扩大 Claude 模型训练规模。竞争对手使用同一训练基础设施——这在 AI 产业中尚属首次。

📎 [Source: AINews May 26](https://news.smol.ai/issues/26-05-26-not-much/) | [Source: AI Morning News May 26](https://www.neican.ai/morningnews/2026-05-26-ai-2026-05-26-/)

---

### Figure 03 人形机器人完成 200 小时零故障连续运行

Figure AI 的 **Figure 03** 人形机器人在一场全程直播中完成了 **200 小时持续完全自主仓库作业**，分拣 25 万个包裹，**零硬件故障**。原定目标是 8 小时，实际成绩超出 **25 倍**。

这标志着人形机器人从"舞台演示"向"工业级可靠性"的关键跨越。200 小时的连续自主运行意味着机器人在实际物流场景中具备了可部署性——不再是实验室玩具。

📎 [Source: The Neuron — May 26 AI Roundup](https://www.theneuron.ai/explainer-articles/everything-that-happened-in-ai-today-tuesday-may-26-2026/)

---

## ⚡ 技术快讯

- **Google DeepMind 用 LLM-Lean 攻克 9 个 Erdős 开放问题**——使用具备形式化验证的自主 LLM-Lean 智能体，在人类评审之前就解决或找到了 9 个 Erdős 开放问题的已知解。与 OpenAI 上周用推理模型解决 Erdős 单位距离猜想不同，DeepMind 的方法强调形式化验证（Lean）确保每一步推理是机器可检查的。这是"LLM + 形式化验证"范式的又一次重要验证。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **vLLM Rust 前端合并入主线：预处理场景吞吐量提升 5 倍**——vLLM 正式合并了 **Rust 前端**，作为 Python API Server 的直接替代方案。在预处理密集型工作负载上测得 **~837 req/s vs 原本的 ~162 req/s**，近 **5.2 倍提升**。对于需要大量 prompt 处理的推理场景（如长上下文、RAG 检索增强），这一改进直接意味着更低的 GPU 空闲等待时间和更高的硬件利用率。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **MiniMax M3 公开稀疏注意力细节：1M token 下预填充 9.7 倍加速**——MiniMax 公布了 M3 的开源计划，并透露了核心技术创新：一种新的 **block-sparse 两阶段注意力路径**。在 100 万 token 上下文下，相较 M2 实现了 **9.7 倍预填充加速和 15.6 倍解码加速**。如果开源承诺兑现，这将是长上下文推理效率的一个重要里程碑。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **Stanford HAI 提出"项目反应标度律"：模型扩展预测的计算量降低 99%**——传统标度律（Scaling Laws）需要训练多个不同规模的模型来预测大模型的表现，计算成本极高。Stanford HAI 引入测量科学方法中的项目反应理论（IRT），在大幅降低计算需求的同时保持甚至提升了预测精度。对那些没有财力做大规模预实验的团队来说，这是一个游戏规则的改变。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **SenseTime 开源 SenseNova-U1 完整训练代码**——商汤科技开源了统一多模态系列 **SenseNova-U1** 的完整训练代码库（8B dense + A3B MoE），涵盖从数据到训练到评估的全流程。在开源大模型日益内卷的当下，"完整训练代码"而非仅"模型权重"正成为差异化竞争的新维度。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **华为发布"Tao (τ) 定律"：绕过 EUV 实现 1.4nm 等效晶体管密度**——在 IEEE ISCAS 2026 上，华为何庭波提出了 **"Tao 定律"**：用"时间折叠"（逻辑折叠 + 3D 堆叠）替代传统的"几何缩小"来延续芯片性能增长。华为声称已使用该方案在 6 年内量产 **381 款芯片**。对于受限于先进制程的中国 AI 芯片产业，这是一条可行的绕过路径。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **LLM 需要"睡眠"——新论文提出将 KV Cache 转为持久化 Fast Weights**——一篇引发关注的新论文提出：在 AI 智能体执行长轨迹任务时，与其无限扩大 KV Cache，不如在"休息"阶段将近期上下文**固化为持久化的 fast weights**，然后清空 KV Cache。这与 Anthropic 正在开发的 Claude "Memory Files"（文件系统级的永久记忆）和 "Dream"（模拟睡眠来巩固记忆）功能方向一致。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

- **Anthropic 租用 Colossus 1 集群 + Microsoft 重组领导层**——Anthropic 租用了 SpaceX/xAI 的 Colossus 1（22万+ GPU）用于 Claude 训练扩展。Microsoft CEO Nadella 废除了高级领导团队（SLT），重组为 5 人战略层 + 35 人工程组 + 3 人 Copilot 团队，并亲自每周审查 AI 指标。 [Source](https://news.smol.ai/issues/26-05-26-not-much/)

---

## 📈 今日数据

> **28.9 万亿** — 全球 AI 模型每周 token 使用量，连续 5 周增长（+7.4% WoW）。中国模型达到 9.22 万亿 token/周，连续第四周超越美国模型。**DeepSeek-V4-Flash** 登顶 OpenRouter 全球调用量排行榜。推理需求仍在加速，Epoch AI 警告推理算力供应可能已出现缺口。

📎 [Source: The Neuron — May 26 AI Roundup](https://www.theneuron.ai/explainer-articles/everything-that-happened-in-ai-today-tuesday-may-26-2026/)

---

## 👀 明日关注

- **GPT-5.6 正式发布日期**——iris-alpha 泄漏后，OpenAI 是否会提前公布发布时间表？
- **Grok V9-Medium 微调细节**——这个 1.5T 参数模型的实际推理能力和成本将是关注焦点
- **vLLM Rust 前端生产就绪程度**——Rust 替代 Python API Server 的性能收益能否在更多真实场景中复现？
- **QUEST 系列开源模型（2B–35B）**——面向长程事实搜索和报告合成的模型家族，值得评估

---

*AI 技术日报每日精选 AI 领域最重要的技术进展与研究突破。*  
*欢迎转发给对 AI 技术感兴趣的朋友。*

*所有来源均已内联标注。观点部分为原创技术评论。*
