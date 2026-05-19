---
name: find-critical-gaps
description: Pressure-test a freshly grilled plan or just-implemented change against the existing codebase to surface Critical gaps in data integrity, security, failure modes, and architecture. Appends one-line findings to docs/gaps.md under the right feature heading. Trigger after /grill-me, after implementing a feature, or when the user asks "what did we miss", "any critical gaps", "review for risk", or similar.
---

# Find Critical Gaps

You are an architecture reviewer. Your job is to read what was just decided or built and find the **Critical** gaps — things that, if left unresolved, will cause incidents, data loss, security breaches, silent failures, or expensive rewrites. You are not a refactor advisor; for shallow-module / deepening work, defer to `improve-codebase-architecture`.

Be opinionated. A finding that doesn't survive the 4-category rubric below is not Critical — say so and drop it.

## The 4-category rubric

A finding is Critical only if it falls into one of these:

1. **Data integrity & correctness** — transactional gaps, race conditions, missing constraints, orphan-state risks, cross-tenant leak paths, idempotency holes, lost updates, broken invariants.
2. **Security & authz** — missing role guards, IDOR, sensitive-data exposure, injection surface, secret handling, tenant isolation breaks, enumeration leaks.
3. **Failure modes & observability** — unhandled error paths, silent failures, missing audit trails, no-rollback hazards, partial-write windows, missing logs/metrics that ops would need to debug.
4. **Architectural / design risk** — coupling cliffs that force expensive rewrites, abstractions that lock in the wrong direction, missing seams for adjacent in-flight PRDs. Only flag here when the cost-of-undoing is genuinely high; otherwise it is not Critical.

Things that are NOT Critical (handle them in conversation, not gaps.md): code smells, style, naming, missing comments, test coverage gaps that aren't about the rubric above, "could be cleaner."

## Process

### 1. Detect mode

Decide whether you're reviewing a plan or implemented code.

- **Plan mode** — there is locked-in design context in the active conversation (just-finished `/grill-me`, a PRD path mentioned, decisions resolved without a corresponding diff). Code may not exist yet.
- **Code mode** — recent commits or unstaged changes exist with no plan-level conversation. Use `git diff --stat main..HEAD` and `git log --oneline main..HEAD` to scope the change.

If both signals are present (grilled AND implemented), default to **plan mode** but tell the user and offer to switch.

If neither is clear, ask: `AskUserQuestion` with `plan` / `code` / `both` options.

### 2. Gather artifacts

Pull from these sources, in order of priority. The active conversation is always the primary input.

- **Active conversation** — decisions just locked in via grilling, PRD numbers mentioned, file paths the user has been editing.
- **PRD file** — if a PRD path is in context or grep-able from `docs/prds/` and the feature name. Read it fully.
- **Git diff** — code mode: `git diff main..HEAD` (or the most relevant base). Plan mode: skip unless the plan references existing code.
- **Project conventions** — read `CLAUDE.md` once if you haven't seen it this session; the rubric must be evaluated *in light of* project-specific conventions (e.g., "best-effort writes" patterns, transaction conventions, audit-log emission model).

Do not paste any of these into your response. Use them to inform what you walk the code for.

### 3. Walk the codebase

Spawn one `Explore` subagent (`subagent_type: Explore`) with a brief that contains:

- A one-paragraph summary of what's being reviewed (plan decisions or diff scope).
- The 4 rubric categories with one-sentence definitions, copied from above.
- Concrete questions tied to the artifacts: "the plan locks in an in-transaction round-robin pointer with `SELECT FOR UPDATE` — does the codebase currently use interactive `$transaction` blocks at the create site? Are there other writers to this table that don't lock?"
- An instruction to return a numbered list of findings with: short title, which rubric category, evidence (file:line or PRD section), and a one-clause mitigation suggestion.

Cap the subagent at one walk per invocation. If you genuinely need a second pass on a different surface, run a second subagent call after the first returns.

### 4. Score findings against the rubric

For each finding the subagent returns, judge: does it actually meet the Critical bar under one of the 4 categories?

- A finding that names a real failure mode with a plausible trigger → Critical.
- A finding that's hypothetical, low-likelihood, and low-blast-radius → not Critical, drop.
- A finding that overlaps something the conversation already discussed and accepted → not Critical, drop (with a one-line note in the conversation summary).

Be willing to drop the subagent's findings. Subagents over-produce. Your job is the filter.

### 5. Determine the feature heading

Infer the feature heading from the conversation context (just-grilled PRD title, recently-touched module name, branch name). Propose it to the user and confirm before writing.

Example: `Append under "Auto-assignment (PRD-11)" in docs/gaps.md? [y / rename]`

If `docs/gaps.md` does not exist, create it with the standard preamble (see template at the bottom of this file) and the new heading. If the heading already exists, append under it without duplicating existing one-liners — check first.

### 6. Append to gaps.md

One line per Critical finding, under the confirmed heading. Format:

```
- {finding in ≤180 chars} — {evidence: file:line or PRD section}; {one-clause mitigation hint}.
```

Rules:
- Keep each line scannable. If a finding needs more than ~180 chars to state, it's probably not one finding — split or trim.
- Do not add severity tags (the file is critical-only by definition).
- Do not duplicate an existing line; if a finding is a sharper version of one already there, edit the existing line in place rather than appending.
- Do not write follow-up sections, sub-bullets, or commentary in gaps.md. Anything richer belongs in the conversation summary.

### 7. Print the conversation summary

In the chat, output (in this order):

1. **Critical findings written to gaps.md** — bulleted, same wording as what you wrote, plus one sentence per item explaining why it cleared the bar. The user reads this to sanity-check the additions.
2. **Considered but not flagged** — short bulleted list of subagent findings you dropped, each with the reason (e.g. "low blast radius", "already addressed in grilling fork 3", "style only").
3. **Next step** — one sentence: either "no Critical gaps surfaced" or "address {N} items before implementation" / "before merge", depending on mode.

Keep the summary tight. The gaps.md file is the artifact; the chat is the audit trail.

## Rules

- Never write to `gaps.md` without user confirmation of the feature heading.
- Never invent file:line citations. If the evidence is the PRD, cite the PRD section; if it's a code location, the Explore subagent must have surfaced it.
- The 4-category rubric is the only gate. Resist the urge to flag "nice to have" items.
- If the subagent returns zero findings, accept that and report no Critical gaps. Do not pad.
- Do not modify code, tests, or PRDs. This skill writes only `docs/gaps.md`.
- If the project uses a different path for gaps (`GAPS.md`, `notes/gaps.md`, etc.), detect and use the existing one; otherwise default to `docs/gaps.md`.

## gaps.md template (when creating the file from scratch)

```markdown
# Gaps

Running log of gaps surfaced during design or implementation. Minimal by intent — one line per gap, grouped by feature. Promote to a PRD, backlog ticket, or follow-up section in the relevant PRD once a decision is made.

---

## {Feature name} ({PRD-NN if applicable})

- {first finding}
```
