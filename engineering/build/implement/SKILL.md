---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

**Worktree preflight.** If you're in a git worktree (`git rev-parse --git-common-dir` differs from `git rev-parse --git-dir`), its env files are gitignored and absent in a fresh checkout. Copy every gitignored env file from the primary checkout (the `git worktree list` entry whose `.git` is a directory, not a file) into the same path here — `.env`, `.env.*`, and any nested ones. Completion: every env file present in the primary also exists in this worktree.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
