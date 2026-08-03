---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

A spec's tickets are worked in a single worktree. **One spec → one worktree → one feature branch → one PR per ticket.**

- **worktree** — the parallel unit. One per spec, worked alongside other specs.
- **feature branch** — the integration branch inside it, cut once off the trunk. Every ticket merges here.
- **task branch** — the serial unit. One per ticket, cut from the feature branch, squash-merged back into it by `/ticket-done`.

The feature branch accumulates; task branches are short-lived. Ticket N+1 is cut from the feature branch *after* ticket N merged into it, so the blocking edges from `/to-tickets` are held by the branch graph — nothing has to be unlocked, and no rebase cascades.

**Light mode — work too small for a spec.** A single well-scoped ticket skips the topology: cut one task branch (`<type>/<slug>`) straight off the trunk in the primary checkout, build it, then have the user run `/ticket-done` in light mode — it opens the PR against the trunk and stops. No worktree, no feature branch, no `/spec-done`, no `/cleanup`.

## Step 0 — Enter the spec

Done **once per spec**, not per ticket. It leaves you standing in a provisioned worktree on a fresh feature branch.

- **No worktree yet** — create one off the trunk, on the feature branch:

  ```bash
  git fetch origin
  git worktree add ../<repo>-<feature> -b <type>/<feature> origin/<trunk>
  cd ../<repo>-<feature> && git push -u origin <type>/<feature>
  ```

  Fetch first so the branch cuts from the current trunk, and push immediately — `/ticket-done`'s PRs need the feature branch to exist on origin. (No remote → skip the fetch and push; `/ticket-done` merges locally.) The feature branch starts empty and is never committed to directly — every commit on it arrives by squash-merge from a task branch.

- **Worktree exists** — `git worktree list` names it. Move there; `git log <trunk>..<type>/<feature>` shows which tickets already merged.

**Provision — once, here.** A fresh checkout lacks what a worktree needs, and everything provisioned at this step is **shared by every ticket in the spec**: env files, dev-server ports, dev DB. `/ticket-done` provisions nothing and tears down nothing; `/cleanup` reclaims it all at the end.

**Prefer the repo's provisioner:** if `scripts/provision.sh` exists, run it — it owns this repo's worktree setup and is expected to be idempotent. **Otherwise** copy every gitignored env file from the primary checkout (the `git worktree list` entry whose `.git` is a directory, not a file) into the same path here — `.env`, `.env.*`, and any nested ones.

**Migration guard.** About to add a DB migration while the worktree still shares the primary's dev DB? Isolate the DB first, or divergent migrations across branches corrupt the shared schema. If the repo ships `scripts/provision.sh` with a per-worktree-DB mode (e.g. `scripts/provision.sh db`), run that; otherwise follow the repo's own convention for an isolated dev DB before migrating. One DB per **worktree**, not per ticket.

Completion: you are standing in the spec's worktree, provisioned, with the feature branch cut off the trunk.

## Step 1 — Build the ticket

Cut a task branch from the feature branch:

```bash
git switch <type>/<feature> && git switch -c <type>/<feature>-<NN>-<ticket-slug>
```

e.g. `feat/checkout-01-cart-schema`, `feat/checkout-02-payment-api` — the shared stem groups them, the number makes the order obvious.

Use /tdd where possible, at the seams the spec pre-agreed.

Build **one ticket per task branch** — the ticket is already sized for it, so don't subdivide. If a ticket turns out to be genuinely too large for one reviewable PR, split the *ticket* on the tracker and give each half its own task branch, rather than quietly stretching one branch to cover both.

Completion: every acceptance criterion on the ticket demonstrably works. Verification and landing belong to `/ticket-done` — don't start them here.

## Close out

Both closers are user-invoked — you can't fire them, so **prompt the user** at each handoff:

- **After each ticket** — prompt the user to run **/ticket-done**. It owns the scoped checks, the cold-read, the per-ticket simplify, the commit, the ticket's PR into the feature branch, the squash-merge, and closing the issue. Then **clear context** and cut the next task branch.
- **Once the last ticket merges** — prompt the user to run **/spec-done**, which reviews the whole feature branch against the spec and opens its PR to the trunk.
