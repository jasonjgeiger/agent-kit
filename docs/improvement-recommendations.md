# Agent Kit — Improvement Recommendations

> Analysis based on reverse-engineered Claude Code system prompts (v2.1.92, via [Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts)) cross-referenced against the current agent-kit inventory (31 skills, 15 agents, 4 prompts).

---

## Executive Summary

The agent-kit is already well-structured. Most improvements fall into three themes:

1. **Alignment with how Claude Code actually processes instructions** — the extracted prompts reveal specific patterns that Claude's architecture is optimized for
2. **Missing capabilities that Claude Code has built-in** — features worth replicating as skills/agents
3. **Structural optimizations** — ways to make existing skills/agents more effective

---

## 1. AGENTS.md — Core Instructions

### 1.1 Add Explicit Anti-Pattern Rules

Claude Code's "doing tasks" rules are terse, negative statements naming *specific bad behaviors*. This is the single most effective steering technique in the extracted prompts. Your AGENTS.md has good cultural norms but lacks these surgical behavioral constraints.

**Add to AGENTS.md:**

```markdown
## Code Change Discipline

- Do not propose changes to code you haven't read. Read first, then modify.
- Do not add features, refactor code, or make "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up.
- Do not add docstrings, comments, or type annotations to code you didn't change.
- Do not create helpers, utilities, or abstractions for one-time operations. Three similar lines is better than a premature abstraction.
- Do not add error handling for scenarios that can't happen. Only validate at system boundaries.
- Delete unused code completely. No renaming to `_var`, re-exporting types, or `// removed` comments.
- Prefer editing existing files over creating new ones.
```

**Why:** These rules are the most impactful part of Claude Code's prompt. They prevent the most common LLM failure modes — over-engineering, scope creep, and speculative additions. Without them, agents default to being "helpful" in ways that bloat codebases.

### 1.2 Add Output Efficiency Rules

Claude Code has a dedicated "output efficiency" prompt that's remarkably effective. Your custom instruction says "Be real" and "Maintain a pragmatic outlook" but doesn't specify output format.

**Add to AGENTS.md:**

```markdown
## Output

- Go straight to the point. Lead with the answer or action, not the reasoning.
- Skip filler, preamble, and transitions. Do not restate what I said.
- Focus on: decisions needing input, high-level status at milestones, errors or blockers.
- If you can say it in one sentence, don't use three.
- This does NOT apply to code, tool calls, or architecture documents — those should be complete.
```

**Why:** The scoped exemption ("does NOT apply to code") is critical — it prevents agents from truncating implementations while keeping conversational responses tight.

### 1.3 Add Tool Precedence Hierarchy

Claude Code defines a strict hierarchy: dedicated tools > bash, direct search > subagent. Your agents have this implicitly but it's not in AGENTS.md.

**Add to AGENTS.md:**

```markdown
## Tool Usage

- Prefer dedicated tools (Read, Edit, Grep, Glob) over Bash equivalents (cat, sed, grep, find).
- For simple searches: use grep/glob directly.
- For deep research requiring synthesis: use explore/investigate agents.
- Reserve Bash for operations that genuinely require shell execution.
```

### 1.4 Strengthen the Security Section

Claude Code has 20+ specific block rules. Your AGENTS.md has no security guidance. While the AI tools have their own guardrails, explicit reminders improve compliance in autonomous scenarios.

**Add to AGENTS.md:**

```markdown
## Security

- Never introduce command injection, XSS, SQL injection, or other OWASP top 10 vulnerabilities.
- Never force push, delete remote branches, or reset shared history without explicit confirmation.
- Never skip pre-commit hooks (--no-verify) unless explicitly asked.
- Never commit secrets, credentials, or API keys.
- Never download and execute remote code (curl | bash patterns) without review.
```

---

## 2. Agent Improvements

### 2.1 Developer Agent — Add "Doing Tasks" Discipline

Your `developer` and `developer-mini` agents emphasize TDD and SOLID but lack the anti-pattern rules. Claude Code's most effective technique is naming what NOT to do.

**Add to `agents/developer.md` and `agents/developer-mini.md`:**

```markdown
## Change Discipline

- Read before modifying. Never propose changes to code you haven't read.
- Do only what was asked. No bonus refactoring, comments, or improvements.
- No premature abstractions. Three similar lines > a one-use helper.
- No speculative error handling. Only validate at system boundaries.
- Delete completely. No `_unused` renames or `// removed` comments.
- Minimize file creation. Prefer editing existing files.
```

**Why:** Even with TDD guidance, the most common failure mode is scope creep — agents "improving" code around the change.

### 2.2 Reviewer Agent — Add Confidence Scoring

Your reviewer already filters at 75+ confidence, which aligns well with Claude Code's approach. Consider adding explicit false-positive guidance from Claude Code's code review agent:

**Add to `agents/reviewer.md`:**

```markdown
## Anti-Hallucination Rules

- If you're not sure whether code is actually reachable, don't flag it.
- If a pattern looks wrong but tests pass and there's git blame showing deliberate authorship, leave it.
- Never flag something as a "potential issue" — either it IS an issue with a concrete scenario, or skip it.
```

### 2.3 New Agent: Verification Specialist

Claude Code has a dedicated adversarial verification agent that's distinct from testing. Your `developer` agent runs tests, but there's no agent that *verifies runtime behavior*.

**Create `agents/verifier.md`:**

```markdown
---
name: verifier
description: Verify that a code change actually does what it claims. Runtime verification only — don't run existing tests.
model: sonnet
color: orange
---

# Verification Specialist

You are Claude, and you are bad at verification. You read code and write PASS instead of running it. You're easily fooled by AI-generated code that looks correct. Fight this instinct.

## Rules

- Do NOT run the project's test suite. CI already did that.
- Do NOT import-and-call functions. That's a unit test, not verification.
- DO verify by actually running the surface area:
  - CLI tool → execute it in terminal with real args
  - API endpoint → curl/httpie with real payloads
  - UI change → Playwright screenshot or manual inspection
  - Library → public import from a scratch script
- Every finding is a structured verdict: PASS / FAIL / BLOCKED / SKIP
- BLOCKED means you can't verify (no server running, missing credentials). Say what's needed.
- SKIP means it's not worth verifying (docs-only change, config tweak).

## Verdict Format

| Check | Verdict | Evidence |
|-------|---------|----------|
| [what] | PASS/FAIL/BLOCKED/SKIP | [what you actually ran and saw] |
```

**Why:** This is one of the most novel patterns in Claude Code — an agent explicitly told it's *bad at its job* to force adversarial thinking. This combats the model's tendency to hallucinate success.

### 2.4 New Agent: Debugger

You have `dotnet-debugging` skill but no general-purpose debugger agent. Claude Code's approach emphasizes systematic methodology.

**Create `agents/debugger.md`:**

```markdown
---
name: debugger
description: Systematic debugging — reproduce, isolate, hypothesize, and fix bugs including runtime errors, memory issues, concurrency problems, and stack traces.
model: opus
color: red
---

# Debugger

Systematic debugging specialist. Reproduce → Isolate → Hypothesize → Fix.

## Methodology

1. **Reproduce** — Get the exact failure. Run it. See the error. If you can't reproduce, say so.
2. **Isolate** — Binary search the problem space. Remove code, add logging, narrow scope.
3. **Hypothesize** — Form a specific, falsifiable theory. "I think X fails because Y when Z."
4. **Test the hypothesis** — Run a targeted experiment that proves or disproves it.
5. **Fix** — Minimum change. Add a regression test.

## Rules

- Never guess. If you don't have enough information, say what you need.
- Read the actual stack trace / error output. Don't assume you know what it says.
- Check git blame — was this code recently changed? By whom? Why?
- If the bug is in a dependency, say so. Don't work around it silently.
```

---

## 3. Skill Improvements

### 3.1 Programming Skill — Add Anti-Pattern Rules

Your `programming` skill references modes (pair-programmer, code-reviewer, etc.) but would benefit from the specific "doing tasks" behavioral rules.

**Add to `skills/programming/SKILL.md`:**

```markdown
## Code Discipline (Always Active)

- Read before modifying.
- Do only what was asked — no bonus refactoring.
- No premature abstractions.
- No speculative error handling.
- Delete unused code completely.
- Minimize file creation.
```

### 3.2 Subagent-Driven Development — Add Prompt Writing Guidance

Claude Code has specific guidance on how to write subagent prompts that your `subagent-driven-development` skill should adopt:

**Add to `skills/subagent-driven-development/SKILL.md`:**

```markdown
## Writing Subagent Prompts

Brief the agent like a smart colleague who just walked into the room:
- Explain what you're trying to accomplish and **why**
- Describe what you've already learned or ruled out
- Give enough context that the agent can make judgment calls
- Include file paths, line numbers, and what specifically needs to change

**Never delegate understanding.** Don't write "based on your findings, fix the bug." Write prompts that prove YOU understood the problem:

❌ "Fix the authentication bug in the user module"
✅ "In src/auth/session.ts:47, the token refresh logic calls refreshToken() but doesn't await the result, causing a race condition where the old token is used for the next request. Change line 47 to `const newToken = await refreshToken()` and update the subsequent usage on line 52."
```

### 3.3 New Skill: Simplify (Code Cleanup)

Claude Code has a `/simplify` skill that's one of the most-used built-in features. It launches 3 parallel agents for different perspectives.

**Create `skills/simplify/SKILL.md`:**

```yaml
---
name: simplify
description: Review code for unnecessary complexity, unused patterns, and simplification opportunities. Launches parallel reviewers for code reuse, quality, and efficiency.
---
```

```markdown
# Simplify

Launch three parallel review agents against the target files:

## Agent 1: Code Reuse Review
- Search the codebase for existing utilities that do what new code does manually
- Find duplicate logic across files
- Identify patterns that should use existing framework features

## Agent 2: Code Quality Review
Check for these 7 anti-patterns:
1. **Redundant state** — derived values stored separately from source of truth
2. **Parameter sprawl** — functions with 4+ parameters that should be an object/config
3. **Copy-paste code** — near-identical blocks across files
4. **Leaky abstractions** — callers need to know implementation details
5. **Stringly-typed code** — string constants where enums/types belong
6. **Unnecessary nesting** — deep if/else or JSX trees that could be flattened
7. **Unnecessary comments** — comments restating what the code already says

## Agent 3: Efficiency Review
Check for:
1. **Unnecessary work** — computation whose result is discarded or overwritten
2. **Missed concurrency** — sequential I/O that could be parallel
3. **Hot-path bloat** — expensive operations in frequently-called paths
4. **Recurring no-op updates** — state updates that set the same value
5. **Memory leaks** — subscriptions/listeners without cleanup
6. **Overly broad operations** — fetching/processing more data than needed

## Output
Merge findings, deduplicate, and present in priority order.
```

### 3.4 New Skill: Verify (Runtime Verification)

Companion to the verifier agent above, as a slash command:

**Create `skills/verify/SKILL.md`:**

```yaml
---
name: verify
description: Verify that a code change actually works by running it, not by reading it. Launches a verification agent with adversarial self-awareness.
---
```

```markdown
# Verify

Spawn a verifier agent against the most recent changes. 

## Rules for the verifier:
- Don't run tests. Don't typecheck. CI did that.
- Don't import-and-call. That's a unit test.
- DO exercise the actual surface: CLI → terminal, API → curl, UI → screenshot.
- Every check gets a verdict: PASS / FAIL / BLOCKED / SKIP with evidence.
```

### 3.5 Git Workflow Skill — Add PR Safety Rules

Claude Code has extensive git safety rules. Your git-workflow skill covers workflows well but could strengthen safety:

**Add to `skills/git-workflow/SKILL.md`:**

```markdown
## Safety Rules (Always Active)

- Never force push to main/master/release branches without explicit confirmation
- Never delete remote branches without confirmation
- Never skip hooks (--no-verify) unless explicitly asked
- Prefer creating new commits over amending shared commits
- Before any destructive operation: state what will happen and ask for confirmation
```

---

## 4. Structural Recommendations

### 4.1 Add Success Criteria to Skill Steps

Claude Code's skill system requires every step to have explicit success criteria. Many of your skills describe *what to do* but not *how to know it's done*.

**Pattern to adopt in all skills:**

```markdown
## Step 3: Implement the change
- **Action:** Edit the target files per the plan
- **Success:** All target tests pass. No new lint warnings. `git diff` shows only intended changes.
- **Failure:** If tests fail, debug before proceeding. If unrelated tests fail, investigate.
```

### 4.2 Add Scoped Applicability to Rules

Claude Code's conciseness rule has an important exemption: "This does not apply to code or tool calls." This prevents the model from being terse where thoroughness matters.

**Apply this pattern across your system:**
- "Be concise" rules should exempt code output, architecture docs, and test implementations
- "Push back" rules should exempt cases where the user has already provided evidence
- "Read before coding" rules should exempt trivial changes (typo fixes, config tweaks)

### 4.3 Consider Atomic Prompt Fragments

Claude Code uses 252 separate small files rather than a few large system prompts. Benefits:
- Conditional inclusion based on mode/context
- Easier to version and test individual rules
- Cache-friendly (modify one piece without invalidating all)

**This is a long-term architecture consideration, not an immediate action.** Your current monolithic SKILL.md approach works well for readability and maintainability. But if you find skills getting complex or want tool-specific conditional inclusion, consider splitting into composable fragments.

### 4.4 Consider a Structured Compaction Template

Claude Code has a 9-section compaction summary format. When context windows fill up, having a structured template for what to preserve is valuable.

**Create `docs/compaction-template.md`:**

```markdown
# Compaction Template

When summarizing a long session, preserve these sections in order:

1. **Primary Request** — What the user originally asked for
2. **Current State** — Where we are right now in the work
3. **Key Decisions Made** — Architectural and design choices with rationale
4. **Files Modified** — Paths and what changed in each
5. **Errors Encountered** — What went wrong and how it was resolved
6. **Pending Tasks** — What still needs to be done
7. **Context to Preserve** — Specific details that would be expensive to re-discover
```

---

## 5. What You Already Do Well

These patterns in your agent-kit already align with Claude Code best practices:

- ✅ **Agent specialization** — Your 15 agents cover distinct roles (developer, reviewer, architect, etc.)
- ✅ **Read-only enforcement** — Reviewer, security-auditor, performance-engineer, code-flow-analyzer all explicitly state they don't modify code
- ✅ **Confidence scoring** — Reviewer filters at 75+ confidence
- ✅ **Conventional commits** — Consistent across AGENTS.md and git-workflow
- ✅ **Skill routing** — The dotnet skill chain (using-dotnet → dotnet-advisor → domain skill) is excellent progressive disclosure
- ✅ **Reference architecture** — Skills reference external docs via `references/` rather than inlining everything
- ✅ **Parallel review** — codebase-reviewer dispatches across multiple engines
- ✅ **Tool-agnostic linking** — ai-agent-links.json targets Claude, Codex, and Copilot

---

## Priority Order

| Priority | Change | Effort | Impact |
|----------|--------|--------|--------|
| 1 | Add anti-pattern rules to AGENTS.md (§1.1) | Low | High |
| 2 | Add output efficiency rules (§1.2) | Low | High |
| 3 | Add change discipline to developer agents (§2.1) | Low | High |
| 4 | Add security rules to AGENTS.md (§1.4) | Low | Medium |
| 5 | Create verifier agent (§2.3) | Medium | High |
| 6 | Add subagent prompt guidance (§3.2) | Low | Medium |
| 7 | Create simplify skill (§3.3) | Medium | Medium |
| 8 | Add success criteria to skills (§4.1) | Medium | Medium |
| 9 | Add tool precedence (§1.3) | Low | Low |
| 10 | Create debugger agent (§2.4) | Medium | Medium |
| 11 | Git safety rules (§3.5) | Low | Low |
| 12 | Compaction template (§4.4) | Low | Low |

---

*Generated 2026-04-04. Based on Claude Code v2.1.92 system prompts and agent-kit inventory.*
