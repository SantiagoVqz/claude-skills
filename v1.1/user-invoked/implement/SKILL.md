---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

**Worktree preflight.** If you're in a git worktree (`git rev-parse --absolute-git-dir` differs from `--git-common-dir`), it needs setup a fresh checkout lacks. **Prefer the repo's provisioner:** if `scripts/provision.sh` exists, run it — it owns this repo's worktree setup (gitignored env, dev-server ports, any per-worktree DB) and is expected to be idempotent. **Otherwise** fall back to copying every gitignored env file from the primary checkout (the `git worktree list` entry whose `.git` is a directory, not a file) into the same path here — `.env`, `.env.*`, and any nested ones. Completion: the worktree has its env files (and, if a provisioner ran, its ports/DB).

**Migration guard.** About to add a DB migration while the worktree still shares the primary's dev DB? Isolate the DB first, or divergent migrations across branches corrupt the shared schema. If the repo ships `scripts/provision.sh` with a per-worktree-DB mode (e.g. `scripts/provision.sh db`), run that; otherwise follow the repo's own convention for an isolated dev DB before migrating.

Use /tdd where possible, at pre-agreed seams.

Build in **phases** — one PR-sized chunk each, the largest piece someone can review in one sitting. Most tickets are a single phase; reach for more only when one PR would genuinely be unpleasant to review. Agree the phases with the user before building, and don't manufacture them to look thorough.

Close out:

- **After each phase** — /phase-done. It owns the simplify, the repo's own checks, the commit, the cold-read, and opening the next phase. A single-phase ticket runs it once.
- **Once the last phase lands** — /ship.
