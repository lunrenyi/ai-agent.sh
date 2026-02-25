# tmux 完全指南：让多个 Claude Code Agent 同时工作

> 终端多路复用器实战手册

---

## 概述

tmux（Terminal MUltipleXer）是终端复用器，允许在一个终端窗口中运行多个会话，断开连接后会话依然保持运行。结合 Claude Code Agent Teams，可以让多个 AI Agent 并行工作，同时查看各自状态。

---

## 核心概念

### 层级结构

```
Server
  └── Session（会话）
        └── Window（窗口）
              └── Pane（面板）
```

### 三大核心优势

| 优势 | 说明 |
|------|------|
| 多面板显示 | 一个屏幕同时看到 Lead + 所有 Teammates |
| 后台持久运行 | 关掉终端/SSH 断开，Agent 们继续工作 |
| 随时恢复 | `tmux a` 立即回到工作现场 |

---

## macOS 安装

### 安装 tmux

```bash
brew install tmux

# 验证
tmux -V
```

### 环境验证

```bash
echo "=== Environment Check ===" && \
tmux -V && \
node -v && \
claude --version && \
echo "=== All Good! ==="
```

---

## 核心操作

### Session 管理

```bash
# 创建 session
tmux new -s my-first

# 列出所有 session
tmux ls

# 分离当前 session（后台运行）
Ctrl+B d

# 重新连接
tmux a -t my-first
```

### 分屏操作

| 快捷键 | 功能 |
|--------|------|
| Ctrl+B " | 水平分割（上下） |
| Ctrl+B % | 垂直分割（左右） |

### Pane 切换

```bash
Ctrl+B ↑/↓/←/→    # 切换到指定 pane
```

### Zoom 功能

```bash
Ctrl+B z    # 放大当前 pane 到全屏
Ctrl+B z    # 恢复原始布局
```

### 滚动查看历史

```bash
Ctrl+B [    # 进入滚动模式
# ↑/↓ 或 PgUp/PgDn 翻页
# q 或 Esc 退出
```

---

## Agent Teams 配置

### 步骤 1：启用实验功能

```bash
# 添加到 ~/.zshrc
echo 'export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1' >> ~/.zshrc
source ~/.zshrc
```

### 步骤 2：配置 tmux 模式

编辑 `~/.claude/settings.json`：

```json
{
  "teammateMode": "tmux"
}
```

### 步骤 3：启动团队

```bash
cd ~/your-project
claude
```

直接描述任务：

```
创建一个开发团队来并行开发这个项目。需要3个teammate：
- "bridging-dev" 负责 Bridging 层代码
- "engine-dev" 负责引擎核心代码
- "utility-dev" 负责工具类扩展
```

---

## 快捷键速查

| 快捷键 | 功能 | 场景 |
|--------|------|------|
| Ctrl+B d | Detach | 让 Agent 后台继续工作 |
| Ctrl+B ↑↓←→ | 切换 Pane | 在 Agent 间切换 |
| Ctrl+B z | Zoom | 放大查看某个 Agent |
| Ctrl+B [ | 滚动模式 | 查看历史输出 |
| Ctrl+B " | 水平分屏 | 手动创建 pane |
| Ctrl+B % | 垂直分屏 | 手动创建 pane |
| Ctrl+B c | 新建 Window | 创建监控标签页 |
| Ctrl+B n/p | 切换 Window | 在标签页间切换 |
| Ctrl+B x | 关闭 Pane | 清理不需要的 |

**记忆技巧**：d=detach, z=zoom, [=看, "=横线, %=竖线

---

## 推荐配置

创建 `~/.tmux.conf`：

```bash
# 开启鼠标支持
set -g mouse on

# 提高历史记录行数
set -g history-limit 50000

# 减少 Esc 延迟
set -sg escape-time 10

# 开启 256 色
set -g default-terminal "screen-256color"

# 活动 pane 边框高亮
set -g pane-active-border-style 'fg=#4ec9b0'

# 重新加载配置
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Alt+方向键快速切换
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
```

让配置生效：

```bash
Ctrl+B r
```

---

## 三种模式对比

| 特性 | in-process | tmux | iterm2 |
|------|------------|------|--------|
| 终端要求 | 任意 | 任意+tmux | 仅 iTerm2 |
| 同时看到所有 Agent | 否 | 是 | 是 |
| 后台运行 | 不支持 | 支持 | 不支持 |
| SSH 远程 | 不支持 | 支持 | 不支持 |
| 配置复杂度 | 零 | 低 | 零 |

**推荐**：
- 需要后台运行 → tmux
- iTerm2 用户且不需要后台 → iterm2
- 快速尝试 → in-process

---

## 实战场景

### 场景一：启动后去吃饭

```bash
# 启动后
Ctrl+B d    # Detach

# 回来时
tmux a      # 重新连接
```

### 场景二：远程服务器运行

```bash
ssh user@server
tmux new -s ai-dev
claude
# SSH 断开后，Agent 继续运行
# 重新连接
tmux a -t ai-dev
```

### 场景三：额外 Window 做监控

```bash
Ctrl+B c           # 创建新 Window
watch -n 5 'git log --oneline -10'  # 监控 git
Ctrl+B 0           # 回到 Agent Teams
Ctrl+B 1           # 看监控
```

---

## Delegate 模式

按 **Shift+Tab** 切换模式：

- **Normal Mode**：正常模式
- **Delegate Mode**：Lead 只负责协调，不写代码
- **Auto-Accept Mode**：自动接受所有操作

---

## 注意事项

1. **CLAUDE.md 是共享上下文**：Teammate 不会继承 Lead 对话历史，只读取 CLAUDE.md
2. **文件隔离**：每个 Teammate 只修改自己负责的文件
3. **任务粒度**：避免多人修改同一文件

---

## 总结

tmux + Claude Code Agent Teams = 并行 AI 开发工厂

核心 5 个快捷键：
- `Ctrl+B d` → "我先去忙"
- `tmux a` → "我回来了"
- `Ctrl+B ↑↓←→` → "看看这个 Agent"
- `Ctrl+B z` → "放大看看"
- `Ctrl+B [` → "往上翻翻"

---

*来源：逐梦苍穹 - 微信读书社区*
