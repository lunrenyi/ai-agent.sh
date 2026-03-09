# Google Workspace CLI：给 AI Agent 装上「Google 全家桶」手脚

> Google 开源的命令行工具，一键操作 Gmail、Drive、Calendar、Sheets、Docs，原生支持 MCP，AI Agent 必备

---

## 背景

自 2026 年开年以来，OpenClaw 的热度持续爆火，衍生出门上门安装生意。很多朋友装好之后，第一件事就是想让它帮忙处理各种日常事务，比如管邮件、整理日历、同步云盘等。

但现实往往会被泼一盆冷水——大多数平台根本不对外开放 API，想接入根本没门。

然而就在前两天，Google 在 GitHub 上悄悄开源了一个命令行工具：**gws**（Google Workspace CLI），把旗下所有 Workspace 服务的 API 全部打包进去，刚开源就暴涨 **14000+ GitHub Star**。

---

## 核心功能

有了 gws，Drive、Gmail、Calendar、Sheets、Docs…Google 旗下的整套办公工具，直接在终端里就能操作：

- 不用打开浏览器一个个切换
- 不用翻 API 文档手动拼 curl
- 分页和 OAuth 认证全部帮我们处理好

### 安装方式

```bash
npm install -g @googleworkspace/cli
```

---

## 技术亮点

### 1. 动态命令构建

传统的 CLI 工具，命令列表都是写死的，开发者加一个新接口，工具就要跟着更新一次。

而 gws 走了完全不同的路子：**在运行时，会直接去读 Google 官方的接口描述，把命令结构动态构建出来**。

这意味着：
- Google 哪天悄悄上线了新接口，我们这边什么都不用做，自动就能用了
- 真正实现了「一次开发，长期受益」

### 2. 结构化 JSON 输出

响应结果全部是结构化 JSON，Agent 拿到数据直接处理，省去了大量解析工作。

### 3. 原生 MCP 支持

gws 是专为 AI Agent 构建的，它原生支持 MCP，可以轻松地把它接进任意 Agent。

一行命令启动 MCP Server，就能把 Workspace 的 API 直接暴露成工具接口：

```bash
gws mcp -s drive,gmail,calendar
```

然后到 Claude Desktop、Cursor 等支持 MCP 的客户端配置，就能让 AI 帮我们查日历、传文件、发邮件。

### 4. 内置 100+ Agent Skills

项目内置了 **100+ 个 Agent Skills**，涵盖 Gmail、Drive、Docs、Calendar、Sheets 的常见工作流，直接开箱即用：

```bash
npx skills add https://github.com/googleworkspace/cli
```

### 5. 与 OpenClaw 无缝集成

如果已安装 OpenClaw，还可以直接把 Skills 软链接到 OpenClaw 的目录下，仓库一更新，Skills 也会跟着自动同步：

```bash
ln -s $(pwd)/skills/gws-* ~/.openclaw/skills/
```

甚至不需要提前手动安装 gws，**gws-shared** 这个 Skill 内置了自动安装逻辑，OpenClaw 检测到 gws 不在环境变量里，会自己通过 npm 完成安装。

---

## 注意事项

1. **认证门槛**：使用 gws 认证这步稍微有点门槛，需要先有一个 Google Cloud 项目用来生成 OAuth 凭据。可以通过执行引导命令 `gws auth setup` 跟着提示一步步完成配置。

2. **依赖 gcloud CLI**：安装前需要先安装 gcloud CLI，否则会报错。

3. **测试预览阶段**：项目刚开源处于测试预览阶段，README 里明确写着后续会有重大更新。建议大家可以先拿来做个人项目或者尝试体验一下，但要接进生产环境，建议先观望一下版本稳定性。

---

## 总结

以前要对接一个 Google 服务，光是翻文档、配 OAuth、处理分页，半天时间就没了。

如今 gws 把这些全部封装好，开箱即用，随时都能给 Agent 装上一套可以直接调用的「手脚」。

对于日常在使用 Google 全家桶的朋友来说，这次的收益是实实在在的：
- 邮件、日历、云盘、表格，以往要分开折腾的东西，现在一个工具全部打通
- 工作效率的提升不是一点点

往更大的方向看，这次 Google 选择把自家全套产品的底层接口开放出来，在整个开源生态里属实少见。

一家体量这么大的公司，愿意主动降低开发者的接入门槛，本身就值得被 Star 点赞。

当然，我们也希望后续有更多平台跟上来。**开放的入口越多，Agent 能跑通的场景就越多，AI 真正能替我们干活这件事，才算迈出了关键一步。**

---

## 相关资源

- GitHub 项目地址：https://github.com/googleworkspace/cli
