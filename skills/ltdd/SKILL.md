---
name: ltdd
description: Use when writing-plans handoff selects LTDD, Quality-LTDD, acceptance-driven execution, or loop TDD; use when executing a plan that has task Levels and acceptance criteria.
---

# LTDD (Quality Loop Test-Driven Development)

## Overview

**First principle: Final Intent is the final goal of every upstream and downstream task.** Every task, subagent, review, test, and AC is only a means to satisfy the user's final requirement. The Controller MUST extract Final Intent before execution and use it as the top-level guard throughout LTDD. A local task, review, or AC that passes but drifts away from Final Intent cannot be released.

Quality-LTDD is **Subagent-Driven Development + Acceptance Gates + Final Intent Guard**:

- Subagents implement and review task-scoped work.
- The Controller runs acceptance gates and routes failures.
- Final Reviewer checks whether all task products stitch into a production-ready whole.
- Plan-Level Acceptance proves the Final Intent with executable evidence.

LTDD is not an infinite retry loop. It is a quality-gated execution protocol with explicit stop points.

## Trigger and Inputs

**Trigger:**
- writing-plans handoff selects `LTDD` or `Quality-LTDD`
- user explicitly asks for `ltdd`, `loop tdd`, `quality loop tdd`, or `acceptance-driven execution`

**Required inputs:**
- plan path: `docs/superpowers/plans/YYYY-MM-DD-*.md`
- spec path: `docs/superpowers/specs/YYYY-MM-DD-*.md`
- task list with `Level`, `Level reason`, and linked AC where required
- final acceptance checklist

**Announce at start:** "I'm using LTDD to execute this plan with subagent-driven quality gates and acceptance checks."

## Roles

### Controller (main session)

The Controller is the LTDD dispatcher and judge. It should not do large implementation work itself.

Responsibilities:
- extract Final Intent
- run preflight checks
- dispatch implementer, reviewer, fix, adjudicator, and final reviewer subagents
- run task-level and plan-level AC
- route failures by evidence
- keep the state ledger current
- stop with evidence when the plan, spec, AC, or environment is wrong

Controller priority order:

```
Final Intent > Spec / Three Pillars > Global Constraints > Plan > Task brief > AC reports
```

### Implementer Subagent

Implements exactly one task.

Required inputs:
- Final Intent
- task brief
- Global Constraints
- relevant spec summary
- linked AC for context
- allowed file scope

Required behavior:
- understand the touched code path before editing
- follow TDD for behavior changes when applicable
- use the smallest correct implementation
- write focused tests or the smallest runnable check for non-trivial logic
- commit changes
- write an implementer report with test evidence

#### Lazy Senior Developer Discipline

The implementer is a lazy senior developer. Lazy means efficient, not careless. The best code is code never written.

After understanding the task and tracing the real flow end to end, stop at the first rung that holds:

1. Does this need to be built at all? If not, report `DONE_WITH_CONCERNS` or `NEEDS_CONTEXT`.
2. Does this already exist in the codebase? Reuse the helper, util, type, or pattern.
3. Does the standard library already do this? Use it.
4. Does a native platform feature cover it? Use it.
5. Does an already-installed dependency solve it? Use it.
6. Can this be one line? Make it one line.
7. Only then write the minimum code that works.

Rules:
- No abstractions that were not explicitly requested.
- No new dependency unless the task explicitly allows it and no existing option is enough.
- No boilerplate nobody asked for.
- Deletion over addition. Boring over clever. Fewest files possible.
- Shortest working diff wins only after understanding the problem.
- Bug fixes address root cause, not only the named symptom. Grep callers of shared functions before patching one path.
- Mark intentional simplifications with a `ponytail:` comment only when the shortcut has a known ceiling, and name the ceiling plus upgrade path.

Never be lazy about: understanding the real flow, trust-boundary validation, data-loss-preventing error handling, security, accessibility, hardware/platform calibration, or anything explicitly requested.

Implementer report MUST include:
- status: `DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT`
- commits created
- files changed
- tests/checks run
- TDD evidence when required
- lazy ladder decision: reused existing code / stdlib / native feature / installed dependency / wrote minimal code; what was deliberately not built and why

### Task Reviewer Subagent

Task Reviewer is a task-scoped quality gate. It proves whether the task diff is correct and clean enough to enter AC gate.

Required inputs:
- Final Intent
- task brief
- Global Constraints
- linked AC
- implementer report
- TDD evidence
- task diff package
- relevant spec summary

Checks:
- **Spec Compliance:** missing requirements, extra behavior, misunderstood requirements, scope drift, Global Constraints violations.
- **Code Quality:** separation of concerns, error handling, edge cases, tests that verify real behavior, TDD evidence credibility, clean output.
- **Lazy Discipline:** reuse of existing patterns, no avoidable dependency, no unrequested abstraction, root-cause bug fix, smallest useful check, valid `ponytail:` comments.

Task Reviewer MUST NOT:
- edit files
- change tests, spec, or AC
- run broad test suites unless the Controller explicitly asks
- expand into whole-repo review
- declare final AC passed

Task may enter AC gate only when:
- Spec Compliance is approved
- Code Quality is approved
- Critical issues = 0
- Important issues = 0
- all `Cannot verify from diff` items are resolved by Controller

### Acceptance Fix Subagent

Acceptance Fix handles a task-level AC failure after Task Reviewer has approved the task.

Required inputs:
- failed AC text
- command/procedure, input, expected result, actual result
- task brief
- Global Constraints
- implementer report
- task reviewer report
- current diff package

It classifies the failure:
- `Implementation gap`
- `Test/check mismatch`
- `Spec ambiguity`
- `Environment/tooling failure`

It may fix only implementation gaps. It may suggest that a check is wrong, but MUST NOT edit spec or AC.

After Acceptance Fix:

```
Acceptance Fix -> Task Reviewer -> task-level AC rerun
```

The same task AC gets at most 2 Acceptance Fix attempts before AC Adjudicator.

### AC Adjudicator Subagent

AC Adjudicator is the brake that prevents blind retry.

Trigger:
- same task AC still fails after 2 Acceptance Fix attempts
- Acceptance Fix classifies failure as `Spec ambiguity`, `Test/check mismatch`, or `Environment/tooling failure`

It is read-only and outputs one classification:
- `IMPLEMENTATION_STILL_WRONG`
- `AC_INCORRECT`
- `SPEC_AMBIGUOUS`
- `PLAN_TASK_WRONG`
- `ENVIRONMENT_FAILURE`
- `INSUFFICIENT_EVIDENCE`

Controller action:
- `IMPLEMENTATION_STILL_WRONG`: one more Acceptance Fix with stronger model and adjudicator findings
- `AC_INCORRECT`: stop; return to writing-plans or human AC repair
- `SPEC_AMBIGUOUS`: stop; return to brainstorming/spec clarification
- `PLAN_TASK_WRONG`: stop; return to writing-plans task decomposition
- `ENVIRONMENT_FAILURE`: stop; fix environment or ask user
- `INSUFFICIENT_EVIDENCE`: gather evidence; do not keep blind-fixing

### Final Reviewer Subagent

Final Reviewer is the production-level whole-product review gate.

Trigger:
- all tasks complete
- all Task Reviewer gates approved
- all task-level AC passed

Required inputs:
- Final Intent
- spec / Three Pillars
- plan
- Global Constraints
- final acceptance checklist
- all task briefs
- all implementer, task reviewer, acceptance fix, and adjudication reports
- whole-branch diff package

Checks:
- **Final Intent Satisfaction:** does the result satisfy the user's final requirement?
- **Business Flow Stitching:** do all task products connect into an end-to-end business flow? Entry, state transitions, downstream consumers, error paths, permissions, idempotency, rollback, UI/API/service/data/config integration.
- **Production Readiness:** config, defaults, env vars/secrets/feature flags, migrations, compatibility, observability, data safety, security, validation, performance, docs/ops notes.
- **Cross-Task Consistency:** names, interfaces, types, DTOs, config, task outputs/inputs, duplicate implementations, conflicting changes.
- **Maintainability:** local patterns, file responsibilities, no needless dependencies, no over-abstraction.
- **Quality Evidence:** credible tests, L3 AC coverage, unresolved reviewer warnings, Minor issues that accumulate into system risk.

Ready for plan-level AC only when:
- Final Intent Satisfaction = approved
- Business Flow Stitching = approved
- Production Readiness = approved
- Critical issues = 0
- Important issues = 0

### Plan-Level Acceptance Gate

Plan-Level Acceptance is controlled by the Controller. It may use subagents only for focused evidence gathering.

It executes the final acceptance checklist and records evidence.

AC statuses:
- `PASS`
- `FAIL`
- `MANUAL_REQUIRED`
- `BLOCKED_ENV`
- `INVALID_AC`

Completion requires:
- all automatic AC = `PASS`
- all manual AC confirmed by user or explicitly accepted
- `FAIL = 0`
- `BLOCKED_ENV = 0`
- `INVALID_AC = 0`

If plan-level AC fails:

```
Plan-level AC fail -> Plan-level Acceptance Fix -> Final Reviewer -> plan-level AC rerun
```

Plan-level Acceptance Fix gets at most 2 attempts for the same failure cluster before AC Adjudicator or human handoff.

## Controller Preflight

Before Task 1, Controller MUST:

1. Extract Final Intent:
   - source: user original request, spec Goal, Three Pillars, final AC, plan Goal
   - summary: the business/user result to deliver
   - success signals: observable outcomes
   - non-goals and constraints
2. Verify plan structure:
   - every task has `Level` and `Level reason`
   - L2/L3 tasks have a verification method
   - L3 tasks have linked AC
   - final AC is covered by at least one non-L1 task
   - Global Constraints are explicit
   - task dependencies and file scopes are plausible
3. Verify execution safety:
   - current git state is understood
   - plan/spec paths exist
   - required tools or test commands are available enough to start

If preflight fails, stop before dispatching implementers.

## Task Levels and Gates

### L1 - Non-Behavioral Change

Examples: ignore rules, comments, tiny docs, formatting, config with no behavior change.

Gate:

```
Controller or cheap implementer -> diff review -> complete
```

No task-level AC. No full reviewer unless it touches behavior-shaping skill text or risky config.

### L2 - Local Behavior Change

Examples: single module logic, one function, one component, one skill rule with local effect.

Gate:

```
Implementer -> Task Reviewer -> focused tests/checks -> complete
```

If L2 has linked AC, Controller runs them after Task Reviewer.

### L3 - Cross-Module or Workflow Change

Examples: business flow change, cross-layer change, user-visible workflow, multiple skills interacting.

Gate:

```
Implementer -> Task Reviewer -> linked task-level AC -> complete
```

Task-level AC is mandatory.

## Main Flow

```text
Controller preflight
for each task:
  dispatch Implementer
  handle DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT
  dispatch Task Reviewer when implementation is ready
  if reviewer finds Critical/Important: dispatch fix, then re-review
  resolve Cannot-Verify items
  if task gate needs AC: run linked AC
  if AC fails: dispatch Acceptance Fix, then Task Reviewer, then AC rerun
  if same AC still fails after allowed attempts: dispatch AC Adjudicator or stop
after all tasks:
  dispatch Final Reviewer
  fix Critical/Important issues, then rerun Final Reviewer
  run Plan-Level Acceptance Gate
  if plan-level AC fails: Plan-Level Acceptance Fix, Final Reviewer, AC rerun
  complete only when all final gates pass
```

## Failure Routing

| Failure | Controller action |
|---|---|
| Implementer `NEEDS_CONTEXT` | provide context and re-dispatch |
| Implementer `BLOCKED` | change model, split task, fix plan, or ask user |
| Task Reviewer Critical/Important | fix subagent, then re-review |
| Task Reviewer `Cannot verify` | Controller verifies or dispatches focused reviewer |
| Task-level AC fail | Acceptance Fix, then Task Reviewer, then AC rerun |
| Same task AC fails twice | AC Adjudicator |
| Adjudicator says AC/spec/plan/env wrong | stop with evidence; return to correct phase |
| Final Reviewer Critical/Important | fix, then Final Reviewer again |
| Plan-level AC fail | Plan-level Acceptance Fix, Final Reviewer, AC rerun |
| Manual AC required | produce manual checklist and wait for user confirmation |

## Retry Limits

LTDD does not retry forever.

- Task Reviewer fix loop: 2 attempts for the same Critical/Important cluster, then Controller reassesses.
- Task-level Acceptance Fix: 2 attempts for the same AC, then AC Adjudicator.
- Plan-level Acceptance Fix: 2 attempts for the same failure cluster, then AC Adjudicator or human handoff.
- Same failure signature twice after a strategy change: stop and classify; do not keep dispatching the same work.

Stopping with evidence is success at the process level when the blocker is plan, spec, AC, or environment quality.

## State Ledger

Controller writes `.superpowers/sdd/ltdd-state.json`. Ensure the directory exists first.

```bash
mkdir -p .superpowers/sdd/
```

State MUST include:

```json
{
  "plan_path": "docs/superpowers/plans/xxx.md",
  "spec_path": "docs/superpowers/specs/xxx.md",
  "final_intent": {
    "summary": "...",
    "success_signals": ["..."],
    "non_goals": ["..."],
    "sources": ["user request", "spec", "three pillars", "final AC", "plan"]
  },
  "current_phase": "preflight | task | final_review | plan_acceptance | complete | blocked",
  "current_task_id": "Task-3",
  "tasks": {
    "Task-1": {
      "level": "L2",
      "status": "passed",
      "linked_ac": [],
      "commits": ["abc123"],
      "implementer_report": "...",
      "reviewer_report": "...",
      "checks": ["..."]
    }
  },
  "ac_attempts": {
    "AC-3": {
      "attempts": 2,
      "last_status": "FAIL",
      "last_failure": "...",
      "adjudication": "..."
    }
  },
  "history": []
}
```

On resume, read this state first and continue from the recorded phase.

## Handoff

When LTDD stops before completion, write `.superpowers/sdd/ltdd-handoff.md`:

```markdown
# LTDD Handoff

## Final Intent
[summary]

## Current State
- Phase:
- Current task:
- Completed tasks:
- Passing AC:
- Failing / blocked AC:

## Evidence
- Last implementer report:
- Last reviewer report:
- Last acceptance output:
- Adjudication, if any:

## Blocker Classification
IMPLEMENTATION_STILL_WRONG | AC_INCORRECT | SPEC_AMBIGUOUS | PLAN_TASK_WRONG | ENVIRONMENT_FAILURE | INSUFFICIENT_EVIDENCE | USER_DECISION_REQUIRED

## Recommended Next Step
[specific next action]
```

## Red Flags

| Thought | Reality |
|---|---|
| "All tasks passed, so final intent must be satisfied" | False. Final Reviewer must check the products stitch into the user's final requirement. |
| "Reviewer approved, so AC can be skipped" | False. Review gates quality; AC gates evidence. |
| "AC failed, just keep trying fixes" | False. Two attempts then adjudicate or stop with evidence. |
| "Change the AC so execution can pass" | Forbidden in LTDD. Return to writing-plans or spec clarification. |
| "A green AC means production-ready" | False. Final Reviewer checks production readiness before plan-level AC. |
| "L1 can include behavior change if it is small" | False. Any behavior change is at least L2. |
| "Controller should code the fix directly" | Usually false. Controller routes and judges; subagents implement unless the fix is trivial and safe. |
| "Final Intent is just the plan Goal" | False. Extract it from user request, spec, Three Pillars, final AC, and plan. |

## Self-Review Before Completion

Before claiming LTDD complete, Controller verifies:

1. Final Intent is recorded and used in prompts/reviews.
2. Every task is complete according to its Level gate.
3. Every Task Reviewer Critical/Important issue is fixed or explicitly routed.
4. All `Cannot verify from diff` items are resolved.
5. All task-level AC required by L3 tasks passed.
6. Final Reviewer approved Final Intent Satisfaction, Business Flow Stitching, and Production Readiness.
7. Plan-Level Acceptance has no `FAIL`, `BLOCKED_ENV`, or `INVALID_AC`.
8. Manual AC, if any, has user confirmation or explicit acceptance.
9. State ledger is final or handoff file explains the blocker.
