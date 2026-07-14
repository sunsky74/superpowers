# Brainstorm 三要素 + Writing-Plan 验收驱动 + LTDD 循环 — Design Spec

**Status:** Proposed (personal fork customization of `obra/superpowers` v6.0.3; not for upstream PR per AGENTS.md)
**Driver:** 实际使用中原 `brainstorming` 不沉淀业务理解(只在 design 输出阶段被动罗列、不在提问阶段主动覆盖三要素角度)、原 `writing-plans` + TDD 在复杂业务场景下反馈太晚。需要的是"三要素驱动的提问框架 + 业务三要素沉淀 + 双层验收 + 失败自动循环"的工作流。
**定位:** 个人 fork 定制。可破坏兼容、可加个人偏好、无需 eval 证据、不重命名(保留触发链)。
**核心原则:** 三要素(A 总体业务流程 / B 当前需求业务流程 / C 当前需求技术架构,其中 C 又分 C1 与现有架构契合度 + C2 新架构赋能)首先是 brainstorming **提问阶段**的硬性框架,其次才是 design 的输出结构。

---

## 0. 决策摘要(设计约束)

8 个关键决策已与用户确认,作为本 spec 的硬约束:

| # | 决策点 | 选择 |
|---|---|---|
| 1 | 改造定位 | 个人 fork,不上游 PR,不需 eval |
| 2 | 改造粒度 | 改 `brainstorming` + 改 `writing-plans` + 新增 `ltdd` |
| 3 | 命名策略 | 原地改 + 新增 `ltdd`(保留触发链) |
| 4 | 循环架构 | 双层级联:任务级 L1/L2/L3 + 计划级最终验收 |
| 5 | 子 agent 边界 | 读 任务文档+验收项+代码 / 改 代码+测试 / 不动 spec 与验收项 |
| 6 | L1-L3 分级 | `writing-plans` 阶段打标签,带理由 |
| 7 | 循环上限 | 不设硬上限(≥5 次软提醒) |
| 8 | 嵌入位置 | `writing-plans` 末尾三选一,`ltdd` 为推荐项 |

**实现方案:B (重集成)。** `brainstorming` 提前产出验收雏形,`writing-plans` 重构为验收驱动,`ltdd` 自带执行能力。代价:后续 merge 上游 `brainstorming`/`writing-plans` 更新冲突较大。可接受。

---

## 1. 总体架构

### 1.1 三 skill 数据流

```
[brainstorming]                [writing-plans]                [ltdd]
   三要素            ──→        三要素引用          ──→        三要素验收
 + 验收雏形                    + 任务级验收项                 ↑↓ 子 agent 循环
                               + L1-L3 标签                   改代码 → 重跑验收
                               + 推荐路径
                                    │
                                    ├─→ subagent-driven-development (原生保留)
                                    ├─→ executing-plans (原生保留)
                                    └─→ ltdd (推荐) ★
```

### 1.2 各 skill 改动定性

| skill | 改动性质 | 改动幅度 |
|---|---|---|
| `brainstorming` | **重构提问框架 + design 输出结构** — 三要素首先作为提问框架(A→B→C1→C2 四角度驱动提问),其次作为 design 必填段 + 验收雏形必产 | 中-大(新增 ~80 行:提问框架 ~50 行 + 输出模板 ~30 行,均带硬约束) |
| `writing-plans` | 重构为验收驱动 — plan header 必含验收清单,任务必带 L1-L3,handoff 三选一含 ltdd | 大(header 模板换、task 结构加字段、handoff 段重写) |
| `ltdd`(新) | 完整定义双层循环 — 内嵌 executing-plans 的批量执行模式 + 失败重启子 agent 协议 + 验收重跑 | 大(全新文件,~200-250 行) |

### 1.3 贯穿设计原则

1. **三要素是提问框架,不只是输出模板**(本 spec 核心原则):三要素(A 总体业务流程 / B 当前需求业务流程 / C 当前需求技术架构,其中 C 又分 C1 契合度 + C2 赋能)首先作为 brainstorming **提问阶段**的硬性框架,按 A→B→C1→C2 顺序逐角度覆盖;其次才沉淀为 design 的输出结构。提问阶段跳过任何角度 = brainstorming 未完成。
2. **三要素提问框架只在涉及技术与编码的需求中强制执行**(范围限定原则):brainstorming 在开放式探索结束后必须先做"适用范围判定",产出 `三要素适用: yes/no/partial` + 理由写进 design 头部。涉及代码/功能/中间件 = `yes` 必走;纯讨论/纯文档 = `no` 可跳过;拿不准默认 `yes`(宁严勿松)。
3. **强契约**:三要素、验收清单、L1-L3 标签在 skill 内容里写为 **MUST**(硬约束),不是 SHOULD。skill 内的 Red Flags 表会明确指出"跳过三要素提问 = 失败"(前提:已判 `yes`)。
4. **可追溯**:每个验收项必须能追溯到三要素中的某一条(避免凭空造验收项)。
5. **最小惊讶**:`ltdd` 循环重启子 agent 时,必须显式说明"重启原因 + 子 agent 任务范围 + 期望产物",不能让子 agent 凭感觉乱改。
6. **可降级**:`ltdd` 跑不出来时允许人工接管(写 handoff 文档)。

---

## 2. brainstorming skill 改造细节

### 2.1 文件
`skills/brainstorming/SKILL.md`

### 2.2 改动清单

#### 2.2.1 三要素驱动提问框架(本改造的核心)

**适用范围(硬约束前置):**

本提问框架**只在"涉及技术与编码"的需求中强制执行**。brainstorming 在开放式探索阶段结束后,必须先做一次"范围判定",根据需求性质决定是否进入三要素提问框架:

| 需求类型 | 是否走三要素提问框架 | 是否产出三要素 design 段 |
|---|---|---|
| **涉及技术与编码**(写代码、改代码、新增/修改功能、重构、性能优化、引入/调整中间件等) | **必须走**(A→B→C1→C2 四角度) | **必须产出**(四子段 MUST) |
| **不涉及技术与编码**(纯概念讨论、纯文档编写、研究性探索、设计思想交流等) | **可跳过** | **可跳过**(design 文档按需组织,不强求三要素段) |
| **边界场景**(例如"为已有代码补文档""讨论某技术方案的可行性但不落地") | 由 brainstorming 显式判定,并在 design 头部标注 `三要素适用: yes/no/partial` + 理由 | 同判定 |

**判定时机**:在开放式探索结束、进入澄清阶段之前,显式做一次判定。判定结果写入 design 文档头部(例如一行 `三要素适用: yes,因为本需求涉及修改 service 层代码`)。

**判定的硬约束:**
- 判定不准"故意把需求降级为'不涉及技术与编码'来逃避三要素提问"(Red Flag)
- 用户明确说"我不写代码,只想讨论 X"时,brainstorming 可判 `no`,但需在 design 头部记理由
- 用户说不清或 brainstorming 自己拿不准时,**默认判 `yes`(保守策略,宁严勿松)**

---

(以下内容仅在判定为 `yes` 时强制执行)

三要素不仅是 design 的输出模板,**更是 brainstorming 提问阶段的提问框架**。当前 superpowers 原版的 brainstorming 提问是开放式的("你想做什么?""有什么约束?"),容易陷入"按用户口述顺序记笔记、缺乏系统性"的状态。改造后,brainstorming 在结束开放式探索、进入澄清阶段后,**必须从三要素三个角度分别提出至少一个问题**,逐个角度深挖,避免遗漏。

提问框架按"从宏观到微观、从业务到技术"的顺序,按以下三层角度组织:

**角度 A — 总体业务流程视角的提问**

目的:把当前需求放进整个系统的业务全景里定位,搞清楚它对系统起的作用、与现有业务模块的联动。

至少问清:
1. **联动关系**:本次需求会与现有哪些业务模块产生数据流或调用关系?哪些会被影响?
2. **作用定位**:在当前系统的业务全景里,这个需求是新增能力、替换既有能力、还是补强既有能力的某个环节?
3. **上下游影响**:它的上游(谁触发、触发条件)和下游(产物给谁、产生什么后续动作)分别是什么?

**角度 B — 当前需求业务流程视角的提问**

目的:搞清本次需求自身的业务流转闭环,从入口到出口、从触发到产物。

至少问清:
1. **入口与触发**:需求从哪里被触发(用户操作 / 定时任务 / 消息 / API)?入口有几个?
2. **业务流转的关键节点**:流转中有哪些不可省略的业务步骤?哪些是同步的、哪些可以异步?
3. **状态变迁与边界**:流转中数据/状态经过哪些变化?异常分支怎么走?兜底是什么?

**角度 C — 当前需求技术架构视角的提问**

这一角度最容易在头脑风暴阶段被忽略,但最关键。再细分两个子角度:

**C1 — 与当前系统现有技术架构的契合度提问**

目的:搞清"这个需求要落地,现有技术架构够不够、差什么"。

至少问清:
1. **现有中间件盘点**:当前系统已经在用哪些中间件(MQ、缓存、分布式锁、搜索、批量、数据库特性等)?它们的覆盖面是否包含本需求场景?
2. **缺口分析**:本需求若直接落地,现有技术架构在哪一环不够用(并发不够、稳定性不够、吞吐不够、可见性不够)?需要补什么?
3. **复用 vs 新建**:能用现有中间件就别新引。若必须新引,新引的中间件与现有架构的边界在哪?

**C2 — 新技术架构对当前需求与系统的赋能提问**

目的:搞清"若引入新的技术架构元素,能为业务流转带来什么具体提升",避免"为了用而用"。

至少问清:
1. **稳定性赋能**:引入的中间件如何提升系统稳定性(降级、熔断、幂等、重试)?
2. **并发/吞吐赋能**:如何提升并发或吞吐(异步化、批量化、缓存、削峰)?
3. **可观测赋能**:新架构能否带来可观测性提升(链路追踪、指标暴露、告警)?
4. **必要性证明**:每项新技术架构元素的引入,必须能用一句话回答"不引入会怎样"。

**提问顺序与硬约束:**

1. 开放式探索完成后,**必须**按 A → B → C1 → C2 顺序提问(从宏观业务到微观技术),不能跳序
2. **每个角度至少一个问题**,不能因为"这个角度感觉很简单"就跳过
3. 用户的回答会直接沉淀到 design 的对应三要素段(角度 A 的回答 → 总体业务流程段;B → 当前需求业务流程段;C1+C2 → 当前需求技术架构段)
4. 若用户在某角度回答不出/不愿回答,brainstorming 必须在该角度标注"未澄清"并继续,**不准静默跳过**

**给 brainstorming 的提示词片段(skill 中要落地的):**

```markdown
## 三要素驱动提问框架(必须执行)

在你完成开放式理解、进入"提出澄清问题"阶段时,不要漫无目的地问。
你必须按以下顺序、覆盖以下四个角度提问,每个角度至少一个问题:

### A. 总体业务流程视角
- 这次需求与现有哪些业务模块有数据流或调用关系?
- 它在系统业务全景中处于什么位置?新增 / 替换 / 补强?
- 上游谁触发?下游产物给谁、触发什么?

### B. 当前需求业务流程视角
- 入口在哪?有几个?由什么触发?
- 业务流转的关键节点是什么?哪些同步、哪些可异步?
- 数据/状态怎么变迁?异常分支怎么走?

### C1. 与现有技术架构的契合度
- 系统现在已经在用哪些中间件?它们能不能覆盖本需求?
- 缺什么?(并发 / 稳定性 / 吞吐 / 可见性)
- 能复用就别新引。若新引,边界在哪?

### C2. 新技术架构的赋能
- 引入的中间件如何提升稳定性?(降级/熔断/幂等/重试)
- 如何提升并发或吞吐?(异步/批量/缓存/削峰)
- 如何提升可观测性?(链路/指标/告警)
- 每项新技术元素,用一句话回答"不引入会怎样"。

### 提问顺序与约束
- 顺序:A → B → C1 → C2,不能跳
- 每个角度至少一个问题,不准因为"简单"而跳过
- 回答不出的角度要标注"未澄清",继续推进,不准静默跳过
- 每个角度的回答会直接沉淀到 design 三要素对应段
```

#### 2.2.2 design 输出模板新增"三要素"必填段(与提问框架对应)

紧跟在 "Goal" 之后,在任何技术细节之前。位置硬约束:三要素在 design 文档里必须是第一等公民。

模板:
```markdown
## 三要素 (Three Pillars) — MUST

### 总体业务流程
[当前系统是做什么的、本次需求在整个系统中处于什么位置、起什么作用。
 不准只写"做 XXX 功能",必须交代与现有系统的关系。]

### 当前需求业务流程
[本次需求自身的业务流转:从入口到出口,关键状态变迁,关键参与者。
 不准只写技术步骤,必须用业务语言描述。]

### 当前需求技术架构

#### 开发架构
[代码分层、文件拆分:controller/service/dao/...;新建/修改哪些包,职责边界。
 必须明确"代码怎么组织",不能只写"实现 X 功能"。]

#### 技术架构
[引入或复用的中间件:MQ/缓存/锁/搜索/批量/...
 它们在业务流转中解决什么问题(稳定性/并发/吞吐)。
 没有引入中间件也必须显式说明"本需求无需新中间件,因为 ..."。]
```

#### 2.2.2 design 输出新增"最终验收清单(Draft)"必填段

在 design 文档末尾,每条验收项必须可追溯到三要素中的一条:

```markdown
## 最终验收清单 (Draft) — MUST

- [AC-1] (来源:总体业务流程) 验证 ... [期望结果]
- [AC-2] (来源:当前需求业务流程) 验证 ... [期望结果]
- [AC-3] (来源:技术架构.开发架构) 验证 ... [期望结果]
- [AC-4] (来源:技术架构.技术架构) 验证 ... [期望结果]
```

**强约束:**
- 每条 AC 必须显式标注"来源",来源必须是三要素中的某一条
- 不准出现"来源:综合"或"来源:整体"这种逃避追溯的写法
- 三要素的每一条至少要被一条 AC 覆盖(覆盖矩阵完整)

#### 2.2.3 Red Flags 表新增条目

| Thought | Reality |
|---|---|
| "三要素太啰嗦,需求很简单" | 简单需求三要素可以短到两三句,但**必须存在**(前提:已判 `yes`)。跳过即失败。 |
| "总体业务流程反正 writing-plans 也会查" | brainstorming 不写,writing-plans 就无源可引。三要素必须在 design 阶段沉淀。 |
| "验收清单是 writing-plans 的事" | brainstorming 必须产出 Draft,让 writing-plans 引用细化。不产出 Draft = design 未完成。 |
| "这个需求没有中间件,技术架构段空着" | 显式写"本需求无需新中间件,因为 X" — 空着 = 未思考。 |
| **"三要素是输出阶段的事,提问阶段还是按用户口述走"** | **三要素首先是提问框架(§2.2.1),其次才是输出模板(§2.2.2)。提问阶段不按 A→B→C1→C2 四角度覆盖 = brainstorming 未完成(前提:已判 `yes`)。** |
| **"用户没主动说业务全景,我也不问"** | **A 角度(总体业务流程)即使口述里没提到也必须主动问。最容易遗漏的就是这层,因此硬性约束。** |
| **"中间件问题(C1/C2)等 writing-plans 阶段再问"** | **不行。技术架构契合度与赋能必须 brainstorming 阶段问清,否则 design 写出来的技术架构段是空中楼阁。** |
| **"这个需求只是讨论/文档,判 `no` 跳过三要素"**(但实际涉及代码改动) | **故意降级判 `no` 逃避三要素提问 = 失败。判定必须诚实,涉及代码就是 `yes`。** |
| **"我拿不准要不要走三要素"** | **默认判 `yes`(保守策略)。拿不准本身就说明可能有代码维度,宁严勿松。** |

#### 2.2.4 Spec Self-Review 新增检查项

在现有 Self-Review 四项(placeholder / consistency / scope / ambiguity)后追加:
- **5. 适用范围判定存在**:design 文档头部有 `三要素适用: yes/no/partial` + 理由。无此行 = 未做判定 = 失败。
- **6. 三要素完整性**(仅当判定为 `yes` 时):三要素四子段(总体/当前/开发架构/技术架构)都有内容,无空段
- **7. 验收项可追溯**(仅当判定为 `yes` 时):每条 AC 都有明确来源,来源可指回三要素
- **8. 覆盖矩阵**(仅当判定为 `yes` 时):三要素的每一条至少被一条 AC 覆盖
- **9. 提问框架覆盖率**(仅当判定为 `yes` 时):确认 A / B / C1 / C2 四角度在提问阶段都至少问了一个问题,用户未回答的角度已显式标注"未澄清"。检查方法:回看 brainstorming 对话记录或 notes,四角度每个都要有对应的提问痕迹。

**对 `no` 判定的额外检查:** 若判定为 `no`,Self-Review 必须复核该判定是否成立 — 复核标准是"该需求真的不会改任何一行代码吗?"。若复核发现实际涉及代码,判定应改为 `yes`,补走三要素。

#### 2.2.5 触发关键词补充(可选)

不修改 name 字段(决策 3),但可在 description 末尾追加触发提示:
```
description: "...Explores user intent, requirements and design before implementation.
  MUST produce 三要素 (Three Pillars) and 最终验收清单 Draft before completion."
```

---

## 3. writing-plans skill 改造细节

### 3.1 文件
`skills/writing-plans/SKILL.md`

### 3.2 改动清单

#### 3.2.1 Plan Header 模板新增"最终验收清单"必填段

与 Global Constraints 同级。**必须引用自 spec 的验收雏形并细化**(给出具体测试命令/数据/边界):

```markdown
## 最终验收清单 (引用自 spec,可细化) — MUST

- [AC-1] (来源:总体业务流程) ...
  细化: 测试命令 `pytest tests/x.py::test_y` / 数据: ... / 边界: ...
- [AC-2] (来源:当前需求业务流程) ...
  细化: ...
- [AC-3] (来源:技术架构.开发架构) ...
  细化: ...
- [AC-4] (来源:技术架构.技术架构) ...
  细化: ...
```

**强约束:**
- 不准照抄 spec 的 Draft,必须给出可执行的细化(具体命令、具体数据、具体边界条件)
- 若 spec 的 AC 不可执行,writing-plans 必须在细化时改写为可执行(但仍标注来源)

#### 3.2.2 Task Structure 新增必填字段

每个任务头增加三行:

```markdown
### Task N: [Component Name]

**Level:** L1 | L2 | L3                    ← MUST
**Level 理由:** [为什么定这个级别]          ← MUST
**关联验收项:** [AC-1, AC-3]               ← MUST (L1 可空)

**Files:** ...
**Interfaces:** ...
```

#### 3.2.3 L1-L3 判定标准(写入 skill,作为分级启发式)

| Level | 触发条件 | 任务级验收方式 |
|---|---|---|
| **L1** | 单文件 / <50 行改动 / 无业务逻辑变化(纯配置、字段增删、UI 微调、文案) | 仅人工 review,不跑验收 |
| **L2** | 单模块改动 / 有业务逻辑但单层 / 标准 TDD 即可覆盖 | TDD red-green |
| **L3** | 跨模块或跨层 / 涉及业务流程变化 / 需要端到端验证 | TDD + 任务级验收项(对应关联的 AC) |

**L3 必须满足的额外要求:**
- `关联验收项` 不能为空
- 关联的 AC 必须在 spec/plan 的最终验收清单中存在
- 任务步骤里必须包含"运行任务级验收"的 step(对照 AC 逐条验证)

#### 3.2.4 Execution Handoff 改为三选一(ltdd 为推荐)

替换原"Subagent-Driven (recommended) / Inline Execution"两选一,改为:

```markdown
**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Three execution options:**

**1. LTDD (推荐)** - 双层验收循环:任务级 L1/L2/L3 + 计划级最终验收;失败自动重启子 agent 改代码、重跑验收。适合有明确业务验收点的需求。

**2. Subagent-Driven** - 原生:每个 task fresh subagent + 两阶段 review (spec compliance / code quality)。适合代码质量优先的需求。

**3. Inline Execution** - 原生:批量执行 + checkpoint。适合人在场、需要逐步确认的需求。

**Which approach?"**

**If LTDD chosen:**
- REQUIRED SUB-SKILL: Use superpowers:ltdd
- 双层验收循环 + 失败重启

**If Subagent-Driven chosen:**
- REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
- (原内容保留)

**If Inline Execution chosen:**
- REQUIRED SUB-SKILL: Use superpowers:executing-plans
- (原内容保留)
```

#### 3.2.5 Self-Review 新增检查项

在现有三项(spec coverage / placeholder / type consistency)后追加:
- **4. Level 完整性**:每个任务都有 Level 与 Level 理由
- **5. L3 验收绑定**:L3 任务的 `关联验收项` 不为空,且引用的 AC 在最终验收清单中存在
- **6. 最终验收覆盖**:最终验收清单每条 AC 至少被一个 L3 任务关联(否则有 AC 没人负责)

---

## 4. ltdd skill 详细设计

### 4.1 文件
`skills/ltdd/SKILL.md`(全新)

### 4.2 YAML 头

```yaml
---
name: ltdd
description: "Loop TDD - 双层验收循环执行。任务级 L1/L2/L3 验收 + 计划级最终验收,失败自动重启子 agent 改代码、重跑验收。Use when writing-plans 末尾选 ltdd、或显式要求 loop tdd / ltdd。"
---
```

### 4.3 主流程

```
load(plan_path, spec_path)
extract:
  最终验收清单[]      ← 从 plan
  tasks[]            ← 从 plan
  spec 三要素         ← 从 spec(供子 agent 参考)

# === 阶段一:任务级循环 ===
for task in tasks:
    announce(f"Task {task.id} [{task.Level}] - {task.title}")

    # 1. 执行 task(批量模式,类 executing-plans)
    execute_task_steps(task) → 代码改动 + 测试改动

    # 2. 任务级验收
    match task.Level:
        L1:
            result = { passed: true, skipped: "L1 no acceptance" }
        L2:
            result = run_tdd(task)        # 跑 TDD red-green
        L3:
            tdd   = run_tdd(task)
            ac    = run_task_acceptance(task, task.关联验收项)
            result = { passed: tdd.passed AND ac.passed, ... }

    # 3. 失败重启循环(无上限,见决策 7)
    iteration = 0
    while not result.passed:
        iteration += 1
        if iteration >= 5:
            WARN(f"Task {task.id} 已循环 {iteration} 次,建议人工介入;继续自动循环中...")

        report = dispatch_subagent(
            role    = "修复工程师",
            input   = [task.doc, task.acceptance_items, current_code_state(task)],
            output  = "code_and_test_changes_only",
            forbid  = [spec, 最终验收清单, other_tasks_code],
            success = "由主 session 重跑验收确定,不准自报通过"
        )
        log(iteration, report)

        # 重跑验收
        match task.Level:
            L2: result = run_tdd(task)
            L3:
                tdd = run_tdd(task)
                ac  = run_task_acceptance(task, task.关联验收项)
                result = { passed: tdd.passed AND ac.passed, ... }

    commit_task(task)

# === 阶段二:计划级循环 ===
announce("进入计划级最终验收")
plan_result = run_plan_acceptance(最终验收清单)   # 跑全部 AC
iteration = 0
while not plan_result.all_passed:
    iteration += 1
    if iteration >= 5:
        WARN(f"计划级验收已循环 {iteration} 次,建议人工介入;继续自动循环中...")

    report = dispatch_subagent(
        role    = "修复工程师(全局)",
        input   = [plan.doc, 最终验收清单, current_state_snapshot, spec.三要素],
        output  = "code_and_test_changes_only",
        forbid  = [spec, 最终验收清单],
        success = "由主 session 重跑全部 AC 确定"
    )
    log(iteration, report)
    plan_result = run_plan_acceptance(最终验收清单)

announce("LTDD complete: all acceptance criteria passed")
```

### 4.4 子 agent 调度协议(写入 skill 内容)

每次 `dispatch_subagent` 必须构造如下 prompt 模板:

```markdown
你是修复工程师。

# 任务范围
你只能修复验收失败,不能扩展功能、不能重构无关代码。

# 输入
- 任务文档:[贴出 task doc 段]
- 验收项:[贴出 AC list]
- 当前代码状态:[贴出相关文件的相关行]
- 失败原因:[贴出上次验收输出]

# 你能改的
- 任务文档中 Files 列表内的代码
- 对应的测试代码

# 你不能改的
- spec
- 最终验收清单
- 其他任务的代码

# 输出报告(必须)
1. 改了哪些文件、改了什么、为什么
2. 对应修复了哪条验收项
3. 预期效果

# 通过判定
你不准自报"已通过"。主 session 会重跑验收来确定。
```

### 4.5 状态记录与中断恢复

每轮循环追加写入 `.superpowers/sdd/ltdd-state.json`(与 commit `207a12b` 的 SDD workspace helper 路径一致):

```json
{
  "plan_path": "docs/superpowers/plans/xxx.md",
  "spec_path": "docs/superpowers/specs/xxx.md",
  "current_phase": "task-level-loop | plan-level-loop",
  "current_task_id": "Task-3",
  "current_iteration": 2,
  "task_status": {
    "Task-1": { "level": "L2", "status": "passed", "iterations": 0 },
    "Task-2": { "level": "L3", "status": "passed", "iterations": 1 },
    "Task-3": { "level": "L3", "status": "in_progress", "iterations": 2 }
  },
  "history": [
    { "ts": "...", "task": "Task-3", "iter": 1, "action": "subagent_dispatched", "summary": "..." }
  ]
}
```

**中断恢复:** 用户中断后重新触发 ltdd,ltdd 必须先读 `ltdd-state.json`,从 `current_task_id` + `current_iteration` 继续,不能从头开始。

**手动重置:** 用户可删除 `ltdd-state.json` 强制从头开始。

### 4.6 失败兜底

- 不设循环上限(决策 7),但 ≥5 次时软提醒(见主流程的 WARN)
- 若用户在中断时显式说"放弃 ltdd",ltdd 写出 handoff 文档:
  ```markdown
  # LTDD Handoff

  ## 当前进度
  - 已完成任务: Task-1, Task-2
  - 卡住任务: Task-3 (L3, iteration 4)
  - 卡住原因: [失败验收项 + 子 agent 报告摘要]

  ## 推荐下一步
  - [ ] 人工 review Task-3 失败的 AC 是否合理
  - [ ] 若 AC 合理,人工修复代码后重跑
  - [ ] 若 AC 不合理,回到 brainstorming 调整 spec
  ```

### 4.7 ltdd 的 Skill 内容大纲(写作时遵循)

约 200-250 行。结构:

1. YAML 头
2. 概述(what / when / 与 subagent-driven-development、executing-plans 的区别)
3. 触发条件
4. 输入约定(plan + spec)
5. 主流程(任务级循环 + 计划级循环)
6. 子 agent 调度协议(prompt 模板 + 边界)
7. 验收重跑协议(L1/L2/L3 分别怎么跑)
8. 状态记录与中断恢复
9. 失败兜底(handoff 文档)
10. Red Flags 表
11. Self-Review 检查项

---

## 5. 跨 skill 契约(数据流硬约束)

### 5.1 brainstorming spec 输出格式(完整)

```markdown
# [Feature] Design

## Goal
...

## 三要素 (Three Pillars) — MUST
### 总体业务流程
...
### 当前需求业务流程
...
### 当前需求技术架构
#### 开发架构
...
#### 技术架构
...

[...其他原有段: Architecture / Components / Data Flow / Error Handling / Testing ...]

## 最终验收清单 (Draft) — MUST
- [AC-1] (来源:总体业务流程) ...
- [AC-2] (来源:当前需求业务流程) ...
- [AC-3] (来源:技术架构.开发架构) ...
- [AC-4] (来源:技术架构.技术架构) ...
```

### 5.2 writing-plans plan 输出格式(完整)

```markdown
# [Feature] Implementation Plan

**Goal:** ...
**Architecture:** ...
**Tech Stack:** ...

## Global Constraints
...

## 最终验收清单 (引用自 spec,可细化) — MUST
- [AC-1] (来源:...) 细化: ...
- [AC-2] (来源:...) 细化: ...
...

---

### Task 1: ...
**Level:** L2
**Level 理由:** 改动 Service 层单方法,有业务逻辑
**关联验收项:** [AC-1, AC-2]
**Files:** ...
**Interfaces:** ...
[...步骤...]

### Task 2: ...
**Level:** L3
...
```

### 5.3 ltdd 读取约定

- 从 plan 读 `tasks[]`、每任务的 `Level` / `关联验收项`
- 从 plan 或 spec 读 `最终验收清单`
- 从 spec 读 `三要素`(供子 agent prompt 参考)
- 状态写 `.superpowers/sdd/ltdd-state.json`(与 SDD workspace helper 路径一致)

### 5.4 跨 skill 引用完整性

`writing-plans` 生成 plan 后,以下引用必须可解析:
- 每条 plan 的最终验收清单 AC,必须能在 spec 的最终验收清单(Draft)中找到对应(来源标注一致)
- 每个 L3 任务的 `关联验收项`,必须能在 plan 的最终验收清单中找到
- `ltdd` 跑 plan 时,若发现引用断裂(AC 编号对不上),立即报错并退出,不进入循环

---

## 6. 验证策略

| 验证层 | 方法 | 通过标准 |
|---|---|---|
| **结构完整性** | grep 检查三个 skill 文件,确认 MUST 段齐全 | 三要素、最终验收清单、Level 字段、关联验收项字段模板都在 |
| **引用链未断** | grep `brainstorming` / `writing-plans` 在 using-superpowers、writing-skills、subagent-driven-development 中的引用 | 无断链(name 字段未改) |
| **手工 dogfood - brainstorming(技术场景)** | 跑一个真实小需求(例如"给现有 X 加导出功能");**对提问阶段全程做记录**(转写或笔记),事后回看 | (1) design 头部有 `三要素适用: yes` + 理由;(2) 提问阶段按 A→B→C1→C2 四角度覆盖,每角度至少问了一题;(3) 用户未答的角度已显式标注"未澄清";(4) spec 含完整三要素 + 验收雏形,每条 AC 可追溯 |
| **手工 dogfood - brainstorming(非技术场景)** | 跑一个纯讨论/纯文档类需求(例如"讨论某概念是否适用于本项目") | (1) design 头部有 `三要素适用: no` + 理由;(2) 未强行套三要素提问框架;(3) design 文档结构按需组织 |
| **手工 dogfood - writing-plans** | 用上一步 spec 生成 plan | 每任务有 Level + 理由 + 关联验收项;最终验收清单细化;L3 任务有任务级验收 step |
| **手工 dogfood - ltdd** | 故意造一个 L3 任务级失败(藏一个 bug) | 子 agent 启动 → 改代码 → 重跑验收 → 通过;状态文件正确写入 |
| **手工 dogfood - ltdd 计划级** | 所有任务跑完后,故意让一条最终 AC 失败 | 进入计划级循环 → 子 agent 修复 → 重跑全部 AC → 通过 |
| **手工 dogfood - 中断恢复** | ltdd 跑到 Task-3 中断,重新触发 | 从 Task-3 继续,不重头开始 |
| **回归** | 跑 `tests/` 现有 plugin 基础测试 | 全过(未触动 plugin 基础设施) |
| **个人 fork 边界** | grep 确认没引入第三方依赖(AGENTS.md 硬约束) | 零新依赖 |

**不做的验证:**
- drill eval(skill-behavior eval)— 个人 fork 不需要(决策 1)
- 跨 harness 集成测试 — 个人 fork 用户只用 1-2 个 harness,不强求全适配

---

## 7. 不在本次范围内(YAGNI)

明确剔除以下内容,避免 scope creep:

- **重命名 brainstorming / writing-plans** — 决策 3:保留触发链
- **完全代替 executing-plans / subagent-driven-development** — 决策 8:三选一共存
- **跨 harness 适配 ltdd** — 用户主 harness 测通即可
- **ltdd 子 agent 并行化** — 第一版串行,后续若有需要再加
- **自动学习历史失败模式** — YAGNI,先跑通基础循环
- **可视化 ltdd 进度** — 文本日志够用
- **CI 集成** — 个人 fork 不强求

---

## 8. 风险与缓解

| 风险 | 概率 | 影响 | 缓解 |
|---|---|---|---|
| `ltdd` 循环死锁(某 AC 永远过不了) | 中 | 高(烧 token) | ≥5 次软提醒 + handoff 文档(决策 7 不设硬上限,用户自担) |
| 子 agent 越界改了 spec/验收项 | 低 | 高(验收失效) | prompt 模板明确 forbid + 主 session 重跑时校验 spec 哈希 |
| brainstorming 产的三要素太虚(空话) | 中 | 中(后续全链条失真) | Red Flags 表强约束 + Self-Review 检查 |
| writing-plans 给 L3 任务漏标关联验收项 | 中 | 中(L3 退化成 L2) | Self-Review 检查"L3 关联验收项不为空" |
| 上游 brainstorming/writing-plans 更新导致 merge 冲突 | 高(时间问题) | 中 | 个人 fork 接受;merge 时手工 reconcile |
| 用户实际不需要那么严格(用了几次嫌烦) | 中 | 低 | 软提醒而非硬阻塞;L1 路径仍可轻量跑 |

---

## 9. 后续维护

- **个人 fork 同步上游**:`git fetch upstream && git merge upstream/main`,手工 reconcile brainstorming/writing-plans 冲突;ltdd 是新文件,无冲突
- **ltdd 自身迭代**:ltdd 是全新文件,改它不会影响上游 merge
- **三要素模板演进**:若发现某些项目类型(如纯前端)三要素不适合,可在 skill 内容里加"项目类型分支",但不在本次范围

---

## 附录 A:与原 superpowers 工作流的关系

原工作流:
```
brainstorming → using-git-worktrees → writing-plans → subagent-driven/executing-plans → TDD → requesting-code-review → finishing-a-development-branch
```

改造后工作流(fork 内):
```
brainstorming (含三要素+验收雏形)
    → using-git-worktrees (不变)
    → writing-plans (含最终验收清单+L1-L3+三选一)
    → ltdd (推荐) / subagent-driven (保留) / executing-plans (保留)
    → [ltdd 内含 TDD + 双层验收 + 失败循环]
    → requesting-code-review (不变)
    → finishing-a-development-branch (不变)
```

不变的部分:using-git-worktrees、requesting-code-review、finishing-a-development-branch、所有 debugging/meta 类 skill。
