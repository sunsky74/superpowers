---
name: three-pillars
description: Use when brainstorming has finished open exploration and must decide whether Three Pillars applies, choose the project type, ask structured clarification questions, or produce design output and draft acceptance criteria.
---

# Three Pillars

## Overview

This skill is this fork's standalone home for the Three Pillars inquiry framework, design output structure, and draft acceptance checklist. It keeps business-driven clarification rules separate from the upstream `brainstorming` skill so upstream changes can be merged while these fork-specific rules evolve independently.

Three Pillars means:

- **A. Overall business flow**
- **B. Current requirement flow**
- **C. Current requirement technical architecture**
  - **C1. Fit with the existing architecture**
  - **C2. New architecture enablement**

The Three Pillars are first a mandatory inquiry framework during brainstorming, then a design output structure.

## Trigger and Inputs

**Triggers:**

- `brainstorming` reaches the end of Checklist item 3, after open exploration and before clarification questions
- the user explicitly asks for `three pillars`, `business-flow-driven questions`, or structured business-flow inquiry

**Inputs:**

- the user's requirement notes collected during open exploration
- project-type context, used to choose the correct inquiry variant

**Outputs to brainstorming:**

- `Three Pillars applicability: yes/no/partial` plus rationale, written into the design header
- if `yes` or `partial`: results from the four inquiry angles, with at least one question per angle
- if `yes` or `partial`: the design's `Three Pillars` section and `Final Acceptance Checklist (Draft)` section

**Announce at start:** "I'm using the three-pillars skill to drive the structured inquiry and design output."

---

## 1. Applicability Decision

Make this decision explicitly after open exploration and before clarification. Output `Three Pillars applicability: yes/no/partial` plus rationale, and write it into the design header.

| Requirement type | Decision | Use the Three Pillars inquiry framework? | Produce the Three Pillars design section? |
|---|---|---|---|
| **Technical or coding work:** writing code, changing code, adding or modifying behavior, refactoring, performance work, middleware changes | `yes` | MUST use A -> B -> C1 -> C2 | MUST produce all four subsections |
| **No technical or coding work:** concept discussion, pure document writing, research exploration, design philosophy discussion | `no` | MAY skip | MAY skip, organize design as needed |
| **Boundary or mixed work:** adding examples to an SDK, discussing feasibility without implementation, mostly frontend with a small backend touch | `partial` | MUST use all four angles, but irrelevant angles may be compressed to one confirmation question | MUST produce the section, but irrelevant subsections may say "Not involved" with a reason |

**Hard constraints:**

- Do not downgrade a coding-related request to `no` to avoid Three Pillars.
- If the user explicitly says they do not want code and only want discussion, `no` is allowed, but record the reason in the design header.
- If uncertain, default to `yes`.
- A `no` decision is rechecked during brainstorming Self-Review with this question: "Will this requirement truly change zero lines of code?"

### Partial Handling Rules

- `partial` means the request mixes coding and non-coding work. Examples: SDK docs with code examples, a frontend component with a small backend endpoint, or a CLI integration script with configuration.
- Treat `partial` like `yes`: ask through A -> B -> C1 -> C2. If the user clearly says one angle is irrelevant, compress that angle into one confirmation question, such as "Confirm this requirement introduces no new infrastructure, correct?" Record the simplification in the design header.
- Do not use `partial` to avoid deep inquiry. If the coding portion is the majority of the work, use `yes`. If the coding portion is small, independent, and secondary, `partial` is reasonable.
- `partial` still MUST produce the Three Pillars section and Final Acceptance Checklist Draft. Irrelevant subsections may say "Not involved, because ..."

---

## 2. Project Type Branch

The Three Pillars skeleton applies to all project types, but the concrete questions differ. After the applicability decision and before asking the four-angle questions, decide the project type.

### 2.1 Project Type Decision

Use this decision tree:

```text
What is the main deliverable?
|- Business backend service: Java/Spring, Go, Python web service with DB, MQ, or cache
|  -> project type = business-backend
|- General server-side service: API gateway, gRPC service, microservice, BFF
|  -> project type = general-backend
|- Frontend component or app: React, Vue, Svelte, mobile
|  -> project type = frontend
|- CLI tool, SDK, or library
|  -> project type = cli-or-sdk
|- Data script, notebook, or pipeline
|  -> project type = data-pipeline
|- Configuration, documentation site, or pure docs
|  -> project type = config-or-docs
`- Other, mixed, or uncertain
   -> default to general-backend
```

Write the result into the design header:

```text
Project type: <type> - Rationale: ...
```

### 2.2 Project Type Question Templates

Use the `business-backend` template in section 4 as the baseline. For other project types, replace the concrete wording as follows while preserving the A -> B -> C1 -> C2 order.

#### general-backend

| Angle | business-backend wording | general-backend wording |
|---|---|---|
| A. Overall | business-flow position and business module interactions | service position, calls to existing services/APIs, upstream/downstream service boundaries |
| B. Current | business process loop | request-response loop, sync/async boundaries, error propagation path |
| C1. Fit | middleware inventory: MQ, cache, locks, search | infrastructure inventory: RPC framework, service discovery, config service, rate limiting, circuit breaking, tracing |
| C2. Enablement | middleware enablement: stability, concurrency, throughput | infrastructure enablement: observability, fault tolerance, elasticity |

#### frontend

| Angle | business-backend wording | frontend wording |
|---|---|---|
| A. Overall | business-flow position | user-scenario position: where this component/page sits in the overall user journey and how it navigates or exchanges data with existing pages/components |
| B. Current | business process loop | interaction loop: user action -> state change -> UI feedback -> side effect such as API call or route change; include loading, error, and empty states |
| C1. Fit | middleware inventory | frontend stack inventory: state management, build tool, UI library, API client, test framework; do they cover this requirement? |
| C2. Enablement | middleware enablement | new frontend capability enablement: state management, build plugin, animation library, Suspense, virtual list, code splitting, and what happens without it |

**Frontend special requirement:** replace controller/service/DAO language in the development architecture section with components/hooks/utils/stores/pages. If no backend middleware is involved, explicitly say so.

#### cli-or-sdk

| Angle | business-backend wording | cli-or-sdk wording |
|---|---|---|
| A. Overall | business-flow position | usage-scenario position: when the developer or end user uses this CLI/SDK and how it integrates with the existing toolchain |
| B. Current | business process loop | command invocation loop: entrypoint -> argument parsing -> core logic -> output/exit code; include errors, help text, compatibility |
| C1. Fit | middleware inventory | dependency inventory: core libraries, runtime requirements, platform compatibility; do they cover this requirement? |
| C2. Enablement | middleware enablement | new dependency enablement: concrete gains in performance, compatibility, or capability, compared with implementing it directly |

**CLI/SDK special requirement:** the development architecture section should use commands/options/handlers or exports/types/tests. If no dependency is introduced, explicitly say why.

#### data-pipeline

| Angle | business-backend wording | data-pipeline wording |
|---|---|---|
| A. Overall | business-flow position | data-flow position: where this script/notebook sits in the full data pipeline, upstream data sources, downstream consumers |
| B. Current | business process loop | processing loop: read -> clean/transform -> compute/aggregate -> output; include data volume, run frequency, retry/re-run strategy |
| C1. Fit | middleware inventory | compute-resource inventory: Pandas, Spark, Ray, DuckDB, storage, scheduler; do they cover this requirement? |
| C2. Enablement | middleware enablement | new tool enablement: concrete gains in performance, scale, or cost compared with the existing approach |

#### config-or-docs

Usually section 1 should decide `no` or `partial`. If it decides `partial`, use this simplified template:

| Angle | business-backend wording | config-or-docs wording |
|---|---|---|
| A. Overall | business-flow position | impact scope: which existing features or readers this configuration/doc change affects |
| B. Current | business process loop | change loop: what changes, why, and how to verify it through render/lint/link checks |
| C1. Fit | middleware inventory | usually not involved; explicitly state if not involved |
| C2. Enablement | middleware enablement | usually not involved; explicitly state if not involved |

### 2.3 Project Type Constraints

- MUST happen after section 1 and before section 4.
- Default to `general-backend` if uncertain.
- Write the result into the design header.
- Once the type is chosen, replace the section 4 question wording using section 2.2; the A -> B -> C1 -> C2 skeleton does not change.

---

## 3. Prompt Fragment for Brainstorming

```markdown
You are now entering the Three Pillars inquiry phase. First make two decisions:

1. **Applicability:** Does this requirement involve technical or coding work? Use yes / no / partial according to three-pillars section 1.
2. **Project type:** What is the main deliverable? Use business-backend / general-backend / frontend / cli-or-sdk / data-pipeline / config-or-docs according to three-pillars section 2.

After those decisions, ask clarification questions in section 4 order: A -> B -> C1 -> C2. Ask at least one question per angle. The user's answers flow into the design's Three Pillars section.
```

---

## 4. Three Pillars Inquiry Framework

This section is mandatory when section 1 decides `yes` or `partial`.

The following wording uses **business-backend** as the baseline. For other project types, replace the concrete terms using section 2.2.

The Three Pillars are not just an output template. They are the mandatory clarification framework. Questions MUST cover the following four angles in order, with at least one question per angle.

### Angle A - Overall Business Flow

**Purpose:** locate the current requirement inside the system's whole business picture.

For `business-backend`, clarify at least:

1. **Interactions:** Which existing business modules will this requirement exchange data with or call? Which modules are affected?
2. **Role:** Is this new capability, a replacement for existing capability, or a strengthening of one step in an existing capability?
3. **Upstream/downstream impact:** Who triggers it, under what condition, who consumes the result, and what follow-up action happens?

### Angle B - Current Requirement Flow

**Purpose:** understand this requirement's own closed-loop business flow.

For `business-backend`, clarify at least:

1. **Entry and trigger:** Where is it triggered from: user action, scheduled task, message, API? How many entrypoints?
2. **Key business steps:** Which steps cannot be skipped? Which steps are synchronous and which can be asynchronous?
3. **State and boundaries:** How does data/state change through the flow? What happens on exception branches and fallback paths?

### Angle C1 - Fit With Existing Technical Architecture

**Purpose:** determine whether the existing architecture is enough to implement this requirement and where the gaps are.

For `business-backend`, clarify at least:

1. **Existing middleware inventory:** Which middleware is already used: MQ, cache, distributed lock, search, batch, database features? Do they cover this scenario?
2. **Gap analysis:** Where is the existing architecture insufficient for concurrency, stability, throughput, or visibility? What must be added?
3. **Reuse vs. new build:** Reuse existing middleware where possible. If a new element is required, define its boundary with the existing architecture.

### Angle C2 - New Architecture Enablement

**Purpose:** determine the concrete business-flow benefit of any new technical architecture element and avoid adopting technology for its own sake.

For `business-backend`, clarify at least:

1. **Stability enablement:** How does the new element improve degradation, circuit breaking, idempotency, or retries?
2. **Concurrency/throughput enablement:** How does it improve concurrency or throughput through async processing, batching, caching, or load shaping?
3. **Observability enablement:** Does it improve tracing, metrics, or alerts?
4. **Necessity proof:** Each new technical element must answer: "What happens if we do not introduce this?"

### Inquiry Order and Constraints

1. After open exploration, MUST ask in A -> B -> C1 -> C2 order.
2. Ask at least one question per angle. Do not skip an angle because it seems simple.
3. User answers flow directly into the matching design subsection.
4. If the user cannot or will not answer an angle, mark that angle `Unclarified` and continue. Do not silently skip it.

---

## 5. Design Output Template

This section is mandatory when section 1 decides `yes` or `partial`.

The design document MUST contain these sections. Put the Three Pillars immediately after Goal. Put Final Acceptance Checklist Draft near the end.

### 5.1 Design Header

Put this near the beginning of the design:

```text
Three Pillars applicability: yes/no/partial - Rationale: ...
Project type: <type> - Rationale: ... (only when applicability is yes or partial)
```

### 5.2 Three Pillars Section

```markdown
## Three Pillars - MUST

### Overall Business Flow
[Where this requirement sits in the system and what role it plays. Do not only write "build feature X"; explain its relationship to the existing system. Source: Angle A answers.]

### Current Requirement Flow
[The requirement's own business flow from entry to exit, key state changes, and key participants. Use business language, not implementation steps. Source: Angle B answers.]

### Current Requirement Technical Architecture

#### Development Architecture
[Code organization and layers: controller/service/DAO for business-backend; components/hooks/utils/stores for frontend; commands/options/handlers for cli-or-sdk. Replace by project type using section 2.2. Be explicit about how code is organized.]

#### Technical Architecture
[Middleware, infrastructure, or dependencies introduced or reused. Replace by project type using section 2.2. Explain what problem they solve in the business flow: stability, concurrency, throughput, observability. Source: Angle C1 + C2 answers. If none are introduced, explicitly say "This requirement needs no new X, because ..."]
```

### 5.3 Final Acceptance Checklist Draft

```markdown
## Final Acceptance Checklist (Draft) - MUST

Each acceptance item MUST explicitly name its source. The source MUST point to one part of the Three Pillars:

- [AC-1] (Source: Overall Business Flow) Verify ... [expected result]
- [AC-2] (Source: Current Requirement Flow) Verify ... [expected result]
- [AC-3] (Source: Technical Architecture.Development Architecture) Verify ... [expected result]
- [AC-4] (Source: Technical Architecture.Technical Architecture) Verify ... [expected result]
```

**Hard constraints:**

- Every AC MUST have an explicit `Source`.
- Do not use vague sources such as `combined`, `overall`, or `general`.
- Every Three Pillars subsection must be covered by at least one AC.

---

## 6. Self-Review Additions

Append these checks after brainstorming's original Self-Review items:

- **#5 Applicability decision exists:** the design header has `Three Pillars applicability: yes/no/partial` plus rationale. Missing line means the decision was skipped.
- **#6 Project type decision exists:** when applicability is `yes` or `partial`, the design header has `Project type: <type>` plus rationale.
- **#7 Three Pillars completeness:** when applicability is `yes`, all four subsections are present and non-empty.
- **#8 AC traceability:** when applicability is `yes`, every AC has a clear source that points back to the Three Pillars.
- **#9 Coverage matrix:** when applicability is `yes`, every Three Pillars subsection is covered by at least one AC.
- **#10 Inquiry framework coverage:** when applicability is `yes`, A / B / C1 / C2 each had at least one question in the brainstorming conversation or notes; unanswered angles are explicitly marked `Unclarified`.
- **#11 Project type consistency:** when applicability is `yes` or `partial`, the questions and design content match the selected project type.

**Extra check for `no`:** re-evaluate whether the requirement will truly change zero lines of code. If it does involve code, change the decision to `yes` and complete Three Pillars.

---

## 7. Red Flags

These thoughts mean STOP; you are rationalizing:

| Thought | Reality |
|---|---|
| "Three Pillars is too much for this simple requirement." | Simple requirements can have very short Three Pillars, but if applicability is `yes`, they must exist. |
| "Writing-plans can figure out the overall flow later." | If brainstorming does not capture it, writing-plans has no source to refine. |
| "Acceptance checklist is writing-plans' job." | Brainstorming MUST produce a draft so writing-plans can refine it. |
| "There is no middleware, so the technical architecture section can be empty." | Explicitly say no new middleware/dependency/infrastructure is needed and why. Empty means unexamined. |
| "Three Pillars is only an output section; questions can follow the user's wording." | Three Pillars is first the inquiry framework. A -> B -> C1 -> C2 coverage is mandatory when applicability is `yes`. |
| "The user did not mention the overall business flow, so I won't ask." | Angle A is mandatory precisely because it is easy to miss. |
| "C1/C2 can wait until writing-plans." | Technical fit and enablement must be clarified during brainstorming, or the design is unsupported. |
| "This is discussion/docs, so I can mark `no` even though code is involved." | Coding work means `yes`. Downgrading to skip inquiry is a failure. |
| "I'm unsure whether Three Pillars applies." | Default to `yes`. |
| "This is frontend/CLI/data work, so middleware questions don't apply and I can skip Three Pillars." | Use the project-type template instead of skipping the skeleton. |
| "I'll just mark everything business-backend." | Project type changes the question content. Choose it honestly. |
| "`partial` means half the framework." | `partial` still uses all four angles; irrelevant angles may only be compressed to one confirmation question. |

---

## 8. Key Principles

- **Three Pillars is an inquiry framework, not just an output template.**
- **Project type changes the question content, not the A -> B -> C1 -> C2 skeleton.**
- **When uncertain, use the stricter path: applicability defaults to `yes`, project type defaults to `general-backend`.**
- **Traceability is mandatory: every AC must point back to the Three Pillars.**
- **Explicit beats implicit: if there is no middleware, dependency, or infrastructure change, say so and explain why.**
