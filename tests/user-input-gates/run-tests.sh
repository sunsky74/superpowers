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

[[ "$RUNS" =~ ^[1-9][0-9]*$ ]] || { echo "--runs must be a positive integer" >&2; exit 2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
TIMESTAMP="$(date +%s)"
OUTPUT_DIR="/tmp/superpowers-tests/${TIMESTAMP}/user-input-gates"

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

fail_setup() {
  echo "SETUP FAIL: $*" >&2
  echo "Raw logs: $OUTPUT_DIR" >&2
  exit 3
}

fail_behavior() {
  echo "BEHAVIOR RED: $*" >&2
  echo "Raw logs: $OUTPUT_DIR" >&2
  exit 1
}

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

assert_claude_no_tool_after_final_question() {
  local json_log="$1"
  jq -e -s '
    def text: [.message.content[]? | select(.type == "text") | .text] | join("\\n");
    def blocking_question: .type == "assistant" and (text | test("[?？]\\s*$"));
    def tool_event: .type == "assistant" and any(.message.content[]?; .type == "tool_use");
    . as $events
    | [$events | to_entries[] | select(.value | blocking_question) | .key]
    | last as $gate
    | $gate != null
    and all($events | to_entries[] | select(.key > $gate);
      (.value | tool_event | not))
  ' "$json_log" >/dev/null
}

assert_codex_schema() {
  local json_log="$1"
  jq -e 'select(.type == "thread.started") | .thread_id | strings' "$json_log" >/dev/null || return 1
  jq -e 'select(.type == "item.completed" and .item.type == "agent_message")' "$json_log" >/dev/null || return 1
  jq -e '
    select((.type == "item.started" or .type == "item.completed") and .item.type != "agent_message")
    | .item.type
  ' "$json_log" | sort -u >"${json_log}.tool-kinds"
  [[ -s "${json_log}.tool-kinds" ]] || return 1
  while IFS= read -r kind; do
    case "$kind" in
      command_execution|file_change|mcp_tool_call|dynamic_tool_call|web_search) ;;
      *) echo "Unrecognized Codex 0.144.4 tool item kind: $kind" >&2; return 1 ;;
    esac
  done <"${json_log}.tool-kinds"
}

assert_claude_schema() {
  local json_log="$1"
  jq -e -s 'any(.[]; .type == "assistant" and (.message.content | type == "array"))' "$json_log" >/dev/null
}

assert_gate() {
  local harness="$1" state="$2" log="$3" last_message="$4"
  assert_question_is_final "$last_message" || fail_behavior "$harness $state did not end in a question"
  assert_single_decision_question "$last_message" || fail_behavior "$harness $state did not ask exactly one decision question"
  if [[ "$harness" == "codex" ]]; then
    assert_no_tool_after_final_question "$log" || fail_behavior "$harness $state invoked a tool after its final question"
  else
    assert_claude_no_tool_after_final_question "$log" || fail_behavior "$harness $state invoked a tool after its final question"
  fi
  echo "PASS $harness $state gate"
}

assert_no_artifacts() {
  local project_dir="$1" label="$2"
  if find "$project_dir/docs/superpowers" -type f \( -path '*/specs/*' -o -path '*/plans/*' \) -print -quit 2>/dev/null | rg -q .; then
    fail_behavior "$label created a spec or plan before its authorizing response"
  fi
}

assert_spec_exists() {
  local project_dir="$1"
  find "$project_dir/docs/superpowers/specs" -type f -print -quit 2>/dev/null | rg -q . || fail_behavior "complete-design did not produce a written spec"
}

assert_no_plan() {
  local project_dir="$1"
  if find "$project_dir/docs/superpowers/plans" -type f -print -quit 2>/dev/null | rg -q .; then
    fail_behavior "written-spec created a plan before plan-decomposition approval"
  fi
}

assert_plan_exists() {
  local project_dir="$1"
  find "$project_dir/docs/superpowers/plans" -type f -print -quit 2>/dev/null | rg -q . || fail_behavior "plan-decomposition did not produce a plan"
}

run_static() {
  local using="$REPO_ROOT/skills/using-superpowers/SKILL.md"
  local codex="$REPO_ROOT/skills/using-superpowers/references/codex-tools.md"
  local brainstorming="$REPO_ROOT/skills/brainstorming/SKILL.md"
  local pillars="$REPO_ROOT/skills/three-pillars/SKILL.md"
  local planning="$REPO_ROOT/skills/writing-plans/SKILL.md"
  local acceptance="$REPO_ROOT/skills/acceptance-driven-plan/SKILL.md"
  local shared_contract_count

  assert_contains "$using" 'USER-INPUT-GATE' 'shared input gate exists'
  assert_contains "$using" 'End the current turn immediately' 'shared gate ends the turn'
  assert_contains "$using" 'Perform no tools, writes, commits, skill transitions' 'shared gate blocks later actions'
  assert_contains "$codex" 'final response' 'Codex maps a blocking gate to the final response'
  assert_contains "$codex" 'Commentary questions are non-blocking' 'Codex rejects commentary as a blocking gate'

  shared_contract_count="$({ rg -l 'Perform no tools, writes, commits, skill transitions' "$REPO_ROOT/skills" || true; } | wc -l | tr -d ' ')"
  [[ "$shared_contract_count" == "1" ]] || {
    echo "FAIL shared gate must have one canonical definition" >&2
    return 1
  }
  echo "PASS shared gate has one canonical definition"

  assert_contains "$brainstorming" 'USER-INPUT-GATE' 'brainstorming declares the shared input gate'
  assert_contains "$brainstorming" 'final response' 'brainstorming makes the gate the final response action'
  assert_contains "$brainstorming" 'clarification-a' 'brainstorming names clarification-a state'
  assert_contains "$brainstorming" 'clarification-b' 'brainstorming names clarification-b state'
  assert_contains "$brainstorming" 'approach-choice' 'brainstorming names approach-choice state'
  assert_contains "$brainstorming" 'design-section' 'brainstorming names design-section state'
  assert_contains "$brainstorming" 'complete-design' 'brainstorming names complete-design state'
  assert_contains "$brainstorming" 'recommendation does not select' 'brainstorming does not treat a recommendation as a choice'
  assert_contains "$brainstorming" 'last section does not approve the complete design' 'brainstorming scopes section approval'
  assert_contains "$brainstorming" 'Only explicit approval of the written spec authorizes' 'brainstorming scopes written-spec approval'
  assert_contains "$pillars" 'pending | answered | explicitly-skipped' 'three-pillars records input status'
  assert_contains "$pillars" 'Any `pending` angle' 'three-pillars blocks design while input is pending'
  assert_contains "$pillars" 'Absence of an answer never changes' 'three-pillars does not infer a skip'
  assert_not_contains "$pillars" 'mark that angle `Unclarified` and continue' 'three-pillars removes silent continuation'
  assert_contains "$planning" 'written-spec' 'writing-plans names written-spec gate'
  assert_contains "$acceptance" 'plan-decomposition' 'acceptance planning names decomposition gate'
  assert_contains "$acceptance" 'execution-choice' 'acceptance planning names execution gate'
}

run_codex_turn() {
  local project_dir="$1" prompt_file="$2" json_log="$3" last_message="$4"
  CODEX_HOME="$CODEX_TEST_HOME" codex exec \
    --strict-config \
    --ignore-rules \
    -c 'approval_policy="never"' \
    -c 'sandbox_mode="workspace-write"' \
    --cd "$project_dir" \
    --skip-git-repo-check \
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

run_claude_turn() {
  local session_id="$1" project_dir="$2" prompt="$3" json_log="$4"
  (
    cd "$project_dir"
    claude -p "$prompt" \
      --session-id "$session_id" \
      --plugin-dir "$REPO_ROOT" \
      --dangerously-skip-permissions \
      --max-turns 10 \
      --verbose \
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
      --verbose \
      --output-format stream-json >"$json_log"
  )
}

next_fixture_response() {
  local state="$1"
  awk -F '\t' -v wanted="$state" '$1 == wanted { print $2; exit }' "$FIXTURES_DIR/full-flow-turns.txt"
}

run_codex_live_once() {
  local run_dir="$1"
  local project_dir="$run_dir/project" initial_log="$run_dir/initial.jsonl" initial_last="$run_dir/initial.txt"
  local session_id state response log last
  mkdir -p "$project_dir/docs/superpowers"

  run_codex_turn "$project_dir" "$FIXTURES_DIR/technical-request.md" "$initial_log" "$initial_last" || fail_setup "Codex initial turn failed"
  assert_codex_schema "$initial_log" || fail_setup "Codex initial JSONL did not match the 0.144.4 schema"
  session_id="$(jq -r 'select(.type == "thread.started") | .thread_id' "$initial_log" | head -n 1)"
  [[ -n "$session_id" && "$session_id" != "null" ]] || fail_setup "Codex did not emit a thread ID"
  assert_gate codex clarification-a "$initial_log" "$initial_last"

  for state in clarification-a clarification-b-pending clarification-b clarification-c1 clarification-c2 approach-choice design-section-1 design-section-2; do
    response="$(next_fixture_response "$state")"
    log="$run_dir/${state}.jsonl"
    last="$run_dir/${state}.txt"
    resume_codex_turn "$session_id" "$response" "$log" "$last" || fail_setup "Codex $state turn failed"
    assert_gate codex "$state" "$log" "$last"
    assert_no_artifacts "$project_dir" "$state"
  done

  state=complete-design
  log="$run_dir/${state}.jsonl"
  last="$run_dir/${state}.txt"
  resume_codex_turn "$session_id" "$(next_fixture_response "$state")" "$log" "$last" || fail_setup "Codex $state turn failed"
  assert_gate codex "$state" "$log" "$last"
  assert_spec_exists "$project_dir"

  state=written-spec
  log="$run_dir/${state}.jsonl"
  last="$run_dir/${state}.txt"
  resume_codex_turn "$session_id" "$(next_fixture_response "$state")" "$log" "$last" || fail_setup "Codex $state turn failed"
  assert_gate codex "$state" "$log" "$last"
  assert_no_plan "$project_dir"

  state=plan-decomposition
  log="$run_dir/${state}.jsonl"
  last="$run_dir/${state}.txt"
  resume_codex_turn "$session_id" "$(next_fixture_response "$state")" "$log" "$last" || fail_setup "Codex $state turn failed"
  assert_gate codex "$state" "$log" "$last"
  assert_plan_exists "$project_dir"
}

run_claude_live_once() {
  local run_dir="$1"
  local project_dir="$run_dir/project" initial_log="$run_dir/initial.jsonl"
  local session_id state response log last
  mkdir -p "$project_dir/docs/superpowers"
  session_id="$(uuidgen | tr '[:upper:]' '[:lower:]')"

  run_claude_turn "$session_id" "$project_dir" "$(<"$FIXTURES_DIR/technical-request.md")" "$initial_log" || fail_setup "Claude initial turn failed"
  assert_claude_schema "$initial_log" || fail_setup "Claude initial stream JSON did not match the 2.1.181 schema"
  last="$run_dir/initial.txt"
  jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' "$initial_log" >"$last"
  assert_gate claude clarification-a "$initial_log" "$last"

  for state in clarification-a clarification-b-pending clarification-b clarification-c1 clarification-c2 approach-choice design-section-1 design-section-2; do
    response="$(next_fixture_response "$state")"
    log="$run_dir/${state}.jsonl"
    last="$run_dir/${state}.txt"
    resume_claude_turn "$session_id" "$project_dir" "$response" "$log" || fail_setup "Claude $state turn failed"
    jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' "$log" >"$last"
    assert_gate claude "$state" "$log" "$last"
    assert_no_artifacts "$project_dir" "$state"
  done

  state=complete-design
  log="$run_dir/${state}.jsonl"
  last="$run_dir/${state}.txt"
  resume_claude_turn "$session_id" "$project_dir" "$(next_fixture_response "$state")" "$log" || fail_setup "Claude $state turn failed"
  jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' "$log" >"$last"
  assert_gate claude "$state" "$log" "$last"
  assert_spec_exists "$project_dir"

  state=written-spec
  log="$run_dir/${state}.jsonl"
  last="$run_dir/${state}.txt"
  resume_claude_turn "$session_id" "$project_dir" "$(next_fixture_response "$state")" "$log" || fail_setup "Claude $state turn failed"
  jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' "$log" >"$last"
  assert_gate claude "$state" "$log" "$last"
  assert_no_plan "$project_dir"

  state=plan-decomposition
  log="$run_dir/${state}.jsonl"
  last="$run_dir/${state}.txt"
  resume_claude_turn "$session_id" "$project_dir" "$(next_fixture_response "$state")" "$log" || fail_setup "Claude $state turn failed"
  jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' "$log" >"$last"
  assert_gate claude "$state" "$log" "$last"
  assert_plan_exists "$project_dir"
}

run_codex_live() {
  local original_codex_home="${CODEX_HOME:-${HOME}/.codex}"
  CODEX_TEST_HOME="$OUTPUT_DIR/codex-home"
  export CODEX_TEST_HOME
  [[ -f "$original_codex_home/auth.json" ]] || fail_setup "Codex auth.json is unavailable"
  mkdir -p "$CODEX_TEST_HOME"
  install -m 0600 "$original_codex_home/auth.json" "$CODEX_TEST_HOME/auth.json"
  cleanup_codex_auth() { rm -f "$CODEX_TEST_HOME/auth.json"; }
  trap cleanup_codex_auth EXIT INT TERM

  CODEX_HOME="$CODEX_TEST_HOME" codex plugin marketplace add "$REPO_ROOT" --json >"$OUTPUT_DIR/codex-marketplace.json" || fail_setup "Codex marketplace setup failed"
  CODEX_HOME="$CODEX_TEST_HOME" codex plugin add superpowers@superpowers-dev --json >"$OUTPUT_DIR/codex-plugin.json" || fail_setup "Codex plugin setup failed"
  rm -f "$OUTPUT_DIR/codex-marketplace.json" "$OUTPUT_DIR/codex-plugin.json"

  local run
  for run in $(seq 1 "$RUNS"); do
    echo "Codex live run $run/$RUNS"
    run_codex_live_once "$OUTPUT_DIR/codex-run-$run"
  done
}

run_claude_live() {
  command -v uuidgen >/dev/null || fail_setup "uuidgen is unavailable"
  local run
  for run in $(seq 1 "$RUNS"); do
    echo "Claude live run $run/$RUNS"
    run_claude_live_once "$OUTPUT_DIR/claude-run-$run"
  done
}

mkdir -p "$OUTPUT_DIR"
echo "Output dir: $OUTPUT_DIR"

case "$MODE" in
  static) run_static ;;
  codex-live)
    command -v codex >/dev/null || fail_setup "codex is unavailable"
    command -v jq >/dev/null || fail_setup "jq is unavailable"
    run_codex_live
    ;;
  claude-live)
    command -v claude >/dev/null || fail_setup "claude is unavailable"
    command -v jq >/dev/null || fail_setup "jq is unavailable"
    run_claude_live
    ;;
esac

echo "PASS $MODE"
