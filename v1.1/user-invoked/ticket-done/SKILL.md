---
name: ticket-done
description: "Close out one ticket — cold-read, scoped checks and simplify fired in parallel, commit, PR into the feature branch, squash-merge, close the issue. The tight per-ticket gate."
disable-model-invocation: true
---

# ticket-done — land one ticket

Run this **once per ticket**, then cut the next task branch — or hand to `/spec-done` when the ticket was the spec's last.

**One ticket = one task branch = one PR into the feature branch.** The ticket is sized for exactly this: `/to-tickets` cuts each one to a vertical slice that fits a single fresh context window, which is the same thing as a PR you read in one sitting. That PR is your genuine first read of code you didn't write — it is the point of the whole shape, not a formality.

This gate is **tight** — scoped, parallel, no human in it until the PR. It runs on every ticket, so anything that scales with the *spec* rather than the *diff* belongs to `/spec-done` instead: the full suite, cross-ticket duplication, spec conformance, the rebase onto the trunk. Here you verify the slice you just wrote and land it on the feature branch.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps; skipping the asking is the reason it exists.

**It is also a context checkpoint.** Every step runs against the ticket's bounded diff or hands off to a fresh sub-agent, so the ritual costs the main window very little — and once it returns, the ticket is merged into the feature branch and its issue is closed. That's durable state outside your context. Clear or `/handoff` right after it returns and cut the next task branch.

## Steps

1. **Load the gun** — the three verification passes are independent, so gather their inputs before any of them runs. None costs anything to prepare:

   - **The changed-file list** — `git diff --name-only <feature-branch>`. This is the cold-read's entire brief and the simplify pass's scope.
   - **The check commands** — the repo already defines what "green" means; **mirror its own checks, don't invent them.** Find them in order of authority: `.github/workflows/*` first (the source of truth), then manifest scripts (`package.json`, `Makefile`/`justfile`, `pyproject.toml`), run through the package manager the lockfile names.

     Scope each to **the diff's blast radius**: the files this ticket touched plus their callers. Typecheck and lint the changed paths; run the test files that cover them. The full suite is `/spec-done`'s job — one run, at the boundary that can act on it.

   Completion: you can state the changed-file list and the exact command line for every check, with nothing dispatched yet.

2. **Fire all three passes in a SINGLE message.** Put the `Explore` sub-agent call, the `/simplify` invocation, and every check command from step 1 in **one assistant turn**. They share no inputs and none can inform the others, so a turn spent waiting on one before starting another is wall-clock added to a gate that fires on every ticket — this overlap is what keeps the gate cheap enough to keep.

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

6. **Squash-merge it into the feature branch.**

   ```bash
   gh pr merge <n> --squash --delete-branch
   ```

   **Squash always.** One commit per ticket on the feature branch is what makes the final spec-level diff readable and each ticket independently revertible. Merging here is safe and routine — the feature branch is not the trunk, nothing has shipped, and this merge is what makes ticket N+1 buildable.

   **Never merge the feature branch itself.** `/spec-done` opens its PR to the trunk; landing it is the user's call, always.

   Completion: the ticket's commit is on the feature branch, the task branch is deleted, and the working tree is back on the feature branch.

7. **Mark the ticket done on the configured tracker** — whichever `/setup-skills` recorded is the single source of truth; update it and nothing else.

   **GitHub / Linear / Jira** — take `ready-for-agent` off the issue, then **close it**: `gh issue close <n> --reason completed --comment "Merged into <feature-branch> in <PR url>."` (The `Closes #<issue>` in the PR body handles this automatically only when merging into the repository's default branch, which this isn't — so close it explicitly.) Don't also write a local file.

   **Local markdown** — tick the ticket file's acceptance-criteria checkboxes and set its **Status** to `done`. There is no issue to close, so this file *is* the record.

   **Why the ticket closes here, at the feature branch.** A ticket's state should track the thing the ticket controls, and a ticket controls whether its code is written and integrated into the feature — not when the feature ships. That's a release decision, at a different altitude, with a different unit. Three altitudes, three closures:

   | Unit | Closes when | What it unblocks |
   |---|---|---|
   | **Ticket** — unit of work | its PR squash-merges into the feature branch | the next ticket |
   | **Spec** — unit of delivery | the feature branch merges to the trunk (`/cleanup` closes it) | the release |
   | **Release** — unit of value | deployed to production | — |

   Track the ticket at *released* instead and the board shows nothing for the whole build, then flips at once; cycle time becomes unmeasurable and a blocking edge reads as blocked when its code is already sitting on the feature branch. Closing here makes the edge resolve at the moment the work is genuinely available to build on.

   The spec issue stays open until the trunk merge, so an abandoned feature always leaves exactly one open thing tracking unshipped work.

   Completion: the tracker shows this ticket closed (or `Status: done` locally), updated in exactly one place.

8. **Cut the next task branch** — `git switch -c <type>/<feature>-<NN+1>-<slug>` from the feature branch you're already standing on.

   No next ticket → hand to `/spec-done`.

   **Branch naming.** Feature branch: `<type>/<feature>` — `feat/checkout`. Task branches: `<type>/<feature>-<NN>-<ticket-slug>` — `feat/checkout-01-cart-schema`, `feat/checkout-02-payment-api`. The shared stem groups them; the number makes the order obvious without reading the diff.

   Completion: you are standing on the task branch the next ticket will be written on, or on the feature branch with `/spec-done` next.

9. **Report** — one line: ticket · check results · cold-read findings and disposition · simplify cleanups · commit hash · PR URL · squash-merged y/n · issue closed · next branch, or "last ticket → /spec-done".

## Review lands after the merge

You review the ticket's PR before merging it — that's step 5→6, and it's the whole point of the per-ticket PR. Feedback that arrives *after* the squash-merge doesn't strand anything: it becomes an ordinary commit on the next task branch, or its own follow-up ticket. Nothing rewrites history, nothing force-pushes, and no review thread is lost.
