# Brainstorm 三要素 + Writing-Plan 验收驱动 + LTDD 循环 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `obra/superpowers` v6.0.3 个人 fork 改造为"三要素驱动提问 + 验收清单驱动计划 + LTDD 双层循环执行"的工作流(改 2 个 skill + 新增 1 个 skill)。

**Architecture:** 三个 skill 通过文档契约衔接 — `brainstorming` 产出"三要素 + 验收雏形"design;`writing-plans` 引用并细化为"最终验收清单 + L1-L3 任务";`ltdd` 读取两者跑双层循环执行。所有改动为 markdown 内容(塑造 agent 行为),无可执行代码改动。

**Tech Stack:** Markdown skill 文件;无第三方依赖(AGENTS.md 硬约束);验证用 grep + 手工 dogfood。

**Spec:** `docs/superpowers/specs/2026-06-25-brainstorm-writing-plan-ltdd-integration-design.md`

## Global Constraints

- **零第三方依赖**(AGENTS.md 硬约束)— 所有改动只用 markdown
- **不重命名 skill**(spec 决策 3)— `brainstorming`/`writing-plans` 的 name 字段不动,保留触发链
- **不上游 PR**(spec 决策 1)— 个人 fork,无需 eval 证据
- **不破坏现有引用链**— `using-superpowers`、`subagent-driven-development` 等对 brainstorming/writing-plans 的引用必须仍可解析
- **MUST 标注语义**:本计划中所有"**MUST**"对应 spec 的硬约束;所有"推荐"对应可选项
- **用户偏好:不提交 git** — 每个任务的 commit step 标注"(可选)",用户可跳过
- **测试方法说明**:本计划修改的是塑造 agent 行为的 markdown 内容,不是可执行代码,因此不能用 red-green TDD。每个任务用"结构 grep 验证 + 手工通读"作为任务级验收;最终 AC 见下"最终验收清单"

## 最终验收清单 (引用自 spec,已细化)

- [AC-1] (来源:总体业务流程) `skills/brainstorming/SKILL.md` 含"三要素适用范围判定"段 + "三要素驱动提问框架"段(A/B/C1/C2 四角度,每角度至少 3 条问题) + design 输出"三要素"MUST 段 + design 输出"最终验收清单(Draft)"MUST 段 + Red Flags 表新增条目 + Self-Review 新增 #5-#9 检查项
  - 细化: `grep -c "三要素适用" skills/brainstorming/SKILL.md` ≥ 1;`grep -c "A → B → C1 → C2\|A→B→C1→C2" skills/brainstorming/SKILL.md` ≥ 2;`grep -c "## 三要素" skills/brainstorming/SKILL.md` ≥ 1
- [AC-2] (来源:当前需求业务流程) `skills/writing-plans/SKILL.md` 含"最终验收清单"header MUST 段 + Task Structure 含 `Level`/`Level 理由`/`关联验收项` 三字段 + L1-L3 判定标准表 + Execution Handoff 三选一(ltdd 为推荐)+ Self-Review 新增 #4-#6 检查项
  - 细化: `grep -c "Level:.*L1.*L2.*L3\|Level 理由\|关联验收项" skills/writing-plans/SKILL.md` 各 ≥ 1;`grep -c "ltdd" skills/writing-plans/SKILL.md` ≥ 3;`grep -c "subagent-driven-development\|executing-plans" skills/writing-plans/SKILL.md` 各 ≥ 1(原生项保留)
- [AC-3] (来源:技术架构.开发架构) `skills/ltdd/SKILL.md` 新文件存在,含 YAML 头 + 主流程(任务级循环 + 计划级循环)+ 子 agent 调度协议(prompt 模板)+ 状态记录/中断恢复 + 失败兜底(handoff)+ Red Flags + Self-Review
  - 细化: `test -f skills/ltdd/SKILL.md && wc -l skills/ltdd/SKILL.md` 行数 ≥ 200;`grep -c "task-level-loop\|plan-level-loop" skills/ltdd/SKILL.md` 各 ≥ 1;`grep -c "dispatch_subagent\|修复工程师" skills/ltdd/SKILL.md` 各 ≥ 1;`grep -c "ltdd-state.json" skills/ltdd/SKILL.md` ≥ 1
- [AC-4] (来源:技术架构.技术架构 — 零依赖) 没引入第三方依赖
  - 细化: `git diff --stat` 显示只改了 `skills/brainstorming/SKILL.md`、`skills/writing-plans/SKILL.md`、新增 `skills/ltdd/SKILL.md`;`grep -rE "^import |^require\(|from [a-z]" skills/ltdd/SKILL.md` 无匹配(markdown 不该有代码导入)
- [AC-5] (来源:跨 skill 契约) 引用链未断 — `using-superpowers`、`subagent-driven-development`、`writing-skills` 中对 brainstorming/writing-plans 的引用仍可解析
  - 细化: `grep -rE "brainstorming|writing-plans" skills/ | grep -v "^skills/brainstorming/SKILL.md\|^skills/writing-plans/SKILL.md"` 输出与改动前对比无新增断链
- [AC-6] (来源:回归) `tests/` 现有 plugin 基础测试不受影响
  - 细化: 跑 `tests/run-*.sh`(若存在),全过

---

## File Structure

| 文件 | 操作 | 责任 |
|---|---|---|
| `skills/brainstorming/SKILL.md` | 修改 | 加入三要素适用范围判定 + 三要素提问框架 + 三要素/验收雏形 design 模板段 + Red Flags + Self-Review |
| `skills/writing-plans/SKILL.md` | 修改 | 加入最终验收清单 header 段 + Task Level 字段 + L1-L3 标准 + 三选一 handoff + Self-Review |
| `skills/ltdd/SKILL.md` | 新建 | 双层循环执行 skill |

任务顺序:Task 1(brainstorming) → Task 2(writing-plans) → Task 3(ltdd) → Task 4(跨 skill 契约校验)。Task 4 不产新代码,只校验前三任务的产物对得上。

---

### Task 1: 改造 brainstorming skill(三要素提问框架 + design 输出 + Red Flags + Self-Review)

**Level:** L3
**Level 理由:** 跨多个 skill 内部章节(适用范围段 + 提问框架 + 输出模板 + Red Flags + Self-Review + Checklist 修改);涉及塑造 agent 行为的核心流程,需要端到端验证。
**关联验收项:** [AC-1, AC-5]

**Files:**
- Modify: `skills/brainstorming/SKILL.md`(全文 159 行,在多处插入新内容)
- Test: 任务级验收用 grep 命令(见步骤 7)

**Interfaces:**
- Consumes: 无(原生 brainstorming 起点)
- Produces: design 文档的新结构 — 必须含 `三要素适用: yes/no/partial` 头部标注 + (若 yes)三要素四子段 + (若 yes)最终验收清单 Draft。后续 `writing-plans` 引用这些产物。

- [ ] **Step 1: 通读现有 brainstorming/SKILL.md 全文,确认插入点**

Run: `cat skills/brainstorming/SKILL.md | head -200`
Expected: 看到 Checklist 段(20-33 行)、Red Flags 表(原版可能在 Process 段或 Key Principles 里)、Self-Review 段(在 "After the Design" 下)。

确认 6 个插入点:
1. YAML description 末尾(第 3 行)— 追加触发提示(可选)
2. Checklist 段(第 20-33 行)— 修改第 3 项"Ask clarifying questions",插入"三要素适用范围判定"作为第 3a 项
3. Process 段的"Understanding the idea"之后 — 插入完整"三要素驱动提问框架"小节(含适用范围 + A/B/C1/C2 四角度 + 提示词片段)
4. "Presenting the design" 段后或"After the Design"前 — 插入"design 输出模板:三要素 + 最终验收清单 Draft"
5. Red Flags 表(若原版有)— 追加 7 条新条目;若原版无 — 新建 Red Flags 表
6. Self-Review 段(在 "Spec Self-Review" 下,现有 4 项后)— 追加 #5-#9

若通读发现 Red Flags 表不存在,需新建(放在 Key Principles 之前)。

- [ ] **Step 2: 修改 YAML description(可选,触发关键词)**

定位 `skills/brainstorming/SKILL.md` 第 3 行:

```yaml
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
```

改为:

```yaml
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation. 涉及技术与编码的需求 MUST 先做三要素适用范围判定,若判 yes MUST 按 A→B→C1→C2 四角度提问,并产出三要素 design 段 + 最终验收清单 Draft。"
```

- [ ] **Step 3: 修改 Checklist 第 3 项,插入"三要素适用范围判定"**

定位 Checklist 第 3 项(约 26 行):
```markdown
3. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
```

改为(替换 + 在其后插入 3a):
```markdown
3. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3a. **三要素适用范围判定(只在涉及技术与编码的需求中强制)** — 在开放式探索结束后、进入澄清阶段前,显式做一次判定。产出 `三要素适用: yes/no/partial` + 理由,后续写进 design 头部。详见 §三要素驱动提问框架。判定为 `yes` 时,后续澄清问题 MUST 按 A→B→C1→C2 四角度逐个覆盖;判定为 `no` 时跳过三要素提问框架,design 按需组织;拿不准默认 `yes`(宁严勿松)。
```

- [ ] **Step 4: 在 Process 段插入完整"三要素驱动提问框架"小节**

定位 Process 段中 "**Understanding the idea:**" 小节末尾(在 "Focus on understanding: purpose, constraints, success criteria" 这一行之后),插入如下新小节:

```markdown
**三要素驱动提问框架(仅在 §3a 判定为 `yes` 时强制执行):**

三要素不只是 design 的输出模板,更是提问阶段的硬性框架。当前 brainstorming 的开放式提问容易陷入"按用户口述顺序记笔记、缺系统性"。改造后,澄清问题 MUST 按以下四角度顺序覆盖,每角度至少一个问题:

**角度 A — 总体业务流程视角的提问**
目的:把当前需求放进整个系统的业务全景里定位。
至少问清:
1. **联动关系**:本次需求会与现有哪些业务模块产生数据流或调用关系?哪些会被影响?
2. **作用定位**:在当前系统的业务全景里,这个需求是新增能力、替换既有能力、还是补强既有能力的某个环节?
3. **上下游影响**:上游(谁触发、触发条件)和下游(产物给谁、产生什么后续动作)分别是什么?

**角度 B — 当前需求业务流程视角的提问**
目的:搞清本次需求自身的业务流转闭环。
至少问清:
1. **入口与触发**:需求从哪里被触发(用户操作 / 定时任务 / 消息 / API)?入口有几个?
2. **业务流转的关键节点**:流转中有哪些不可省略的业务步骤?哪些同步、哪些可异步?
3. **状态变迁与边界**:流转中数据/状态经过哪些变化?异常分支怎么走?兜底是什么?

**角度 C1 — 与现有技术架构的契合度提问**
目的:搞清"这个需求要落地,现有技术架构够不够、差什么"。
至少问清:
1. **现有中间件盘点**:当前系统已经在用哪些中间件(MQ、缓存、分布式锁、搜索、批量、数据库特性等)?它们覆盖本需求场景吗?
2. **缺口分析**:本需求若直接落地,现有技术架构在哪一环不够用(并发 / 稳定性 / 吞吐 / 可见性)?需要补什么?
3. **复用 vs 新建**:能用现有中间件就别新引。若必须新引,新引的中间件与现有架构的边界在哪?

**角度 C2 — 新技术架构对当前需求与系统的赋能提问**
目的:搞清"若引入新技术架构元素,能为业务流转带来什么具体提升",避免"为了用而用"。
至少问清:
1. **稳定性赋能**:引入的中间件如何提升稳定性(降级、熔断、幂等、重试)?
2. **并发/吞吐赋能**:如何提升并发或吞吐(异步化、批量化、缓存、削峰)?
3. **可观测赋能**:新架构能否带来可观测性提升(链路追踪、指标暴露、告警)?
4. **必要性证明**:每项新技术架构元素的引入,必须能用一句话回答"不引入会怎样"。

**提问顺序与硬约束:**
1. 开放式探索完成后,MUST 按 A → B → C1 → C2 顺序提问(从宏观业务到微观技术),不能跳序
2. 每个角度至少一个问题,不能因为"这个角度感觉很简单"就跳过
3. 用户的回答直接沉淀到 design 的对应三要素段(A → 总体业务流程;B → 当前需求业务流程;C1+C2 → 技术架构)
4. 若用户在某角度回答不出/不愿回答,brainstorming MUST 在该角度标注"未澄清"并继续,**不准静默跳过**
```

- [ ] **Step 5: 在"Presenting the design"段后插入"design 输出模板:三要素 + 最终验收清单 Draft"**

定位 Process 段中 "**Presenting the design:**" 小节末尾(在 "Be ready to go back and clarify if something doesn't make sense" 这一行之后),插入:

```markdown
**design 输出模板(仅在 §3a 判定为 `yes` 时强制):**

design 文档 MUST 含以下两段(位置:三要素紧跟 Goal 之后;最终验收清单 Draft 在文档末尾):

`## 三要素 (Three Pillars) — MUST`

`### 总体业务流程`
[本次需求在整个系统中处于什么位置、起什么作用。不准只写"做 XXX 功能",必须交代与现有系统的关系。来源:角度 A 的回答。]

`### 当前需求业务流程`
[本次需求自身的业务流转:从入口到出口,关键状态变迁,关键参与者。用业务语言,不用技术步骤。来源:角度 B 的回答。]

`### 当前需求技术架构`

`#### 开发架构`
[代码分层、文件拆分:controller/service/dao/...;新建/修改哪些包,职责边界。必须明确"代码怎么组织"。]

`#### 技术架构`
[引入或复用的中间件:MQ/缓存/锁/搜索/批量/...;它们在业务流转中解决什么问题(稳定性/并发/吞吐)。来源:角度 C1+C2 的回答。没有引入中间件也 MUST 显式说明"本需求无需新中间件,因为 ..."。]

`## 最终验收清单 (Draft) — MUST`

每条验收项 MUST 显式标注来源,来源 MUST 是三要素中的某一条:

- [AC-1] (来源:总体业务流程) 验证 ... [期望结果]
- [AC-2] (来源:当前需求业务流程) 验证 ... [期望结果]
- [AC-3] (来源:技术架构.开发架构) 验证 ... [期望结果]
- [AC-4] (来源:技术架构.技术架构) 验证 ... [期望结果]

**强约束:**
- 每条 AC MUST 显式标注"来源",来源 MUST 可指回三要素
- 不准出现"来源:综合"或"来源:整体"这种逃避追溯的写法
- 三要素的每一条至少要被一条 AC 覆盖(覆盖矩阵完整)

**design 头部标注(所有判定结果都要写):**
design 文档第一段(在 Goal 之前或之后)MUST 含一行:
`三要素适用: yes/no/partial — 理由: ...`
```

- [ ] **Step 6: 追加 Red Flags 表条目**

定位 Key Principles 段之前(若原版无 Red Flags 表,新建一个 `## Red Flags` 段)。在现有 Red Flags 表末尾追加 7 条新条目:

```markdown
| Thought | Reality |
|---|---|
| "三要素太啰嗦,需求很简单" | 简单需求三要素可以短到两三句,但 MUST 存在(前提:已判 `yes`)。跳过即失败。 |
| "总体业务流程反正 writing-plans 也会查" | brainstorming 不写,writing-plans 无源可引。三要素 MUST 在 design 阶段沉淀。 |
| "验收清单是 writing-plans 的事" | brainstorming MUST 产出 Draft,让 writing-plans 引用细化。不产出 = design 未完成。 |
| "这个需求没有中间件,技术架构段空着" | 显式写"本需求无需新中间件,因为 X" — 空着 = 未思考。 |
| "三要素是输出阶段的事,提问阶段还是按用户口述走" | 三要素首先是提问框架(§3a + §三要素驱动提问框架),其次才是输出模板。提问阶段不按 A→B→C1→C2 四角度覆盖 = brainstorming 未完成(前提:已判 `yes`)。 |
| "用户没主动说业务全景,我也不问" | A 角度(总体业务流程)即使口述里没提到也 MUST 主动问。最容易遗漏的就是这层。 |
| "中间件问题(C1/C2)等 writing-plans 阶段再问" | 不行。技术架构契合度与赋能 MUST brainstorming 阶段问清,否则 design 的技术架构段是空中楼阁。 |
| "这个需求只是讨论/文档,判 `no` 跳过三要素" | 故意降级判 `no` 逃避三要素提问 = 失败。判定必须诚实,涉及代码就是 `yes`。 |
| "我拿不准要不要走三要素" | 默认判 `yes`(保守策略)。拿不准本身就说明可能有代码维度,宁严勿松。 |
```

(若原版已有 Red Flags 表,追加新行;若表格列结构不同,适配列结构但保留"Thought / Reality"含义。)

- [ ] **Step 7: 追加 Self-Review 检查项**

定位 "Spec Self-Review" 段,在现有 4 项(placeholder / consistency / scope / ambiguity)后追加:

```markdown
5. **适用范围判定存在**:design 文档头部有 `三要素适用: yes/no/partial` + 理由。无此行 = 未做判定 = 失败。
6. **三要素完整性**(仅当判定为 `yes` 时):三要素四子段(总体/当前/开发架构/技术架构)都有内容,无空段。
7. **验收项可追溯**(仅当判定为 `yes` 时):每条 AC 都有明确来源,来源可指回三要素。
8. **覆盖矩阵**(仅当判定为 `yes` 时):三要素的每一条至少被一条 AC 覆盖。
9. **提问框架覆盖率**(仅当判定为 `yes` 时):确认 A / B / C1 / C2 四角度在提问阶段都至少问了一个问题,用户未回答的角度已显式标注"未澄清"。检查方法:回看 brainstorming 对话记录或 notes。

**对 `no` 判定的额外检查:** 若判定为 `no`,Self-Review MUST 复核该判定是否成立 — 复核标准是"该需求真的不会改任何一行代码吗?"。若复核发现实际涉及代码,判定应改为 `yes`,补走三要素。
```

- [ ] **Step 8: 任务级验收 — 结构 grep 检查**

Run(每条独立执行,期望都 ≥ 1):
```bash
grep -c "三要素适用" skills/brainstorming/SKILL.md
grep -cE "A → B → C1 → C2|A→B→C1→C2" skills/brainstorming/SKILL.md
grep -c "## 三要素" skills/brainstorming/SKILL.md
grep -c "最终验收清单 (Draft)" skills/brainstorming/SKILL.md
grep -c "三要素驱动提问框架" skills/brainstorming/SKILL.md
grep -cE "角度 A —|角度 B —|角度 C1 —|角度 C2 —" skills/brainstorming/SKILL.md
```
Expected: 每条 ≥ 1(多数应 ≥ 2)。若某条 = 0,回到对应 step 补上。

- [ ] **Step 9: 任务级验收 — 手工通读**

打开 `skills/brainstorming/SKILL.md`,从头读一遍,确认:
1. Checklist 第 3a 项与后面"三要素驱动提问框架"小节相互引用一致
2. "三要素驱动提问框架"小节中 A→B→C1→2 顺序正确、每角度有 3-4 条问题
3. "design 输出模板"小节的四子段标题与"三要素驱动提问框架"四角度对应(A→总体业务流程;B→当前需求业务流程;C1+C2→技术架构)
4. Red Flags 表 9 条新条目措辞与 Self-Review 检查项一致
5. 没破坏原版的 HARD-GATE、Visual Companion 等段(它们应仍完整存在)

- [ ] **Step 10: (可选) Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat(brainstorming): add 三要素适用范围判定 + 三要素驱动提问框架 + design 输出模板 + Red Flags + Self-Review (个人 fork)"
```

(用户偏好不提交 git — 跳过此步)

---

### Task 2: 改造 writing-plans skill(最终验收清单 + L1-L3 + 三选一 handoff + Self-Review)

**Level:** L3
**Level 理由:** 跨多个内部章节(header 模板 + task 结构 + L1-L3 标准表 + handoff 段 + Self-Review);需要与 brainstorming 产出的契约对得上,需端到端验证。
**关联验收项:** [AC-2, AC-5]

**Files:**
- Modify: `skills/writing-plans/SKILL.md`(全文 174 行)
- Test: grep + 手工通读

**Interfaces:**
- Consumes: brainstorming 产出的 design(spec 中的三要素 + 最终验收清单 Draft)
- Produces: plan 文档的新结构 — header 含最终验收清单、每个 task 含 Level/Level 理由/关联验收项、handoff 三选一。后续 `ltdd`/`subagent-driven-development`/`executing-plans` 读取此结构。

- [ ] **Step 1: 通读现有 writing-plans/SKILL.md 全文,确认插入点**

Run: `cat skills/writing-plans/SKILL.md`
Expected: 看到 Plan Document Header(53-77 行)、Task Structure(79-126 行)、Self-Review(144-154 行)、Execution Handoff(156-174 行)。

确认 5 个插入/修改点:
1. Plan Document Header 模板(58-77 行)— 在 `## Global Constraints` 前插入 `## 最终验收清单` 段
2. Task Structure(81-126 行)— 在 `### Task N:` 后、`**Files:**` 前插入 `**Level:** / **Level 理由:** / **关联验收项:**` 三行
3. "Task Right-Sizing" 段(37-43 行)后或 Task Structure 后 — 插入"L1-L3 判定标准"表
4. Execution Handoff 段(156-174 行)— 改为三选一(ltdd 为推荐)
5. Self-Review(144-154 行)— 追加 #4-#6

- [ ] **Step 2: 在 Plan Document Header 模板插入"最终验收清单"段**

定位 Plan Document Header 模板的 ``` ``` ``` 块内,在 `## Global Constraints` 之前插入新段。修改后的 header 模板应为:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: ...

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[...]

## 最终验收清单 (引用自 spec,可细化) — MUST

- [AC-1] (来源:...) ...
  细化: 测试命令 ... / 数据: ... / 边界: ...
- [AC-2] (来源:...) ...
  细化: ...
[...]

---
```

在 header 模板后的散文说明里追加一段:
"**最终验收清单 MUST 引用自 spec 的 Draft 并细化**(给出具体测试命令/数据/边界)。不准照抄 spec 的 Draft。若 spec 的 AC 不可执行,plan 阶段 MUST 在细化时改写为可执行(仍标注来源)。"

- [ ] **Step 3: 在 Task Structure 模板插入 Level/Level 理由/关联验收项 三字段**

定位 Task Structure 的代码块(约 82 行起),在 `### Task N: [Component Name]` 后、`**Files:**` 前插入三行。修改后:

```markdown
### Task N: [Component Name]

**Level:** L1 | L2 | L3                    ← MUST
**Level 理由:** [为什么定这个级别]          ← MUST
**关联验收项:** [AC-1, AC-3]               ← MUST (L1 可空)

**Files:**
- Create: `exact/path/to/file.py`
...
```

- [ ] **Step 4: 在 Task Structure 后插入"L1-L3 判定标准"表**

定位 Task Structure 段末尾(在 "## No Placeholders" 段之前),插入新段:

```markdown
## L1-L3 判定标准

每个 task 的 Level 由本表判定。Level MUST 在 writing-plans 阶段打出,并写明理由。

| Level | 触发条件 | 任务级验收方式 |
|---|---|---|
| **L1** | 单文件 / <50 行改动 / 无业务逻辑变化(纯配置、字段增删、UI 微调、文案) | 仅人工 review,不跑验收 |
| **L2** | 单模块改动 / 有业务逻辑但单层 / 标准 TDD 即可覆盖 | TDD red-green |
| **L3** | 跨模块或跨层 / 涉及业务流程变化 / 需要端到端验证 | TDD + 任务级验收项(对应关联的 AC) |

**L3 的额外要求:**
- `关联验收项` 不能为空
- 关联的 AC MUST 在 plan 的最终验收清单中存在
- 任务步骤里 MUST 含"运行任务级验收"的 step(对照 AC 逐条验证)

**L2/L3 的 TDD 说明:** 若 task 改的是 markdown 内容(塑造 agent 行为的 skill)、配置文件、文档等非可执行代码,不能用传统 red-green。改用"结构 grep 验证 + 手工通读"作为任务级 TDD 等价物。
```

- [ ] **Step 5: 改造 Execution Handoff 段为三选一**

定位 Execution Handoff 段(约 156-174 行),整个段替换为:

```markdown
## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Three execution options:**

**1. LTDD(推荐)** - 双层验收循环:任务级 L1/L2/L3 + 计划级最终验收;失败自动重启子 agent 改代码、重跑验收。适合有明确业务验收点的需求。

**2. Subagent-Driven** - 原生:每个 task fresh subagent + 两阶段 review(spec compliance / code quality)。适合代码质量优先的需求。

**3. Inline Execution** - 原生:批量执行 + checkpoint。适合人在场、需要逐步确认的需求。

**Which approach?"**

**If LTDD chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:ltdd
- 双层验收循环 + 失败重启

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
```

- [ ] **Step 6: 追加 Self-Review 检查项**

定位 Self-Review 段(现有 3 项:spec coverage / placeholder / type consistency),追加:

```markdown
**4. Level 完整性**:每个任务都有 Level 与 Level 理由。
**5. L3 验收绑定**:L3 任务的 `关联验收项` 不为空,且引用的 AC 在最终验收清单中存在。
**6. 最终验收覆盖**:最终验收清单每条 AC 至少被一个 L3 任务关联(否则有 AC 没人负责)。若发现某 AC 没人关联,补任务或调整 Level。
```

- [ ] **Step 7: 任务级验收 — 结构 grep 检查**

Run:
```bash
grep -c "最终验收清单" skills/writing-plans/SKILL.md
grep -cE "Level:.*L1.*L2.*L3|Level 理由|关联验收项" skills/writing-plans/SKILL.md
grep -cE "^\| \*\*L1\*\*|^\| \*\*L2\*\*|^\| \*\*L3\*\*" skills/writing-plans/SKILL.md
grep -c "ltdd" skills/writing-plans/SKILL.md
grep -cE "subagent-driven-development|executing-plans" skills/writing-plans/SKILL.md
```
Expected:
- 最终验收清单 ≥ 2(header 模板 + Self-Review)
- Level 相关三项各 ≥ 1
- L1/L2/L3 表行各 ≥ 1
- ltdd ≥ 3(handoff 三选一里至少 3 处)
- subagent-driven-development 与 executing-plans 各 ≥ 1(原生项保留)

- [ ] **Step 8: 任务级验收 — 手工通读**

打开 `skills/writing-plans/SKILL.md` 通读,确认:
1. Plan Header 模板的"最终验收清单"段位置正确(Global Constraints 之后、`---` 之前)
2. Task Structure 模板里 Level 三字段在 Files 之前
3. L1-L3 判定标准表的"L3 额外要求"与 Task Structure 的 `关联验收项` 字段相互一致
4. Execution Handoff 三选一中,ltdd 项放在第一位(推荐位),原生两项保留
5. Self-Review 新增 #4-#6 与前面 Task Structure/L1-L3 标准相互引用一致

- [ ] **Step 9: (可选) Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat(writing-plans): add 最终验收清单 header + L1-L3 task fields + 三选一 handoff + Self-Review (个人 fork)"
```

(用户偏好不提交 git — 跳过此步)

---

### Task 3: 新建 ltdd skill(双层循环 + 子 agent 协议 + 状态恢复)

**Level:** L3
**Level 理由:** 全新文件,~200-250 行;多个内部章节相互引用;是整个改造最复杂的部分,需要端到端验证。
**关联验收项:** [AC-3, AC-4]

**Files:**
- Create: `skills/ltdd/SKILL.md`
- Test: grep + 手工通读

**Interfaces:**
- Consumes: plan 文档(`docs/superpowers/plans/*.md`,含最终验收清单 + L1-L3 任务)+ spec 文档(`docs/superpowers/specs/*.md`,含三要素)
- Produces: 任务级与计划级验收通过的代码改动 + `.superpowers/sdd/ltdd-state.json` 状态文件 + (失败时)handoff 文档

- [ ] **Step 1: 创建 skills/ltdd/SKILL.md,写入 YAML 头 + 概述**

```markdown
---
name: ltdd
description: "Loop TDD - 双层验收循环执行。任务级 L1/L2/L3 验收 + 计划级最终验收,失败自动重启子 agent 改代码、重跑验收。Use when writing-plans 末尾选 ltdd、或显式要求 loop tdd / ltdd。"
---

# LTDD (Loop Test-Driven Development)

## 概述

LTDD 是 superpowers 工作流的执行阶段 skill,与 `subagent-driven-development`、`executing-plans` 同级、三选一。它适用于"有明确业务验收点的需求":

- **任务级循环**:每个 task 按 Level(L1/L2/L3)做对应验收;失败则启动子 agent 改代码、重跑验收,直到通过
- **计划级循环**:所有 task 完成后,跑最终验收清单;失败则启动子 agent 全面修复、重跑,直到通过

与 `subagent-driven-development` 的区别:后者每 task fresh subagent + 两阶段 review;LTDD 关注的是**验收驱动 + 失败循环**,不强制 fresh subagent(可批量执行 + 按需启动修复子 agent)。

与 `executing-plans` 的区别:后者批量执行 + checkpoint;LTDD 自动跑完 checkpoint(验收),失败自动重启修复。
```

- [ ] **Step 2: 追加"触发与输入"段**

```markdown
## 触发与输入

**触发:**
- writing-plans 末尾 handoff 选 ltdd
- 用户显式说 `ltdd`、`loop tdd`、`循环验收`

**输入:**
- plan 路径(必填):`docs/superpowers/plans/YYYY-MM-DD-*.md`,含最终验收清单 + L1-L3 任务
- spec 路径(必填):`docs/superpowers/specs/YYYY-MM-DD-*.md`,含三要素(供子 agent prompt 参考)

**Announce at start:** "I'm using the ltdd skill to execute this plan with double-layer acceptance loop."
```

- [ ] **Step 3: 追加"主流程"段(任务级循环 + 计划级循环)**

```markdown
## 主流程

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
            result = run_tdd(task)        # 跑 TDD red-green(或结构 grep + 通读,见 L1-L3 标准)
        L3:
            tdd   = run_tdd(task)
            ac    = run_task_acceptance(task, task.关联验收项)
            result = { passed: tdd.passed AND ac.passed, ... }

    # 3. 失败重启循环(无上限)
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
```

- [ ] **Step 4: 追加"子 agent 调度协议"段**

```markdown
## 子 agent 调度协议

每次 `dispatch_subagent` MUST 构造如下 prompt:

```
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

**调度边界硬约束:**
- 子 agent 只能改代码与测试,不能改 spec、最终验收清单、其他任务代码
- 子 agent 不准自报通过;通过由主 session 重跑验收确定
- 每次调度 MUST 显式说明:重启原因、任务范围、期望产物
```

- [ ] **Step 5: 追加"状态记录与中断恢复"段**

```markdown
## 状态记录与中断恢复

每轮循环追加写入 `.superpowers/sdd/ltdd-state.json`(与 commit 207a12b 的 SDD workspace helper 路径一致):

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

**中断恢复:** 用户中断后重新触发 ltdd,ltdd MUST 先读 `ltdd-state.json`,从 `current_task_id` + `current_iteration` 继续,不能从头开始。

**手动重置:** 用户可删除 `ltdd-state.json` 强制从头开始。
```

- [ ] **Step 6: 追加"失败兜底"段**

```markdown
## 失败兜底

- **不设循环上限**(用户决策 7),但 ≥5 次时软提醒(见主流程的 WARN)
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
```

- [ ] **Step 7: 追加"Red Flags"与"Self-Review"段**

```markdown
## Red Flags

| Thought | Reality |
|---|---|
| "L1 也要跑验收" | L1 跳过验收,只人工 review。跑 = 浪费时间。 |
| "L3 只跑 TDD 就行" | L3 = TDD + 任务级验收项。少了任务级验收 = 退化成 L2。 |
| "子 agent 自报通过就算" | 不算。通过由主 session 重跑验收确定。子 agent 自报 = 偷懒。 |
| "子 agent 改下 spec 让验收过" | 绝对禁止。子 agent 只能改代码与测试。spec 是不可变边界。 |
| "循环跑了 10 次了,我自己改下验收项让它过" | 绝对禁止。验收项是 spec 决定的,不可由执行阶段改动。卡住该走 handoff。 |
| "状态文件 ltdd-state.json 没必要" | 必要。中断恢复靠它。不写 = 中断就得从头开始。 |
| "中间用户打断了,我重头跑" | 错。先读 ltdd-state.json,从断点继续。 |

## Self-Review

执行结束前,自检:

1. **所有 task 通过任务级验收**(L1 跳过的除外)
2. **计划级最终验收清单全部通过**
3. **状态文件 ltdd-state.json 已更新为 final 状态**(或显式删除,若用户要求)
4. **每个调度的子 agent 都有报告记录**(history 字段完整)
5. **若写了 handoff 文档,推荐下一步具体可执行**(不能"再试试")
```

- [ ] **Step 8: 任务级验收 — 结构 grep 检查**

Run:
```bash
test -f skills/ltdd/SKILL.md && wc -l skills/ltdd/SKILL.md
grep -c "task-level-loop\|plan-level-loop" skills/ltdd/SKILL.md
grep -cE "dispatch_subagent|修复工程师" skills/ltdd/SKDD.md 2>/dev/null; grep -cE "dispatch_subagent|修复工程师" skills/ltdd/SKILL.md
grep -c "ltdd-state.json" skills/ltdd/SKILL.md
grep -c "handoff" skills/ltdd/SKILL.md
grep -cE "^import |^require\(|^from [a-z]" skills/ltdd/SKILL.md
```
Expected:
- 文件存在,行数 ≥ 200
- task-level-loop + plan-level-loop 各 ≥ 1
- dispatch_subagent / 修复工程师 各 ≥ 1
- ltdd-state.json ≥ 1
- handoff ≥ 1
- 最后一条 = 0(markdown 不该有代码 import — AC-4 零依赖)

- [ ] **Step 9: 任务级验收 — 手工通读**

打开 `skills/ltdd/SKILL.md` 通读,确认:
1. 主流程伪代码里 L1/L2/L3 三分支都正确(L1 跳过、L2 跑 TDD、L3 跑 TDD + 任务级验收)
2. 子 agent 调度协议的"你能改的/你不能改的"清晰
3. 状态记录 JSON 结构与 spec §4.5 一致
4. 失败兜底的 handoff 文档模板完整
5. Red Flags 7 条措辞明确

- [ ] **Step 10: (可选) Commit**

```bash
git add skills/ltdd/SKILL.md
git commit -m "feat(ltdd): new skill - double-layer acceptance loop with subagent restart (个人 fork)"
```

(用户偏好不提交 git — 跳过此步)

---

### Task 4: 跨 skill 契约校验(只校验,不产新代码)

**Level:** L2
**Level 理由:** 单模块(校验)改动,验证前三任务产物对得上;无新业务逻辑。
**关联验收项:** [AC-2, AC-3, AC-5, AC-6]

**Files:**
- 无修改(只校验 Task 1-3 的产物)

- [ ] **Step 1: 校验引用链未断**

Run:
```bash
grep -rlE "brainstorming|writing-plans" skills/ | sort
```
Expected 输出中应包含(且与改造前一致):
- skills/using-superpowers/SKILL.md
- skills/subagent-driven-development/SKILL.md(若原版引用了)
- skills/writing-skills/SKILL.md(若原版引用了)
- 其他原版引用 brainstorming/writing-plans 的 skill

**断链判定:** 若改造前某 skill 引用了 brainstorming/writing-plans、改造后不再引用 = 断链。本任务不修改这些引用,所以应该都还在。

- [ ] **Step 2: 校验 writing-plans 的 handoff 三选一引用的 skill 都存在**

Run:
```bash
grep -oE "superpowers:[a-z-]+" skills/writing-plans/SKILL.md | sort -u
```
Expected 包含:
- superpowers:ltdd(新建,Task 3 已建)
- superpowers:subagent-driven-development(原生保留)
- superpowers:executing-plans(原生保留)

```bash
test -d skills/ltdd && test -d skills/subagent-driven-development && test -d skills/executing-plans && echo "ALL EXIST"
```
Expected: `ALL EXIST`

- [ ] **Step 3: 校验 brainstorming 与 writing-plans 之间的契约**

Run:
```bash
# brainstorming 产出的 design 模板里有"最终验收清单 (Draft)"
grep -c "最终验收清单 (Draft)" skills/brainstorming/SKILL.md

# writing-plans 引用此 Draft
grep -c "引用自 spec" skills/writing-plans/SKILL.md
```
Expected: 两个都 ≥ 1。

- [ ] **Step 4: 校验 writing-plans 与 ltdd 之间的契约**

Run:
```bash
# writing-plans 产出的 plan 模板里有 Level 字段
grep -c "Level:.*L1.*L2.*L3" skills/writing-plans/SKILL.md

# ltdd 读取此 Level
grep -c "task.Level\|L1.*L2.*L3" skills/ltdd/SKILL.md
```
Expected: 两个都 ≥ 1。

- [ ] **Step 5: 跑 tests/ 现有测试(回归)**

Run:
```bash
ls tests/run-*.sh 2>/dev/null
```
若有 run-*.sh,依次跑;若无,跑:
```bash
ls tests/*/run-*.sh 2>/dev/null
```
若都没有,跳过本步(个人 fork 不强求)。

Expected: 改造前的测试都过(本改造只动 markdown,不该破坏测试)。

- [ ] **Step 6: 零依赖最终校验(AC-4)**

Run:
```bash
git status --short
```
Expected: 只显示:
```
M skills/brainstorming/SKILL.md
M skills/writing-plans/SKILL.md
?? skills/ltdd/SKILL.md
```
(若有 docs/superpowers/specs/ 与 docs/superpowers/plans/ 的新文件,也 OK — 那是本流程产物)

不应有 package.json、requirements.txt、go.mod 等依赖文件的修改。

- [ ] **Step 7: 任务级验收 — 生成校验报告**

把 step 1-6 的输出汇总成一段简短文字(贴回主 session),格式:
```
跨 skill 契约校验报告:
- 引用链: [完整 / 断链列表]
- handoff 三选一目标: [ltdd / subagent-driven-development / executing-plans 都存在]
- brainstorming → writing-plans 契约(最终验收清单 Draft): [对得上 / 对不上]
- writing-plans → ltdd 契约(Level): [对得上 / 对不上]
- tests/ 回归: [全过 / 失败列表 / 跳过(无测试)]
- 零依赖: [是 / 否]
```

- [ ] **Step 8: (可选) Commit**

本任务无代码改动,无需 commit。若 spec/plan 文档要一起进 git,可:
```bash
git add docs/superpowers/specs/2026-06-25-brainstorm-writing-plan-ltdd-integration-design.md docs/superpowers/plans/2026-06-25-brainstorm-writing-plan-ltdd-integration.md
git commit -m "docs: spec + plan for 三要素 + LTDD 改造 (个人 fork)"
```

(用户偏好不提交 git — 跳过此步)

---

## 最终验收清单(自检)

执行完所有 task 后,主 session 对照本 plan 头部的"最终验收清单"逐条跑:

- [AC-1] brainstorming 改造完整 — Task 1 step 8 已验
- [AC-2] writing-plans 改造完整 — Task 2 step 7 已验
- [AC-3] ltdd 新建完整 — Task 3 step 8 已验
- [AC-4] 零依赖 — Task 3 step 8 + Task 4 step 6 已验
- [AC-5] 引用链未断 — Task 4 step 1-4 已验
- [AC-6] tests/ 回归 — Task 4 step 5 已验

**最终验收由人确认**(用户审阅三个 SKILL.md 的实际内容)。
