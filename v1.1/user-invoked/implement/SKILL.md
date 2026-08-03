---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

A feature's tickets are worked in a single worktree — the worktree is the parallel unit (one per feature), the ticket is the serial unit inside it. Where stacked PRs are enabled, **one ticket = one layer = one PR**; where they aren't, the feature is one branch and the tickets are commits on it. `/setup-skills` recorded which.

## Step 0 — Enter the feature

The feature owns a worktree; this step gets you standing in it, provisioned.

- **No worktree yet** — create one off the trunk. **Stacked:** `git worktree add ../<repo>-<feature> -b <type>/<feature>-01-<ticket-slug> <trunk>`, provision, then `gh stack init -b <trunk> <branch>`. **Solo:** the same, branching `<type>/<feature>` and with no stack to initialise.
- **Worktree exists** — `git worktree list` names it. Move there and continue; `gh stack view` (or `git log`) shows where it left off.

**Provision.** A fresh checkout lacks what a worktree needs. **Prefer the repo's provisioner:** if `scripts/provision.sh` exists, run it — it owns this repo's worktree setup (gitignored env, dev-server ports, any per-worktree DB) and is expected to be idempotent. **Otherwise** copy every gitignored env file from the primary checkout (the `git worktree list` entry whose `.git` is a directory, not a file) into the same path here — `.env`, `.env.*`, and any nested ones.

**Migration guard.** About to add a DB migration while the worktree still shares the primary's dev DB? Isolate the DB first, or divergent migrations across branches corrupt the shared schema. If the repo ships `scripts/provision.sh` with a per-worktree-DB mode (e.g. `scripts/provision.sh db`), run that; otherwise follow the repo's own convention for an isolated dev DB before migrating.

Completion: you are standing in the feature's worktree with its env files (and, if a provisioner ran, its ports/DB), on the layer branch for the ticket you're about to build.

## Step 1 — Build the ticket

Use /tdd where possible, at pre-agreed seams.

Build **one ticket per layer** — the ticket is already sized for it, so don't subdivide. If a ticket turns out to be genuinely too large for one reviewable PR, split the *ticket* on the tracker and give each half its own layer, rather than quietly stretching one layer to cover both.

## Close out

- **After each ticket** — /ticket-done. It owns the scoped checks, the cold-read, the commit, the layer's PR, and opening the next layer. Then **clear context** and take the next ticket from the stack.
- **Once the last ticket seals** — /feature-done, which reviews the whole feature against the spec and hands to /ship.
