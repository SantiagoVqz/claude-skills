---
name: ship
description: "Push the current work and open its pull requests — the external-git half of the build lifecycle, run after /feature-done has verified the whole feature. Handles a solo branch or a whole stack. Never merges."
disable-model-invocation: true
argument-hint: [base]
---

# Ship

Take committed, reviewed work and **land it on the remote as pull requests** — nothing more. `/implement` owns the code and `/ticket-done` / `/feature-done` own the verification; `ship` owns the git that leaves the machine: integrate, push, PR. It never merges — that stays the human's call.

Work arrives in one of two shapes, and every step below branches on it:

- **Solo** — one branch, one PR.
- **Stack** — an ordered chain of branches, one per ticket, each PR based on the one below. Built layer by layer by `/ticket-done`, which already published each PR as it sealed; ship's job on a stack is the **final** sync and republish against a trunk that may have moved.

Command syntax for `gh stack` lives in the **gh-stack skill** (`gh extension install github/gh-stack`) — consult it rather than guessing flags.

## Step 1 — Preflight gate

- **Trunk** = the branch this repo merges into, recorded by `/setup-skills` under delivery shape (often `develop`, not `main`). Fall back to the default branch (`git symbolic-ref refs/remotes/origin/HEAD`) only when nothing is recorded.
- **Head** = current branch (`git rev-parse --abbrev-ref HEAD`). Refuse to ship from the trunk.
- **Clean tree.** `git status --porcelain` must be empty. `ship` publishes committed work; it does not commit. Dirty → stop and send the user back to `/implement`.

Completion: on a feature branch with an empty status.

## Step 2 — Read the shape

`git fetch --all --prune` first, so everything below reflects the remote.

- **Stack?** `gh stack view --json`. It succeeds → stack; record the branch order and the trunk. Exit **2** (not in a stack) → solo. Exit **9** → stacked PRs aren't enabled for this repo; treat as solo and say so in the report.
- **Solo base** = the open PR's `baseRefName` (`gh pr view --json number,url,baseRefName,state`), else `$ARGUMENTS`, else the trunk. A PR existing also means the branch is **under review**.

Completion: you can state the shape in one line — `stack of N onto <trunk>`, or `head ← base, new | under review`.

## Step 3 — Integrate

**Stack** — `gh stack sync`. One command fetches, fast-forwards the trunk, cascade-rebases every layer, and pushes. Rebasing a reviewed layer is the contract here; `gh stack sync` retargets each PR as it goes, so approvals travel with them.

- Exit **3** (rebase conflict) → hand to **/resolving-merge-conflicts**, then `gh stack rebase --continue`. Repeat until sync completes.

**Solo** — integrate only if behind (`git rev-list --count <head>..origin/<base>` > 0):

- **New branch** → rebase onto the base for a clean, linear history; Step 4 pushes with lease.
- **Under review** → merge the base into head, preserving review threads and approvals.
- Conflicts → **/resolving-merge-conflicts**.

Completion: `git rev-list --count <head>..origin/<base>` is 0 for every branch being shipped.

## Step 4 — Push and PR

**Stack** — `gh stack submit --auto --open`. Pushes every active branch, then creates or updates one PR per layer and links them into the stack on GitHub. Most layers already have their PR from `/ticket-done`; this run **updates** them against the synced trunk and catches anything the last layer's fixes moved. `--open` marks each layer ready for review immediately — the point of stacking is that a layer becomes reviewable the moment it seals, and a draft isn't. Drop it only when the user explicitly wants the stack held back.

**Solo**

- Push: new remote branch → `git push -u origin <head>`; after a rebase → `git push --force-with-lease`; otherwise → `git push`.
- PR exists → report its URL and note that it's updated. No PR → `gh pr create --base <base> --head <head>`, titled and bodied for *this branch's* change only: a tight summary plus the ticket it closes, not a blow-by-blow of the work.

Completion: every branch shipped has exactly one open PR against the right base.

## Never

- **Never merge.** `ship` lands work for review. Merging a stack (`gh stack merge`) and merging a solo PR are both the human's call. Post-merge teardown is `/cleanup`.
- **Never `git push --force`** — `--force-with-lease` only. `gh stack push` already leases per branch.
- **Never ship a dirty tree** — send unfinished work back to `/implement`, whose `/ticket-done` commits it.
- **Rebase a solo branch only while it is unreviewed.** Once it has a PR, integrate by merge so approvals survive. Stack layers are the exception, and only because `gh stack sync` retargets their PRs as part of the cascade.

## Report

Shape (solo / stack of N) · `head ← base` or the layer order · integrated y/n and how · conflicts resolved (which files) · pushed y/n · PR URL(s) · anything left for the human.
