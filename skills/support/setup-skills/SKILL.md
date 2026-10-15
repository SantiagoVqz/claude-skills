---
name: setup-skills
description: "Set up this repo for the skill set: tracker, labels, domain docs, worktree provisioning, and the Agent skills block in AGENTS.md. Run once per repo, and again to repair."
disable-model-invocation: true
---

# Setup skills

Every other skill finds the tracker, the domain docs and the worktree rules through the `## Agent skills` block in `AGENTS.md`. This skill writes that block and the files it points at. A rerun repairs what is missing and keeps what is already correct.

## 1. Explore

Read the repo's current state:

- `git remote -v`: the host of the repo.
- `gh auth status`: `gh` can write to this repo.
- `AGENTS.md` and `CLAUDE.md` at the root: which exist, whether one has an `## Agent skills` block, and whether `CLAUDE.md` imports `@AGENTS.md`.
- `docs/agents/`: files from an earlier run.
- `GLOSSARY.md` and `docs/adr/`.
- `gh label list`: labels that already exist.
- What a new worktree lacks: gitignored `.env` files (`git ls-files --others --ignored --exclude-standard`), a lockfile, a database URL in an env file. When the repo has none of these, it needs no provisioning.
- `scripts/provision.sh` and `.claude/hooks/provision-worktree.sh`: files from an earlier run.

Completion: you can name the tracker, the state of each file above, each label that is missing, and whether the repo needs provisioning.

## 2. Confirm

The tracker is GitHub when the remote is on GitHub. This version supports GitHub only. For any other tracker, stop and say that this version does not support it.

Show the user, in one message:

- The `## Agent skills` block from step 3, and the file that gets it.
- The files that you will write or change, and the labels that you will create.
- When the repo needs provisioning: the filled CONFIG block of `provision.sh`, from [PROVISIONING.md](PROVISIONING.md).
- Each existing file or label that you will keep as it is.

Ask each choice with the question tool, one at a time: the tracker, and each existing file or label that you could keep or replace. Put your recommendation first. Then show the drafts, and ask for approval with the question tool. Give the options "Approve" and "Change". When the user picks Change, apply the edits and ask again.

Completion: the user picked Approve.

## 3. Write

**Docs.** Copy [tracker-github.md](tracker-github.md) to `docs/agents/tracker.md` and [domain.md](domain.md) to `docs/agents/domain.md`. When a file exists, keep the user's edits and add only what is missing.

**Labels.** Create each label from the table in `tracker-github.md`. Use its Meaning as the description: `gh label create <name> --description "<meaning>" --force`. `--force` updates a label that exists, so a rerun is safe.

**Block.** The block goes in `AGENTS.md`, because agents other than Claude Code read that file. Make `CLAUDE.md` load it:

- No `AGENTS.md`: create it with the block.
- `AGENTS.md` exists: replace its `## Agent skills` block, or append the block when there is none. Keep every other section.
- No `CLAUDE.md`: create it with the line `@AGENTS.md`.
- `CLAUDE.md` exists without `@AGENTS.md`: add the line at the top. When `CLAUDE.md` has an `## Agent skills` block from an earlier set, move its content to `AGENTS.md`, so that one block remains.

```markdown
## Agent skills

### Tracker

Specs, tickets and bugs are GitHub issues. Before you create, read, link, label or close an issue, read `docs/agents/tracker.md`.

### Domain docs

Before you explore the code, read `GLOSSARY.md` and the ADRs in `docs/adr/` for the area. The rules are in `docs/agents/domain.md`.

### Worktrees

Code work runs in a linked worktree under `.claude/worktrees/`. The primary checkout stays on the trunk. Before code work starts on a branch, use the `worktree` skill.
```

**Worktrees.** When the repo needs provisioning, install it with [PROVISIONING.md](PROVISIONING.md). Add `.claude/worktrees/` to `.gitignore` in every repo.

Leave the changes uncommitted. The user commits them.

Completion: both docs files exist, `gh label list` shows every label from the table, `AGENTS.md` has exactly one `## Agent skills` block, `CLAUDE.md` loads `@AGENTS.md`, and the provisioning check in `PROVISIONING.md` passed, or the repo needs no provisioning.

## Report

Tracker · files written, changed or kept · labels created or updated · the file that holds the block · provisioning: deps, ports, database, or none · the files left to commit.
