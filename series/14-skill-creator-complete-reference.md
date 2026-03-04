# Skill Creator

Skill Creator 是 Claude Code 的一个技能，用于创建新技能、修改改进现有技能、以及测量技能性能。该工具提供完整的技能开发、测试、评估和优化工具链。

## 目录结构

```
skill-creator/
├── SKILL.md                    # 技能定义和完整使用说明
├── agents/                     # 子代理指令
│   ├── grader.md              # 评分代理
│   ├── comparator.md           # 盲比较代理
│   └── analyzer.md            # 分析代理
├── scripts/                    # Python 工具脚本
│   ├── aggregate_benchmark.py  # 聚合基准测试结果
│   ├── run_eval.py             # 运行触发评估
│   ├── run_loop.py             # 优化循环
│   ├── improve_description.py  # 改进描述
│   ├── package_skill.py        # 打包技能
│   ├── quick_validate.py       # 快速验证
│   ├── generate_report.py      # 生成 HTML 报告
│   └── utils.py                # 工具函数
├── eval-viewer/                # 评估结果查看器
│   ├── generate_review.py      # 生成评估页面
│   └── viewer.html             # 评估页面模板
├── references/                 # 参考文档
│   └── schemas.md              # JSON Schema 定义
└── assets/                     # 静态资源
    └── eval_review.html        # 评估审查模板
```

## 技能定义 (SKILL.md)

### YAML Frontmatter

每个技能以 YAML frontmatter 开始，包含以下字段：

```yaml
---
name: skill-name
description: 触发条件和功能描述（主要触发机制）
---
```

- **name**: 技能唯一标识符
- **description**: 触发条件和功能描述，这是主要触发机制——决定何时调用技能

### 渐进式披露

技能使用三级加载系统：

1. **Metadata** (name + description) - 始终在上下文中 (~100 词)
2. **SKILL.md body** - 技能触发时加载 (<500 行理想)
3. **Bundled resources** - 按需加载 (无限制)

### 技能解剖结构

```
skill-name/
├── SKILL.md (必需)
│   ├── YAML frontmatter (name, description 必需)
│   └── Markdown 指令
└── Bundled Resources (可选)
    ├── scripts/    - 可执行代码，用于确定性/重复性任务
    ├── references/  - 按需加载到上下文的文档
    └── assets/     - 输出中使用的文件（模板、图标、字体）
```

## 创建流程

### 1. 捕获意图

从理解用户意图开始：
1. 这个技能应该让 Claude 做什么？
2. 什么时候触发这个技能？（什么用户短语/上下文）
3. 期望的输出格式是什么？
4. 是否需要设置测试用例来验证技能工作？

### 2. 访谈研究

主动询问边缘情况、输入/输出格式、示例文件、成功标准和依赖项。在获取测试提示之前，先把这些弄清楚。

### 3. 编写 SKILL.md

根据用户访谈，填充以下组件：

- **name**: 技能标识符
- **description**: 何时触发，做什么。包括技能做什么 AND 具体触发上下文。所有"何时使用"信息放在这里，而不是正文中。
- **compatibility**: 必需工具、依赖项（可选，很少需要）
- **技能主体**: 指令和示例

### 4. 创建测试用例

将测试用例保存到 `evals/evals.json`：

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "用户的任务提示",
      "expected_output": "预期结果描述",
      "files": [],
      "expectations": []
    }
  ]
}
```

## 测试和评估流程

### 工作区结构

```
<skill-name>-workspace/
└── iteration-N/
    ├── eval-ID/
    │   ├── with_skill/
    │   │   ├── run-1/
    │   │   │   ├── outputs/
    │   │   │   ├── grading.json
    │   │   │   └── timing.json
    │   │   └── run-2/
    │   └── without_skill/
    │       └── run-1/
    ├── benchmark.json
    └── feedback.json
```

### 执行步骤

#### Step 1: 并行启动所有运行

对于每个测试用例，在同一轮中启动两个子代理——一个带技能，一个不带。同时启动它们，这样它们都能同时完成。

**带技能运行：**
```
执行这个任务：
- 技能路径: <path-to-skill>
- 任务: <eval prompt>
- 输入文件: <eval files if any, or "none">
- 保存输出到: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- 要保存的输出: <what the user cares about>
```

**基线运行：**
- **创建新技能**: 完全不带技能
- **改进现有技能**: 旧版本

#### Step 2: 运行时起草断言

在运行进行时，为每个测试用例起草定量断言。更新 `eval_metadata.json` 文件。

#### Step 3: 捕获计时数据

每个子代理任务完成时，任务通知包含 `total_tokens` 和 `duration_ms`。立即将此数据保存到运行目录的 `timing.json`：

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

#### Step 4: 评分、聚合并启动查看器

1. **评分每个运行** - 生成 grader 子代理，评估每个断言
2. **聚合到基准** - 运行聚合脚本：
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```
3. **分析师分析** - 阅读基准数据并浮现聚合统计可能隐藏的模式
4. **启动查看器**:
   ```bash
   nohup python <skill-creator-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   ```

### 查看器功能

查看器有两个标签页：

- **Outputs 标签**: 显示一个测试用例一次
  - Prompt: 给出的任务
  - Output: 技能产生的文件
  - Previous Output (迭代 2+): 上次迭代的输出
  - Formal Grades (如果运行了评分): 断言通过/失败
  - Feedback: 自动保存的文本框
  - Previous Feedback (迭代 2+): 上次的评论

- **Benchmark 标签**: 显示统计摘要
  - 每个配置的平均通过率、计时和 token 使用量
  - 每个测试的细分
  - 分析师观察

## 描述优化流程

描述字段是决定 Claude 是否调用技能的主要机制。在创建或改进技能后，提供优化描述以提高触发准确性。

### Step 1: 生成触发评估查询

创建 20 个评估查询——混合 should-trigger 和 should-not-trigger：

```json
[
  {"query": "用户提示", "should_trigger": true},
  {"query": "另一个提示", "should_trigger": false}
]
```

查询必须是真实的、具体且详细的，包含文件路径、个人上下文、公司名称等。

**好的查询示例:**
> "ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage. The revenue is in column C and costs are in column D i think"

**should-trigger (8-10个):** 覆盖不同措辞的相同意图——正式、休闲混合。包含用户没有明确命名技能但明显需要它的案例。

**should-not-trigger (8-10个):** 最重要的是接近失误——分享关键词或概念但实际需要不同的查询。

### Step 2: 用 HTML 模板让用户审查

1. 从 `assets/eval_review.html` 读取模板
2. 替换占位符
3. 写入临时文件并打开
4. 用户可以编辑查询、切换 should-trigger、添加/删除条目

### Step 3: 运行优化循环

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id> \
  --max-iterations 5 \
  --verbose
```

**run_loop.py 功能：**
- 60% 训练集 / 40% 测试集分割（可配置）
- 每次查询运行 3 次以获得可靠的触发率
- 使用扩展思考 (extended thinking) 改进描述
- 最多 5 次迭代
- 按测试分数选择最佳描述（而非训练分数）以避免过拟合

### Step 4: 应用结果

从 JSON 输出中获取 `best_description` 并更新技能的 SKILL.md frontmatter。

## 子代理

### Grader Agent

评估断言是否通过。读取转录和输出文件，判断每个期望是否通过，并提供具体证据。

**关键职责：**
- 评估每个期望是否通过
- 提取并验证输出中的声明
- 批判评估本身（断言是否有效区分好坏结果）

### Comparator Agent

盲 A/B 比较——不知道哪个技能产生了哪个输出。基于输出质量判断胜负。

**评分标准:**
- **Content Rubric**: 正确性、完整性、准确性
- **Structure Rubric**: 组织、格式、可用性

### Analyzer Agent

分析结果，识别模式和非正常现象。

**两种模式：**

1. **Post-hoc 分析**: 在盲比较后，理解为什么赢家赢了，生成改进建议
2. **Benchmark 分析**: 审查所有基准运行结果，生成帮助用户理解技能性能的注释。专注于浮现聚合指标不会显示的模式和异常

## JSON Schema

### evals.json

测试用例定义，位于 `evals/evals.json`：

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "用户的示例提示",
      "expected_output": "预期结果描述",
      "files": ["evals/files/sample1.pdf"],
      "expectations": [
        "输出包含 X",
        "技能使用了脚本 Y"
      ]
    }
  ]
}
```

### grading.json

评分代理输出，位于 `<run-dir>/grading.json`：

```json
{
  "expectations": [
    {
      "text": "输出包含名字 'John Smith'",
      "passed": true,
      "evidence": "在转录第 3 步找到: '提取的名字: John Smith, Sarah Johnson'"
    }
  ],
  "summary": {
    "passed": 2,
    "failed": 1,
    "total": 3,
    "pass_rate": 0.67
  },
  "execution_metrics": {...},
  "timing": {...},
  "claims": [...],
  "eval_feedback": {...}
}
```

### benchmark.json

基准测试输出，位于 `benchmarks/<timestamp>/benchmark.json`：

```json
{
  "metadata": {
    "skill_name": "pdf",
    "timestamp": "2026-01-15T10:30:00Z",
    "evals_run": [1, 2, 3],
    "runs_per_configuration": 3
  },
  "runs": [...],
  "run_summary": {
    "with_skill": {
      "pass_rate": {"mean": 0.85, "stddev": 0.05, "min": 0.80, "max": 0.90},
      "time_seconds": {"mean": 45.0, "stddev": 12.0},
      "tokens": {"mean": 3800, "stddev": 400}
    },
    "without_skill": {...},
    "delta": {
      "pass_rate": "+0.50",
      "time_seconds": "+13.0",
      "tokens": "+1700"
    }
  },
  "notes": [...]
}
```

### timing.json

运行计时数据：

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3,
  "executor_start": "2026-01-15T10:30:00Z",
  "executor_end": "2026-01-15T10:32:45Z",
  "executor_duration_seconds": 165.0,
  "grader_start": "2026-01-15T10:32:46Z",
  "grader_end": "2026-01-15T10:33:12Z",
  "grader_duration_seconds": 26.0
}
```

### comparison.json

盲比较器输出：

```json
{
  "winner": "A",
  "reasoning": "...",
  "rubric": {
    "A": {...},
    "B": {...}
  },
  "output_quality": {...},
  "expectation_results": {...}
}
```

### history.json

跟踪改进模式中的版本进度：

```json
{
  "started_at": "2026-01-15T10:30:00Z",
  "skill_name": "pdf",
  "current_best": "v2",
  "iterations": [
    {
      "version": "v0",
      "parent": null,
      "expectation_pass_rate": 0.65,
      "grading_result": "baseline",
      "is_current_best": false
    }
  ]
}
```

## 关键脚本

| 脚本 | 用途 |
|------|------|
| `aggregate_benchmark.py` | 将单独运行结果聚合为基准摘要统计 |
| `run_eval.py` | 运行触发评估，检查技能是否被调用 |
| `run_loop.py` | 执行完整的优化循环（评估+改进） |
| `improve_description.py` | 基于评估结果生成改进的描述 |
| `package_skill.py` | 将技能打包成 .skill 文件 |
| `quick_validate.py` | 快速验证技能格式 |
| `generate_report.py` | 生成 HTML 报告 |
| `generate_review.py` | 生成评估查看器页面 |

## 使用场景

### 创建新技能

1. 理解用户想要的技能功能
2. 编写技能草稿
3. 创建测试用例
4. 运行并评估结果
5. 根据反馈改进
6. 重复直到满意
7. 优化触发描述
8. 打包技能

### 改进现有技能

1. 加载现有技能
2. 运行测试用例（包括基线对比）
3. 审查结果
4. 根据反馈改进技能
5. 重复直到满意
6. 优化触发描述

### 基准测试

运行带技能和不带技能的多次测试，收集统计数据，分析技能的性能改进。

### 描述优化

优化技能的 description 字段，提高触发准确性——确保在应该触发时触发，不应该触发时不触发。

## 相关文件路径

- 技能定义: `skill-creator/SKILL.md`
- 子代理指令: `skill-creator/agents/*.md`
- 工具脚本: `skill-creator/scripts/*.py`
- 评估查看器: `skill-creator/eval-viewer/`
- Schema 定义: `skill-creator/references/schemas.md`
