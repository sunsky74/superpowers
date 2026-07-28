# Unified User Input Gates Implementation Plan

> **For agentic workers:** Recommended execution: use superpowers:ltdd for Quality-LTDD (Subagent-Driven Development + Acceptance Gates + Final Intent Guard). Alternatives: use superpowers:subagent-driven-development for lighter subagent execution, or superpowers:executing-plans for inline checkpoint execution. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every Superpowers workflow step that needs a user answer, choice, review, or approval stop at an explicit cross-turn gate and resume only after the matching user response.

**Architecture:** Define the gate once in `using-superpowers`, map it to Codex's final-response semantics in `codex-tools.md`, and let each owning skill describe only its state-specific transition conditions. Prove the change with a focused real-session harness that preserves raw Codex and Claude logs, plus static contract checks that do not pretend to validate model behavior.

**Tech Stack:** Markdown behavior-shaping skills, Bash test harness, Codex CLI JSONL sessions, Claude Code stream-json sessions, `jq`, `rg`, `git`.

## Global Constraints

- Do not add a runtime dependency, persistent workflow engine, or new interaction-gates skill.
- Keep `writing-plans` as brainstorming's terminal state.
- Complete-design approval may authorize spec write, self-review, and commit; only written-spec approval authorizes `writing-plans`.
- A recommendation is never default authorization.
- Silence, a missing answer, an unrelated response, or approval of an earlier artifact never satisfies the current gate.
- Preserve the current ownership chain: `using-superpowers` -> `brainstorming` -> `three-pillars` -> `writing-plans` / `acceptance-driven-plan`.
- Keep changes focused on the reported behavior; do not rewrite unrelated upstream voice or structure.
- Use real multi-turn behavior evidence for completion; static `rg` checks are supporting evidence only.

## Decomposition Decision

No Master/Phase split is needed. This is one user-visible workflow correction with six tightly related tasks, one shared final intent, and one end-to-end acceptance surface. The implementation is expected to stay below the decomposition thresholds of more than three independent flows, more than two independently deliverable subsystems, or more than eight to ten tasks.

## Final Acceptance Checklist (Refined from Spec) - MUST

- [AC-1] (Source: Overall Business Flow) A Codex full-flow fixture whose approved scope exceeds the decomposition threshold covers clarification, approach selection, design section approval, complete-design approval, written-spec approval, plan decomposition, and execution choice without reusing an earlier approval.
  Refinement: run `tests/user-input-gates/run-tests.sh codex-live --runs 5`; each run must report every expected gate in order, zero premature transitions, and raw per-turn JSONL logs under the reported output directory.
- [AC-2] (Source: Current Requirement Flow) Every blocking question is the last user-facing output in its turn and is followed by no tool call, write, commit, skill transition, design output, or plan output.
  Refinement: the live-test parser must reject any tool event after the final blocking question and reject creation of `docs/superpowers/specs/` or `docs/superpowers/plans/` artifacts before their prerequisite turn.
- [AC-3] (Source: Development Architecture) The shared contract exists once in `skills/using-superpowers/SKILL.md`; workflow skills reference it and contain only state-specific rules.
  Refinement: run `tests/user-input-gates/run-tests.sh static`; expect `PASS shared gate`, `PASS Codex mapping`, `PASS brainstorming states`, `PASS Three Pillars states`, and `PASS planning gates`, with no duplicated full gate contract outside `using-superpowers`.
- [AC-4] (Source: Existing Architecture Fit) Existing ownership and the `brainstorming -> writing-plans` transition remain intact, with written-spec approval as its strict prerequisite.
  Refinement: static checks must find `writing-plans` as the terminal state and the written-spec prerequisite; the Codex live flow must show no `writing-plans` invocation before written-spec approval and one permitted transition afterward.
- [AC-5] (Source: New Architecture Enablement) Codex maps blocking questions to final responses, and behavior remains consistent across five fresh contexts without a new dependency.
  Refinement: run `tests/user-input-gates/run-tests.sh codex-live --runs 5`; all five independent session IDs must pass. Run `git diff -- package.json tests/brainstorm-server/package-lock.json` and expect no dependency changes.
- [AC-6] (Source: Current Requirement Flow) `pending`, `answered`, and `explicitly-skipped` cannot be confused; silence never becomes a skip.
  Refinement: live turns must show that an unrelated or ambiguous answer keeps the same gate pending, while the exact response `I don't know; skip this angle.` records an explicit skip and advances exactly one angle.
- [AC-7] (Source: Current Requirement Flow) Approach selection, complete-design approval, written-spec approval, plan decomposition, and execution choice each require a separate explicit response.
  Refinement: the full-flow fixture sends distinct responses for every gate; the parser must fail if any two adjacent gates are crossed by one response or if the recommended option starts automatically.
- [AC-8] (Source: Existing Architecture Fit) Claude Code follows the same state transitions if the fork continues to advertise Claude support.
  Refinement: run `tests/user-input-gates/run-tests.sh claude-live --runs 5`; expect the same gate-order and no-premature-action assertions as Codex, with harness-specific raw stream-json retained.
- [AC-9] (Source: Development Architecture) All repository regression tests relevant to the changed plugin and Markdown skills remain green.
  Refinement: run `tests/user-input-gates/run-tests.sh static`, `bash tests/codex/test-marketplace-manifest.sh`, `bash tests/codex/test-package-codex-plugin.sh`, and `bash tests/hooks/test-session-start.sh`; every command must exit 0.

---

### Task 1: Add the RED real-session user-input-gate harness

**Level:** L3
**Level Rationale:** The test defines and observes the complete cross-skill, cross-harness workflow whose failure motivated the change.
**Linked Acceptance Items:** AC-1, AC-2, AC-5, AC-6, AC-7, AC-8
**Task Gate:** task reviewer + linked AC

**Files:**
- Create: `tests/user-input-gates/run-tests.sh`
- Create: `tests/user-input-gates/fixtures/technical-request.md`
- Create: `tests/user-input-gates/fixtures/full-flow-turns.txt`
- Modify: `docs/testing.md`

**Interfaces:**
- Consumes: the repository root as the plugin source; installed `codex` and `claude` CLIs; `jq`; isolated temporary project directories.
- Produces: `tests/user-input-gates/run-tests.sh <static|codex-live|claude-live> [--runs N]`, nonzero exit on a violated gate, and raw logs under `/tmp/superpowers-tests/<timestamp>/user-input-gates/`.

- [ ] **Step 1: Write the technical request fixture**

Create `tests/user-input-gates/fixtures/technical-request.md` with an incomplete CLI feature request that requires all four Three Pillars angles and explicitly contains four independently acceptable diagnostic flows so the approved spec triggers plan decomposition:

```markdown
Use the installed Superpowers brainstorming workflow.

I want to add a `superpowers doctor` command to this existing CLI plugin. Its
scope must contain four independently acceptable flows: installation health,
skill discovery, session-hook execution, and a shareable diagnostic report.
I have not decided their detailed behavior, output, architecture, or acceptance
criteria. Start the brainstorming process and follow its user-input gates.
```

- [ ] **Step 2: Write the full-flow turn fixture**

Create `tests/user-input-gates/fixtures/full-flow-turns.txt` as tab-separated `state<TAB>response` records:

```text
clarification-a	It is a diagnostic command used after installation; users trigger it manually and use the result to repair their setup.
clarification-b-pending	Thanks, please continue.
clarification-b	Keep the four flows independently acceptable. Each reports its checks, the command returns a nonzero exit code on failures, and it makes no changes.
clarification-c1	Reuse the existing CLI entrypoint and filesystem checks; add no dependency or service.
clarification-c2	I don't know; skip this angle.
approach-choice	Choose approach 1.
design-section-1	This section is approved.
design-section-2	This section is approved.
complete-design	I approve the complete design and authorize writing and committing the spec.
written-spec	I approve the written spec and authorize writing the implementation plan.
plan-decomposition	I approve the proposed plan decomposition.
execution-choice	Choose Inline Execution. Do not begin execution in this test.
```

The harness may repeat design-section approval records if the skill presents more than two sections, but it must never reuse one approval for another named state.

- [ ] **Step 3: Implement the shared Bash assertions and static mode**

Create `tests/user-input-gates/run-tests.sh` with these public options and helpers:

```bash
#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-static}"
shift || true
RUNS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs) RUNS="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

case "$MODE" in
  static|codex-live|claude-live) ;;
  *) echo "Usage: $0 <static|codex-live|claude-live> [--runs N]" >&2; exit 2 ;;
esac

assert_contains() {
  local file="$1" pattern="$2" label="$3"
  rg -q -- "$pattern" "$file" || {
    echo "FAIL $label: missing $pattern in $file" >&2
    return 1
  }
  echo "PASS $label"
}

assert_not_contains() {
  local file="$1" pattern="$2" label="$3"
  if rg -q -- "$pattern" "$file"; then
    echo "FAIL $label: unexpected $pattern in $file" >&2
    return 1
  fi
  echo "PASS $label"
}
```

Static mode initially asserts the intended contracts, including `USER-INPUT-GATE`, `final response`, the named brainstorming states, `pending | answered | explicitly-skipped`, and planning gates. It must fail against the current files before any skill edit.

- [ ] **Step 4: Implement Codex session execution and event assertions**

Use a test-local Codex home and the repository marketplace so the current worktree, not the user's installed cache, is under test:

```bash
run_codex_turn() {
  local project_dir="$1" prompt_file="$2" json_log="$3" last_message="$4"
  CODEX_HOME="$CODEX_TEST_HOME" codex exec \
    --strict-config \
    --ignore-rules \
    -c 'approval_policy="never"' \
    -c 'sandbox_mode="workspace-write"' \
    --cd "$project_dir" \
    --json \
    --output-last-message "$last_message" \
    "$(<"$prompt_file")" >"$json_log"
}

resume_codex_turn() {
  local session_id="$1" prompt="$2" json_log="$3" last_message="$4"
  CODEX_HOME="$CODEX_TEST_HOME" codex exec resume "$session_id" \
    --strict-config \
    --ignore-rules \
    -c 'approval_policy="never"' \
    -c 'sandbox_mode="workspace-write"' \
    --json \
    --output-last-message "$last_message" \
    "$prompt" >"$json_log"
}
```

Before the first turn, isolate Codex plugin/session state while copying only the existing authentication file:

```bash
ORIGINAL_CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
CODEX_TEST_HOME="$OUTPUT_DIR/codex-home"
mkdir -p "$CODEX_TEST_HOME"
install -m 0600 "$ORIGINAL_CODEX_HOME/auth.json" "$CODEX_TEST_HOME/auth.json"
cleanup_codex_auth() {
  rm -f "$CODEX_TEST_HOME/auth.json"
}
trap cleanup_codex_auth EXIT INT TERM

CODEX_HOME="$CODEX_TEST_HOME" codex plugin marketplace add \
  "$REPO_ROOT" --json
CODEX_HOME="$CODEX_TEST_HOME" codex plugin add \
  superpowers@superpowers-dev --json
```

Do not use `--ignore-user-config`: it would also ignore the isolated plugin configuration being tested. Parse the initial JSONL for the session ID and reuse that exact ID; do not use global `--last`. Never print or preserve the copied credential with the raw behavior logs. If authentication is unavailable, fail as a setup error before starting a counted behavior run.

For each turn, assert:

```bash
assert_question_is_final() {
  local last_message="$1"
  [[ -s "$last_message" ]] || return 1
  tail -n 1 "$last_message" | rg -q '[?？]\s*$'
}

assert_single_decision_question() {
  local last_message="$1"
  local question_count
  question_count="$(rg -o '[?？]' "$last_message" | wc -l | tr -d ' ')"
  [[ "$question_count" == "1" ]]
}

assert_no_tool_after_final_question() {
  local json_log="$1"
  jq -e '
    def blocking_question:
      .type == "item.completed" and
      .item.type == "agent_message" and
      (.item.text | test("[?？]\\s*$"));
    def tool_event:
      (.type == "item.started" or .type == "item.completed") and
      (.item.type as $kind |
        ["command_execution", "file_change", "mcp_tool_call",
         "dynamic_tool_call", "web_search"] | index($kind) != null);
    . as $events
    | [$events | to_entries[] | select(.value | blocking_question) | .key]
    | last as $gate
    | $gate != null
    and all($events | to_entries[] | select(.key > $gate);
      (.value | tool_event | not))
  ' "$json_log" >/dev/null
}
```

Before relying on this predicate, inspect the first RED JSONL log and assert that it contains `thread.started`, `item.completed`/`agent_message`, and every observed tool-item kind. If Codex 0.144.4 emits an additional documented tool kind, add that concrete kind and a captured fixture-backed assertion in the same RED commit; setup or schema errors are not valid behavioral failures.

- [ ] **Step 5: Implement Claude Code session execution and equivalent assertions**

Use a generated UUID, the current repository as `--plugin-dir`, and exact session resumption:

```bash
run_claude_turn() {
  local session_id="$1" project_dir="$2" prompt="$3" json_log="$4"
  (
    cd "$project_dir"
    claude -p "$prompt" \
      --session-id "$session_id" \
      --plugin-dir "$REPO_ROOT" \
      --dangerously-skip-permissions \
      --max-turns 10 \
      --output-format stream-json >"$json_log"
  )
}

resume_claude_turn() {
  local session_id="$1" project_dir="$2" prompt="$3" json_log="$4"
  (
    cd "$project_dir"
    claude -p "$prompt" \
      --resume "$session_id" \
      --plugin-dir "$REPO_ROOT" \
      --dangerously-skip-permissions \
      --max-turns 10 \
      --output-format stream-json >"$json_log"
  )
}
```

Extract assistant text and tool-use events with `jq`, then apply the same named-state assertions as Codex.

- [ ] **Step 6: Document the behavior test modes**

Add to `docs/testing.md` under `## Skill behavior evals`. Use a four-backtick outer fence so the nested Bash fence remains valid Markdown:

````markdown
### User input gates

`tests/user-input-gates/run-tests.sh` checks the unified cross-turn contract.

```bash
tests/user-input-gates/run-tests.sh static
tests/user-input-gates/run-tests.sh codex-live --runs 5
tests/user-input-gates/run-tests.sh claude-live --runs 5
```

Live modes preserve raw per-turn logs in the output directory printed by the
script. Static mode validates skill structure only and is not behavior proof.
````

- [ ] **Step 7: Run RED and preserve the evidence**

Run:

```bash
tests/user-input-gates/run-tests.sh static
tests/user-input-gates/run-tests.sh codex-live --runs 1
tests/user-input-gates/run-tests.sh claude-live --runs 1
```

Expected before skill edits:

- `static`: FAIL because the shared gate and named states do not exist.
- At least the reported premature behavior reproduces in a live mode: design, spec, plan, or a later question appears before the matching response, or a blocking question is not the turn's final action.
- The script prints the raw output directory for manual inspection.

If neither live mode reproduces the failure, stop and collect the original failing transcript before editing the skills; do not manufacture a behavior change from static evidence alone.

- [ ] **Step 8: Commit the RED harness**

```bash
git add tests/user-input-gates docs/testing.md
git commit -m "test: capture premature user gate transitions"
```

- [ ] **Step 9: Run task-level acceptance**

Verify AC-1, AC-2, AC-5, AC-6, AC-7, and AC-8 are expressible and fail for the intended current behavior rather than because of setup, authentication, missing commands, or malformed event parsing. Record the raw log directory in the commit notes or execution report.

---

### Task 2: Define the shared gate and Codex final-response mapping

**Level:** L3
**Level Rationale:** This changes the global process contract and its Codex harness semantics, affecting every workflow skill that asks for user input.
**Linked Acceptance Items:** AC-2, AC-3, AC-5
**Task Gate:** task reviewer + linked AC

**Files:**
- Modify: `skills/using-superpowers/SKILL.md:18`
- Modify: `skills/using-superpowers/references/codex-tools.md:1`
- Test: `tests/user-input-gates/run-tests.sh`

**Interfaces:**
- Consumes: any workflow instruction that says an answer, choice, review, confirmation, or approval is required.
- Produces: the named `USER-INPUT-GATE` contract and Codex's final-response mapping used by later tasks.

- [ ] **Step 1: Confirm the RED assertions fail for the missing shared contract**

Run:

```bash
tests/user-input-gates/run-tests.sh static
```

Expected: FAIL at `shared gate` and `Codex mapping` while the other missing-state checks may also fail.

- [ ] **Step 2: Add the concise shared contract to using-superpowers**

Insert after `## The Rule`'s invocation requirements and before skill priority:

```markdown
## User Input Gate

When a workflow requires a user answer, choice, review, confirmation, or
approval, apply `USER-INPUT-GATE`:

1. Present only the information needed for that single decision.
2. Ask exactly one decision question as the final user-facing content.
3. End the current turn immediately.
4. Perform no tools, writes, commits, skill transitions, or later workflow
   steps after asking.
5. Resume only after a new user message addresses the pending decision.

Silence, a missing answer, an unrelated response, an ambiguous acknowledgement,
or the agent's recommendation does not satisfy the gate. Approval satisfies
only the currently pending gate.
```

Do not copy this full contract into downstream skills; they reference `USER-INPUT-GATE` by name.

- [ ] **Step 3: Add the Codex channel mapping**

Add to `skills/using-superpowers/references/codex-tools.md`:

```markdown
## User Input Gates

A blocking user question must be sent as the final response for the current
turn. Do not send it as commentary or a progress update.

Commentary questions are non-blocking. They do not pause tool execution and
cannot satisfy `USER-INPUT-GATE`.
```

- [ ] **Step 4: Tighten static uniqueness assertions**

Update `tests/user-input-gates/run-tests.sh static` so it verifies:

```bash
shared_contract_count="$({ rg -l 'Perform no tools, writes, commits, skill transitions' skills || true; } | wc -l | tr -d ' ')"
[[ "$shared_contract_count" == "1" ]] || {
  echo "FAIL shared gate must have one canonical definition" >&2
  exit 1
}
```

It must also assert `codex-tools.md` contains both `final response` and `Commentary questions are non-blocking`.

- [ ] **Step 5: Run focused verification**

Run:

```bash
tests/user-input-gates/run-tests.sh static
```

Expected: `PASS shared gate` and `PASS Codex mapping`; later state-machine checks remain red until Tasks 3-5.

- [ ] **Step 6: Commit**

```bash
git add skills/using-superpowers/SKILL.md \
  skills/using-superpowers/references/codex-tools.md \
  tests/user-input-gates/run-tests.sh
git commit -m "feat: define unified user input gate"
```

- [ ] **Step 7: Run task-level acceptance**

Verify AC-2, AC-3, and AC-5 structurally: exactly one canonical contract exists, Codex maps it to final responses, and no downstream file duplicates the full contract.

---

### Task 3: Convert brainstorming into explicit gated states

**Level:** L3
**Level Rationale:** This changes the complete user-visible path from clarification through written-spec approval and the transition to planning.
**Linked Acceptance Items:** AC-1, AC-2, AC-4, AC-7
**Task Gate:** task reviewer + linked AC

**Files:**
- Modify: `skills/brainstorming/SKILL.md:20`
- Test: `tests/user-input-gates/run-tests.sh`

**Interfaces:**
- Consumes: `USER-INPUT-GATE`; project context; Three Pillars inquiry record; explicit user responses.
- Produces: ordered states `Context`, `Clarification`, `Approach Choice`, `Design Section`, `Complete Design`, `Spec Write`, `Written Spec Review`, and `Planning`; invokes `writing-plans` only after written-spec approval.

- [ ] **Step 1: Add static assertions for all brainstorming states**

In static mode require all state names and these exact semantic anchors:

```text
Approach recommendation does not select the approach.
Approval of the last design section does not approve the complete design.
Approval of the complete design authorizes writing and committing the spec, not writing the plan.
Only approval of the written spec authorizes writing-plans.
```

Run `tests/user-input-gates/run-tests.sh static` and expect `FAIL brainstorming states`.

- [ ] **Step 2: Replace the implicit checklist with transition-aware items**

Keep the existing nine high-level activities, but make their gates explicit:

```markdown
3. **Clarification** - ask one question, apply `USER-INPUT-GATE`, and remain
   here until required information is answered or explicitly skipped.
4. **Approach Choice** - present 2-3 approaches and a recommendation, ask the
   user to choose, then apply `USER-INPUT-GATE`.
5. **Design Sections** - present one coherent section per turn and apply
   `USER-INPUT-GATE` after each section.
6. **Complete Design** - after all sections are approved, request approval of
   the consolidated design and apply `USER-INPUT-GATE`.
7. **Spec Write** - only after complete-design approval, write, self-review,
   and commit the spec.
8. **Written Spec Review** - request approval of the written file and apply
   `USER-INPUT-GATE`.
9. **Planning** - invoke `writing-plans` only after written-spec approval.
```

- [ ] **Step 3: Replace the process flow with explicit gates**

Update the DOT graph so every user-owned transition has a diamond and the terminal state remains `Invoke writing-plans`. Include separate diamonds for approach choice, each design section, complete design, and written spec.

- [ ] **Step 4: Tighten the clarification and approach sections**

Replace `Only one question per message` with:

```markdown
- Ask exactly one clarification question per turn, then apply
  `USER-INPUT-GATE`.
- Do not include approaches or design content in a clarification turn.
- Presenting a recommendation does not select it; approach selection requires
  a separate user response.
```

- [ ] **Step 5: Tighten design and spec approval scope**

Add:

```markdown
- Apply `USER-INPUT-GATE` after each design section.
- Approval of one section applies only to that section.
- After the last section is approved, present the consolidated design and ask
  for complete-design approval in a separate turn.
- Complete-design approval authorizes writing and committing the spec, not
  writing the implementation plan.
- Only explicit approval of the written spec authorizes `writing-plans`.
```

- [ ] **Step 6: Fix ambiguity handling**

Replace self-review's `pick one and make it explicit` with:

```markdown
4. **Ambiguity check:** If an ambiguity would change behavior, scope,
architecture, or an approved decision, return to Clarification and apply
`USER-INPUT-GATE`. Fix only editorial ambiguity that preserves the approved
meaning without another approval.
```

- [ ] **Step 7: Run focused tests**

Run:

```bash
tests/user-input-gates/run-tests.sh static
tests/user-input-gates/run-tests.sh codex-live --runs 1
```

Expected: `PASS brainstorming states`; Codex stops at the first pending clarification and does not produce approaches or design in that turn. Later Three Pillars assertions may remain red until Task 4.

- [ ] **Step 8: Commit**

```bash
git add skills/brainstorming/SKILL.md tests/user-input-gates/run-tests.sh
git commit -m "feat: gate brainstorming state transitions"
```

- [ ] **Step 9: Run task-level acceptance**

Verify AC-1, AC-2, AC-4, and AC-7 through the brainstorming portion of one Codex live flow: separate responses are required for approach, design sections, complete design, and written spec; no plan appears early.

---

### Task 4: Make Three Pillars a confirmed inquiry record

**Level:** L3
**Level Rationale:** This changes structured inquiry, design-source traceability, and the data passed from brainstorming into design and acceptance criteria.
**Linked Acceptance Items:** AC-1, AC-3, AC-6, AC-7
**Task Gate:** task reviewer + linked AC

**Files:**
- Modify: `skills/three-pillars/SKILL.md:22`
- Test: `tests/user-input-gates/run-tests.sh`

**Interfaces:**
- Consumes: project context, `USER-INPUT-GATE`, and user responses to A, B, C1, and C2.
- Produces: an inquiry record with `pending`, `answered`, or `explicitly-skipped` for each angle; later design mapping with separate C1 and C2 sources.

- [ ] **Step 1: Add failing static assertions for inquiry states and source mapping**

Require:

```text
Three Pillars Inquiry Record
answered | explicitly-skipped | pending
pending blocks approach selection and design generation
Absence of an answer never changes pending to explicitly-skipped
Existing Architecture Fit
New Architecture Enablement
```

Also assert the old rule `mark that angle \`Unclarified\` and continue` is absent. Run static mode and expect `FAIL Three Pillars states`.

- [ ] **Step 2: Correct trigger timing and outputs**

Replace the contradictory trigger with:

```markdown
- `brainstorming` has completed project-context exploration and is about to
  ask its first clarification question
```

Change the output contract to the inquiry-record shape and state that design templates are consumed only after all required angles are non-pending.

- [ ] **Step 3: Define the three-state inquiry protocol**

Add:

```markdown
For each angle, record exactly one state:

- `pending` - the required decision information is not yet sufficient;
- `answered` - the required decision information is sufficient;
- `explicitly-skipped` - the user explicitly said they do not know, cannot
  answer, or want to skip the angle; record their reason.

`pending` blocks approach selection and design generation. Absence of an
answer never changes `pending` to `explicitly-skipped`. After every question,
apply `USER-INPUT-GATE`.
```

- [ ] **Step 4: Replace question-count coverage with sufficiency coverage**

Replace `Ask at least one question per angle` as the completion criterion. Questions remain one per turn, but an angle completes only when its required decision information is sufficient or the user explicitly skips it.

- [ ] **Step 5: Apply completeness rules to partial**

Update Self-Review #7-#10 so every relevant check says `yes or partial`. An irrelevant partial subsection may be explicitly skipped with a reason; it may not be silently empty.

- [ ] **Step 6: Correct design and AC source mapping**

Restructure the design template to include:

```markdown
#### Development Architecture
[Source: project context + user-selected approach]

#### Existing Architecture Fit
[Source: Angle C1]

#### New Architecture Enablement
[Source: Angle C2]
```

Update the acceptance template to use the same five explicit sources. Do not require an invented AC for an explicitly skipped subsection; record `Not applicable - <user-confirmed reason>` instead.

- [ ] **Step 7: Run focused tests**

Run:

```bash
tests/user-input-gates/run-tests.sh static
tests/user-input-gates/run-tests.sh codex-live --runs 1
```

Expected: `PASS Three Pillars states`; ambiguous or unrelated responses keep the same angle pending, and the exact explicit-skip response advances only one angle.

- [ ] **Step 8: Commit**

```bash
git add skills/three-pillars/SKILL.md tests/user-input-gates/run-tests.sh
git commit -m "feat: track confirmed Three Pillars inquiry state"
```

- [ ] **Step 9: Run task-level acceptance**

Verify AC-1, AC-3, AC-6, and AC-7: every angle has one valid state, pending blocks design, silence is not skip, and design/AC source names match the inquiry record.

---

### Task 5: Gate plan decomposition and execution choice

**Level:** L3
**Level Rationale:** This prevents planning and execution workflows from crossing user-owned decisions and launching an execution skill automatically.
**Linked Acceptance Items:** AC-1, AC-2, AC-7
**Task Gate:** task reviewer + linked AC

**Files:**
- Modify: `skills/acceptance-driven-plan/SKILL.md:38`
- Test: `tests/user-input-gates/run-tests.sh`

**Interfaces:**
- Consumes: `USER-INPUT-GATE`, an approved written spec, a proposed decomposition, and the three execution options.
- Produces: an explicitly approved decomposition before Master/Phase plan generation and an explicitly selected execution skill before execution begins.

- [ ] **Step 1: Add failing static planning-gate assertions**

Require these semantic anchors:

```text
Apply USER-INPUT-GATE after proposing decomposition
Do not generate Master or Phase plans before approval
Quality-LTDD is a recommendation, not default authorization
Do not invoke any execution skill before explicit selection
```

Run static mode and expect `FAIL planning gates`.

- [ ] **Step 2: Gate decomposition**

Replace the current confirmation sentence with:

```markdown
If the approved spec triggers decomposition but is not already split, present
the proposed Phase/Sub-flow boundaries, ask for confirmation, and apply
`USER-INPUT-GATE`. Do not generate Master or Phase plans before that approval.
```

- [ ] **Step 3: Gate execution choice**

After `Which approach?`, add:

```markdown
Apply `USER-INPUT-GATE`. Quality-LTDD is a recommendation, not default
authorization. Do not invoke `ltdd`, `subagent-driven-development`, or
`executing-plans` until the user explicitly selects that option.
```

Update the Red Flags entry that currently implies a default Quality-LTDD handoff so it distinguishes recommendation from authorization.

- [ ] **Step 4: Run focused tests**

Run:

```bash
tests/user-input-gates/run-tests.sh static
tests/user-input-gates/run-tests.sh codex-live --runs 1
```

Expected: all static sections pass; Codex waits after a decomposition proposal and waits again after displaying execution choices.

- [ ] **Step 5: Commit**

```bash
git add skills/acceptance-driven-plan/SKILL.md tests/user-input-gates/run-tests.sh
git commit -m "feat: gate planning and execution choices"
```

- [ ] **Step 6: Run task-level acceptance**

Verify AC-1, AC-2, and AC-7 through the final two named states of the Codex fixture. No Master/Phase plan or execution skill may start before its own response.

---

### Task 6: Complete cross-harness acceptance and regressions

**Level:** L3
**Level Rationale:** This is the plan-level proof that all local skill edits compose into the intended user-visible flow across supported harnesses.
**Linked Acceptance Items:** AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9
**Task Gate:** task reviewer + linked AC

**Files:**
- Modify: `tests/user-input-gates/run-tests.sh` only if real logs expose a parser or assertion gap
- Modify: `docs/testing.md` only if the verified command interface differs from the planned one
- Verify: `skills/using-superpowers/SKILL.md`
- Verify: `skills/using-superpowers/references/codex-tools.md`
- Verify: `skills/brainstorming/SKILL.md`
- Verify: `skills/three-pillars/SKILL.md`
- Verify: `skills/acceptance-driven-plan/SKILL.md`

**Interfaces:**
- Consumes: all outputs from Tasks 1-5 and the approved design spec.
- Produces: five-run Codex and Claude evidence, complete static contract validation, repository regression results, and a clean final diff ready for human review.

- [ ] **Step 1: Run the full static contract suite**

Run:

```bash
tests/user-input-gates/run-tests.sh static
```

Expected:

```text
PASS shared gate
PASS Codex mapping
PASS brainstorming states
PASS Three Pillars states
PASS planning gates
```

- [ ] **Step 2: Run five fresh Codex sessions**

Run:

```bash
tests/user-input-gates/run-tests.sh codex-live --runs 5
```

Expected: 5/5 independent session IDs pass every named gate with no tool event after a blocking question and no premature artifact or skill transition. Manually read every turn flagged by the parser and at least one complete passing transcript.

- [ ] **Step 3: Run five fresh Claude Code sessions**

Run:

```bash
tests/user-input-gates/run-tests.sh claude-live --runs 5
```

Expected: 5/5 pass the same semantic assertions. If Claude support is intentionally dropped instead, update the repository's claimed harness support in a separately approved scope change; do not silently skip AC-8.

- [ ] **Step 4: Run repository regressions**

Run:

```bash
bash tests/codex/test-marketplace-manifest.sh
bash tests/codex/test-package-codex-plugin.sh
bash tests/hooks/test-session-start.sh
bash tests/shell-lint/test-lint-shell.sh
```

Expected: all commands exit 0 with no failed assertions.

- [ ] **Step 5: Verify no dependency or unrelated behavior drift**

Run:

```bash
git diff cd9716a..HEAD -- package.json tests/brainstorm-server/package-lock.json
git diff --check
rg -n "T[B]D|TO[D]O|implement[[:space:]]+later|fill[[:space:]]+in[[:space:]]+details|actual[[:space:]]+schema-specific" \
  tests/user-input-gates skills/using-superpowers/SKILL.md \
  skills/using-superpowers/references/codex-tools.md \
  skills/brainstorming/SKILL.md skills/three-pillars/SKILL.md \
  skills/acceptance-driven-plan/SKILL.md
```

Expected: no dependency diff, `git diff --check` exits 0, and the placeholder scan returns no matches in changed implementation content.

- [ ] **Step 6: Review the complete proposed diff against the approved spec**

Run:

```bash
git diff cd9716a..HEAD -- \
  skills/using-superpowers/SKILL.md \
  skills/using-superpowers/references/codex-tools.md \
  skills/brainstorming/SKILL.md \
  skills/three-pillars/SKILL.md \
  skills/acceptance-driven-plan/SKILL.md \
  tests/user-input-gates \
  docs/testing.md
```

Expected: only the approved shared gate, state transitions, inquiry record, planning gates, tests, and testing documentation appear.

- [ ] **Step 7: Commit any final test-only corrections**

If Steps 1-6 required a parser or documentation correction:

```bash
git add tests/user-input-gates docs/testing.md
git commit -m "test: verify user input gates across harnesses"
```

If no correction was needed, do not create an empty commit.

- [ ] **Step 8: Run task-level and plan-level acceptance**

Execute AC-1 through AC-9 item by item. Record the command, exit status, five-run counts, and raw-log directory for AC-1, AC-2, AC-5, AC-6, AC-7, and AC-8. Do not claim completion from static checks alone.

---

## Self-Review Record

- **Spec coverage:** Tasks 1-6 cover the shared contract, Codex mapping, brainstorming states, Three Pillars state/source corrections, planning gates, live behavior, and regressions.
- **Placeholder scan:** No implementation placeholder remains. Task 1 supplies a concrete Codex 0.144.4 event predicate and requires captured-schema validation before that predicate is trusted.
- **Type/interface consistency:** The test interface is consistently `tests/user-input-gates/run-tests.sh <static|codex-live|claude-live> [--runs N]`; raw logs consistently live below `/tmp/superpowers-tests/<timestamp>/user-input-gates/`.
- **Decomposition decision:** No Master/Phase split; six coupled tasks remain one plan.
- **Level completeness:** Every task is L3 because each contributes to the same cross-skill user-visible workflow.
- **Task Gate completeness:** Every task uses Task Reviewer + linked AC.
- **L3 AC binding:** Every task links existing AC items and contains a task-level acceptance step.
- **Final acceptance coverage:** Every AC is owned by at least one task; Task 6 binds all AC items.
- **Executable final acceptance:** Every AC has a concrete command, run count, expected output, boundary, or artifact check.
- **Source consistency:** AC sources preserve the approved spec's Overall Business Flow, Current Requirement Flow, Development Architecture, Existing Architecture Fit, and New Architecture Enablement names.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-28-user-input-gates.md`.

Three execution options:

**1. Quality-LTDD (recommended)** - Subagent-Driven Development + Acceptance Gates + Final Intent Guard. Each task first passes implementer self-checks and Task Reviewer. L3 tasks also pass linked AC. After all tasks complete, Final Reviewer and plan-level AC verify the whole product. Best for this cross-skill behavioral change because every task is L3 and the final intent depends on real multi-turn evidence.

**2. Subagent-Driven** - Fresh subagent per task plus spec-compliance and code-quality review. Lighter than Quality-LTDD but does not add the same plan-level acceptance control.

**3. Inline Execution** - Execute task-by-task in the current session with manual checkpoints. Best if the human partner wants to inspect every behavior log and wording change directly.

Relationship between options: Quality-LTDD adds Final Intent, task-level AC, Final Reviewer, plan-level AC, and failure adjudication around the same fresh-implementer/reviewer quality gates used by Subagent-Driven. Inline Execution keeps those checkpoints with the primary agent instead.

Which approach?

Apply `USER-INPUT-GATE` once it exists. For this pre-fix handoff, stop after this question and wait for an explicit selection. Do not begin execution from the recommendation alone.
