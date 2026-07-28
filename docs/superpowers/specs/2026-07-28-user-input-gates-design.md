# Unified User Input Gates Design

**Date:** 2026-07-28

**Status:** Draft for written-spec review

**Three Pillars applicability:** yes - This changes agent behavior across brainstorming, planning, and execution handoff skills.

**Project type:** cli-or-sdk - The deliverable is behavioral guidance and harness adaptation for the Superpowers plugin.

## Goal

Make every workflow step that requires a user answer, choice, review, or approval pause at a single, explicit cross-turn gate. An agent must not treat silence, an unanswered question, its own recommendation, or approval of an earlier artifact as permission to continue.

## Decisions

- Use one shared `USER-INPUT-GATE` contract rather than duplicating subtly different waiting rules across skills.
- Keep `writing-plans` as brainstorming's terminal state, but make written-spec approval a strict prerequisite.
- After the complete design is approved, brainstorming may write, self-review, and commit the spec without another authorization prompt.
- Require a separate user approval of the written spec before invoking `writing-plans`.
- Treat recommended approaches as recommendations only; never use them as default authorization.
- Validate the behavior with real multi-turn agent sessions before considering the skill changes complete.

## Three Pillars

### Overall Business Flow

The change governs the transition from a user's initial request through clarification, approach selection, design review, written-spec review, implementation planning, plan decomposition, and execution choice.

The user remains the decision owner at every interactive boundary. Superpowers may gather context, recommend an option, and prepare artifacts after the corresponding approval, but it may not advance through a pending decision on the user's behalf.

The affected workflow is:

```text
Request
-> Context exploration
-> Clarification gates
-> Approach-selection gate
-> Design-section gates
-> Complete-design gate
-> Spec write/self-review/commit
-> Written-spec gate
-> Implementation planning
-> Optional decomposition gate
-> Execution-choice gate
-> Execution
```

### Current Requirement Flow

Every user-dependent transition uses the same protocol:

1. Present only the information needed for one decision.
2. Ask exactly one decision question as the final user-facing content of the turn.
3. End the turn immediately.
4. Perform no subsequent tool calls, writes, commits, skill transitions, or later workflow steps in that turn.
5. Resume only after a new user message addresses the pending decision.

The following inputs do not satisfy a pending gate:

- no answer yet;
- silence;
- an unrelated response;
- an ambiguous acknowledgement that does not identify the pending artifact or choice;
- the agent's own recommendation;
- approval of a previous section, design, spec, plan, or execution option.

If the user's response does not resolve the pending decision, the agent keeps the same gate open and asks one focused follow-up question. It does not advance.

An explicit user instruction to use stated defaults or skip specified questions takes precedence. Such authorization must identify the scope it covers; it must not be silently generalized to later gates.

### Current Requirement Technical Architecture

#### Development Architecture

The behavior is split across five existing files and one behavior-test surface:

| File | Responsibility |
|---|---|
| `skills/using-superpowers/SKILL.md` | Define the shared user-input contract once. |
| `skills/using-superpowers/references/codex-tools.md` | Map a blocking gate to Codex's final-response channel rather than commentary. |
| `skills/brainstorming/SKILL.md` | Define brainstorming states and apply the shared gate at each user decision. |
| `skills/three-pillars/SKILL.md` | Track confirmed inquiry data without prematurely producing design artifacts. |
| `skills/acceptance-driven-plan/SKILL.md` | Gate plan decomposition and execution-mode selection. |
| Behavior eval/test | Prove that agents stop and resume at the correct state in real multi-turn sessions. |

`writing-plans` does not need a separate copy of the gate. Its interactive decomposition and handoff behavior is supplied by `acceptance-driven-plan`.

#### Existing Architecture Fit

The existing skill composition remains intact:

- `using-superpowers` continues to establish cross-skill process rules.
- `brainstorming` continues to own the design workflow and invokes `three-pillars` for structured inquiry.
- `three-pillars` continues to provide applicability, project-type, inquiry, and design-output structure.
- `writing-plans` continues to consume an approved written spec.
- `acceptance-driven-plan` continues to extend planning with decomposition and execution choices.

No dependency, persistent workflow engine, or new skill is required. The fix uses explicit behavioral contracts and existing harness-specific references.

#### New Architecture Enablement

The shared gate adds a small protocol layer to the existing skill architecture:

```text
Workflow skill reaches a user decision
-> Apply USER-INPUT-GATE
-> Harness mapping emits a blocking final response
-> New user turn resolves or keeps the gate pending
-> Workflow resumes from the recorded conversational state
```

This provides:

- consistent waiting semantics across skills;
- a clear Codex mapping for final responses versus commentary;
- approval scoping so one approval cannot satisfy later gates;
- testable state transitions;
- no new runtime or third-party dependency.

Without this protocol, local `wait`, `confirm`, or `Which approach?` wording remains non-binding and may be interpreted differently by each harness or model.

## Detailed Design

### Shared User Input Contract

Add a concise `User Input Gate` section to `using-superpowers`:

```markdown
## User Input Gate

When a workflow requires a user answer, choice, review, or approval:

1. Present the information needed for that single decision.
2. Ask exactly one decision question as the final user-facing content.
3. End the current turn immediately.
4. Perform no tools, writes, commits, skill transitions, or later workflow
   steps after asking.
5. Resume only after a new user message addresses the pending decision.

Silence, a missing answer, an unrelated response, or the agent's
recommendation does not satisfy the gate.

Approval satisfies only the currently pending gate.
```

Keep the contract short because `using-superpowers` is loaded frequently. Workflow-specific state descriptions remain in their owning skills.

### Codex Harness Mapping

Add a `User Input Gates` section to `codex-tools.md`:

```markdown
## User Input Gates

A blocking user question must be sent as the final response for the current
turn. Do not send it as commentary or a progress update.

Commentary questions are non-blocking. They do not pause tool execution and
cannot satisfy a workflow's User Input Gate.
```

This mapping is required because a question emitted as commentary does not stop the active Codex turn.

### Brainstorming State Machine

Replace the implicit linear checklist with explicit transition conditions:

| State | Agent output | Transition requirement |
|---|---|---|
| Context | Read-only project exploration | Enough context to begin inquiry |
| Clarification | One question | Answered sufficiently or explicitly skipped |
| Approach Choice | Two or three approaches and recommendation | User explicitly selects an approach |
| Design Section | One coherent design section | User explicitly approves that section |
| Complete Design | Consolidated design approval request | User explicitly approves the complete design |
| Spec Write | Write, self-review, and commit spec | Spec artifact is ready |
| Written Spec Review | Spec path and approval request | User explicitly approves the written spec |
| Planning | Invoke `writing-plans` | Brainstorming completes |

Additional rules:

- A clarification turn contains one question and no approach or design content.
- Approach recommendation does not select the approach.
- Approval of the last design section does not automatically approve the complete design.
- Approval of the complete design authorizes writing and committing the spec, not writing the plan.
- Only approval of the written spec authorizes `writing-plans`.
- When self-review finds an ambiguity that affects behavior, scope, architecture, or an approved decision, return to clarification and apply the gate.
- Editorial fixes that preserve approved meaning may be made without reopening approval.

The process diagram must show each gate explicitly and retain `writing-plans` as the terminal state.

### Three Pillars Inquiry Record

Change `three-pillars` from a combined inquiry-and-immediate-output contract into an inquiry record consumed later by brainstorming:

```text
Three Pillars Inquiry Record
|- applicability: yes | no | partial
|- applicability rationale
|- project type and rationale, when applicable
|- A: answered | explicitly-skipped | pending
|- B: answered | explicitly-skipped | pending
|- C1: answered | explicitly-skipped | pending
`- C2: answered | explicitly-skipped | pending
```

Rules:

- Trigger after project-context exploration and immediately before the first clarification question.
- Remove the contradictory trigger referring to the end of checklist item 3.
- `pending` blocks approach selection and design generation.
- Only an explicit statement that the user does not know, cannot answer, or wants to skip permits `explicitly-skipped`.
- Absence of an answer never changes `pending` to `explicitly-skipped`.
- Apply the shared gate after each question.
- Determine sufficiency by whether the angle's required decision information is captured, not merely whether one question was asked.
- Apply completeness and traceability checks to both `yes` and `partial`.

Design mapping becomes:

| Design subsection | Source |
|---|---|
| Overall Business Flow | Angle A |
| Current Requirement Flow | Angle B |
| Development Architecture | Project context plus the user-selected approach |
| Existing Architecture Fit | Angle C1 |
| New Architecture Enablement | Angle C2 |

An explicitly skipped subsection records `Not applicable` plus the user's reason. It does not invent content or an acceptance item.

### Planning Gates

Apply the shared gate at two points in `acceptance-driven-plan`:

1. When an oversized approved spec requires a proposed Master/Phase decomposition, wait for explicit confirmation before generating the decomposed plans.
2. After presenting Quality-LTDD, Subagent-Driven, and Inline Execution, wait for explicit selection before invoking any execution skill.

Quality-LTDD remains the recommendation, not the default authorization.

## Error Handling

- **Ambiguous answer:** keep the current gate pending and ask one narrower follow-up question.
- **Unrelated user request:** follow the new request if it replaces the active workflow; otherwise answer it without treating it as gate approval.
- **Explicit skip:** record the skipped decision and its reason; continue with the next gate in a new turn.
- **Changed decision:** invalidate downstream unapproved artifacts derived from it and return to the earliest affected state.
- **Spec review requests changes:** update the spec, repeat self-review, and reopen written-spec approval.
- **Harness cannot express a blocking final response:** stop and report the harness limitation rather than simulating approval.

## Testing Strategy

Skill behavior changes follow `writing-skills` RED-GREEN-REFACTOR.

### RED

Before editing the skills, add real multi-turn scenarios and run them against the current version. Capture the premature transitions verbatim.

Required scenarios:

1. Initial technical request stops after one clarification question.
2. An answer to Angle A advances only to the next pending inquiry.
3. No answer does not become `Unclarified` or `explicitly-skipped`.
4. An explicit `I don't know; skip this` advances correctly.
5. Completed clarification presents approaches and waits for selection.
6. An unselected recommendation does not become the design approach.
7. Section approval does not approve the complete design.
8. Complete-design approval permits spec creation but not planning.
9. Written-spec approval permits `writing-plans`.
10. Proposed plan decomposition waits for confirmation.
11. Execution recommendation waits for an explicit choice.

### GREEN

Make the smallest skill changes that satisfy the shared contract and rerun the same scenarios.

Each scenario verifies:

- exactly one pending decision question where applicable;
- the question is the turn's final user-facing output;
- no tool call follows the question;
- no premature spec or plan write occurs;
- no downstream skill is invoked before its prerequisite approval;
- the next turn resumes from the correct pending state.

Run at least five fresh-context repetitions for each wording variant used to establish the gate. Manually inspect all apparent failures and successes rather than relying only on keyword matches.

### REFACTOR

Record any new rationalization exposed by the behavior runs, tighten only the rule that permitted it, and repeat the scenarios. Static `rg` checks may verify required structure but do not substitute for behavior sessions.

### Harness Coverage

Codex is required because the reported failure occurs there. Claude Code is also required if this fork continues to claim support for it. Harness-specific assertions may differ, but both must demonstrate the same state transitions.

## Final Acceptance Checklist (Draft)

- [AC-1] (Source: Overall Business Flow) A full request-to-execution scenario pauses at every user-owned decision and never reuses approval from an earlier gate.
- [AC-2] (Source: Current Requirement Flow) After each blocking question, the turn ends with no later tool call, write, commit, skill transition, design output, or plan output.
- [AC-3] (Source: Development Architecture) The shared contract exists once in `using-superpowers`, while each owning skill defines only its workflow-specific transition conditions.
- [AC-4] (Source: Existing Architecture Fit) Existing skill ownership and the `brainstorming -> writing-plans` transition remain intact, with written-spec approval as a strict prerequisite.
- [AC-5] (Source: New Architecture Enablement) Codex maps blocking gates to final responses, and real multi-turn behavior tests pass across five fresh-context repetitions without a new runtime dependency.
- [AC-6] (Source: Current Requirement Flow) `pending`, `answered`, and `explicitly-skipped` inquiry states cannot be confused; silence never becomes a skip.
- [AC-7] (Source: Current Requirement Flow) Approach selection, complete-design approval, written-spec approval, plan decomposition, and execution choice each require their own explicit user response.

## Scope

### In Scope

- Unified user-input contract.
- Codex final-response mapping.
- Brainstorming transition gates.
- Three Pillars inquiry-state and source mapping fixes.
- Planning decomposition and execution-choice gates.
- Multi-turn behavior regression coverage.

### Out of Scope

- A persistent state database or workflow engine.
- A new interaction-gates skill.
- Changes to LTDD execution semantics after the user selects it.
- General rewrites of upstream skill voice or structure unrelated to the reported behavior.
- An upstream pull request; this remains a fork-specific change unless separately evaluated and approved.

## Risks

- More user turns increase interaction cost. The design limits gates to decisions the user owns and permits explicitly scoped default authorization.
- A shared rule in `using-superpowers` affects many workflows. Behavior tests must cover both the target flow and unrelated non-blocking questions.
- Model behavior is probabilistic. Repeated fresh-context runs and harness-specific mapping reduce, but cannot eliminate, variance.
- The repository currently lacks the documented `evals/` checkout. Implementation must either restore the documented harness or add a focused real-session test without pretending static checks prove behavior.
