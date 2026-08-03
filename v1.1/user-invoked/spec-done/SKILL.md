---
name: spec-done
description: "Close out a whole spec once its last ticket merges — walk the traceability table, rebase onto the trunk, run the full suite, review against the spec, then open the feature branch's PR. Never merges."
disable-model-invocation: true
---

# spec-done — the conformance gate

Run this **once per spec**, after `/ticket-done` merged the last ticket into the feature branch. Everything here scales with the **spec**, not the diff, which is exactly why it doesn't run per ticket: a full suite on a 40-line slice is waste, and there is nothing to check conformance against until the last slice exists.

The question this gate answers is **conformance** — does the feature branch, taken whole, deliver the spec? Each ticket was verified against itself and simplified within its own diff; nothing has yet asked whether they add up.

It ends by **opening a PR, never merging it.** Landing anything on the trunk — `develop`, `main`, or whatever the repo merges into — is the user's call, every time.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps.

## Steps

1. **Walk the traceability table.** The spec issue body carries the story → ticket table `/to-tickets` wrote. Check it three ways against `git log <trunk>..<feature-branch>`:

   - **Every user story has a ticket, and that ticket's commit is on the feature branch.** A story with nothing behind it means the spec isn't delivered — stop and name it.
   - **Every ticket maps to at least one story.** A ticket mapping to none is scope nobody asked for.
   - **Every ticket on the tracker is closed.** One still open means `/ticket-done` didn't finish, or the ticket never got built.

   This is the check that makes conformance countable instead of a vibe. Do it before the expensive passes — a missing ticket is cheaper to find now than after a full suite run.

   Completion: every story maps to a merged ticket, every ticket maps to a story, and any gap in either direction is named.

2. **Rebase onto the trunk.** This is the **only** point in the pipeline where the feature branch integrates with the trunk — tickets never rebase, so the branch has been diverging since `/implement` cut it.

   ```bash
   git fetch origin && git rebase origin/<trunk>
   ```

   Conflicts → **/resolving-merge-conflicts**, then `git rebase --continue`. The branch has no open PR yet, so rebasing is free — no approvals to preserve; the force-push in step 7 overwrites only your own ticket history on origin, never a reviewer's.

   Completion: `git rev-list --count <feature-branch>..origin/<trunk>` is 0.

3. **Full suite** — run the repo's checks whole, not scoped. `.github/workflows/*` is the source of truth for what "whole" means; this run is the one that has to match CI. Run it *after* the rebase, so it tests what the trunk will actually get.
   Completion: the full suite has run, and each result is green or attributed (this-spec → fixed, pre-existing → reported).

4. **Cross-ticket simplify** — invoke `/simplify` over `git diff <trunk>...HEAD` with a **narrow brief: duplication and drift across tickets only.** Each ticket was already simplified within its own diff by `/ticket-done`, so re-running the general pass is waste. What only becomes visible here is the helper written in ticket 01 and again in ticket 03, the type that wants to be shared, the two near-identical shapes neither ticket could see.
   Completion: the cross-ticket pass has run and its cleanups are applied, or it found nothing.

5. **Review against the spec** — invoke `/code-review` with the trunk as the fixed point and the spec as the spec source. Its **Spec** axis is the conformance check: requirements the spec asked for that are missing or partial, behaviour nobody asked for, requirements implemented wrong. Its **Standards** axis catches what the per-ticket cold-reads couldn't see from inside one slice.
   Completion: both axes have reported.

6. **Triage the findings.** Nothing is on the trunk yet and every ticket is already squashed to one commit, so fix on top of the feature branch as ordinary commits. Rewriting history to place each fix in its originating ticket buys nothing — the feature branch lands as one PR, and the per-ticket PRs are already merged and readable as the audit trail.

   A finding that reveals the *spec* was wrong stops here: it's the user's call, not a fix.

   Completion: every finding is fixed or escalated to the user with a reason.

7. **Open the PR to the trunk** — and stop.

   ```bash
   git push --force-with-lease -u origin <feature-branch>
   gh pr create --base <trunk> --head <feature-branch>
   ```

   `--force-with-lease` because the remote feature branch predates the step-2 rebase (the ticket PRs merged into it there); a plain push is rejected as non-fast-forward. On GitLab use `glab mr create` per the tracker doc. No remote → nothing to push: report and stop; the user merges the feature branch into the trunk locally.

   The body summarises the **spec**, not the tickets — the per-ticket PRs already carry the blow-by-blow:

   <pr-body>

   ## What this delivers

   The spec's solution, from the user's perspective.

   ## Tickets

   The line of merged ticket PRs, in order, each with the user stories it satisfied — the traceability table from step 1.

   ## Decisions

   Judgement calls made at spec level that no single ticket PR carries.

   Closes #<spec-issue>

   </pr-body>

   **Never merge it.** Whether this goes to `develop`, to `main`, or waits — that's the user's call, always. Post-merge teardown is `/cleanup`, which also closes the spec issue.

   Completion: exactly one open PR from the feature branch to the trunk, and nothing merged.

8. **Report** — one block: traceability (stories covered / orphan stories / orphan tickets) · rebased onto trunk, conflicts resolved · full-suite result · cross-ticket simplify cleanups · Standards findings and disposition · Spec findings and disposition · anything escalated · PR URL · "not merged — your call".
