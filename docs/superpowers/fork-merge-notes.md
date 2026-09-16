# Fork Merge Notes

> 本文档记录本 fork 相对 `obra/superpowers` 上游的所有改动点。每次上游 sync 前,先对照本文档检查冲突预案。
>
> 注意:本仓库只配置了 `origin`(sunsky74/superpowers),**没有 `upstream` remote**。上游已抓取为本地 ref `obra-upstream/main`(= v6.3.0 `b36e082`)。同步命令见「上游 sync 操作步骤」。

**Fork 基线:** upstream v6.1.1(`d884ae0`,2026-07-02)+ 4 个 fork commit
**Fork 当前 HEAD:** `main` @ `0b7c31c`(与 `origin/main` 一致,工作区干净)
**同步目标:** upstream v6.3.0(`b36e082`,2026-08-12;ref `obra-upstream/main`;截至 2026-09-16 无更新)
**最后更新:** 2026-09-16

---

## 一、fork 改动总览

### 1.1 提交清单(4 个 commit,全部在 `d884ae0` 之上)

| 提交 | 日期 | 说明 | 变更规模 |
|---|---|---|---|
| `b36e4ca` | 2026-07-16 | feat: add experimental Quality-LTDD fork workflow | 17 文件,+2903/−67 |
| `cd9716a` | 2026-07-28 | docs: design unified user input gates | 1 文件,+327 |
| `e7642e8` | 2026-07-28 | docs: plan unified user input gates | 1 文件,+868 |
| `0b7c31c` | 2026-07-28 | fix: gate brainstorming on explicit user input | 9 文件,+604/−43 |

合计:**24 个文件,+4683/−91**(`git diff --stat d884ae0..main`)。其中 4 个文件被两个 fork commit 先后修改(brainstorming、three-pillars、acceptance-driven-plan、writing-plans);using-superpowers 与 codex-tools 仅由 `0b7c31c` 引入。

### 1.2 文件清单(24 个)

| # | 文件 | 引入提交 | 类型 | 改动性质 |
|---|---|---|---|---|
| 1 | `skills/three-pillars/SKILL.md` | b36e4ca,0b7c31c | 新建 skill | 三要素适用范围判定 + 项目类型分支 + A→B→C1→C2 提问框架 + design 输出模板 + Red Flags + Self-Review;0b7c31c 加入输入的 `pending / answered / explicitly-skipped` 状态机 |
| 2 | `skills/acceptance-driven-plan/SKILL.md` | b36e4ca,0b7c31c | 新建 skill | 最终验收清单 header + Level 字段 + L1-L3 判定 + 三选一 handoff + `plan-decomposition` / `execution-choice` 门禁 |
| 3 | `skills/ltdd/SKILL.md` | b36e4ca | 新建 skill | Quality-LTDD 执行协议(Subagent-Driven + Acceptance Gates + Final Intent Guard) |
| 4 | `skills/brainstorming/SKILL.md` | b36e4ca,0b7c31c | 修改 skill | 5 处 FORK TRIGGER 调用 three-pillars;0b7c31c 改造成 9 步门禁状态机(共 110 行增减) |
| 5 | `skills/writing-plans/SKILL.md` | b36e4ca,0b7c31c | 修改 skill | FORK TRIGGER + `[//]: # (FORK` 占位注释 + 三选一 Execution Handoff;0b7c31c 加入 Entry gate 与 `plan-decomposition` 门禁(共 42 行增减) |
| 6 | `skills/using-superpowers/SKILL.md` | 0b7c31c | 修改 skill | 新增 `## User Input Gate` 小节(`USER-INPUT-GATE` 的唯一规范定义) |
| 7 | `skills/using-superpowers/references/codex-tools.md` | 0b7c31c | 修改 | 新增 `## User Input Gates` 小节(final response / commentary 规则) |
| 8 | `README.md` | b36e4ca | 修改 | fork 头部 + Fork Status + Quality-LTDD workflow 段落 |
| 9 | `.claude-plugin/marketplace.json` | b36e4ca | 修改 | 品牌化(Sunsky)+ 版本 |
| 10 | `.claude-plugin/plugin.json` | b36e4ca | 修改 | 品牌化 + 版本 |
| 11 | `.codex-plugin/plugin.json` | b36e4ca | 修改 | 品牌化 + 版本 |
| 12 | `.cursor-plugin/plugin.json` | b36e4ca | 修改 | 品牌化 + 版本 |
| 13 | `.kimi-plugin/plugin.json` | b36e4ca | 修改 | 品牌化 + 版本 |
| 14 | `gemini-extension.json` | b36e4ca | 修改 | 描述 + 版本 |
| 15 | `package.json` | b36e4ca | 修改 | 描述 + keywords + 版本 |
| 16 | `.gitignore` | b36e4ca | 修改 | 新增 `.omo/` |
| 17 | `docs/superpowers/specs/2026-06-25-brainstorm-writing-plan-ltdd-integration-design.md` | b36e4ca | 新建文档 | fork 设计 spec |
| 18 | `docs/superpowers/plans/2026-06-25-brainstorm-writing-plan-ltdd-integration.md` | b36e4ca | 新建文档 | fork 实施 plan |
| 19 | `docs/superpowers/specs/2026-07-28-user-input-gates-design.md` | cd9716a | 新建文档 | 用户输入门禁设计 |
| 20 | `docs/superpowers/plans/2026-07-28-user-input-gates.md` | e7642e8 | 新建文档 | 用户输入门禁实施 plan |
| 21 | `docs/superpowers/fork-merge-notes.md` | b36e4ca | 新建文档 | 本文档 |
| 22 | `tests/user-input-gates/run-tests.sh` | 0b7c31c | 新建测试 | 门禁回归套件(static / codex-live / claude-live 三种模式,403 行) |
| 23 | `tests/user-input-gates/fixtures/full-flow-turns.txt` | 0b7c31c | 新建测试 | live 模式全流程夹具(11 个状态) |
| 24 | `tests/user-input-gates/fixtures/technical-request.md` | 0b7c31c | 新建测试 | live 模式启动 prompt |

> 第 9–15 行的 7 个 manifest 均只是一行到几行的品牌/版本改动;两轮 fork 工作都以外加段落/新文件为主,尽量不改上游原有正文。

### 1.3 门禁状态机(0b7c31c 引入,合并时必须保留)

`skills/brainstorming/SKILL.md` 声明的工作流状态名(10 个,合并后必须逐字保留):

`clarification-a`、`clarification-b`、`clarification-c1`、`clarification-c2`、`approach-choice`、`design-section`、`complete-design`、`spec-write`、`written-spec`、`planning`

另外两个门禁名声明在 `skills/acceptance-driven-plan/SKILL.md`:`plan-decomposition`、`execution-choice`。

---

## 二、上游 v6.2.0 → v6.3.0 变更概览

`git log --oneline main..obra-upstream/main` = **53 个 commit**;`git diff --stat d884ae0..obra-upstream/main` = **76 个文件,+7772/−1021**。

| 版本 | 提交 | 日期 | 主要内容 |
|---|---|---|---|
| v6.2.0 | `3dcbd5c` | 2026-07-23 | SDD plan-scoped workspace + resume 式修复循环 + five-round breaker + rationalization 表;大范围 skill 压缩改写;`writing-good-tests` 取代被删除的 `testing-anti-patterns.md`;Windows SessionStart hook 修复(Git Bash dispatch);`find-polluter.sh` 修复 |
| (单独文档提交) | `44c9b2d` | 2026-07-28 | README 删除 "We're Hiring" 小节(不属于任何一个 release commit) |
| v6.3.0 | `b36e082` | 2026-08-12 | Devin CLI 支持(`.devin-plugin`)+ Hermes Agent 支持(`.hermes-plugin`、`hermes-tools.md`);brainstorming 三路径路由重写(Spike/Bounded/Architectural);SDD/Codex 效率修复(codex-tools.md 重写);Gemini CLI 支持恢复(`gemini-tools.md` 重新加回,`1d4c8d2` Revert "Remove Gemini CLI support");版本管理自动化(`.version-bump.json` + `scripts/bump-version.sh` 重写) |

- 截至 2026-09-16,`obra-upstream/main` 在 2026-08-12 之后没有任何新 commit(`git log --since=2026-08-13 --oneline obra-upstream/main | wc -l` = 0)。
- 上游 README 还顺带新增了 Grok Build CLI / Gemini CLI / Devin CLI / Hermes Agent 章节并加入 Table of Contents。

---

## 三、冲突预案(13 个双方同改文件)

双方改动文件集合的交集(13 个):

```bash
comm -12 <(GIT_MASTER=1 git diff --name-only d884ae0..main | sort) \
         <(GIT_MASTER=1 git diff --name-only d884ae0..obra-upstream/main | sort)
```

### 3.1 实测预测(2026-09-16,只读 `git merge-tree` dry-run,未执行任何实际 merge)

```bash
git merge-tree --write-tree --name-only main obra-upstream/main
```

输出读法:第 1 行是合并结果的 tree oid,紧接着的 9 行是冲突文件名(与下表一致);其后每个文件的 `Auto-merging` / `CONFLICT` 行是逐文件明细,末尾的 `Auto-merging` 行(无 CONFLICT)对应自动合并的 4 个文件。

实测结果:**9 个文件真冲突**,**4 个自动合并**:

| 文件 | 上游改动 | fork 改动 | 预测 | 风险 |
|---|---|---|---|---|
| `skills/brainstorming/SKILL.md` | 三路径路由重写(127 行增减) | 门禁状态机 + 5 处 FORK TRIGGER(110 行增减) | **冲突** | **高** |
| `README.md` | 删 "We're Hiring"、ToC、新 harness 章节、Community 移动(109 行增减) | fork 头部 + Fork Status + Quality-LTDD 文案(28 行增减) | **冲突** | 中 |
| `.claude-plugin/marketplace.json` | 仅版本号 6.1.1→6.3.0 | 品牌化 + 版本号 | **冲突**(机械) | 低 |
| `.claude-plugin/plugin.json` | 仅版本号 | 品牌化 + 版本号 | **冲突**(机械) | 低 |
| `.codex-plugin/plugin.json` | 仅版本号 | 品牌化 + 版本号 | **冲突**(机械) | 低 |
| `.cursor-plugin/plugin.json` | 仅版本号 | 品牌化 + 版本号 | **冲突**(机械) | 低 |
| `.kimi-plugin/plugin.json` | 仅版本号 | 品牌化 + 版本号 | **冲突**(机械) | 低 |
| `gemini-extension.json` | 仅版本号 | 描述 + 版本号 | **冲突**(机械) | 低 |
| `package.json` | 仅版本号 | 描述 + keywords + 版本号 | **冲突**(机械) | 低 |
| `skills/using-superpowers/SKILL.md` | +1 行(`Hermes Agent: references/hermes-tools.md`) | +17 行 `## User Input Gate` | 自动合并 | 低(仍需复核) |
| `skills/using-superpowers/references/codex-tools.md` | 整篇重写(71 行增减) | +8 行 `## User Input Gates` | 自动合并 | 中(必须复核) |
| `skills/writing-plans/SKILL.md` | +`**Spec:**` 字段、删 `## Remember`(9 行增减) | Entry gate + FORK TRIGGER + 三选一 handoff(42 行增减) | 自动合并 | 低-中(必须复核) |
| `.gitignore` | +Python 段(6 行) | +`.omo/`(1 行) | 自动合并 | 低 |

> **要点:自动合并 ≠ 语义正确。** `merge-tree` 只说明 git 无文本冲突;上表中 4 个自动合并文件在合并后仍要逐个人工检查「双方内容都在、且互相不矛盾」(尤其 codex-tools.md 与 writing-plans/SKILL.md)。
>
> 预测基于 2026-09-16 的 `main`@`0b7c31c` 与 `obra-upstream/main`@`b36e082`;实际 merge 时若上游有更新,以实际 `git status` 为准。

### 3.2 极低冲突风险(fork 独有,fork-only 11 文件)

上游不存在这些文件,永远不会与上游冲突(但合并后可能因上游 skill 改名/搬家需要自检):

| 文件 | 原因 |
|---|---|
| `skills/three-pillars/SKILL.md` | 全新 skill |
| `skills/acceptance-driven-plan/SKILL.md` | 全新 skill |
| `skills/ltdd/SKILL.md` | 全新 skill |
| `docs/superpowers/specs/2026-06-25-*.md`、`2026-07-28-*.md` | fork 设计文档(上游同步新增了各自命名的 spec,路径不重叠) |
| `docs/superpowers/plans/2026-06-25-*.md`、`2026-07-28-*.md` | fork 实施 plan |
| `docs/superpowers/fork-merge-notes.md` | 本文档 |
| `tests/user-input-gates/**` | fork 测试套件 |

---

## 四、逐文件合并策略

### 4.1 `skills/brainstorming/SKILL.md`(高风险 — 双方各自重写)

**上游侧改动(vs d884ae0):** 三路径路由重写 —— 新增 `## Three Paths`(Spike / Bounded / Architectural,先分类并出声宣布)、重写 `<HARD-GATE>`(改成 "先告诉 human partner 意图并取得批准",明确 ceremony 随任务缩放、批准门禁不缩放)、重写 Anti-Pattern、新增 7 行 Red Flags 表、按路径拆分的 Checklist、新 Process Flow 图(带分类菱形)、path-bound 终态(architectural→writing-plans;bounded→直接进入实现;spike→报告建议)。

**fork 侧改动(vs d884ae0):** Checklist 前言 + 第 3–9 项改成 `USER-INPUT-GATE` 门禁序列;声明 10 个状态名;Process Flow 图改成逐门禁状态;Process 各段插入门禁规则(推荐不等于选择、段落批准只对当前段、complete-design 单独批准、written-spec 单独批准);Spec Self-Review 第 4 项改为「歧义会改变行为时回到 Clarification 并过门禁」;User Review Gate 文案改写;Red Flags 段改为指向 three-pillars 的 FORK TRIGGER + 一句说明;5 处 FORK TRIGGER。

**合并策略:以上游三路径骨架为结构基底,fork 的门禁层按路径重挂:**

1. **保留上游骨架(不要退回旧版):** `## Three Paths` 三路径分类与「先宣布分类」、新 HARD-GATE 措辞、path-bound Checklist、上游 Red Flags 表、path-bound 终态段、新 Process Flow 图的分类菱形与路径分支。
2. **逐路径重挂 fork 门禁:**
   - **Spike 路径:** fork 门禁 = "nod gate" —— 把「问题 + 探针计划(2–3 句)」作为**最终回复**呈现,只问一个决策问题,结束当前回合;沉默/模糊回复不算批准(替代上游的 "get a nod" 表述,语义按 `USER-INPUT-GATE`)。
   - **Bounded 路径:** fork 门禁 = design-approval gate —— 「短设计(approach / 涉及文件 / 测试方式)」作为最终回复呈现,`USER-INPUT-GATE` 停住,**批准前不得在同一回合开始实现**(上游第 4 步 "STOP and wait for an explicit yes" 保留)。
   - **Architectural 路径:** 恢复 fork 完整门禁状态机。把上游 architectural checklist 的第 3–9 步与 fork 的 9 步逐一对应重写:
     Clarification(门禁,含 `clarification-a/b/c1/c2`)→ Approach Choice(门禁,`recommendation does not select`)→ Design Sections(逐段门禁,`design-section`)→ Complete Design(独立门禁,`last section does not approve the complete design`)→ Spec Write(仅 complete-design 批准后) → Written Spec Review(门禁,`written-spec`;`Only explicit approval of the written spec authorizes` 进入 writing-plans)→ Planning。保留 10 个状态名清单与「不得越过转换条件」一句。
3. **必须逐字保留的字符串**(`tests/user-input-gates/run-tests.sh` 静态断言,brainstorming 文件内):
   `USER-INPUT-GATE`、`final response`、`clarification-a`、`clarification-b`、`approach-choice`、`design-section`、`complete-design`、`recommendation does not select`、`last section does not approve the complete design`、`Only explicit approval of the written spec authorizes`。
   (另:live 测试会以夹具驱动 `clarification-c1`、`clarification-c2` 回合;`spec-write`、`planning` 是状态机内部状态,同样要留在状态名清单里。`clarification-b-pending` 夹具验证「模糊回复不得推进状态」。)
4. **5 处 FORK TRIGGER 重挂位置**(上游重写后行号会变,以锚点为准):
   1. Architectural checklist 的 Clarification 一步(适用性 + 项目类型判定 + §4 提问框架 + §5 输出模板);
   2. Process → Understanding the idea 末尾(§4 A→B→C1→C2 + §5);
   3. Process → Presenting the design 段内(§5 设计文档结构模板);
   4. Spec Self-Review(#5–#11 检查项);
   5. 上游新 Red Flags 表之后(§7 Red Flags;fork 旧文案 "This skill's own Red Flags remain the upstream ones" 应改写,因为上游现在自带了 Red Flags 表)。
5. **待决问题(OPEN DECISION):三要素在 spike / bounded 路径上如何适用。**
   建议(待 dogfood 验证):
   - Spike:three-pillars **不适用**(产物是结论,无 design/spec/AC),trigger 文案应写明 spike 跳过;
   - Bounded:只保留轻量适用性判定 —— 用 §4 的 A→C1/C2 角度帮助选择「值得问的澄清问题」,短设计里可带一段草稿验收清单;不加载 §5 模板、§6 Self-Review、§7 Red Flags(这些随 architectural 的 spec/plan 流程走);
   - 同时修改 FORK TRIGGER 1 的措辞("bounded and architectural paths")并在合并后跑一次 live 测试确认夹具仍按 architectural 路径走。
6. **合并后必须跑:** `bash tests/user-input-gates/run-tests.sh static`(24 条断言),并建议跑 `codex-live` / `claude-live` 各一次(需要 codex / claude CLI 凭证)。

### 4.2 `skills/using-superpowers/SKILL.md`(低 — 预测自动合并)

- fork 新增 `## User Input Gate` 小节(The Rule 与 Skill Priority 之间);
- 上游只加一行:`- Hermes Agent: references/hermes-tools.md`(Platform Adaptation 列表)。
- **策略:两边全要。** 合并后确认:① `USER-INPUT-GATE` 小节完整;② Hermes 一行在;③ 「`Perform no tools, writes, commits, skill transitions`」在 `skills/` 下仍然只有这一个文件包含(静态测试断言必须恰好 1 处,防止合并时复制出第二份定义)。

### 4.3 `skills/using-superpowers/references/codex-tools.md`(中 — 预测自动合并,必须复核)

- 上游把正文整体重写:`multi_agent` 段(V1/V2 工具差异、`spawn_agent {fork_turns: "none"}`、`agent_type`、`followup_task` 修复轮、V2 无 `close_agent`、模型名检查)、新增 `## Waiting on children`(wait_agent 是事件订阅不是轮询;有本地工作就不要 wait)、新增 `## Model routing on spawns`(`model` + `reasoning_effort` 显式设置,`[agents]` 兜底配置)、保留 `## Environment Detection` 与 `## Codex App Finishing`。
- fork 只在上半部插入了 `## User Input Gates` 小节("blocking user question 必须作为当前回合的 final response;commentary questions 非阻塞,不满足 `USER-INPUT-GATE`")。
- **策略:取上游重写后的正文,把 fork 的 `## User Input Gates` 小节原样保留。** 位置建议:放在上游 `## Model routing on spawns` 之后、`## Environment Detection` 之前,保持上游子代理章节连续。
- **矛盾排查(已做):** 上游 "Waiting on children" 讲的是子代理等待纪律,fork 门禁讲的是用户答复;当 `USER-INPUT-GATE` 触发时回合已经结束,两者不矛盾。上游新文本不再有旧版 "always close implementer and reviewer subagents" 那句,不要从旧版找回。
- **静态断言要求的字符串(必须保留):** `final response`、`Commentary questions are non-blocking`。

### 4.4 `skills/writing-plans/SKILL.md`(低-中 — 预测自动合并,必须复核)

- fork 侧(现有文件):第 16–19 行 Entry gate(必须 `written-spec` 门禁被明确批准才能启动);第 30 行 Scope Check 的 Master/Phase 分解 FORK TRIGGER + `plan-decomposition` 门禁(第 32–36 行);第 71/98/149/177/183 行共 5 处其余 FORK TRIGGER;第 91/103 行两处 `[//]: # (FORK` 占位注释;三选一 Execution Handoff + `USER-INPUT-GATE`(第 183–200 行)。
- 上游侧:Plan Document Header 模板新增 `**Spec:**` 字段(Tech Stack 之后);删除旧的 `## Remember` 小节。
- **策略:**
  1. 保留 fork 全部内容:Entry gate、`written-spec` 字符串、6 处 FORK TRIGGER(见 §8)、2 处 `[//]: # (FORK` 注释、三选一 handoff 与 `execution-choice` 门禁;
  2. 取上游 `**Spec:**` 字段(插入 header 模板);
  3. **确认 `## Remember` 已消失**(当前 fork 文件第 161–165 行还有它,是继承的旧上游内容;上游已删,合并后不得复活);
  4. 复核第 30 行 trigger 与「If decomposition is required...」段衔接正常。

### 4.5 品牌化 manifest × 7(`.claude-plugin/marketplace.json`、`.claude-plugin/plugin.json`、`.codex-plugin/plugin.json`、`.cursor-plugin/plugin.json`、`.kimi-plugin/plugin.json`、`gemini-extension.json`、`package.json`)(低 — 机械冲突)

- 上游对 7 个文件的改动全部只是版本号 `6.1.1` → `6.3.0`(各 1 行);fork 改的是标题/描述/作者(Sunsky)、`sunsky74/superpowers` URL、keywords(quality-ltdd / acceptance-driven / three-pillars / ltdd)、版本 `6.1.1-quality-ltdd.0`。
- **策略:全部取 fork(ours)侧,然后把版本统一改为 `6.3.0-quality-ltdd.0`。**
- 合并后目标状态(共 8 处版本声明应为 `6.3.0-quality-ltdd.0`):7 个 manifest + `README.md` Fork Status;`.claude-plugin/marketplace.json` 的版本在 `plugins[0].version` 字段。
- `.devin-plugin/plugin.json` 与 `.hermes-plugin/plugin.yaml` 是上游**新增**文件,与 fork 无冲突;初始可保留上游品牌与 `6.3.0` 版本(可选后续再品牌化,记为后续工作,不阻塞合并)。

### 4.6 `README.md`(中 — 冲突)

- 上游:删 "We're Hiring"(`44c9b2d`)、新增 Table of Contents、新增 Devin/Gemini/Grok/Hermes 章节、Community 章节上移;README 中 "How it works" 等正文段落保持上游语气(fork 不采用)。
- fork:改标题为 "Superpowers Quality-LTDD Fork"、替换导语、加 Fork Status 表、改 "How it works" 与 Basic Workflow 为 Three Pillars / Level / Task Gate / ltdd 表述、Skills Library 增 3 个 fork skill。
- **策略:fork 头部 + 上游内容更新:**
  1. 保留 fork 标题/导语/Fork Status(更新为 Version `6.3.0-quality-ltdd.0`、Upstream base v6.3.0);
  2. **删除 "We're Hiring!"**(上游已删;合并后不要复活);
  3. 采纳上游 ToC 与 Devin CLI / Gemini CLI / Grok Build CLI / Hermes Agent 安装章节及 Community 位置;
  4. 保留 fork 版 "How it works" / Basic Workflow / Skills Library 的 fork 增补;
  5. **修正 Testing bullet:** 现在是 `test-driven-development - ... (includes testing anti-patterns reference)`,但 `testing-anti-patterns.md` 已被上游删除,应改成 `includes writing-good-tests reference`。注意:**上游 v6.3.0 自己的 README 仍写着 testing anti-patterns(上游遗留文案,已确认第 292 行),不要照抄。**

### 4.7 `.gitignore`(低 — 预测自动合并)

- 取并集:fork 的 `.omo/` + 上游的 Python 段(`__pycache__/`、`*.pyc`、`*.pyo`、`.pytest_cache/`)。

---

## 五、可干净合并的上游改动(63 个文件,无双方冲突)

`comm -13 <(git diff --name-only d884ae0..main | sort) <(git diff --name-only d884ae0..obra-upstream/main | sort) | wc -l` = **63**。这些文件 fork 都没碰过,合并按上游版本直接落地(注意一个删除文件):

| 分组 | 数量 | 文件 / 说明 |
|---|---|---|
| SDD 重构 | 7 | `skills/subagent-driven-development/`:SKILL.md(plan-scoped workspace、resume 修复循环、five-round breaker、rationalization 表)、`implementer-prompt.md`、`task-reviewer-prompt.md`、新增 `re-review-prompt.md`、`scripts/sdd-workspace`、`scripts/task-brief`、`scripts/review-package` |
| skill 压缩清扫 | 13 | `dispatching-parallel-agents`、`executing-plans`、`finishing-a-development-branch`(+212)、`receiving-code-review`、`requesting-code-review`(SKILL.md + `code-reviewer.md`)、`systematic-debugging`(SKILL.md + `find-polluter.sh`)、`using-git-worktrees`、`verification-before-completion`、`writing-skills`(SKILL.md + `render-graphs.js`)、`brainstorming/visual-companion.md` |
| TDD 测试指南换代 | 3 | `skills/test-driven-development/SKILL.md`(链接指向新文件)、**删除** `testing-anti-patterns.md`(−299)、**新增** `writing-good-tests.md`(+198) |
| 新/恢复 harness 支持 | 6 | `.devin-plugin/plugin.json`(新)、`.hermes-plugin/__init__.py`(新)、`.hermes-plugin/plugin.yaml`(新)、`references/antigravity-tools.md`、`references/gemini-tools.md`(恢复)、`references/hermes-tools.md`(新) |
| hooks / Windows | 2 | `hooks/hooks.json`(SessionStart 命令加 `"shell": "bash"`)、`docs/windows/polyglot-hooks.md` |
| 版本管理自动化 | 2 | `.version-bump.json`(新)、`scripts/bump-version.sh`(重写) |
| 打包脚本 | 2 | `scripts/package-codex-plugin.sh`、`scripts/sync-to-codex-plugin.sh` |
| 测试 | 16 | `tests/claude-code/`(run-skill-tests、test-helpers、test-sdd-workspace、test-subagent-driven-development)、`tests/antigravity/`、`tests/codex/`、`tests/devin/`(新)、`tests/hermes/`(新,4 个文件)、`tests/hooks/test-session-start.sh`、`tests/pi/`、`tests/systematic-debugging/`、`tests/version-bump/`(新)、`tests/writing-skills/`(新) |
| 文档 | 12 | `CLAUDE.md`(1 行)、`docs/porting-to-a-new-harness.md`、`RELEASE-NOTES.md`、`docs/superpowers/plans/` 新增 4 篇(2026-07-06 / 07-15 / 07-30 / 08-06)、`docs/superpowers/specs/` 新增 5 篇(2026-07-06×2 / 07-15 / 07-30 / 08-05) |

---

## 六、语义风险 / 注意点

1. **fork 测试断言 brainstorming 等文件的字符串。** 合并后第一件事:`bash tests/user-input-gates/run-tests.sh static`(24 条断言,需要 `rg`)。断言覆盖:brainstorming 的 10 个字符串(§4.1)、using-superpowers 的 `## User Input Gate` 三条、codex-tools 的两条、three-pillars 的 `pending | answered | explicitly-skipped` / `` Any `pending` angle `` / `Absence of an answer never changes`(且**不得**出现 `mark that angle \`Unclarified\` and continue`)、writing-plans 的 `written-spec`、acceptance-driven-plan 的 `plan-decomposition` / `execution-choice`。
2. **三路径 vs 验收驱动的哲学调和是待决问题(OPEN DECISION)。** 上游把流程按任务规模分档(Spike/Bounded 不写 spec/plan),fork 的 Quality-LTDD 假设「spec → plan → Level/AC → ltdd」全流程。需要决定:spike/bounded 路径上 three-pillars、验收清单、writing-plans Entry gate 如何缩放(§4.1 给出建议,合并后需 dogfood 确认)。
3. **`ltdd` 是自包含的:** 已实测 `grep -nE "sdd-workspace|task-brief|review-package" skills/ltdd/SKILL.md` 无匹配 —— ltdd 自己描述 subagent 协议,不调用上游 SDD 的脚本,因此上游 SDD 大改**不会**破坏 ltdd。后续可选增强:吸收上游的 resume 式修复循环 / five-round breaker(当前 ltdd 有自己的停机点,不强制)。
4. **`scripts/bump-version.sh` + `.version-bump.json` 与 fork 版本方案兼容性:** 脚本第 230 行的格式校验是 ``^[0-9]+\.[0-9]+\.[0-9]+``,`6.3.0-quality-ltdd.0` 可匹配(预发布后缀不参与校验);脚本依赖 `jq`(JSON)与 `yq`(YAML,`.hermes-plugin/plugin.yaml`)。`.version-bump.json` 登记了 9 个文件(package.json、.hermes-plugin/plugin.yaml、5 个 plugin.json(claude/cursor/codex/devin/kimi)、marketplace.json 的 `plugins.0.version`、gemini-extension.json)。**结论:可用**,但建议合并后先跑 `bash scripts/bump-version.sh --check` 再实际 bump;jq 重写 JSON 可能带来全文件格式化 diff,提交前肉眼过一遍。上游自带测试:`bash tests/version-bump/test-bump-version.sh`(需要 jq + yq)。
5. **`testing-anti-patterns` 引用清理。** 合并后:fork README 的 Testing bullet 与 TDD SKILL.md 的链接都应指向 `writing-good-tests.md`(TDD SKILL.md 走上游版本自动完成)。**注意上游自己的 README(v6.3.0 第 292 行)仍写 "includes testing anti-patterns reference" —— 属上游 stale 文案,不要照抄进 fork。** 写法注意:连字符 `testing-anti-patterns` 只出现在 TDD SKILL.md 的链接里;README 用的是空格写法 `testing anti-patterns reference`,两条 grep 都要清。合并后自检:`grep -rn "testing-anti-patterns" skills/ README.md` 与 `grep -rn "testing anti-patterns" README.md` 均应为 0 命中(历史文档 `RELEASE-NOTES.md`、`docs/plans/2025-11-28-*` 中的命中是历史记录,允许保留)。
6. **没有 upstream remote。** 同步时二选一(见 §7 步骤 1):临时 `git remote add upstream` + fetch,或直接 `git fetch <url> +main:obra-upstream/main`(本仓库已用后者抓取到 `obra-upstream/main`;后续 sync 建议保留 `+` 前缀以允许非快进更新)。
7. **merge-tree 预测:9 冲突 + 4 自动合并。** 自动合并的 4 个文件(using-superpowers、codex-tools、writing-plans、.gitignore)不能只看"无冲突"就算过 —— 必须人工确认双方内容都在、且无互相抵消(§4.2–4.4、4.7)。
8. **版本/品牌一致性:** 合并后 7 个 manifest + README Fork Status 统一为 `6.3.0-quality-ltdd.0`;`.devin-plugin` / `.hermes-plugin` 暂为上游 `6.3.0` 品牌(可选后续处理,不阻塞)。
9. **live 测试的路径分类风险:** live 夹具(`technical-request.md`)描述的是「给一个已存在的 CLI 插件加 `superpowers doctor` 命令、四个独立 flow、架构与验收标准未定」。按上游 bounded 的定义(「要改的 flow 必须已经存在可读」,而测试项目是空目录),它应在 architectural 路径落地;合并后跑 live 测试时若分类器把它判成 bounded/spike,live 套件会在 `clarification-a` 阶段就失败 —— 这是验证三路径与门禁机器整合是否正确的关键信号。

### 待确认(合并时验证,勿凭猜)

- [ ] `codex-live` / `claude-live` 全套通过(需 codex / claude CLI 凭证;static 模式已于 2026-09-16 全绿)
- [ ] 上游三路径分类器对 `technical-request.md` 夹具的实际判定(应为 architectural)
- [ ] `bump-version.sh` 对 7 个 fork manifest 的格式化影响(jq 重写后 diff 噪音是否可接受)
- [ ] `.devin-plugin` / `.hermes-plugin` 是否在本轮品牌化(当前计划:不动)

---

## 七、上游 sync 操作步骤(v6.3.0)

```bash
# 0) 前置检查(只读)
git status                                    # 应干净
git log --oneline -5                          # main @ 0b7c31c + 4 个 fork commit
git remote -v                                 # 只有 origin(sunsky74/superpowers),没有 upstream

# 1) 获取上游(二选一;不要动 origin)
#    a. 直接抓取到本地 ref(本仓库当前用的方式)
git fetch https://github.com/obra/superpowers.git +main:obra-upstream/main
#    b. 或添加 upstream remote
git remote add upstream https://github.com/obra/superpowers.git
git fetch upstream

# 2) 确认目标与基线(预期输出 b36e082 与 d884ae0)
git log -1 --format="%h %s" obra-upstream/main    # b36e082 Release v6.3.0
git merge-base main obra-upstream/main            # d884ae0

# 3) 建同步分支
git checkout -b sync-upstream-v6.3.0

# 4) (可选)只读预测冲突:2026-09-16 实测 9 个冲突文件
git merge-tree --write-tree --name-only main obra-upstream/main

# 5) 合并
git merge obra-upstream/main

# 6) 解冲突:9 个文件按「四、逐文件合并策略」处理
git status --short                            # UU/AA 开头的就是冲突文件
#    skills/brainstorming/SKILL.md 是大头(见 §4.1),6 个 manifest + README + package.json 是机械冲突(见 §4.5/4.6)

# 7) 自动合并的 4 个文件也要「语义复核」(见 §4.2/4.3/4.4/4.7):
#    .gitignore / skills/using-superpowers/SKILL.md / .../references/codex-tools.md / skills/writing-plans/SKILL.md

# 8) 测试(真实入口;旧版文档里的 tests/run-*.sh 不存在)
bash tests/user-input-gates/run-tests.sh static        # 门禁静态断言(24 条),需要 rg —— 必跑
bash tests/user-input-gates/run-tests.sh codex-live    # 可选:需要 codex + jq
bash tests/user-input-gates/run-tests.sh claude-live   # 可选:需要 claude + jq + uuidgen
bash tests/version-bump/test-bump-version.sh           # 版本脚本回归,需要 jq + yq
bash tests/hooks/test-session-start.sh                 # SessionStart hook(上游改了 Windows dispatch)

# 9) 触发链/FORK TRIGGER 自检(见 §9,数字全部对得上再提交)

# 10) 提交
git add -A
git commit -m "merge: upstream v6.3.0 into fork (Quality-LTDD)"
```

---

## 八、FORK TRIGGER 位置表(行号为 2026-09-16 `main`@`0b7c31c` 实测;合并后需重新 grep 定位)

### 8.1 `skills/brainstorming/SKILL.md`(5 处)

| # | 当前行号 | 锚点 | 内容 |
|---|---|---|---|
| 1 | 31 | Checklist 第 3 项(Clarification)内 | three-pillars 适用性/项目类型判定 + §4 提问框架 + §5 模板 |
| 2 | 108 | Process → Understanding the idea 末尾 | §4 A→B→C1→C2 提问 + §5 设计输出 |
| 3 | 132 | Process → Presenting the design 段内 | §5 设计文档结构模板 |
| 4 | 167 | Spec Self-Review 第 4 项之后 | §6 Self-Review #5-#11 |
| 5 | 191 | Red Flags 段内 | §7 Red Flags |

### 8.2 `skills/writing-plans/SKILL.md`(6 处 FORK TRIGGER + 2 处 `[//]: # (FORK` 注释)

| # | 当前行号 | 锚点 | 内容 |
|---|---|---|---|
| 1 | 30 | Scope Check 段内 | §0 Master/Phase 分解判定(超规格需求生成 Master Plan + Phase Plans) |
| 2 | 71 | Plan Document Header 模板前 | §1 最终验收清单 header |
| 3 | 91 | header 模板内 | `[//]: # (FORK` 占位注释(插入最终验收清单段) |
| 4 | 98 | Task Structure 段开头 | §2 Level / Level Rationale / Linked Acceptance Items / Task Gate |
| 5 | 103 | Task Structure 模板内 | `[//]: # (FORK` 占位注释(插入 Level/Gate 字段) |
| 6 | 149 | Task Structure 段末尾 | §3 L1-L3 判定表 |
| 7 | 177 | Self-Review #3 之后 | §5 Self-Review #4-#11 |
| 8 | 183 | Execution Handoff 段开头 | §4 三选一 handoff(Quality-LTDD 推荐) |

> 更正记录:`b36e4ca` 引入时 writing-plans 为 **5 处** FORK TRIGGER;`0b7c31c` 在 Scope Check 新增了 `plan-decomposition` 门禁(第 30 行),现为 **6 处**。旧版本本文档写「5 处」已过时。
>
> 合并后位置会整体位移:brainstorming 将被三路径结构重排(§4.1 重挂 5 处 trigger),writing-plans 的 trigger 数量应保持 6 处 + 2 注释。**以 grep 结果为准,不要相信行号。**

---

## 九、验证命令与期望输出(2026-09-16 实测数字)

每次 merge 后跑一遍;数字对不上说明合并丢了东西。

```bash
# 门禁静态断言(24 条):期望逐条 PASS,最后一行 "PASS static"
bash tests/user-input-gates/run-tests.sh static

# FORK TRIGGER / 引用计数(当前实测)
grep -c "FORK TRIGGER" skills/brainstorming/SKILL.md                       # 5
grep -c "FORK TRIGGER" skills/writing-plans/SKILL.md                       # 6
grep -c "three-pillars" skills/brainstorming/SKILL.md                      # 5
grep -c "acceptance-driven-plan" skills/writing-plans/SKILL.md             # 10
grep -c "\[//\]: # (FORK" skills/writing-plans/SKILL.md                    # 2
grep -cE "ltdd|subagent-driven-development|executing-plans" skills/writing-plans/SKILL.md  # 4

# 门禁关键字符串
grep -c "USER-INPUT-GATE" skills/using-superpowers/SKILL.md                # 1
grep -c "USER-INPUT-GATE" skills/using-superpowers/references/codex-tools.md  # 1
grep -rl "Perform no tools, writes, commits, skill transitions" skills/ | wc -l  # 1(必须恰好 1)
grep -c "plan-decomposition" skills/acceptance-driven-plan/SKILL.md        # 1
grep -c "execution-choice" skills/acceptance-driven-plan/SKILL.md          # 1

# 新 skill 文件存在
test -f skills/three-pillars/SKILL.md && echo "three-pillars OK"
test -f skills/acceptance-driven-plan/SKILL.md && echo "acceptance-driven-plan OK"
test -f skills/ltdd/SKILL.md && echo "ltdd OK"

# 合并后应消失的陈旧引用(现在还有 1 处:skills/test-driven-development/SKILL.md:359;合并后期望 0)
grep -rn "testing-anti-patterns" skills/ README.md
# README 里是空格写法,修复后也应消失(现在 1 处;注意与连字符写法区分)
grep -rn "testing anti-patterns" README.md

# 版本一致性(合并后 7 个 manifest + README Fork Status 都应为 6.3.0-quality-ltdd.0)
grep -rn "6.3.0-quality-ltdd.0" package.json .claude-plugin/ .codex-plugin/ .cursor-plugin/ .kimi-plugin/ gemini-extension.json README.md
```

预期:全部通过、数字与上表一致。若有任何一条失败,说明 merge 时丢了 trigger/门禁,需按 §4 手工补回。
