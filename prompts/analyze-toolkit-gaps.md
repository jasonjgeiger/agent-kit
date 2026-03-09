---
name: analyze-toolkit-gaps
description: Analyze session history and workstreams to identify what custom agents, skills, and prompts to build. Use when asked to "analyze my sessions", "what skills do I need", "toolkit gaps", or "audit my workflow".
arguments:
  - name: FOCUS
    type: string
    description: Optional focus area to narrow analysis (e.g., "WinUI work", "frontend", "backend APIs"). If omitted, analyzes all workstreams.
---

Spawn a **researcher** agent to analyze session history, then produce a concrete build-or-adopt plan for new agents, skills, and prompts.

**Focus:** $FOCUS

## Phase 1: Session Analysis

1. Read session transcripts, LEARNINGS.md files, and conversation logs from `~/.copilot/`, `~/.claude/`, and `~/.codex/`.
2. Cluster work into recurring **workstreams** — groups of related tasks that repeat across sessions.
3. For each workstream, calculate rough frequency (what % of sessions involve it) and identify the **workflow shape** — the repeating sequence of steps (e.g., "capture screenshot → audit → fix → verify", "read docs → install → wrapper → DI → test").
4. Rank workstreams by frequency and effort — the ones that consume the most time and repeat the most are the best candidates for automation.

## Phase 2: Gap Analysis

For each high-value workstream:

1. **Check existing toolkit.** Search the current agents (`agents/*.md`), skills (`skills/*/SKILL.md`), and prompts (`prompts/*.md`) for coverage. Does an existing agent/skill already handle this workstream well?
2. **Search for community options.** Web search for publicly available skills, agents, or open-source tooling that covers this workstream. Check GitHub stars, recent activity, and actual coverage depth.
3. **Classify each gap:**
   - **Covered** — existing toolkit handles it, no action needed
   - **Adopt** — a community skill/agent exists and covers the need well enough to use directly
   - **Extend** — an existing skill/agent partially covers it but needs additions
   - **Build** — nothing exists, needs a custom skill/agent/prompt

## Phase 3: Build Plan

For each gap classified as Adopt, Extend, or Build, produce a concrete deliverable spec:

| Field           | Description                                                |
| --------------- | ---------------------------------------------------------- |
| **Deliverable** | What to create (skill, agent, prompt, or extension)        |
| **Type**        | `skill` / `agent` / `prompt` / `extension`                 |
| **Name**        | Proposed name following existing conventions               |
| **Trigger**     | What user requests should activate it                      |
| **Workflow**    | Numbered steps the skill/agent follows                     |
| **References**  | Documentation/community resources to ground it             |
| **Complements** | Existing toolkit items it works alongside (not duplicates) |
| **Effort**      | S/M/L estimate                                             |

## Output Format

```markdown
## Session Analysis

### Workstreams (ranked by frequency × effort)

1. **[Name]** — [frequency]% of sessions, [workflow shape summary]
2. ...

### Existing Coverage

- [What's already covered and by which agent/skill]

## Gap Analysis

| Workstream | Current coverage | Community options | Decision                         |
| ---------- | ---------------- | ----------------- | -------------------------------- |
| ...        | ...              | ...               | Covered / Adopt / Extend / Build |

## Build Plan

### 1. [Deliverable name]

[Spec table from above]

### 2. ...

## Implementation Order

[Ordered list with dependencies noted]
```

## Rules

- Do not propose duplicating existing skills — complement them
- Prefer extending existing skills over creating new ones when the gap is small
- Every "Build" recommendation must cite why no community option works
- Keep the plan actionable — each deliverable should be implementable in one session
- Note which deliverables can be built in parallel vs. which have dependencies
