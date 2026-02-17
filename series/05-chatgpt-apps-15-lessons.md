# 15 Lessons Learned Building ChatGPT Apps

> 翻译整理自 OpenAI Developers Blog，原文来自 Alpic 公司

---

## 核心要点

### "Three Body Problem"（三方问题）

传统 Web 应用只有**用户**和 **UI** 两方，而 ChatGPT App 引入了第三方：**模型**。

这导致了 **context asymmetry（上下文不对称）**——每个主体只持有部分信息，没有任何一个拥有完整视图。

构建好的 ChatGPT Apps 需要明确决定：
- **什么信息**应该共享
- **何时**共享
- **谁**需要看到

---

## 15 个 Lessons

### 基础：上下文管理

#### Lesson 1: 并非所有上下文都需要共享

> "Different parts of a ChatGPT App often need intentionally different views of the same state."

**解决方案**：使用不同的工具输出字段

| 字段 | 可见性 |
|------|--------|
| `structuredContent` | 同时对 widget 和模型可见 |
| `_meta` | 仅对 widget 可见，模型无法访问 |

#### Lesson 2: 懒加载不适用于 AI 应用

> "In ChatGPT, the paradigm is reversed: tool calls imply delays."

**最佳实践**：**前置加载**（front-load aggressively）
- 尽可能在初始工具响应中发送更多数据
- 避免让模型等待工具调用返回

#### Lesson 3: 模型需要可视性

使用 `window.openai.setWidgetState(state)` 让模型知道用户当前查看的 UI 内容。

团队还开发了 `data-llm` 属性实现**声明式 UI 上下文共享**。

#### Lesson 4: 不同交互需要不同的 API

需要明确区分三种通信路径：

| 路径 | 描述 |
|------|------|
| widget ↔ server | 传统 API 调用 |
| widget ↔ model | 模型直接调用工具 |
| server ↔ model | 服务端消息传递 |

---

### UI 重构

#### Lesson 5: UI 必须适配多种显示模式

ChatGPT Apps 有三种显示模式：

| 模式 | 描述 |
|------|------|
| **Inline** | 默认模式，嵌入对话中 |
| **Fullscreen** | 占据整个屏幕 |
| **Picture-in-Picture (PiP)** | 悬浮在对话上方 |

#### Lesson 6: UI 一致性在嵌入式环境中尤为重要

**建议**：使用 OpenAI 官方的 **Apps SDK UI Kit**（基于 Tailwind CSS）来保持与 ChatGPT 的视觉一致性。

#### Lesson 7: 语言优先的过滤

> "Instead of a sidebar with options to filter and sort, we provide the model with a List of Values (LOV)."

让用户可以直接用**自然语言**表达意图，而不是通过 UI 控件。

#### Lesson 8: 文件可以解锁更丰富的交互

文件不应被视为次要输入。通过 `openai/fileParams` 让模型可以直接处理上传的文件。

Widget 端也可以使用 `window.openai.uploadFile`。

---

### 生产环境

#### Lesson 9: CSP 是新的 CORS

> "Unlike traditional web dev where you might get away with a loose policy, the Apps SDK requires you to be surgical."

需要在 manifest 中精确声明：

| 配置项 | 用途 |
|--------|------|
| `connectDomains` | API 请求 |
| `resourceDomains` | 图片、字体、脚本 |
| `frameDomains` | 嵌入 iframe |
| `redirectDomains` | 外部链接 |

#### Lesson 10: 小型 widget 标志有巨大影响

关键设置包括：

| 设置 | 描述 |
|------|------|
| `widgetDomain` | 必需，用于全屏模式 |
| 工具注解 | `readOnly`、`destructiveHint`、`openWorldHint` |
| `widgetAccessible` | 控制 widget 是否可以自主调用工具 |

---

### 优化迭代速度

#### Lesson 11: 快速迭代需要热重载

团队开发了 Vite 插件，可以在 ChatGPT 内实时重载 widget。

#### Lesson 12: 不是所有测试都需要在 ChatGPT 中进行

**轻量级本地模拟器**可以加速早期迭代，只在验证模型交互时使用真实 ChatGPT。

#### Lesson 13: 移动端测试需要显式支持

需要支持**隧道端口的域名转发**才能在 iOS 和 Android 设备上测试。

#### Lesson 14: 熟悉的抽象（如 React hooks）加速前端开发

团队创建了自定义 hooks：

| Hook | 用途 |
|------|------|
| `useCallTool` | 调用工具 |
| `useWidgetState` | 管理 widget 状态 |
| `useLocale` | 本地化 |
| `createStore` | 基于 Zustand 的状态管理 |

#### Lesson 15: 将经验转化为可重用工具

团队创建了两个开源项目：

| 项目 | 描述 |
|------|------|
| **Skybridge Framework** | React 框架，包含上述模式和 hooks |
| **chatgpt-apps-builder Codex Skill** | 支持完整应用生命周期 |

安装命令：`npx skills add alpic-ai/skybridge`

---

## 总结

构建 ChatGPT Apps 需要**重新思考**：
- 上下文如何流动
- 界面如何行为
- 用户和模型如何协作

许多经验教训都来自于**传统 Web 模式与代理系统现实之间的差距**。

通过将这些经验编码到开源框架和 Codex Skill 中，可以帮助其他开发者减少重复发现问题的时间，更多地探索这种新交互模型的可能性。
