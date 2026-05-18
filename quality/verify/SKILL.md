---
name: verify
description: Generate and optionally execute E2E verification steps after completing a plan or implementation. Trigger this skill whenever the user has just finished building something and wants to confirm it works — including phrases like "verify", "did it work", "is this done", "how do I test this", "check the changes", "let's test", "make sure nothing broke", "sanity check", "validate", "QA", or after exiting plan mode. Also trigger when the user says they "just finished" or "wrapped up" something and asks a question that implies verification (e.g., "is this done?", "check if everything landed"). This is the go-to skill for post-implementation confidence — use it even when the user doesn't explicitly say "verify".
---

# Verify

Generate actionable verification steps that confirm an implementation works end-to-end, then optionally execute them. The goal is to give the user (and yourself) confidence that what was built actually works — not just that code exists, but that it behaves correctly.

## Instructions

### 1. Gather context

Understand what was implemented by checking these sources. The more context you gather, the better your verification steps will be — a verification plan that misses half the changes is worse than none at all.

**Sources (check all that apply):**

- **Conversation history**: What was the user working on? What plan was being executed? What were the stated goals?
- **Plan file**: Look for the most recent plan in `planning/`, `.planning/`, or `.gsd/` directories. Extract the objectives, acceptance criteria, and scope.
- **Git state**: Run `git diff --stat` for unstaged changes, `git diff --cached --stat` for staged changes, and `git log --oneline -10` to see recent commits. Use `git diff HEAD~N..HEAD` with an appropriate range based on plan scope.
- **Changed files**: Read key files from the diff to understand implementation details — especially new tests, new endpoints, and config changes.
- **Existing tests**: Check if new tests were added as part of the work. Run `git diff --name-only | grep -i test` to find them.

### 2. Extract plan objectives

Before writing verification steps, list the plan's objectives or acceptance criteria. If the plan file has explicit acceptance criteria, use those. If not, infer them from the plan's scope description, task list, or conversation history.

Beyond the explicitly stated objectives, also consider common edge-case and defensive objectives that the plan may not mention but are important to verify — things like fallback behavior, error handling, backward compatibility, and negative tests (what should NOT happen). Add 1-2 of these inferred objectives when relevant.

Write these down as a numbered list — you will cross-reference them in step 4.

Example:
```
Plan objectives:
1. Natural language triggers SR flow for SR-capable tenants
2. Keyword-based triggers still work
3. Diagnostic logging is present for debugging
4. Non-SR-capable tenants are unaffected
5. (inferred) Graceful fallback when intent detection is uncertain
```

### 3. Generate verification steps

For each plan objective, write at least one verification step. Each step must include:

- **What to verify** — one sentence describing the check
- **How** — the exact command to run OR the manual action to take
- **Expected result** — what success looks like, specifically
- **Covers** — which plan objective(s) this step validates

Prioritize in this order:
1. Runnable commands over manual checks (tests, linting, curl, build commands)
2. E2E flows that prove pieces work together over unit-level spot checks
3. Happy path first, then edge cases and error handling
4. Check CI status if available (`gh run list --limit 3` or similar)

Step type examples:

- **Automated test**: `make test-api` → all tests pass, 0 failures — covers objectives 1, 2
- **Targeted test**: `docker compose exec api python -m pytest chat/tests/test_sr_automation.py -v` → 7 passed, 0 failed — covers objective 1
- **API probe**: `curl -s http://localhost:8000/health/` → 200 OK with JSON body — covers objective 3
- **Log check**: `docker compose logs api | grep SR_DIAG` → log lines show tenant and gate info — covers objective 3
- **Manual E2E**: Open the app, send "report a pothole", verify SR flow activates — covers objective 1
- **Negative test**: Send same message to a non-SR tenant, verify normal chat response — covers objective 4

Use project-specific commands from CLAUDE.md when available (e.g., `make test-api` over `python manage.py test`).

### 4. Coverage check

After drafting steps, cross-reference against the plan objectives from step 2. Every objective must have at least one verification step. If any objective is uncovered, add a step for it.

Present coverage as:
```
Coverage:
- Objective 1 (NLP triggers): Steps 1, 4 ✓
- Objective 2 (keyword triggers): Step 5 ✓
- Objective 3 (diagnostic logging): Step 3 ✓
- Objective 4 (non-SR tenants): Step 6 ✓
```

If an objective genuinely cannot be verified with available tools (e.g., requires a production environment), note it as "manual verification needed" rather than skipping it silently.

### 5. Output the verification plan

#### Determine the output location

Find the planning folder by checking for existing structure in this order:
1. Look for a **feature-specific subfolder** that matches the current work — e.g., if the plan lives in `planning/ServiceRequests/`, save verification there too
2. If the plan file is inside a subfolder, use that same subfolder
3. If no subfolder exists, check for `planning/`, `.planning/`, or `.gsd/` at the project root
4. If none exist, create `planning/`

Name the verification file to match the feature or plan:
- If inside a feature subfolder: `verification.md` (the subfolder provides context)
- If at the planning root: `verification-{feature-name}.md` (e.g., `verification-sr-automation.md`)
- If a `verification.md` already exists from a previous plan, use the feature-name suffix to avoid overwriting it

#### Format depends on step count

- **≤5 steps** → Print inline as a numbered checklist. No file needed.
- **6–10 steps** → Print inline AND save to the determined location
- **>10 steps** → Split into domain files (e.g., `verification-backend.md`, `verification-frontend.md`), max 10 steps each, in the same location. Print summary inline with file paths.

#### File format

```markdown
# Verification: {Plan Name}

Generated: {date}
Scope: {brief description of what was implemented}

## Plan Objectives
1. {objective}
2. {objective}
...

## Steps

### 1. {What to verify}
**How:** `{command}` OR {manual action}
**Pass:** {expected result}
**Covers:** Objective {N}

### 2. ...

## Coverage
- Objective 1: Steps {X, Y} ✓
- Objective 2: Step {Z} ✓
...
```

### 6. Offer to execute

After presenting the verification plan, offer to run all command-based steps automatically. If the user agrees:

1. Run each command-based step in sequence
2. Report pass/fail for each with actual output vs. expected
3. Summarize at the end: "X/Y automated checks passed. Z steps require manual verification."

If a step fails, show the actual output and suggest what might be wrong — but keep going through the remaining steps rather than stopping at the first failure.

## Rules

- Every plan objective must map to at least one verification step — this is the most important rule
- Never exceed 10 steps per file — split if needed
- Skip trivial checks like "file exists" or "code compiles" — focus on behavior
- If the plan touched both backend and frontend, include at least one step for each
- If new tests were added as part of the plan, always include running those specific tests
- When the user hasn't explicitly asked to verify but you're auto-triggering post-plan, keep it concise — ≤5 steps focused on the highest-risk areas
