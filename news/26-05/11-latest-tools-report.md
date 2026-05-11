# AI 开源工具报告
**日期**: 2026-05-11
**来源**: ossinsight.io（Rust/Go/Python/TypeScript/Shell 语言新兴项目）、hellogithub.com

---

## 说明

本报告通过 GitHub API 筛选各语言在过去一个月内新建且获星量最高的新兴项目（`created:2026-04-01..2026-05-11`），同时收录 [HelloGitHub](https://hellogithub.com/) 平台最新上线但未在上一期（第 121 期）月刊中收录的项目。所有数据通过 GitHub Search API 和 Web 检索自动化抓取。

> **注**：HelloGitHub 月刊每月 28 号发布。第 121 期（4 月 28 日）已在上一份报告覆盖，第 122 期预计 5 月 28 日发布。本报告补充 HelloGitHub 平台于 5 月上线的增量项目。

---

## HelloGitHub 平台 5 月增量精选

以下项目为 HelloGitHub 平台 5 月最新上线、且未在第 121 期月刊中收录的项目：

| 项目 | Stars | 语言 | 简介 |
|------|-------|------|------|
| [DeepSeek-TUI](https://github.com/Hmbown/DeepSeek-TUI) | 1.8k | Rust | 运行在终端中的 DeepSeek V4 编码助手，可直接读写文件、执行命令 |
| [OfficeCLI](https://github.com/iOfficeAI/OfficeCLI) | 1.9k | C# | 命令行工具，可直接创建、读取、修改 Word/Excel/PPT 文件 |
| [claude-code-mem](https://github.com/thedotmack/claude-mem) | 6.8w→持续增长 | Python | Claude Code 持久化记忆压缩系统，支持语义搜索跨会话记忆 |

---

## 各语言新兴项目 TOP 2

### Rust

| # | 项目 | Stars | 简介 |
|---|------|-------|------|
| 1 | [h4ckf0r0day/obscura](https://github.com/h4ckf0r0day/obscura) | **11.4k** | 面向 AI Agent 和网页抓取的无头浏览器（headless browser），专为自动化工作负载设计 |
| 2 | [ultraworkers/claw-code-parity](https://github.com/ultraworkers/claw-code-parity) | **6.7k** | Claw Code 的 Rust 移植版本，社区驱动的开源复现项目 |

**趋势解读**：Rust 新兴项目呈现出强烈的 **AI Agent 基础设施化**倾向。obscura 将浏览器变成 AI 可直接调用的底层工具，而 claw-code-parity 则反映了社区对高性能 AI 编程工具 Rust 化复现的热情。两者都指向同一方向——用 Rust 构建 AI Agent 的高性能底层执行环境。

---

### Go

| # | 项目 | Stars | 简介 |
|---|------|-------|------|
| 1 | [maaslalani/sheets](https://github.com/maaslalani/sheets) | **2.2k** | 终端电子表格工具，在命令行中直接操作和浏览表格数据 |
| 2 | [432539/gpt2api](https://github.com/432539/gpt2api) | **1.5k** | 基于 ChatGPT.com 逆向的 OpenAI 兼容 SaaS 网关，支持批量出图、多账号池、高并发调度 |

**趋势解读**：Go 的新兴项目体现出两个方向：一是 **终端工具持续进化**（sheets 将生产力场景搬到命令行），二是 **AI API 的基础设施层**（gpt2api 通过逆向工程提供稳定、低成本的 OpenAI 兼容网关，降低了 AI 能力接入的门槛）。

---

### Python

| # | 项目 | Stars | 简介 |
|---|------|-------|------|
| 1 | [MemPalace/mempalace](https://github.com/MemPalace/mempalace) | **51.9k** | 性能最佳的开源 AI 记忆系统，基准测试领先，免费使用 |
| 2 | [safishamsi/graphify](https://github.com/safishamsi/graphify) | **46.2k** | AI 编程助手 Skill（支持 Claude Code、Codex、Cursor、Gemini CLI 等），将任意代码文件夹、SQL schema 等转化为可查询的知识图谱 |

**趋势解读**：Python 生态的爆发力惊人。mempalace 在一个月内从零冲到 **5.2 万星**，graphify 一个月内从 3.6k 暴涨至 **4.6 万星**（增长超 10 倍）。两个项目都围绕 **AI Agent 的记忆与知识管理**——mempalace 解决"记住什么"，graphify 解决"理解代码结构"。这印证了 AI 编程助手生态中"记忆系统"已成为最核心的差异化能力之一。

---

### TypeScript

| # | 项目 | Stars | 简介 |
|---|------|-------|------|
| 1 | [nexu-io/open-design](https://github.com/nexu-io/open-design) | **36.4k** | 本地优先的 AI 设计工具，开源的 Anthropic Claude Design 替代品。内置 19 个 Skills、71 套品牌级设计系统，支持 AI 生成 UI 设计稿 |
| 2 | [Gitlawb/openclaude](https://github.com/Gitlawb/openclaude) | **26.3k** | Claude Code 的开源替代方案——"在任何地方运行，使用任何后端" |

**趋势解读**：TypeScript 社区正在上演一场 **AI 工具的"去平台化"运动**。open-design（36.4k 星）试图用开源方案替代 Anthropic 的设计工具，openclaude（26.3k 星）则试图解耦 Claude Code 的 API 依赖。这种"开源替代 Anthropic 全家桶"的浪潮，与 DeepClaude（Claude Code 环 + DeepSeek 后端）同属一条主线——开发者拒绝被单一供应商锁定。

---

### Shell

| # | 项目 | Stars | 简介 |
|---|------|-------|------|
| 1 | [hexiecs/talk-normal](https://github.com/hexiecs/talk-normal) | **1.6k** | 让任何 LLM "说人话"的 system prompt——去除 AI 腔（slop），输出自然对话风格 |
| 2 | [fluffypony/dothething](https://github.com/fluffypony/dothething) | **1.6k** | 自主 AI Agent——你描述任务，它自动完成。极简 Shell 风格的工作流设计 |

**趋势解读**：Shell 项目虽星数较少，但指向两个有趣方向：**AI 输出的"去 AI 化"**（talk-normal 让 LLM 输出更像真人）和 **极简 Agent 设计**（dothething 用一个 Shell 脚本实现"你说我做"的 Agent 理念）。Shell 语言在 AI 生态中的角色正从"系统管理脚本"转向"Agent 的快捷原型和胶水语言"。

---

## 关键趋势总结

1. **AI 记忆系统爆发**：mempalace（5.2 万星）和 graphify（4.6 万星）分别从"通用记忆"和"代码知识图谱"两个维度切入，记忆系统成为 AI Agent 基础设施中最热门的赛道
2. **开源替代 Anthropic 生态运动**：open-design（替代 Claude Design）、openclaude（替代 Claude Code）、claw-code-parity（Rust 移植 claw-code）——开发者正系统性地为 Anthropic 的每一项闭源产品创建开源替代
3. **Rust 进军 AI Agent 基础设施**：obscura 的无头浏览器专为 AI Agent 设计，claw-code-parity 用 Rust 重写 AI 编程工具——Rust 的性能和安全优势使其成为 Agent 底层工具链的理想语言
4. **AI 的"人性化"需求涌现**：talk-normal 让 AI 输出去除机器腔，反映出用户对 AI 交互体验的更高要求——不再满足于"能回答"，而是追求"像人一样交流"
5. **TypeScript 生态去中心化**：open-design 和 openclaude 均在一个月内获得数万星，表明前端开发者社区对 AI 工具开源化的强烈意愿
