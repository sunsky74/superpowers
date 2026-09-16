---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Entry gate:** This skill may start only after brainstorming's `written-spec`
gate is explicitly approved. Approval of a design section or the complete
design does not authorize plan generation. If written-spec approval is absent
or ambiguous, return to that gate and apply `USER-INPUT-GATE`.

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

> **FORK TRIGGER:** Master/Phase decomposition for large requirements lives in `superpowers:acceptance-driven-plan` section 0. During Scope Check, MUST use that section to decide whether decomposition is needed. For oversized requirements, generate a Master Plan plus Phase/Sub-flow Plans: the Master Plan tracks only Final Intent, document index, Progress Ledger, AC coverage matrix, and overall progress; concrete task steps move into Phase/Sub-flow Plans. Do not generate a bloated monolithic plan.

If decomposition is required but the approved spec does not already define it,
present the proposed split, apply the `plan-decomposition` gate from
`superpowers:acceptance-driven-plan`, and stop. Do not write any plan until the
user approves the split. If decomposition is not required, continue without
asking for confirmation.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

> **FORK TRIGGER:** The Plan Document Header's `Final Acceptance Checklist` section, refined from the spec draft, lives in `superpowers:acceptance-driven-plan` section 1. When generating the header, MUST insert that section after `## Global Constraints` and before `---` using the section 1 template.

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** Recommended execution: use superpowers:ltdd for Quality-LTDD (Subagent-Driven Development + Acceptance Gates + Final Intent Guard). Alternatives: use superpowers:subagent-driven-development for lighter subagent execution, or superpowers:executing-plans for inline checkpoint execution. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [path to the spec/design doc this plan implements — the plan
argues from the spec, so the spec travels with it; executors read both]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

[//]: # (FORK: Insert the Final Acceptance Checklist section here; see superpowers:acceptance-driven-plan section 1.)

---
```

## Task Structure

> **FORK TRIGGER:** The Task Structure fields `Level / Level Rationale / Linked Acceptance Items / Task Gate` live in `superpowers:acceptance-driven-plan` section 2. For every task, MUST insert those four Level/Gate fields after `### Task N:` and before `**Files:**` using the section 2 template.

````markdown
### Task N: [Component Name]

[//]: # (FORK: Insert Level / Level Rationale / Linked Acceptance Items / Task Gate fields here; see superpowers:acceptance-driven-plan section 2.)

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

> **FORK TRIGGER:** The L1-L3 decision table lives in `superpowers:acceptance-driven-plan` section 3: L1 = no behavior change, L2 = local behavior change, L3 = cross-module or business-flow change. When assigning each task's Level and Task Gate, MUST use that table and write the Level Rationale. Any behavior change is at least L2.

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

> **FORK TRIGGER:** Acceptance-driven Self-Review additions (#4-#11: decomposition decision, Master/Phase completeness, Level completeness, Task Gate completeness, L3 AC binding, final acceptance coverage, executable final acceptance checklist, source consistency with spec) live in `superpowers:acceptance-driven-plan` section 5. During Self-Review, MUST append those checks.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

> **FORK TRIGGER:** The three-way Execution Handoff (Quality-LTDD recommended / Subagent-Driven / Inline Execution) lives in `superpowers:acceptance-driven-plan` section 4. After saving the plan, MUST present the three-way handoff using that template. This fork replaces the upstream two-option handoff and makes Quality-LTDD the recommended option.

After saving the plan, offer execution choice and apply `USER-INPUT-GATE` — see
`superpowers:acceptance-driven-plan` section 4 for the exact three-way handoff
text and the `execution-choice` gate. Do not invoke an execution skill until
the user chooses an option.

**If Quality-LTDD chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:ltdd
- SDD + Acceptance Gates + Final Intent Guard

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
