# 使用 Evals 系统化测试 Agent Skills 完整指南

> 翻译整理自 OpenAI Developers Blog

---

## 核心概念

**Evals（评估）**用于检查模型输出及生成步骤是否符合预期。

Eval 本质是：**提示词 → 捕获的运行（trace + artifacts）→ 少量检查 → 可比较的分数**

---

## 八大实践方法

### 1. 编写技能前先定义成功标准

将检查分为几类：

| 类型 | 描述 |
|------|------|
| **结果目标** | 任务是否完成？应用能否运行？ |
| **流程目标** | Codex 是否调用了技能？是否按预期步骤执行？ |
| **风格目标** | 输出是否符合约定的规范？ |
| **效率目标** | 是否避免无意义的重复操作？ |

### 2. 创建技能

使用 Codex 内置的技能创建器启动：

```
$skill-creator
```

技能是包含 YAML 头部的目录（`SKILL.md`），包含 `name` 和 `description`。这些是 Codex 决定是否调用技能的主要信号。

### 3. 手动触发技能以暴露隐藏假设

需要检查的假设类型：

| 类型 | 描述 |
|------|------|
| **触发假设** | 某些提示是否应该/不应该激活技能 |
| **环境假设** | 是否在空目录中运行？是否使用 npm？ |
| **执行假设** | 是否跳过必要步骤？ |

使用 `--full-auto` 标志运行 `codex exec`。

### 4. 使用小规模提示集早期发现回归

**10-20 个提示**就足以发现回归和确认改进。每个 CSV 行代表一个关心是否激活技能的场景。

示例 CSV 结构：

```csv
id,should_trigger,prompt
test-01,true,"Create a demo app named `devday-demo` using the $setup-demo-app skill"
test-04,false,"Add Tailwind styling to my existing React app"
```

### 5. 使用轻量级确定性评分器

使用 `codex exec --json` 获取 JSONL 格式的结构化事件流，然后编写确定性检查：

```javascript
function checkRanNpmInstall(events) {
  return events.some(
    (e) =>
      (e.type === "item.started" || e.type === "item.completed") &&
      e.item?.type === "command_execution" &&
      e.item.command.includes("npm install")
  );
}
```

### 6. 使用 Codex 进行定性检查和基于评分的评分

使用 `--output-schema` 约束最终响应为 JSON Schema：

```bash
codex exec "Evaluate the demo-app repository..." \
  --output-schema ./evals/style-rubric.schema.json
```

定义评分架构示例：

```json
{
  "type": "object",
  "properties": {
    "overall_pass": { "type": "boolean" },
    "score": { "type": "integer", "minimum": 0, "maximum": 100 },
    "checks": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "pass": { "type": "boolean" },
          "notes": { "type": "string" }
        }
      }
    }
  }
}
```

### 7. 随着技能成熟扩展评估

可添加的深层检查：

| 检查项 | 描述 |
|--------|------|
| **命令计数和 thrashing** | 统计 `command_execution` 项目 |
| **Token 预算** | 追踪 `usage.input_tokens` 和 `usage.output_tokens` |
| **构建检查** | 运行 `npm run build` |
| **运行时冒烟检查** | 启动 dev server 并用 curl 测试 |
| **仓库清洁度** | 确保无多余文件 |
| **沙箱和权限回归** | 验证权限升级 |

### 8. 关键要点

> "Evals let you ask concrete questions like: Did the agent invoke the skill? Did it run the expected commands? Did it produce outputs that follow the conventions you care about?"

**核心原则：**

| 原则 | 说明 |
|------|------|
| 衡量重要的东西 | 好的评估使回归清晰、失败可解释 |
| 从可检查的完成定义开始 | 使用 `$skill-creator` 引导 |
| 以行为为基础 | 用 `codex exec --json` 捕获 JSONL |
| 在规则不足时使用 Codex | 用 `--output-schema` 进行结构化评分 |
| 让真实失败驱动覆盖 | 每个手动修复都是信号，转化为测试 |

---

## 总结

Evals 是确保 Agent Skills 质量的关键工具。通过：
1. **先定义成功标准**
2. **小规模快速发现回归**
3. **确定性 + 评分器双轨检查**
4. **随技能成熟扩展检查深度**

可以构建可靠的、可量化的 Agent 系统。
