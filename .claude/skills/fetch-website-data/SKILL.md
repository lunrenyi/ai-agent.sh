---
name: fetch-website-data
description: Fetch structured data from websites using x-cmd links dump. Use when the user needs to fetch or scrape website content, get README/repo info from GitHub/Gitee, or prepare LLM-friendly text from URLs.
---


可以使用 `x-cmd links dump` 命令获取网站的 LLM 友好文本数据。

**工作流程：**
1. 优先获取专为 LLM 优化的 llmstxt 格式
2. 对于代码托管平台（GitHub、Gitee、Codeberg、GitLab），优先获取原始数据
3. 回退方案：使用 elinks 文本浏览器提取内容

**常用示例：**

```bash
# 获取 GitHub 仓库信息（推荐，自动识别平台特性）
x-cmd links dump -l -c https://github.com/sigoden/aichat

# 仅获取原始数据（适用于代码仓库）
x-cmd links dump --llmstxt --codeurl <url>

# 抓取任意网页内容
x-cmd links dump <url>
```

**参数说明：**
- `-l, --llmstxt`：输出专为 LLM 优化的文本格式
- `-c, --codeurl`：将代码链接转换为原始文件 URL（适合代码仓库）
