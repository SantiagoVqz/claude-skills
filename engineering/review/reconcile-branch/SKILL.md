---
name: reconcile-branch
description: "Bring a working branch up to date with its base and confirm the surviving diff is exactly the intended change: inspect base-vs-head, integrate the base (merge/rebase per repo convention), resolve conflicts conservatively, prune anything unintended, and re-verify. Never merges the PR. Use when a branch is behind or shows conflicts, after the base moved, or when the user says 'reconcile my branch', 'rebase and check the diff', 'resolve conflicts and verify', 'is my diff clean'."
---

# Reconcile Branch

Take a branch that has drifted from its base and leave it **up to date, conflict-free, and containing only the changes it was meant to contain**. Three jobs, in order: (1) see what the branch actually changes, (2) integrate the base and resolve conflicts, (3) verify the surviving diff is exactly the intended change — no more, no less. This skill does **not** merge the branch anywhere; the merge decision stays with the human.

## Phase 0 — Establish base and head

1. **Head** = the current branch (`git rev-parse --abbrev-ref HEAD`). Confirm it's not the base itself.
2. **Base** = what this branch targets. In order of preference: the branch's open PR base (`gh pr view --json baseRefName -q .baseRefName`); else the repo default branch (`git symbolic-ref refs/remotes/origin/HEAD`); else `main`. If ambiguous, ask.
3. State both back to the user in one line (`head <X> ← base <Y>`) before touching anything.

## Phase 1 — Preflight

- **Clean working tree.** `git status --porcelain` must be empty. If not, stop and ask — never stash or discard the user's in-progress work to clear it.
- **Fetch.** `git fetch --all --prune` so base and head reflect the remote, not a stale local copy.
- **Sync head to remote.** If the local branch diverges from `origin/<head>`, reset to origin or abort — operating on a stale local branch silently drops the remote's commits.

## Phase 2 — Read the intended change (before integrating)

Snapshot what the branch means to do, so you can tell later whether the diff still matches intent:

- `git diff <base>...<head>` (three-dot: only what head added since it forked from base) — this is the branch's *intended* change set.
- `git diff <base>..<head> --stat` and the commit list (`git log <base>..<head> --oneline`) for shape.
- Note the files and behaviors this branch is *supposed* to touch. Anything outside that set after integration is suspect.

## Phase 3 — Integrate the base and resolve conflicts

- **Method: an explicit directive wins, then CLAUDE.md is law** (rebase vs merge). A caller or user asking for a **rebase** — e.g. `/ship` reconciling a new, unreviewed branch — overrides everything below. When no one asks and the repo is silent, default to **merge base into head** for a branch already under review (non-destructive, preserves review threads and existing approvals); **rebase** only a branch not yet reviewed.
- Resolve each conflict **conservatively, preserving the intent of BOTH sides** — the base change and the branch change. Never resolve a conflict by silently reverting a base change or dropping the branch's work to make the merge trivial.
- If schema/migration/seed state changed on the base, reset the local DB to the integrated branch before any DB-backed test — a DB ahead of the code produces phantom failures.
- **Stop and flag** (do not auto-resolve) when a conflict is **semantic, not textual** — both sides changed the same behavior in incompatible ways and picking one silently changes the product. Surface it; let the human decide.

## Phase 4 — Verify the surviving diff is exactly what's needed

This is the point of the skill. After integration, re-inspect `git diff <base>...<head>` and confirm every hunk is intended:

- **No conflict debris** — grep the diff for leftover markers (`<<<<<<<`, `=======`, `>>>>>>>`).
- **No accidental base reverts** — a bad conflict resolution can re-delete or roll back a change the base introduced. Every base change should still be present unless the branch deliberately changes it.
- **No unrelated cruft** — stray debug prints, unintended reformatting, files that snuck in during resolution, changes outside the file set noted in Phase 2. Remove them.
- **Nothing dropped** — every behavior the branch was supposed to add (Phase 2) is still there.
- **Redundancy check** — if integrating the base made the branch's diff **empty or trivially small**, the base likely already did this work. Don't push an empty change; flag it as "appears superseded by the base" and stop for the human.

Walk the final diff hunk by hunk against the Phase 2 intent. The output of this phase is a plain-language statement: *"the surviving diff is exactly X, Y, Z — the intended change, nothing else."*

## Phase 5 — Re-verify and push back

- Run the repo's test policy for the files now touched. When the integrated base delta is large or hit a shared module the branch depends on, widen beyond the branch's own files — integration can regress behavior the narrow tests miss.
- Push so the work actually lands on the branch:
  - **merge-based**: `git push` (fast-forward of the remote branch).
  - **rebase-based**: `git push --force-with-lease` — **never** plain `--force`. `--with-lease` aborts if the remote moved since your fetch; if it's rejected, re-fetch and re-evaluate rather than clobbering someone's concurrent push.
- Push **only** if Phase 3 actually changed the branch. A branch that was already up to date with a clean diff is a no-op — say so and stop.

## Never

- **Never merge the branch** into its base — reconcile leaves it up to date and review-ready; the merge stays the human's call.
- **Never `git push --force`** — only `--force-with-lease`, and only for rebase-based branches.
- **Never stash or discard** uncommitted work to clear preflight — stop and ask.
- **Never resolve a semantic conflict just to make tests go green** — flag it.
- **Never revert a base change or drop branch work** to simplify a conflict — preserve both sides' intent.

## Report

`head ← base` · integration method (merge/rebase) · conflicts resolved (which files) · the surviving diff in plain language (the intended change, confirmed) · anything pruned as cruft · anything flagged for a human (semantic conflict, superseded branch) · test results (exact counts) · pushed y/n. If the branch was already clean and current, say so plainly — that's a valid outcome.
