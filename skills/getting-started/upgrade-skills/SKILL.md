---
name: upgrade-skills
description: "Bring a repo that was set up under an earlier version of this skill set up to the current one: refresh its Agent skills block, replace in-repo skill copies with links to the current skills, and move an old worktree harness to the current provision script and hook. Run once per repo after this skill set changes."
disable-model-invocation: true
---

# Upgrade Skills

A repo set up months ago carries the skill set as it was then: copied skill folders, an `## Agent skills` block in an older shape, a worktree harness with rules the current skills contradict. This skill brings one repo to the current set without touching anything the repo wrote for itself.

The current set lives in the repo three folders above this file (`../../..` from this skill's folder), with `install.sh` at its root and the skills under `skills/`. That repo is the source of truth for every skill it holds; the target repo is the source of truth for everything else.

This is a prompt-driven skill: explore, present the plan, confirm, then apply.

## 1. Explore

Read the target repo and record each finding:

- **Agent file**: `CLAUDE.md` and `AGENTS.md` at the root. Which one is real, which is a symlink to the other. The real one is the file edited below. Missing `## Agent skills` block: say `Run /setup-skills first` and stop; this skill upgrades a setup, it does not create one.
- **Block shape**: the sub-blocks under `## Agent skills`, and any worktree text anywhere in the file: a `### Worktrees` sub-block, a top-level `## Worktrees` section, a rule such as "work in a worktree, never in the primary checkout".
- **In-repo skills**: every folder in `.claude/skills/`. For each: symlink or copy, its prefix (`<prefix>-<leaf>`), and whether `<leaf>` exists in the current set (`find <set>/skills -name SKILL.md`). A copy whose leaf is in the set is **stale**. A copy whose leaf is not in the set is **repo-own** and stays as it is. A symlink into the set is current.
- **Worktree harness**: `scripts/provision.sh` and its CONFIG block; `.claude/hooks/provision-worktree.sh`; any other worktree hook, such as a PreToolUse guard that refuses edits in the primary; the hooks in `.claude/settings.json`; `.claude/worktrees/` in `.git/info/exclude`.
- **Provisioning need**: gitignored `.env*` files, a lockfile, a database URL in an env file. A repo with none of these gets no harness.

Completion: a table of findings, each marked current, stale, repo-own, or missing.

## 2. Present the plan

One line per change, grouped as below. The human strikes lines before anything is written.

## 3. Apply

**Agent file.** Rewrite the `## Agent skills` block to the shape `/setup-skills` writes today: `### Issue tracker`, `### Triage labels` (only when `docs/agents/triage-labels.md` exists), `### Domain docs`, each a one-line summary plus its `See docs/agents/<file>.md` pointer. Keep the existing summaries; they are the repo's. Add the docs-to-trunk sentence to `### Domain docs` exactly as `/setup-skills` writes it (`../setup-skills/SKILL.md`), when it is missing. When `docs/agents/triage-labels.md` has no `later` row, add the row from the template (`../setup-skills/triage-labels.md`), and create the label on a GitHub tracker. Remove every old worktree rule and section. When the repo keeps a harness, write the `### Worktrees` sub-block exactly as step 3 of the `setup-worktrees` skill writes it (`../setup-worktrees/SKILL.md`), with the bracketed parts the CONFIG does not do dropped. An older Worktrees block is replaced: the current one sends `/implement` to the `worktree` skill.

Text outside the block stays byte for byte.

**In-repo skills.** For each stale copy: delete the folder, then `<set>/install.sh skills/<path-to-leaf> --prefix <prefix>` from the target repo root (`--no-prefix` when the copy had none). The link keeps the same name the repo already uses in prompts. Repo-own skills are listed in the report and left alone. A repo that links the set into `.claude/skills/` and has a harness also gets `worktree` linked, with the same prefix.

**Worktree harness.** When the repo needs provisioning:

- `scripts/provision.sh`: take the CONFIG values from the old file (`install_deps`, port bases, `stamp_ports`, the DATABASE variables, `stamp_database`, `migrate`) and put them into the current template from the `setup-worktrees` skill folder. The ENGINE section is the template's. `stamp_database` now takes the dev database and the test database as two arguments; adapt the old body to it. Say what changed: the default shares the primary's dev database, `db fork` is the explicit fork, and `db share` and `--no-db` are gone.
- `.claude/hooks/provision-worktree.sh`: replace with the template's `hook.sh`.
- A primary-checkout guard hook: delete the file and its entry in `.claude/settings.json`. Planning and changes to docs only happen in the primary now.
- `.claude/settings.json`: the SessionStart and PostToolUse(EnterWorktree) entries as `/setup-worktrees` writes them; other hooks stay.
- `.claude/worktrees/` in `.git/info/exclude`.

Completion: every line of the confirmed plan applied, or named as skipped with the reason.

## 4. Verify

- `ls -la .claude/skills` shows a link for every skill of the set, a folder for every repo-own one.
- With a harness: a throwaway worktree off the trunk in `.claude/worktrees/provision-check` runs `scripts/provision.sh` green. When there is a database, the tail shows it shared, `db fork` runs green, and `db drop` removes the fork and the test database. Then `git worktree remove` it and delete its branch.

## Report

Agent file edited (which) · block sub-blocks written · `later` row and label added or n/a · worktree text removed · skills linked (listed) · repo-own skills left (listed) · harness replaced, kept, or none · guard removed or n/a · verify result.
