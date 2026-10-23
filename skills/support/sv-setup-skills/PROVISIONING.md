# Provisioning

Install two files so that every linked worktree gets env files, dependencies, free ports and its databases before work starts:

- [provision.sh](provision.sh) → `scripts/provision.sh`. It sets up the worktree that it runs in. Only its CONFIG block and its DATABASE block change per repo.
- [hook.sh](hook.sh) → `.claude/hooks/provision-worktree.sh`. It runs `provision.sh` when a session opens in a linked worktree. `sv-worktree` runs `provision.sh` itself after `EnterWorktree`, so no hook runs on that tool. A hook on it also provisioned a worktree that `sv-worktree` Remove was about to drop.

## Existing script

When `scripts/provision.sh` exists and has no ENGINE header, it is the repo's own script, and an ADR can require it. Keep it. Check the contract that `sv-worktree` needs:

- With no argument, it provisions the worktree that it runs in, and the end of its output names the dev and test databases.
- With `drop`, it removes the databases that the worktree owns.

Add only the mode that is missing, in the style of the script. Then install the hook and run the check below. Show the change in the confirm step.

## Fill the CONFIG

Find each value in the repo. Ask the user only for the values that you cannot find.

- `install_deps`: the install command for each lockfile, run from its folder.
- `FE_PORT_BASE`, `BE_PORT_BASE` and `stamp_ports`: the dev servers and the env vars that carry their ports, from the README and the env files. Leave a base empty for a server that picks its own port.
- DATABASE block: `APP_DB` is the primary's dev database. Then the user, the password, the port, and the compose service, or empty for Postgres on the host. A compose file must pin its project `name:`, so that every worktree uses the same container. `db_url`, `stamp_database` and `migrate` use the app's own variables and migration tool.
- No database: delete the DATABASE block, down to the ENGINE header.

Show the filled block in the confirm step.

## Install

- Write both files, executable. Copy the ENGINE section of `provision.sh` as it is.
- Merge the hook into `.claude/settings.json`. Keep the hooks that are already there. Remove a `PostToolUse` hook on `EnterWorktree` that runs `provision-worktree.sh`, from an earlier run.

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/provision-worktree.sh", "timeout": 600 } ] }
    ]
  }
}
```

## Check

1. Make a throwaway worktree from the trunk: `git worktree add -b provision-check .claude/worktrees/provision-check <trunk>`.
2. Run `scripts/provision.sh` in it. The end of the output names a dev database `<APP_DB>_provision_check` and a test database with the `_test` suffix.
3. Run `scripts/provision.sh drop` in it. Then `git worktree remove` it and delete the `provision-check` branch.

When a step fails, fix the CONFIG and run the check again. The check passes before the user gets the script.
