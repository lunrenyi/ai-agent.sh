# 构建 Claude Skill 完整指南

> 翻译整理自 Anthropic 官方文档

---

## 什么是 Skill

Skill 是 Claude 可调用的一组指令和能力，允许你在特定领域创建专家。

```
用户: "帮我优化这个查询"
    ↓
Claude: 检测到需要 SQL 优化技能
    ↓
加载 sql-optimization skill
    ↓
使用专业工具和知识执行任务
```

### Skill vs 普通 Prompt

| 特性 | 普通 Prompt | Skill |
|------|-----------|-------|
| 持久性 | 每次会话重新输入 | 一次定义，长期使用 |
| 工具 | 无 | 可包含自定义工具 |
| 版本控制 | 无 | 有版本管理 |
| 按需加载 | 每次都加载 | 仅在需要时加载 |

---

## Skill 的核心组件

### 1. SKILL.md

每个 Skill 有一个 `SKILL.md` 文件：

```yaml
---
name: sql-optimization
description: 优化 SQL 查询以提高性能
version: 1.0.0
---

# SQL Optimization Skill

## 何时使用
当用户要求优化 SQL 查询性能时使用此技能。

## 工具
- sql-explain: 分析查询执行计划
- sql-format: 格式化 SQL

## 最佳实践
- 始终先运行 EXPLAIN
- 检查索引使用情况
- 避免 SELECT *
```

### 2. 工具定义

Skill 可以自带工具：

```
/my-skill/
├── SKILL.md
└── tools/
    ├── tool1.py
    └── tool2.sh
```

---

## Skill 元数据

### YAML 头部

```yaml
---
name: skill-name        # 技能名称（必需）
description: 描述      # 简短描述（必需）
version: 1.0.0        # 版本号
author: 作者           # 作者信息
tags: [tag1, tag2]    # 标签
---
```

### 描述技巧

**好的描述**:
```
"Optimize SQL queries for PostgreSQL databases.
Analyzes query plans, suggests indexes, and rewrites queries."
```

**不好的描述**:
```
"Helps with databases and queries."
```

---

## 创建 Skill 的步骤

### 步骤 1: 定义技能

确定技能解决的问题：
- 什么场景使用？
- 用户会怎么问？
- 需要什么工具？

### 步骤 2: 编写 SKILL.md

包含：
1. **元数据** - name, description, version
2. **使用场景** - 何时调用
3. **工具列表** - 可用工具
4. **示例** - 输入输出示例

### 步骤 3: 添加工具（可选）

```python
# tools/analyze_query.py
def analyze_query(sql: str) -> dict:
    """分析 SQL 查询并返回优化建议"""
    # 实现逻辑
    return {"suggestions": []}
```

### 步骤 4: 测试和迭代

- 用真实案例测试
- 收集反馈
- 持续改进

---

## Skill 最佳实践

### 1. 描述要精确

```
❌ "Helps with code"  ← 太模糊

✅ "Reviews Python code for security vulnerabilities,
   including SQL injection, XSS, and command injection"
```

### 2. 包含负面示例

```markdown
## 何时不使用

- 用户只是想聊天
- 需要 general-purpose 帮助时
```

### 3. 提供示例

```markdown
## 示例

用户输入: "帮我优化这个 SQL"
技能输出: 分析查询计划，提供具体优化建议
```

### 4. 保持专注

一个 Skill 专注做好一件事：
- ✅ "SQL optimization"
- ❌ "Database and code and security"

---

## 高级主题

### 1. 版本控制

```yaml
---
name: my-skill
version: 1.0.0  # 遵循语义化版本
---
```

### 2. 依赖管理

```yaml
---
name: advanced-sql
requires:
  - sql-basic
  - postgresql-tools
---
```

### 3. 条件加载

```yaml
---
name: react-optimization
trigger:
  files: ["*.tsx", "*.jsx"]
  context: ["react", "component", "hook"]
---
```

---

## 工具集成

### 定义工具

```yaml
## 工具

### sql-explain
分析 SQL 查询的执行计划

参数:
- query: SQL 查询字符串
- database: 数据库连接

返回:
- 执行计划
- 性能建议
```

### 工具命名

| 好的命名 | 不好的命名 |
|----------|------------|
| `analyze-query` | `do-stuff` |
| `format-sql` | `helper` |
| `check-index` | `tool1` |

---

## 常见错误

### 1. 描述太宽泛

```yaml
# ❌ 错误
description: "Helps with development"

# ✅ 正确
description: "Writes and optimizes SQL queries for PostgreSQL"
```

### 2. 缺少使用场景

必须清楚说明：
- 什么时候调用这个 Skill？
- 什么时候不调用？

### 3. 工具定义不清晰

每个工具需要：
- 清晰的名称
- 准确的描述
- 参数说明
- 返回值格式

---

## 测试 Skill

### 创建测试用例

```yaml
## 测试用例

### Test 1: 简单查询优化
Input: "SELECT * FROM users WHERE email = 'test@example.com'"
Expected: 分析计划，建议添加索引

### Test 2: 复杂 JOIN
Input: "SELECT * FROM orders JOIN users ..."
Expected: 识别性能问题，建议重写
```

### 测试清单

- [ ] 基本功能正常工作
- [ ] 边界情况正确处理
- [ ] 错误信息清晰
- [ ] 性能可接受

---

## 发布和维护

### 发布前检查

- [ ] SKILL.md 完整
- [ ] 工具都已测试
- [ ] 示例都已验证
- [ ] 版本号已更新

### 持续改进

- 收集用户反馈
- 跟踪错误报告
- 定期更新文档

---

## 总结

构建好的 Skill 关键点：

1. **精确的描述** - 让 Claude 知道何时使用
2. **合适的工具** - 提供完成任务的能力
3. **清晰的示例** - 帮助理解预期行为
4. **专注** - 一个 Skill 做好一件事
5. **持续迭代** - 根据反馈不断改进
