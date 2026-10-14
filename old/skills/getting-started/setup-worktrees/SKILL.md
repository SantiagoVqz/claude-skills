---
name: setup-worktrees
description: "Install worktree provisioning in this repo: scripts/provision.sh and the session hook that runs it in every linked worktree, so a worktree has env files, dependencies, free ports and a database before any work. Run once per repo, after /setup-skills."
disable-model-invocation: true
---

# Setup Worktrees

Code work runs in a linked worktree; planning and docs stay in the primary checkout. A worktree is made by Herdr, by `git worktree add`, or by the `worktree` skill, and all three must end up provisioned the same way. This skill installs the two files that make that true:

- `scripts/provision.sh`: copies the primary's gitignored env files, installs dependencies, stamps a free port pair, creates a test database for the worktree, and points the app at the primary's dev database. `db fork` clones that database as `<db>_<branch>` for a worktree with schema changes; a rerun keeps the fork. Idempotent, refuses to run in the primary. Only its CONFIG block is per repo.
- `.claude/hooks/provision-worktree.sh`: runs the script on every session that opens in a linked worktree, and after `EnterWorktree`. Outside a linked worktree it does nothing.

Both templates sit beside this file. This is a prompt-driven skill: explore, present, confirm, then write.

## 1. Explore

- `scripts/provision.sh` and `.claude/hooks/provision-worktree.sh`: does either exist already? An existing script is edited in its CONFIG block only.
- What a fresh worktree lacks: gitignored `.env*` files (`git ls-files --others --ignored --exclude-standard`), a dependency lockfile per package, a database URL in an env file, a migration tool.
- Dev servers and the env vars that carry their ports, from the README and the env files.
- The database: compose service name and pinned project `name:` in the compose file, or a host Postgres; user, password, published port; the app's database URL and test database URL variables.
- Which of `CLAUDE.md` / `AGENTS.md` holds the `## Agent skills` block from `/setup-skills`. That file gets the Worktrees block; `CLAUDE.md` when neither has it.

Completion: you can fill every CONFIG value or name the ones you need from the user.

## 2. Present and confirm

Show the filled CONFIG block: `install_deps`, the port bases and `stamp_ports`, and the DATABASE block, or its deletion for a repo with no database. Ask for the values you could not find. Let the user edit before writing.

## 3. Write

- `provision.sh` → `scripts/provision.sh`, executable, CONFIG as confirmed. The ENGINE and database engine sections are copied verbatim.
- `hook.sh` → `.claude/hooks/provision-worktree.sh`, executable.
- Merge into `.claude/settings.json`, keeping hooks already there:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/provision-worktree.sh", "timeout": 600 } ] }
    ],
    "PostToolUse": [
      { "matcher": "EnterWorktree", "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/provision-worktree.sh", "timeout": 600 } ] }
    ]
  }
}
```

- `.claude/worktrees/` in `.git/info/exclude`, so a dispatch-made worktree never shows in `git status`.
- The block below in the file chosen in step 1, after `## Agent skills`:

```markdown
### Worktrees

Code work runs in a linked worktree, one spec per worktree. Before `/implement` writes code, invoke the `worktree` skill. `scripts/provision.sh` sets up each worktree: env files, dependencies, [the stamped ports], [its own test database, and the primary's dev database, forked as `<db>_<branch>` when the spec has schema changes]. Planning and changes to docs only stay in the primary checkout.
```

Drop the bracketed parts the CONFIG does not do.

Completion: both files executable, the hook registered, the exclude line present, the block written.

## 4. Verify

Make a throwaway worktree off the trunk in `.claude/worktrees/provision-check`, run `scripts/provision.sh` in it, and show the tail. When the repo has a database, the tail shows it shared; run `scripts/provision.sh db fork` and see it forked. Green: run `scripts/provision.sh db drop` there when the repo has a database, then `git worktree remove` it and delete its branch. Red: fix the CONFIG and rerun until green; the human never inherits a script that failed.

## Report

Files written · CONFIG summary (deps, ports, database or none) · verify result · the file that holds the Worktrees block.
