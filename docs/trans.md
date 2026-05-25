# 翻译

## 目标

将给定的链接或文档，翻译为双语格式的 Markdown 文档

## 输入(翻译源)

用户给定的链接或文档

## 输出

输出的所有内容均保存到 docs/ 目录下，并按照功能进行划分：如 plan, figures

## 要求

### 0. 执行步骤

1. 先提取原文
   + 如果原文过长(超过 ~300 行，或者文件过大)，考虑按章节/小节进行拆分，并以章节/小节名作为文件名
   + 如果是 pdf 格式，可以考虑调用 mineru api skill
2. 将原文翻译成译文(不要覆盖原文文件)：译文请满足下面要求
3. 请使用 subagent 来完成翻译和审阅，以免上下文爆照
   + 注意 subagent 的读写权限问题，请提取规划好

### 1. 格式

双语格式：每段文本采用「英文原文 + 空行 + 中文译文」格式

```txt
原文(English)

译文(Chinese)
```

### 2. 术语规范

+ 术语首次出现格式：`中文(English)`，后续直接用中文
+ 专有名词（如类名 `StateMachine`、枚举 `PseudostateKind`）保留英文
+ 生成术语对照表

### 3. 图表处理

要求必须保留原文的图表

+ 如果图表可以用 url 方式引用，则直接引用 **(推荐)**
+ 否则，尝试用截图的方式截取出图片，然后进行引用 **(推荐)**
+ 或者尝试用 `plantuml` 等工具绘制，并导出图片后进行引用

### 4. 排版

+ 章节标题层级：`# 14` → `## 14.1` → `### 14.2.1` → `#### 14.2.3.1`
+ 标题双语格式：`### 14.2.3 Semantics（语义）`
+ 章节间用 `---` 分隔
+ 列表项保持原文的 bullet/numbered 格式

### 5. 验收标准

+ **格式**：是否为双语格式（英文段 → 空行 → 中文段）
+ **完整性**：是否包含原文的所有内容
+ **正确性**：是否和原文的内容一致
+ **一致性**：同一术语在不同段落中的翻译是否统一
+ **完成度**：在符合上面要求的情况下，需要符合中文表述习惯，而非机翻

---

## 执行

### Phase 0：前置准备

> 每个 Phase 完成后需要验证通过才能进入下一阶段。

### 计划

1. 翻译前，先制定计划，有任何疑问或模糊(二义性)的地方，请和用户确认
2. **要求计划的每个步骤都可以进行验证，并且只有验证或审阅通过后才能进行下一步**
   + 完整性：是否包含原文的所有内容
   + 正确性：是否和原文的内容一致
   + 一致性：同一术语在不同段落中的翻译是否统一
   + 格式：是否为双语格式（英文段 → 空行 → 中文段）

## 其他

1. **不要随意假设，以实际验证结果为准**

---

## 补充：扫描版 UML 规范 PDF 翻译（uml-ch14）

### S1. OCR 质量验证

扫描 PDF 经 OCR 提取后需人工校对，重点关注：

+ **术语识别**：UML 专业术语是否被 OCR 正确识别（如 `Pseudostate`、`StateMachine`、`ConnectionPointReference`）
+ **公式/多重性**：多重性标注如 `[0..1]`、`[1..*]` 是否完整保留
+ **编号连续性**：章节编号、图编号（Figure 14.x）是否连续无遗漏
+ **验证方式**：逐节对照原文 PDF 截图，修正 OCR 错误后再进行翻译

### S2. UML 图表处理

UML 规范包含大量图表（类图、状态机图、协议图等），按以下优先级处理：

1. **原文截图**（推荐）：直接引用 MinerU 提取的图片文件 `images/*.jpg`，保留原始图表
2. **Mermaid 图表**：MinerU 生成的 `<details>` 内 Mermaid 代码需保留，不翻译 Mermaid 语法中的标签
3. **图标题双语**：如 `Figure 14.1 Behavior StateMachines（行为状态机）`
4. **图片引用路径**：统一使用相对于当前 md 文件的相对路径，如 `../images/xxx.jpg`

### S3. 拆分策略

源文件 `uml-ch14.md`（3019 行）按一级节拆分为 6 个文件：

| 文件名                              | 章节                           | 行数   | 说明                   |
| --------                            | ------                         | ------ | ------                 |
| `14.1-Summary.md`                   | 14.1 Summary                   | ~6     | 状态机概述             |
| `14.2-Behavior-StateMachines.md`    | 14.2 Behavior StateMachines    | ~1280  | 行为状态机（最大章节） |
| `14.3-StateMachine-Redefinition.md` | 14.3 StateMachine Redefinition | ~145   | 状态机重定义           |
| `14.4-Protocol-StateMachines.md`    | 14.4 ProtocolStateMachines     | ~203   | 协议状态机             |
| `14.5-Classifier-Descriptions.md`   | 14.5 Classifier Descriptions   | ~1029  | 分类器描述             |
| `14.6-Association-Descriptions.md`  | 14.6 Association Descriptions  | ~354   | 关联描述               |

拆分规则：

+ 每个文件保持完整的内部小节结构
+ 图片引用路径统一调整（拆分后文件在 `docs/` 下，图片在 `uml-ch14/images/` 下）
+ 14.2 较大（1280 行），翻译时可由 subagent 进一步按二级节分段处理

### S4. UML 术语对照表预设

第 14 章（StateMachines）核心术语对照：

| English                  | 中文           | 备注               |
| ---------                | ------         | ------             |
| StateMachine             | 状态机         | 保留英文用于类名   |
| Region                   | 区域           |                    |
| Vertex                   | 顶点           |                    |
| State                    | 状态           |                    |
| Transition               | 转换           |                    |
| Pseudostate              | 伪状态         |                    |
| PseudostateKind          | 伪状态种类     | 保留英文用于枚举名 |
| FinalState               | 终态           |                    |
| ConnectionPointReference | 连接点引用     |                    |
| Trigger                  | 触发器         |                    |
| Event                    | 事件           |                    |
| Behavior                 | 行为           |                    |
| Classifier               | 分类器         |                    |
| BehavioredClassifier     | 行为分类器     |                    |
| ProtocolStateMachine     | 协议状态机     |                    |
| Composite State          | 组合状态       |                    |
| Submachine State         | 子机器状态     |                    |
| Entry/Exit/Do Activity   | 入口/出口/活动 | 状态内部行为       |
| Run-to-completion        | 运行到完成     | 执行语义           |
| Guard                    | 监护条件       |                    |
| Effect                   | 效果           | 转换上的行为       |
| Redefinition             | 重定义         |                    |
| Protocol Conformance     | 协议一致性     |                    |

术语首次出现时使用 `中文(English)` 格式，后续统一用中文。
