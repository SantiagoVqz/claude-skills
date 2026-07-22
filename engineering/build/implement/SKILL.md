---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

**Worktree preflight.** If you're in a git worktree (`git rev-parse --absolute-git-dir` differs from `--git-common-dir`), it needs setup a fresh checkout lacks. **Prefer the repo's provisioner:** if `scripts/provision.sh` exists, run it — it owns this repo's worktree setup (gitignored env, dev-server ports, any per-worktree DB) and is expected to be idempotent. **Otherwise** fall back to copying every gitignored env file from the primary checkout (the `git worktree list` entry whose `.git` is a directory, not a file) into the same path here — `.env`, `.env.*`, and any nested ones. Completion: the worktree has its env files (and, if a provisioner ran, its ports/DB).

**Migration guard.** About to add a DB migration while the worktree still shares the primary's dev DB? Isolate the DB first, or divergent migrations across branches corrupt the shared schema. If the repo ships `scripts/provision.sh` with a per-worktree-DB mode (e.g. `scripts/provision.sh db`), run that; otherwise follow the repo's own convention for an isolated dev DB before migrating.

Use /tdd where possible, at pre-agreed seams.

Close out in proportion to what you built:

- **A single slice** — run the repo's checks, then commit.
- **A phase of a multi-phase build** — /phase-done after each one; it owns the checks, the commit, and the cold-read.
- **The whole branch, once the last phase lands** — /two-axis-review against its base.
