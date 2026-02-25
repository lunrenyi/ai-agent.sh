# Shell + Skills + Compaction：长时运行 Agent 实战技巧

> 翻译整理自 OpenAI Developers Blog

## 核心概念

### Skills（技能）

- **定义**：可重复使用的版本化指令集，包含 `SKILL.md` 清单
- **用途**：模型根据元数据决定是否调用技能

### Shell 工具

- **托管容器**：OpenAI 托管，支持安装依赖、运行脚本、写入输出
- **本地模式**：自行执行 `shell_call`，返回 `shell_call_output`

### 压缩（Compaction）

- **服务器端压缩**：自动在流中处理，无需单独调用
- **独立端点**：`/responses/compact` 用于显式控制

---

## 十大实战技巧

### 1. 像路由逻辑一样编写技能描述

技能描述是模型的决策边界，应明确：
- 何时使用
- 何时不使用
- 输出和成功标准

### 2. 添加负面示例减少误触发

- 加入 "Don't call this skill when..." 案例
- 覆盖边界情况
- **案例**：Glean 添加负面示例后，触发准确率从下降 20% 恢复

### 3. 将模板和示例放入技能中

- 仅在技能调用时加载
- 不增加无关查询的 token 开销
- 适用于：结构化报告、升级摘要、账户计划、数据分析报告

### 4. 早期设计长时运行：容器复用 + 压缩

- 跨步骤复用同一容器
- 传递 `previous_response_id` 保持线程连续
- 将压缩作为默认原语

### 5. 需要确定性时显式指定技能

```
"Use the <skill name> skill."
```

### 6. 技能 + 网络访问 = 高风险组合

- 技能：允许
- Shell：允许
- 网络：仅在最小允许名单下启用

### 7. 使用 /mnt/data 作为制品边界

- 工具写入磁盘
- 模型推理磁盘内容
- 开发者从磁盘检索

### 8. 允许名单双层系统

- **组织级允许名单**：管理员配置
- **请求级 `network_policy`**：必须为组织允许名单的子集

### 9. 使用 domain_secrets 保护认证

- 运行时模型看到占位符（如 `$API_KEY`）
- 边车仅向批准目的地注入真实值

### 10. 云端和本地使用相同 API

- 技能兼容托管和本地 Shell 模式
- 开发循环：本地迭代 → 托管容器部署

---

## 三种构建模式

### 模式 A：安装 → 获取 → 写入制品

```python
# 示例流程
1. 安装依赖库
2. 抓取或调用 API
3. 将报告写入 /mnt/data/report.md
```

### 模式 B：技能 + Shell 实现可重复工作流

1. 将工作流编码为技能
2. 挂载到 Shell 环境
3. 代理按技能执行

**适用场景**：
- 电子表格分析
- 数据清理 + 摘要生成
- 标准化报告生成

### 模式 C（高级）：技能作为企业工作流载体

**案例**：Glean - Salesforce 技能
- 评估准确率：73% → 85%
- 首 token 时间：减少 18.1%

---

## 安全建议

- 保持组织允许名单小而稳定
- 保持请求允许名单更小
- 避免在面向消费者的流程中同时开放网络访问和强大工具

---

## 相关文档

- [Skills 文档](https://platform.openai.com/docs/guides/tools-skills)
- [Shell 文档](https://platform.openai.com/docs/guides/tools-shell)
- [压缩文档](https://platform.openai.com/docs/guides/context-management)
- [OpenAI 智能体工程指南：10 条实战技巧和 3 种构建模式](https://x.com/dotey/status/2022074016656191809)
