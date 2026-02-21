# SkillsBench 论文结论：自生成 Agent Skills 毫无用处

> 论文 arXiv:2602.12670 — 系统性验证 Skills 是否有价值

## 核心结论

**自生成的 Agent Skills 毫无用处** — 这是 SkillsBench 论文的核心发现。

论文在一个专门设计的基准上测试发现：让模型自己写一套"技能/流程指南"，平均并不能提高成功率，甚至略微下降。

## 背景：什么是 Agent Skill？

Agent Skill 被定义为一种结构化的"程序性知识包"，用于在推理/执行时增强 Agent：

- 通常是一个文件夹，包含 SKILL.md（流程/操作步骤）
- 可选脚本、模板、参考资料、示例等
- 核心特征是「怎么做」，而不是「是什么」

**Skill 不等于**：
- 普通系统提示词
- Few-shot
- RAG 检索
- 纯工具文档

Skill 更强调**可复用的工作流/SOP + 结构化资源**。

## 论文区分的两类 Skills

### Curated Skills（人工设计的技能）
提前设计好的、结构化的"操作指南 + 资源包"，能落地执行的 SOP。

### Self-generated Skills（自生成技能）
模型自己写的技能。例如：给模型一个任务，要求它先"写一个技能文件"，然后再用自己写的技能去做任务。

## SkillsBench Benchmark 设计

### 任务规模
- **84 个任务**，覆盖 **11 个领域**
- 每个任务都有确定性验证场景（跑脚本/单测，给出 pass/fail）

### 任务难度分布
| 难度 | 数量 | 人类完成时间 |
|------|------|-------------|
| Core | 17 个 (19.8%) | < 60 min |
| Extended | 43 个 (50.0%) | 1–4 hours |
| Extreme | 26 个 (30.2%) | > 4 hours |

### 三种测试条件
1. **No Skills**：只有任务说明 instruction.md，环境里没有 skills
2. **With Skills（Curated Skills）**：提供专业写好的完整技能包
3. **Self-Generated Skills**：要求模型先自己生成"技能文件"再做任务

## 核心实验结果

| 条件 | 平均通过率 | 相对收益 |
|------|-----------|---------|
| No Skills | 24.3% | 基准 |
| Curated Skills | 40.6% | **+16.2pp** |
| Self-generated Skills | 21.0% | **-1.3pp** |

### 关键发现

1. **Self-generated Skills 普遍无效**
   - 除了 Claude Code Opus 4.6 有 +1.4pp，其他模型均下降
   - Codex + GPT-5.2 甚至出现了 -5.6pp

2. **Curated Skills 效果显著但非完美**
   - 84 个任务里有 16 个任务出现负向 delta
   - 平均收益 +16.2pp

## Self-generated Skills 失败原因

论文通过轨迹分析总结了两个典型失败模式：

### 1. 知识泛化不完整
- 知道需要领域知识，但写出来太泛/不完整
- 例如：只写"用 pandas 处理数据"，却不给关键 API 模式、坑点、验证方法、边界条件

### 2. 领域知识缺失
- 高领域知识任务里，没意识到需要专门技能
- 在制造、金融等任务上，模型常用"通用解法"硬莽
- 错过了需要 SOP/行业流程的关键步骤

> 模型"会做"但"不会写出可复用的程序性知识"。

## 技能设计因素分析

### 技能数量
- **2–3 个模块最好**，太多反而拖累
- 按任务提供的 skill 数量分组：2–3 skills 提升最大（+18.6pp），4 个以上提升很小

### 技能文档复杂度
- **聚焦型胜过"大全型"**
- detailed、compact 提升更大
- comprehensive（"把所有东西都塞进去"）平均降低了 **-2.9pp**

> 技能不是越长越好，而是要把 agent 下一步要做什么写清楚。

## 结论

1. **Self-generated Skills 几乎没用**，甚至拉低效果
   - 关键原因：模型很难稳定写出真正可执行、降低搜索空间的程序性知识
   - 生成的往往是"看起来像指南的废话"

2. **高质量技能 = 搜索空间压缩器**
   - 限定决策路径
   - 减少无效探索
   - 提供验证锚点
   - 显式化领域隐性流程

3. **避免百科式技能**
   - 可能带来更多噪音
   - 如果发现 Skill 用多了 Agent 反而变傻，不是 Agent 的问题，是 Skill 的问题

---

## 来源

- 论文：SkillsBench: Benchmarking How Well Agent Skills Work Across Diverse Tasks (arXiv:2602.12670)
- 生态数据：ClawHub 官方注册 Skills 7800+
