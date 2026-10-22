# No setup

A skill reads this file when the `## Agent skills` block is missing from `AGENTS.md`. The skill goes on with the sources below, and its report names each fallback that it used.

- **Rules**: `AGENTS.md` or `CLAUDE.md` at the root, when they exist.
- **Glossary**: `GLOSSARY.md` or `CONTEXT.md` at the root, and the ADRs in `docs/adr/`. With none of these, work from the code alone.
- **Tracker**: a file in `docs/agents/` that names the tracker. Otherwise, when `git remote -v` is on GitHub and `gh repo view --json viewerPermission` shows `WRITE`, `MAINTAIN` or `ADMIN`, use the operations in [tracker-github.md](tracker-github.md). Add a label only when `gh label list` shows it. With no tracker, the report keeps the issue text, and the branch name has no number: `fix/<slug>`.
- **Worktree**: call the `sv-worktree` skill. When it reports blocked:
  - The primary checkout is clean: make the branch there with `git switch -c <branch>`, and commit on it.
  - The primary checkout has changes: work in place, and commit nothing. The report lists each file that you changed.

`/sv-ship` and `/sv-cleanup` need the setup, so the report gives the next step as `/sv-setup-skills`, or as the user's own commit and PR.
