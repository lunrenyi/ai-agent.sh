# Welcome to the Wasteland：连接数千个 Gas Town 的协作网络

> Steve Yegge 介绍 AI 驱动的分布式工作协作新范式

---

## 引言

Steve Yegge 在这篇文章中介绍了 **Wasteland**（废土）—— 一个连接数千个 Gas Town 的信任网络，旨在让人们能够以极快的速度协作构建项目。

这标志着 AI 编程协作从"单人编程"向"大规模协作"的进化。

---

## 什么是 Wasteland？

Wasteland 是 Gas Town 的必然进化产物：

- **核心概念**：将大量 Gas Town 用户连接在一起，形成信任网络
- **核心功能**：共享的 Wanted Board（需求看板）
- **核心理念**：以工作成果为输入，以声誉为输出

> "Wasteland 的设计目的是 federating work，但它向 RPG 的演变似乎势不可挡。"

---

## 核心角色系统

Wasteland 有三种核心角色：

| 角色 | 描述 |
|------|------|
| **Rigs** | 执行工作的实体，每个 Rig 对应一个人类参与者 |
| **Posters** | 发布任务的人，任何 Rig 都可以发布工作 |
| **Validators** | 验证工作质量的人，需要达到维护者级别的信任 |

> 信任等级：
> - **Level 1（注册参与者）**：浏览、认领、提交工作
> - **Level 2（贡献者）**：获得更多权限
> - **Level 3（维护者）**：可以验证他人的工作并发放 Stamp

---

## Wanted Board：需求看板

Wanted Board 是 Wasteland 的核心对象，一个共享的开放工作列表：

**工作生命周期**：
1. **Open** - 任务开放
2. **Claimed** - 被认领（其他 Rig 可以看到谁在做什么）
3. **In Review** - 提交完成，等待验证
4. **Completed** - 验证通过，完成

每个工作项包含：标题、描述、工作量估计、标签

---

## Stamp：多维度声誉系统

Stamp 不是简单的通过/失败，而是**多维度证明**：

```
Stamp = {
  质量 (Quality),
  可靠性 (Reliability),
  创造力 (Creativity),
  置信度 (Confidence),    // 验证者有多大把握？
  严重性 (Severity)     // 这是叶子任务还是架构决策？
}
```

**Stamp 原则**：
- 每个 Stamp 锚定到具体的完成证据
- 声誉始终可追溯到真实工作
- **年鉴规则**：不能给自己盖章（你的声誉来自他人评价）

---

## 联邦化设计

Wasteland 采用联邦化而非中心化设计：

- 任何人都可以创建自己的 Wasteland（团队、公司、大学、开源项目）
- 每个 Wasteland 都是独立的主权数据库
- **Rig 身份可跨 Wasteland 迁移**：在根 Commons 注册后，可以加入 Grab 的 Wasteland、大学的 Wasteland
- 你的 Stamp 跟着你走

> "工作是唯一的输入，声誉是唯一的输出。没有购买声誉的方式，没有刷粉，没有脱离证据的社交信号。"

---

## RPG 元素

Wasteland 融入了游戏化元素：

- **Character Sheets（角色卡）**：预置了 GitHub top 10k 贡献者的数据
- **Leaderboards（排行榜）**：展示贡献者排名
- **Levels（等级）**：原本有等级系统，但 Steve Yegge 是 18 级而 Linus Torvalds 是 14 级，所以被放弃了

> "我不建议你太执着于你的高分。在未来 2-3 个月内，我们很可能会推翻整个系统至少两次。"

---

## 技术基础：Dolt

Wasteland 建立在 **Dolt** 之上——一个具有 Git 语义的 SQL 数据库：

- 可以 fork、branch、merge、发送 pull requests
- 适用于结构化数据
- 这使得整个联邦化协作成为可能
- Schema 迁移变得轻而易举

---

## 如何参与

简单入门步骤：

1. 安装 Dolt 并创建免费的 DoltHub 账户
2. 访问 [gastownhall.ai](https://gastownhall.ai) 浏览 Wanted Board
3. 加载 Wasteland Claude skill，让你的 agent 引导你完成 `wl join`

> "如果你觉得这些指令不够，等一周或两周——我们会让你更容易上手。如果觉得够了，欢迎来到 Wasteland。你正是我们在寻找的人。"

---

## 未来展望

- **Gas City**：将 Gas Town 拆解成可组合的部件，让用户自定义编排拓扑
- **工厂式编程 Agent**：构建一个真正愿意做重复工作的编程 Agent
- **沙盒和私有仓库机制**

---

## 我的思考

Wasteland 代表了一种全新的 AI 时代工作范式：

1. **从个人到群体**：从"一个人指挥 AI 编程"到"指挥一群 AI 协作"
2. **从中心化到联邦化**：不依赖单一平台，而是让声誉跨平台迁移
3. **从雇佣到证明**：不再是自己声称擅长什么，而是他人对你的工作盖章认可
4. **Git 工作流的扩展**：将 PR 模式从代码协作扩展到所有形式的工作

> "世界需要像一个工厂工人一样工作的编程 Agent，而我们现在还没有。所以它会被构建出来。"

---

## 参考资料

- [gastownhall.ai](https://gastownhall.ai)
- [Dolt - Git for Data](https://www.dolthub.com/)
- Steve Yegge's Gas Town 系列文章

---

*本文是对 Steve Yegge 文章的整理与思考，原文发表于 5 天前。*
