---
name: ticket-done
description: "Close out one ticket — cold-read, scoped checks and simplify fired in parallel, commit, PR into the feature branch, squash-merge, close the issue. The tight per-ticket gate."
disable-model-invocation: true
---

# ticket-done — land one ticket

Run this **once per ticket**, then cut the next task branch — or hand to `/spec-done` when the ticket was the spec's last.

**One ticket = one task branch = one PR into the feature branch.** The ticket is sized for exactly this: `/to-tickets` cuts each one to a vertical slice that fits a single fresh context window, which is the same thing as a PR you read in one sitting. That PR is your **post-merge first read** of code you didn't write — the audit trail the whole shape exists to produce.

**Light mode** — no spec, task branch cut straight off the trunk: the "feature branch" below reads "trunk", so steps 6–8 don't apply. Run steps 1–5, open the PR against the trunk, report, and stop — landing on the trunk is the user's call, always.

This gate is **tight** — scoped, parallel, no human in it until the PR. It runs on every ticket, so anything that scales with the *spec* rather than the *diff* belongs to `/spec-done` instead: the full suite, cross-ticket duplication, spec conformance, the rebase onto the trunk. Here you verify the slice you just wrote and land it on the feature branch.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps; skipping the asking is the reason it exists.

**It is also a context checkpoint.** Every step runs against the ticket's bounded diff or hands off to a fresh sub-agent, so the ritual costs the main window very little — and once it returns, the ticket is merged into the feature branch and its issue is closed. That's durable state outside your context. Clear or `/handoff` right after it returns and cut the next task branch.

## Steps

1. **Load the gun** — the three verification passes are independent, so gather their inputs before any of them runs. None costs anything to prepare:

   - **The changed-file list** — `git diff --name-only <feature-branch>`. This is the cold-read's entire brief and the simplify pass's scope.
   - **The check commands** — the repo already defines what "green" means; **mirror its own checks, don't invent them.** Find them in order of authority: `.github/workflows/*` first (the source of truth), then manifest scripts (`package.json`, `Makefile`/`justfile`, `pyproject.toml`), run through the package manager the lockfile names.

     Scope each to **the diff's blast radius**: the files this ticket touched plus their callers. Typecheck and lint the changed paths; run the test files that cover them. The full suite is `/spec-done`'s job — one run, at the boundary that can act on it.

   Completion: you can state the changed-file list and the exact command line for every check, with nothing dispatched yet.

2. **Fire all three passes from a SINGLE turn.** Dispatch the `Explore` sub-agent and every check command from step 1 together — they run in the background — then invoke `/simplify` inline in the same turn while they execute. None can inform the others, so a turn spent waiting on one before starting another is wall-clock added to a gate that fires on every ticket — this overlap is what keeps the gate cheap enough to keep.

   - **Cold-read** — a fresh `Explore` agent with NO context beyond the changed-file list. Its brief is the **residue** of the edit — what the change left behind, not the code's overall quality: naming drift, half-applied renames, discriminants collapsed to `string`, dead fallbacks, orphaned callers.
   - **Simplify** — `/simplify` scoped to `git diff <feature-branch>...HEAD`. Quality, not residue: reuse, needless indirection, wrong altitude. Running it here, while the context is hot and the fix is a commit on the branch you're standing on, is far cheaper than finding the same thing at spec scope. It cannot see duplication *against other tickets* — that stays `/spec-done`'s job, and is the only part of simplify that does.
   - **Checks** — the scoped commands from step 1.

   Completion: all three have reported, dispatched from one turn.

3. **Triage** — fix the real cold-read flags and apply the simplify cleanups; dismiss false positives with a reason. Fix check failures **this ticket caused**; pre-existing failures get reported, never fixed silently. If a fix touched logic, re-run the checks that cover it.
   Completion: every flag is fixed or explicitly dismissed, every cleanup applied or declined with a reason, and every check result is green or attributed (this-ticket → fixed, pre-existing → reported).

4. **Commit** on this ticket's task branch: short present-tense summary matching the repo's log style, one logical change per commit.
   Completion: working tree clean.

5. **Open the PR into the feature branch.**

   ```bash
   git push -u origin <task-branch>
   gh pr create --base <type>/<feature> --head <task-branch>
   ```

   Commands show `gh`; on GitLab use the `glab mr` equivalents from the tracker doc. On a repo with **no remote** there is no PR: review `git diff <type>/<feature>...HEAD` yourself, then `git switch <type>/<feature> && git merge --squash <task-branch> && git commit` — that replaces steps 5–6.

   The base is the **feature branch**, never the trunk. The PR body carries, for *this ticket's* change only:

   <pr-body>

   ## What this delivers

   The end-to-end behaviour this ticket makes work, from the user's perspective.

   ## User stories

   The numbered stories from the spec this ticket satisfies — the same numbers the traceability table in the spec issue carries.

   ## Decisions

   Every judgement call made while building that a reviewer can't recover from the diff — a seam chosen, an alternative rejected, a constraint discovered. Skip the section entirely when there were none; don't manufacture entries.

   Closes #<issue>

   </pr-body>

   Completion: exactly one open PR for this ticket, based on the feature branch.

6. **Squash-merge it into the feature branch, then sync local.**

   ```bash
   gh pr merge <n> --squash --delete-branch
   git switch <type>/<feature> && git pull
   ```

   The merge lands on **origin's** feature branch; the pull is what brings it local — skip it and the next task branch is cut without this ticket's code.

   **Squash always.** One commit per ticket on the feature branch is what makes the final spec-level diff readable and each ticket independently revertible. Merging here is safe and routine — the feature branch is not the trunk, nothing has shipped, and this merge is what makes ticket N+1 buildable.

   **Never merge the feature branch itself.** `/spec-done` opens its PR to the trunk; landing it is the user's call, always.

   Completion: `git log -1` on the **local** feature branch shows this ticket's squash commit, and the task branch is deleted.

7. **Mark the ticket done on the configured tracker** — whichever `/setup-skills` recorded is the single source of truth; update it and nothing else.

   **GitHub / Linear / Jira** — take `ready-for-agent` off the issue, then **close it**: `gh issue close <n> --reason completed --comment "Merged into <feature-branch> in <PR url>."` (The `Closes #<issue>` in the PR body only fires on merges into the repository's default branch, which the feature branch isn't — so close it explicitly.) Don't also write a local file.

   **Local markdown** — tick the ticket file's acceptance-criteria checkboxes and set its **Status** to `done`. There is no issue to close, so this file *is* the record.

   The ticket closes **here**, at the feature-branch merge — the moment its work is genuinely available to build on, which is what resolves the blocking edge. Shipping is the spec's closure, a different altitude; the spec issue stays open until `/cleanup`.

   Completion: the tracker shows this ticket closed (or `Status: done` locally), updated in exactly one place.

8. **Cut the next task branch** — `git switch -c <type>/<feature>-<NN+1>-<slug>` from the feature branch you're already standing on.

   No next ticket → tell the user to run `/spec-done` (user-invoked — only they can fire it).

   Naming follows the stem `/implement` cut: `<type>/<feature>-<NN>-<slug>`, next number.

   Completion: you are standing on the task branch the next ticket will be written on, or on the feature branch with `/spec-done` next.

9. **Report** — one line: ticket · check results · cold-read findings and disposition · simplify cleanups · commit hash · PR URL · squash-merged y/n · issue closed · next branch, or "last ticket → /spec-done".

## Review lands after the merge

The ritual doesn't pause for a read — the PR is your **post-merge first read**, taken at your own pace. Feedback never strands anything: it becomes an ordinary commit on the next task branch, or its own follow-up ticket. Nothing rewrites history, nothing force-pushes, and no review thread is lost.
