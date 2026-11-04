# Upgrade

`/setup-skills --upgrade` brings a repo that was set up earlier to the current rules. It changes only what differs, and shows each change first.

## 1. Compare

Read the repo as in step 1 of [SKILL.md](SKILL.md), then compare each item:

- `docs/agents/tracker.md` and `docs/agents/domain.md` against [tracker-github.md](tracker-github.md) and [domain.md](domain.md): the content that is missing. A difference that the user wrote stays.
- The `## Agent skills` block and the `@AGENTS.md` line.
- `gh label list` against the table in `tracker-github.md`.
- `.claude/skills/`: each old copy of a skill of this set.
- The hook against [hook.sh](hook.sh) and the settings in [PROVISIONING.md](PROVISIONING.md).
- The engine: run [upgrade-engine.sh](upgrade-engine.sh) `scripts/provision.sh`. Its last line is the state. For `own`, check the contract in `PROVISIONING.md` under Existing script.
- The compose file: each rule in `PROVISIONING.md` under Compose rules.

Completion: each item above has a state of current, or a named change.

## 2. Confirm

Show one message: each change with its diff, and each item that stays. For a port move, name the env files that change. When an ADR fixes a value that a rule would change, show the conflict and keep the value unless the user picks the rule. Ask with the question tool, with the options "Approve" and "Change". When the user picks Change, apply the edits and ask again. When every item is current, report that, and stop.

Completion: the user picked Approve.

## 3. Apply

Make a linked worktree from the trunk on the branch `fix/upgrade-skills`, and make each change to a tracked file there. Run `upgrade-engine.sh scripts/provision.sh --apply` there. Leave the changes uncommitted. The user commits them.

**Port move.** Change the port in the compose file or `DB_PORT`, whichever holds it. Then change each gitignored env file that holds the old port, in the primary and in each linked worktree. Run `git worktree list` to find them. Change only the port, and print no value from an env file. Stamped database URLs hold the port too.

**Containers.** A bind or a port applies only when the container is made again. From the folder of the compose file in the upgrade worktree, run `docker compose --env-file <primary>/.env up -d <service>` when the primary has a root `.env`, and leave out the flag when it has none. The named volume stays. List the databases before and after, and confirm that the lists match.

Completion: `upgrade-engine.sh` prints `current` or `own`, each rule under Compose rules holds, and no env file holds an old port.

## 4. Check

The check in `PROVISIONING.md` starts from the trunk, which lacks these changes, so check the upgrade worktree itself. Run `scripts/provision.sh` in it. The end of the output names its dev and test databases. Then run `scripts/provision.sh drop`. Keep the worktree: it holds the uncommitted changes.

Completion: the check passed, or the report names the step that failed, with the end of its output.

## Report

Each item · current, changed or kept · the engine state · the port before and after · the check result · the branch and the files left to commit · the step that remains until the merge: worktrees made from the trunk before the merge still get the old `provision.sh`.
