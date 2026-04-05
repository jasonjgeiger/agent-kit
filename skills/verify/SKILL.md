---
name: verify
description: Verify that a code change actually works by running it, not by reading it. Spawns a verification agent with adversarial self-awareness.
---

# Verify

Spawn a verifier agent against the most recent changes.

## When to Use

- After implementing a feature or fix, to confirm it works at runtime.
- After a subagent completes work, to validate the result.
- When a PR claims to fix something and you want proof.

## What This Is NOT

- **Not a test runner.** Don't run the test suite — CI does that.
- **Not a type checker.** Don't verify types — the compiler does that.
- **Not a code review.** Don't read code and opine — the reviewer does that.

## What This IS

Runtime verification. Actually run the change and observe the result.

- CLI tool → execute it in terminal with real arguments.
- API endpoint → curl/httpie with real payloads.
- UI change → Playwright screenshot or manual inspection.
- Library → public import from a scratch script.
- Config change → restart the service, confirm behavior changed.

## Process

1. Determine what changed (`git diff HEAD~1` or recent work context).
2. Identify the surface area — what can a user/caller actually observe?
3. Exercise that surface area with real inputs.
4. Record structured verdicts: PASS / FAIL / BLOCKED / SKIP.
5. If FAIL: describe expected vs actual behavior with full output.
6. If BLOCKED: state exactly what's needed to unblock.
