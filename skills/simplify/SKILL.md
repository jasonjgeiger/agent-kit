---
name: simplify
description: Review code for unnecessary complexity, unused patterns, and simplification opportunities. Launches parallel reviewers for code reuse, quality, and efficiency.
---

# Simplify

Review target code from three perspectives in parallel. Merge findings, deduplicate, and present in priority order.

## Agent 1: Code Reuse Review

- Search the codebase for existing utilities that do what new code does manually.
- Find duplicate logic across files.
- Identify patterns that should use existing framework/library features.
- Check if there's a project utility or helper that already solves this.

## Agent 2: Code Quality Review

Check for these 7 anti-patterns:

1. **Redundant state** — derived values stored separately from source of truth.
2. **Parameter sprawl** — functions with 4+ parameters that should be an object/config.
3. **Copy-paste code** — near-identical blocks across files.
4. **Leaky abstractions** — callers need to know implementation details.
5. **Stringly-typed code** — string constants where enums/types belong.
6. **Unnecessary nesting** — deep if/else or component trees that could be flattened.
7. **Unnecessary comments** — comments restating what the code already says.

## Agent 3: Efficiency Review

Check for:

1. **Unnecessary work** — computation whose result is discarded or overwritten.
2. **Missed concurrency** — sequential I/O that could be parallel.
3. **Hot-path bloat** — expensive operations in frequently-called paths.
4. **Recurring no-op updates** — state updates that set the same value.
5. **TOCTOU issues** — time-of-check/time-of-use gaps in conditional logic.
6. **Memory leaks** — subscriptions/listeners/handles without cleanup.
7. **Overly broad operations** — fetching/processing more data than needed.

## Output Format

### Simplification Report

**Scope:** `<files/directories reviewed>`

Found N simplification opportunities:

1. **[Category] <description>**
   File: `path/to/file` lines X-Y
   ```
   <current code>
   ```
   **Suggestion:** <what to change and why>
   **Impact:** High / Medium / Low

If nothing found: "Code is clean — no significant simplification opportunities."
