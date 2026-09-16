---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by classifying how much process the request needs, then work
through your path: understand the context, refine the idea, present a
design, and get your human partner's approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any
project, or take any implementation action until you have told your
human partner what you intend and they have approved it. This applies
to EVERY task on EVERY path below — the ceremony scales with the task;
the approval gate never does.
</HARD-GATE>

## Three Paths

Before your first question, classify the request and say the
classification out loud — "this looks bounded, so I'll present a short
design here rather than write a spec" — so your human partner can
override it:

- **Spike** — a feasibility question ("can we...", "is it possible...",
  "quick and dirty is fine") whose output is an answer, not code you
  keep. Present the question and what you'll try in 2-3 sentences, get
  a nod, then find out as cheaply as correctness allows. No design
  doc, no spec file. Report findings as a recommendation; anything you
  built stays labeled throwaway.
- **Bounded** — a well-scoped change to code that already exists in
  this repo: a new flag, a small endpoint, a one-file fix.
  Understanding the kind of app is not enough — bounded means the flow
  you are changing is already here to read. If there is no existing
  flow to change, the task is not bounded. Ask the clarifying
  questions that matter, present a short design IN CHAT (a few
  sentences to a few short paragraphs), and STOP. Implementation
  starts only after your human partner says yes to that design — a
  bounded task's approval is as hard a gate as an architectural
  one. No spec file, no implementation plan document.
- **Architectural** — new projects, new subsystems, changes that
  restructure how components fit together or alter interfaces others
  depend on. Follow the full process: questions, approaches, sectioned
  design, written spec, then the writing-plans skill.

When in doubt between two paths, take the heavier one. The ratchet is
one-way: hidden complexity discovered mid-task upgrades the path —
stop, say so, and step up. Nothing downgrades mid-task.

## Anti-Pattern: "Too Simple To Need Approval"

Every path ends with your human partner approving your intent before
implementation. A todo list, a single-function utility, a config
change — the design may be two sentences in chat, but you MUST present
it and get approval. "Simple" tasks are where unexamined assumptions
cause the most wasted work. What scales with simplicity is the
artifact, never the approval.

## Red Flags

| Thought | Reality |
|---------|---------|
| "This is too simple to need a design" | Simple means a short design, not no design. Two sentences in chat, then approval. |
| "I'll call it bounded and skip the spec" | Reaching for a label to skip work IS the doubt — take the heavier path. |
| "It's bounded and the design is obvious — I'll start while they read it" | The gate is the approval, not the design's length. Present, then stop until you hear yes. |
| "I understand this kind of app, so it's bounded" | Bounded measures the repo, not your familiarity. A new project has no existing flow — it is architectural. |
| "The spike works, so I'll keep the code" | A spike's output is an answer. Keeping the code is a new request — classify it. |
| "It grew, but I'm almost done — no need to re-classify" | Hidden complexity upgrades the path mid-task. Stop and say so. |
| "They approved the spike, so the follow-up change is approved too" | Each task gets its own classification and its own approval. |

> **FORK TRIGGER:** Three Pillars Red Flags live in `superpowers:three-pillars` section 7. After this skill triggers Three Pillars, MUST follow that Red Flags table.

## Checklist

Classify first, announce the path, then create a task for each item on
your path and complete them in order. Every item that requires the user
applies `USER-INPUT-GATE`: ask exactly one decision question as the
final response, then end the turn.

**Spike:**
1. **Explore project context** — enough to frame the probe
2. **Present question + probe plan** — 2-3 sentences
3. **Get approval** — a nod is enough
4. **Investigate** — as cheaply as correctness allows
5. **Report findings** — a recommendation; label anything built as throwaway

**Bounded:**
1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, the ones that matter
3. **Present short design in chat** — approach, files touched, testing
4. **Get approval** — STOP and wait for an explicit yes; presenting the design and starting in the same breath is skipping the gate
5. **Implement** — proceed with the normal development workflow (TDD applies); no plan document

**Architectural:**
1. **Explore project context** — check files, docs, recent commits
2. **Offer the visual companion just-in-time** — NOT upfront. The first time a question would genuinely be clearer shown than described, offer it then (its own message); on approval its browser tab opens for you. If no visual question ever arises, never offer it. See the Visual Companion section below.
3. **Clarification** — ask one question, apply `USER-INPUT-GATE`, and remain
   here until the required information is answered or explicitly skipped

   > **FORK TRIGGER:** After open exploration and before clarification questions, **MUST** use `superpowers:three-pillars` to decide Three Pillars applicability and project type. If applicability is `yes` or `partial`, use its section 4 A -> B -> C1 -> C2 inquiry framework for follow-up questions and its section 5 templates for the design's `Three Pillars` and `Final Acceptance Checklist (Draft)` sections. If applicability is `no`, it may be skipped. See `skills/three-pillars/SKILL.md`.

4. **Approach Choice** — present 2-3 approaches and your recommendation, then
   apply `USER-INPUT-GATE`; your recommendation does not select an approach
5. **Design Sections** — present one coherent section per turn and apply
   `USER-INPUT-GATE` after each section
6. **Complete Design** — after all sections are approved, present the
   consolidated design and apply `USER-INPUT-GATE` for separate approval
7. **Spec Write** — only after complete-design approval, write, self-review,
   and commit the spec
8. **Written Spec Review** — ask the user to review the written file and apply
   `USER-INPUT-GATE`
9. **Planning** — invoke writing-plans only after written-spec approval

Use these state names when tracking the workflow: `clarification-a`,
`clarification-b`, `clarification-c1`, `clarification-c2`, `approach-choice`,
`design-section`, `complete-design`, `spec-write`, `written-spec`, and
`planning`. Do not advance a state without its stated transition condition.

## Process Flow

```dot
digraph brainstorming {
    "Classify: spike / bounded / architectural" [shape=diamond];
    "Present question + probe (2-3 sentences)" [shape=box];
    "Ask clarifying questions (bounded)" [shape=box];
    "Present short design in chat" [shape=box];
    "Human approves?" [shape=diamond];
    "Investigate; report recommendation" [shape=doublecircle];
    "Implement via normal workflow (no plan doc)" [shape=doublecircle];
    "Explore project context" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Clarification answered or explicitly skipped?" [shape=diamond];
    "Propose 2-3 approaches" [shape=box];
    "User selects approach?" [shape=diamond];
    "Present design sections" [shape=box];
    "User approves this section?" [shape=diamond];
    "All sections approved?" [shape=diamond];
    "Present consolidated design" [shape=box];
    "User approves complete design?" [shape=diamond];
    "Write design doc" [shape=box];
    "Spec self-review\n(fix inline)" [shape=box];
    "User approves written spec?" [shape=diamond];
    "Invoke writing-plans skill" [shape=doublecircle];
    "Hidden complexity? Upgrade path" [shape=box];

    "Classify: spike / bounded / architectural" -> "Present question + probe (2-3 sentences)" [label="spike"];
    "Classify: spike / bounded / architectural" -> "Ask clarifying questions (bounded)" [label="bounded"];
    "Classify: spike / bounded / architectural" -> "Explore project context" [label="architectural"];
    "Present question + probe (2-3 sentences)" -> "Human approves?";
    "Ask clarifying questions (bounded)" -> "Present short design in chat";
    "Present short design in chat" -> "Human approves?";
    "Human approves?" -> "Investigate; report recommendation" [label="spike: yes"];
    "Human approves?" -> "Implement via normal workflow (no plan doc)" [label="bounded: yes"];
    "Hidden complexity? Upgrade path" -> "Classify: spike / bounded / architectural";
    "Explore project context" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Clarification answered or explicitly skipped?";
    "Clarification answered or explicitly skipped?" -> "Ask clarifying questions" [label="no or more needed"];
    "Clarification answered or explicitly skipped?" -> "Propose 2-3 approaches" [label="all complete"];
    "Propose 2-3 approaches" -> "User selects approach?";
    "User selects approach?" -> "Propose 2-3 approaches" [label="no"];
    "User selects approach?" -> "Present design sections" [label="yes"];
    "Present design sections" -> "User approves this section?";
    "User approves this section?" -> "Present design sections" [label="revise"];
    "User approves this section?" -> "All sections approved?" [label="yes"];
    "All sections approved?" -> "Present design sections" [label="no"];
    "All sections approved?" -> "Present consolidated design" [label="yes"];
    "Present consolidated design" -> "User approves complete design?";
    "User approves complete design?" -> "Present design sections" [label="no, revise"];
    "User approves complete design?" -> "Write design doc" [label="yes"];
    "Write design doc" -> "Spec self-review\n(fix inline)";
    "Spec self-review\n(fix inline)" -> "User approves written spec?";
    "User approves written spec?" -> "Write design doc" [label="changes requested"];
    "User approves written spec?" -> "Invoke writing-plans skill" [label="approved"];
}
```

**Terminal states are path-bound.** Architectural: the ONLY skill you
invoke after brainstorming is writing-plans — never frontend-design,
mcp-builder, or any other implementation skill. Bounded: after
approval, implementation proceeds directly through the normal
development workflow; no plan document. Spike: the terminal state is a
reported recommendation.

## The Process

The subsections below serve the bounded and architectural paths (a
spike stops at "present the probe, get a nod"). Sections from
**Exploring approaches** onward are architectural-path depth — for
bounded work, context plus a few questions plus a short in-chat design
is the whole process.

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → plan → implementation cycle.
- For appropriately-scoped projects, ask exactly one clarification question per
  turn, then apply `USER-INPUT-GATE`
- Prefer multiple choice questions when possible, but open-ended is fine too
- Do not include approaches or design content in a clarification turn
- If a response is ambiguous or unrelated, keep the same clarification pending
  and ask one focused follow-up; silence never counts as an answer or skip
- Focus on understanding: purpose, constraints, success criteria

> **FORK TRIGGER:** The Three Pillars inquiry framework (A -> B -> C1 -> C2) and design output templates (`Three Pillars` + `Final Acceptance Checklist Draft`) live in `superpowers:three-pillars`. After this skill triggers it in Checklist item 3, ask according to its section 4 and produce design sections according to its section 5. The upstream `Exploring approaches` and `Presenting the design` flow continues below.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why
- YAGNI ruthlessly - remove unnecessary features from every approach and design
- Presenting a recommendation does not select it. Ask the user to choose, apply
  `USER-INPUT-GATE`, and do not begin the design until they respond.

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Present one coherent section per turn, then apply `USER-INPUT-GATE`
- Approval applies only to the currently pending section
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense
- After the last section is approved, present the consolidated design and apply
  `USER-INPUT-GATE` for complete-design approval in a separate turn
- Approval of the last section does not approve the complete design
- Complete-design approval authorizes writing and committing the spec, not
  writing the implementation plan

> **FORK TRIGGER:** Design output templates for the header, `Three Pillars`, and `Final Acceptance Checklist Draft` live in `superpowers:three-pillars` section 5. When writing the design document, structure those sections using that template.

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier for you to work with - you reason better about code you can hold in context at once, and your edits are more reliable when files are focused. When a file grows large, that's often a signal that it's doing too much.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design - the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## After the Design (architectural path)

**Documentation:**

- Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
  - (User preferences for spec location override this default)
- Use elements-of-style:writing-clearly-and-concisely skill if available
- Commit the design document to git

**Spec Self-Review:**
After writing the spec document, look at it with fresh eyes:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** If an ambiguity would change behavior, scope,
   architecture, or an approved decision, return to Clarification and apply
   `USER-INPUT-GATE`. Fix only editorial ambiguity that preserves the approved
   meaning without another approval.

> **FORK TRIGGER:** Three Pillars Self-Review additions (#5-#11: applicability decision, project type decision, Three Pillars completeness, AC traceability, coverage matrix, inquiry framework coverage, project type consistency) live in `superpowers:three-pillars` section 6. During Self-Review, if Checklist item 3 triggered Three Pillars with `yes` or `partial`, MUST append those checks.

Fix any issues inline. No need to re-review — just fix and move on.

**User Review Gate:**
After the spec review loop passes, ask the user to review the written spec before proceeding:

> "Spec written and committed to `<path>`. Do you approve this written spec so I can start writing the implementation plan?"

Apply `USER-INPUT-GATE` and wait for the user's response. If they request
changes, make them, re-run the spec review loop, and request written-spec
approval again. Only explicit approval of the written spec authorizes
writing-plans. Complete-design approval or approval of a design section does
not satisfy this gate.

**Implementation:**

- Invoke the writing-plans skill to create a detailed implementation plan
- Do NOT invoke any other skill. writing-plans is the next step.

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming. Available as a tool — not a mode. Accepting the companion means it's available for questions that benefit from visual treatment; it does NOT mean every question goes through the browser.

**Offering the companion (just-in-time):** Do NOT offer it upfront. Wait until a question would genuinely be clearer shown than told — a real mockup / layout / diagram question, not merely a UI *topic*. The first time that happens, offer it then, as its own message:
> "This next part might be easier if I show you — I can put together mockups, diagrams, and comparisons in a browser tab as we go. It's still new and can be token-intensive. Want me to? I'll open it for you."

**This offer MUST be its own message.** Only the offer — no clarifying question, summary, or other content. Wait for the user's response. If they accept, start the server with `--open` so their browser opens to the first screen automatically. If they decline, continue text-only and don't offer again unless they raise it.

**Per-question decision:** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or the terminal. The test: **would the user understand this better by seeing it than reading it?**

- **Use the browser** for content that IS visual — mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use the terminal** for content that is text — requirements questions, conceptual choices, tradeoff lists, A/B/C/D text options, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" is a conceptual question — use the terminal. "Which wizard layout works better?" is a visual question — use the browser.

If they agree to the companion, read the detailed guide before proceeding:
`skills/brainstorming/visual-companion.md`
