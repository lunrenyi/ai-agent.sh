# OpenAI 2025 开发者年度报告

> 翻译整理自 OpenAI Developers Blog

---

## 核心要点 (TL;DR)

- **重大转变**：代理原生 APIs + 更好的模型，可执行更复杂任务
- **Codex 成熟**：GPT-5.2-Codex 提供仓库级推理能力
- **改进的工具链**：更容易将模型连接到实际系统
- **多模态成为实际默认**：PDF、图像、音频、视频
- **Evals、graders 和调优功能成熟**：形成可重复的"测量→改进→发布"循环

---

## 1. 推理能力 (Reasoning)

### 发展历程

- 2024 年底：推出"思考时间"范式
- 2025 年初：**o1、o3、o4-mini** 等专用推理模型
- **o3-mini**：首个表明推理可进入成本效益好、开发者友好形态的信号
- 2025 年中后期：**融合趋势** - 推理深度、工具使用和对话质量整合到同一旗舰模型线

### 具体产品

| 模型 | 定位 |
|------|------|
| o1 | 推理模型 |
| o3 / o4-mini | 深度推理 |
| o3-mini | 高效推理 |
| GPT-5.x 系列 | 统一推理能力 |

---

## 2. 多模态能力 (Multimodality)

### 音频 + 实时

- **下一代音频模型**：提高语音转文本准确性，增强可控文本转语音
- **Realtime API**：正式发布，支持低延迟双向音频流

### 图像

- **GPT Image 1**：新一代图像生成模型，高质量图像和结构化编辑
- **GPT Image 1 mini**：更高效的图像生成
- **GPT Image 1.5**：最高级图像生成模型，显著提升图像质量和编辑一致性

### 视频

- **Sora 2 & Sora 2 Pro**：更高保真度视频生成，更强时间一致性
- **Video API**：通过 `v1/videos` 提供视频生成和编辑

### PDF 和文档

- **PDF 输入**：直接在 API 中处理文档密集型工作流
- **PDF-by-URL**：通过引用文档减少上传摩擦

---

## 3. Codex

### 模型

- **GPT-5.2-Codex**：代码生成、审查和仓库级推理的最新默认选择

### CLI

- **Codex CLI**（开源）：直接在本地环境运行代理风格编码
- 支持脚本化自动化模式

### 安全与控制

| 功能 | 描述 |
|------|------|
| 沙盒功能 (Sandboxing) | 安全隔离 |
| 审批模式 (Approval Modes) | 让人保持控制 |
| AGENTS.md | 定义代理行为规范 |
| MCP | 支持第三方工具扩展 |

### 平台支持

- **Web + Cloud**：更长会话支持
- **IDE 扩展**：更紧密的推理与代码更改循环
- **Codex Autofix**：CI 中的自动化修复

---

## 4. 平台转变：Responses API 和代理构建块

### Responses API

- 支持多种输入输出，包括不同模态
- 支持推理控制和摘要
- 改进的工具调用支持（包括推理期间）

### 高级构建块

- **Agents SDK**（开源）：Python 和 TypeScript
- **AgentKit**：更高级的代理开发工具

### 状态管理

- **Conversation State**：持久化线程和可重放状态
- **Connectors 和 MCP 服务器**：整合外部上下文

### 内置工具

| 工具 | 用途 |
|------|------|
| Web 搜索 | 获取最新信息和引用 |
| 文件搜索 | 矢量存储，RAG 基础 |
| Code Interpreter | 沙箱中运行 Python |
| Computer Use | 点击/输入/滚动自动化 |

---

## 5. 运行和扩展

- **Prompt 缓存**：减少延迟和输入成本
- **Background 模式**：长时间运行响应
- **Webhooks**：事件驱动系统
- **Rate Limits**：工作负载优化指导

---

## 6. 开放标准和开源

### Agents SDK

- **Python** 和 **TypeScript** 版本
- 工具使用、切换、护栏、追踪的构建块
- **提供商无关**：支持非 OpenAI 模型

### AgentKit

- Agent Builder
- ChatKit
- Connector Registry
- 评估循环

### 开放标准

- **AGENTS.md** 规范
- **AAIF (Agentic AI Foundation)**
- **MCP (Model Context Protocol)**
- **Skills**

### 开源模型

- **gpt-oss 120b & 20b**：自托管部署的推理模型
- **gpt-oss-safeguard 120b & 20b**：安全策略模型

---

## 7. 评估、调优和安全发布

- **Evals API**：评估驱动开发
- **Reinforcement Fine-tuning (RFT)**：使用可编程 graders
- **Supervised Fine-tuning / Distillation**：质量下沉到更小模型
- **Graders**：评分函数
- **Prompt Optimizer**：提示优化

---

## 8. 按任务推荐模型（2025 年底）

| 任务 | 推荐模型 |
|------|----------|
| 通用（文本+多模态）| GPT-5.2 |
| 深度推理/可靠性敏感 | GPT-5.2 Pro |
| 编码和软件工程 | GPT-5.2-Codex |
| 图像生成和编辑 | GPT Image 1.5 |
| 实时语音 | gpt-realtime |

---

## 总结：五大主题

1. **可扩展、可控的推理**作为核心能力
2. **原生 API** + 统一的代理表面
3. **开放的构建块**和新兴互操作性标准
4. **深度多模态支持**（文本、图像、音频、视频、文档）
5. 更强大的**生产工具**用于评估、调优和部署
