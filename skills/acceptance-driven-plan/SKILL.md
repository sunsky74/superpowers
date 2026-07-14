---
name: acceptance-driven-plan
description: Use when writing-plans starts generating a plan that needs acceptance criteria, task Levels, task gates, Master/Phase decomposition, or LTDD/Quality-LTDD execution handoff.
---

# Acceptance-Driven Plan

## Overview

This skill is this fork's standalone home for acceptance-driven plan structure. It separates Master/Phase decomposition, the final acceptance checklist header, Task Level, Task Gate, L1-L3 criteria, and Quality-LTDD handoff from the upstream `writing-plans` skill so upstream changes can be merged while this fork-specific planning policy evolves independently.

Core idea: large requirements should become a Master/Phase document system before executable task planning. Each executable task must explain which quality gate proves it. Master design/plan documents preserve Final Intent and global progress. Phase design/plan documents carry executable, reviewable, and acceptable work. L1 is only for no behavior change. L2 requires an implementer, Task Reviewer, and focused checks. L3 must also bind to task-level AC. Quality-LTDD is the recommended execution path: Subagent-Driven Development + Acceptance Gates + Final Intent Guard.

## Trigger and Inputs

**Triggers:**

- `writing-plans` is generating the Plan Document Header or Task Structure and must apply this template
- the user explicitly asks for `acceptance-driven`, `acceptance criteria`, or `L1 L2 L3`

**Inputs:**

- the design spec from brainstorming, including Three Pillars and Final Acceptance Checklist Draft from `superpowers:three-pillars`
- the task list produced by `writing-plans`

**Outputs to writing-plans:**

- the `Final Acceptance Checklist` section for the plan header, refined from the spec draft
- Master/Phase decomposition decision, document index, Progress Ledger, and AC coverage matrix when the requirement is large
- four fields for every task: Level, Level Rationale, Linked Acceptance Items, Task Gate
- L1-L3 decision criteria for plan self-review
- Execution Handoff with Quality-LTDD as the recommended path

**Announce at start:** "I'm using the acceptance-driven-plan skill to decide Master/Phase decomposition and structure the plan with acceptance criteria, L1-L3 task gates, and Quality-LTDD handoff."

---

## 0. Master/Phase Decomposition for Large Requirements

Before generating concrete tasks, `writing-plans` MUST decide whether decomposition is needed. If the requirement is too large, do not put every detail into one design/plan. Keep top-level Master design/plan documents, but use them only for governance and indexing. Move executable details into Phase or Sub-flow design/plan documents.

### 0.1 Decomposition Triggers

Decompose when any of these conditions apply:

- more than 3 independent business flows or user journeys
- more than 2 independent subsystems or technical layers must coordinate
- likely more than 8-10 tasks
- a single plan is likely to exceed 1500-2000 lines
- multiple rollout stages, canary stages, or manual acceptance stages are needed
- there are phases or sub-flows that can be delivered and accepted independently
- different parts have clearly different risk models, such as payment, authorization, data migration, and ordinary UI

If the design/spec is already split into Master + Phase documents, `writing-plans` MUST generate Master Plan + Phase Plans using that split. If the design/spec is too large but not split, `writing-plans` MUST propose a decomposition and ask for user confirmation before generating a giant plan.

### 0.2 Decomposition Priority

Prefer business-loop decomposition. Use technical-layer decomposition only as the last option:

1. **Phase:** a stage that can be delivered or released independently
2. **Sub-flow:** a business flow that can be accepted independently
3. **Capability:** a capability that can be used independently
4. **Technical slice:** frontend/backend/data split, only when no business-loop split is possible

Avoid defaulting to `backend plan / frontend plan / database plan`; that often loses Final Intent. Better splits look like `submission flow / approval flow / notification and audit flow / admin configuration flow`.

### 0.3 Master Design and Master Plan Responsibilities

Master design SHOULD record only:

- Final Intent
- Three Pillars overview
- end-to-end business-flow overview
- Phase/Sub-flow decomposition table
- child design links
- cross-phase dependencies
- global constraints
- Global AC Draft
- in-scope and out-of-scope boundaries

Master plan SHOULD record only:

- Final Intent
- child plan index
- phase order and dependencies
- Progress Ledger
- current execution phase
- done / not-started / blocked phases
- Global AC coverage matrix
- final plan-level acceptance

Master plan MUST NOT include every task's implementation steps. Those belong in Phase plans.

### 0.4 Phase Design and Phase Plan Responsibilities

Each Phase/Sub-flow design contains the detailed design for one independently acceptable slice.

Each Phase/Sub-flow plan:

- implements exactly one phase or sub-flow
- contains concrete tasks with Level and Task Gate fields
- has its own Phase AC
- maps Phase AC back to Global AC
- can be executed independently by Quality-LTDD

### 0.5 Progress Ledger Template

Master plan MUST include this table when decomposition is used:

```markdown
## Progress Ledger

| Phase | Design | Plan | Status | Current Gate | Depends On | Final Intent Coverage |
|---|---|---|---|---|---|---|
| Phase 1: ... | specs/... | plans/... | not-started / in-progress / done / blocked | ... | ... | AC-1, AC-2 |
```

### 0.6 AC Layering

Use two AC layers:

- **Global AC:** proves Final Intent at the whole-product level.
- **Phase AC:** proves one phase or sub-flow works independently.

Rules:

- Every Phase plan MUST have Phase AC.
- Every Global AC MUST map to one or more Phase AC items.
- Master plan maintains the AC coverage matrix.
- Phase plans execute Phase AC. After all necessary phases pass, the Master plan executes final Global AC.

### 0.7 File Naming

Use stable names:

```text
docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md
docs/superpowers/specs/YYYY-MM-DD-<topic>-phase-1-<name>-design.md
docs/superpowers/plans/YYYY-MM-DD-<topic>-plan.md
docs/superpowers/plans/YYYY-MM-DD-<topic>-phase-1-<name>-plan.md
```

---

## 1. Plan Document Header Template

In the original `writing-plans` Plan Document Header template, insert this section after `## Global Constraints` and before `---`:

```markdown
## Final Acceptance Checklist (Refined from Spec) - MUST

- [AC-1] (Source: ...) ...
  Refinement: test command ... / data: ... / boundary: ...
- [AC-2] (Source: ...) ...
  Refinement: ...
[...]
```

**Hard constraints:**

- The final acceptance checklist MUST be refined from the spec draft produced by `three-pillars`.
- Do not copy the spec draft verbatim. Add executable test commands, data, and boundary conditions.
- If the spec's AC is not executable, rewrite it into executable form while preserving the source.
- Every AC source must match the spec's Three Pillars source.

---

## 2. Task Structure Template

In the original `writing-plans` Task Structure template, insert these four fields after `### Task N: [Component Name]` and before `**Files:**`:

```markdown
### Task N: [Component Name]

**Level:** L1 | L2 | L3
**Level Rationale:** [why this level is correct]
**Linked Acceptance Items:** [AC-1, AC-3] (required; may be empty for L1)
**Task Gate:** [diff review | task reviewer + focused checks | task reviewer + linked AC]

**Files:**
[...original Task Structure content...]
```

---

## 3. L1-L3 Decision Criteria

Each task's Level is decided by this table. The Level and Level Rationale MUST be written during planning.

| Level | Trigger | Task-level acceptance method |
|---|---|---|
| **L1** | **No behavior change:** ignore rules, comments, pure docs, formatting, or configuration that cannot change execution results | diff review; no AC run |
| **L2** | Local behavior change: one module, function, component, or local skill rule; focused tests/checks can cover it | Implementer + Task Reviewer + focused tests/checks |
| **L3** | Cross-module, cross-layer, cross-skill, business-flow, or user-visible workflow change; must prove task output serves Final Intent | Implementer + Task Reviewer + linked task-level AC |

**Hard constraints:**

- Any behavior change is at least L2. Do not mark behavior changes L1 because they are single-file or under 50 lines.
- L1 may have empty `Linked Acceptance Items`; L2 may bind AC; L3 MUST bind AC.
- If a final AC is covered only by L1 tasks, the Leveling is wrong. Final Intent cannot be proven by no-behavior-change tasks.

### Extra Requirements for L3

- `Linked Acceptance Items` MUST NOT be empty.
- Linked AC MUST exist in the plan's final acceptance checklist.
- Task steps MUST include a "run task-level acceptance" step that verifies linked AC item by item.

### TDD Equivalent for L2/L3 Non-Code Changes

If a task changes Markdown that shapes agent behavior, configuration, documentation, or other non-executable content, traditional red-green may not apply. Use **structural grep verification + manual read-through** as the task-level TDD equivalent.

---

## 4. Execution Handoff

After saving the plan, `writing-plans` MUST use this handoff instead of the upstream handoff:

```markdown
## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/<filename>.md`.

Three execution options:

**1. Quality-LTDD (recommended)** - Subagent-Driven Development + Acceptance Gates + Final Intent Guard. Each task first passes implementer self-checks and Task Reviewer. L3 tasks also pass linked AC. After all tasks complete, Final Reviewer and plan-level AC verify the whole product. Best for requirements with clear Final Intent, business flows, or production-quality expectations.

**2. Subagent-Driven** - Upstream path: fresh subagent per task + two-stage review for spec compliance and code quality. Best when code quality is the main goal and acceptance gates are lighter.

**3. Inline Execution** - Upstream path: batch execution with checkpoints. Best when the human partner is present and wants step-by-step confirmation.

Relationship between options: Quality-LTDD is not a competitor to Subagent-Driven. It adds Final Intent, task-level AC, Final Reviewer, plan-level AC, and failure adjudication around Subagent-Driven's fresh implementer + reviewer quality gates. Subagent-Driven is the lighter path. Inline Execution is the manual checkpoint path.

Which approach?

If Quality-LTDD is chosen:
- **REQUIRED SUB-SKILL:** Use superpowers:ltdd
- SDD + Acceptance Gates + Final Intent Guard

If Subagent-Driven is chosen:
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

If Inline Execution is chosen:
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
```

---

## 5. Self-Review Additions

Append these checks after the original `writing-plans` Self-Review #1-#3:

- **#4 Decomposition decision:** section 0 was used to decide whether Master/Phase decomposition is needed. If not decomposed, the reason is clear. If decomposed, Master Plan and Phase Plans have clear responsibility boundaries.
- **#5 Master/Phase completeness:** when decomposed, Master Plan has Progress Ledger, child document index, and Global AC coverage matrix; every Phase Plan has Phase AC mapped back to Global AC.
- **#6 Level completeness:** every executable task has Level and Level Rationale.
- **#7 Task Gate completeness:** every executable task has Task Gate, and the gate matches its Level: L1 = diff review; L2 = Task Reviewer + focused checks; L3 = Task Reviewer + linked AC.
- **#8 L3 AC binding:** every L3 task has non-empty Linked Acceptance Items, and each referenced AC exists in the current plan's acceptance checklist.
- **#9 Final acceptance coverage:** every final AC is linked to at least one non-L1 task or Phase AC. Cross-module, end-to-end, or business-flow AC SHOULD be covered by L3 tasks or Phase AC. If an AC has no owner, add a task/phase or adjust the Level.
- **#10 Executable final acceptance checklist:** every AC refinement includes concrete test commands, data, and boundaries rather than abstract descriptions.
- **#11 Source consistency with spec:** plan AC sources match the spec's Three Pillars sources. If the spec says `Source: Overall Business Flow`, the plan must not rewrite it as `Current Requirement Flow`.

---

## 6. Red Flags

| Thought | Reality |
|---|---|
| "L1 should also run acceptance." | L1 skips AC and uses human diff review. Running AC for no behavior change wastes time. |
| "A small single-file change is L1." | Wrong. Any behavior change is at least L2. L1 is only for no behavior change. |
| "L3 only needs TDD." | L3 = TDD plus task-level acceptance. Without linked AC, it collapses to L2. |
| "Copying the spec's acceptance checklist is enough." | The plan MUST refine it into executable commands, data, and boundaries. |
| "Large requirements can still fit in one plan." | Wrong when section 0 triggers. Master Plan governs and indexes; Phase Plans carry execution details. |
| "Frontend/backend/database split is the clearest decomposition." | Usually wrong. Prefer business Phase/Sub-flow split; technical-layer split is the last option. |
| "Task Level does not matter, mark everything L2." | Wrong. Level determines acceptance method. Bad Leveling causes missed coverage or wasted work. |
| "Default handoff can stay Subagent-Driven." | This fork recommends Quality-LTDD when the user has not chosen a lighter path. |
| "AC sources can be omitted." | Sources are the traceability chain between plan and spec. Without them, coverage cannot be verified. |

---

## 7. Key Principles

- **Acceptance-driven planning:** every task explains which quality gate proves it; the final acceptance checklist drives final evidence.
- **Master/Phase separation:** large requirements use Master design/plan for Final Intent and progress, and Phase design/plan for execution details.
- **Level routing:** L1 = no behavior change, L2 = local behavior change, L3 = cross-module or business-flow change.
- **Executable AC:** plan AC refinements must include concrete commands, data, and boundaries.
- **Traceable sources:** every plan AC points back to the spec's Three Pillars.
- **Quality-LTDD recommended:** default to SDD + Acceptance Gates + Final Intent Guard; Subagent-Driven and Inline remain available for lighter execution.
