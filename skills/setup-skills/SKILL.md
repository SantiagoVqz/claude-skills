---
name: setup-skills
description: Configure this repo for the harness — issue tracker, triage label vocabulary, domain doc layout, and worktree/Docker provisioning. Run once before first use of the other skills.
disable-model-invocation: true
---

# Setup Skills

Scaffold the per-repo configuration that the harness skills assume:

- **Issue tracker** — where issues live (GitHub by default; local markdown is also supported out of the box)
- **Triage labels** — the strings used for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them
- **Worktree provisioning** — an optional `scripts/provision.sh` run to set up a fresh worktree (env, dev-server ports, per-worktree DB, dependency install); skipped for repos with no dev servers or DB
- **Dev environment shape** — whether development runs in Docker (a compose file) or natively, so provisioning and teardown know what each worktree owns

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use
- Is the `triage` skill installed? (a `triage` skill folder alongside this one, or `triage` in your available skills.) This decides whether Section B runs at all.
- `scripts/provision.sh` — does the worktree provisioner already exist? Note the repo's shape for Section D: a `frontend`/`backend` split, the env vars carrying each server's URL to the other, a `DATABASE_URL` in a backend env file, a migration tool (Alembic `migrations/`, Prisma, etc.).
- Docker signals — a `docker-compose.yml`/`compose.yaml` or `Dockerfile`. A compose file means dev runs in Docker: worktrees share the compose project name by default (directory basename), so Section D must record how ports, project names, and volumes are kept per-worktree, and `/cleanup`'s Docker teardown applies.
- Monorepo signals — a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. Present only in a genuinely large multi-package repo; their absence means single-context, which is almost every repo.

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order — one section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Give a one-line explainer only when the choice genuinely branches; skip the section entirely when exploration already settled it (Section B when `triage` isn't installed, Section C when there's no monorepo).

**Section A — Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `tickets`, `triage`, `spec`, and `wayfinder` read from and write to it — they need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub** — issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** — issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Linear** — issues live in a Linear team (via the Linear MCP server or CLI, whichever is available — record which, plus the team key, in the tracker doc; if neither is reachable, say so and fall back to asking the user how they drive Linear)
- **Local markdown** — issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, etc.) — ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

Record the choice in `docs/agents/issue-tracker.md`. The GitHub and GitLab templates carry a "PRs as a request surface" flag, defaulted **off** — leave it off and don't raise it; a user who wants external PRs in the triage queue can flip the flag in the file later.

**Section B — Triage label vocabulary.** Skip this section entirely if the `triage` skill isn't installed (exploration told you) — an uninstalled skill needs no labels.

If it is installed, ask exactly one question:

> Do you want to keep the default triage labels? (recommended: **yes**)

The defaults are the five canonical roles, each label string equal to its name: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. On **yes**, write them as-is. Only if the user says no — usually because their tracker already uses other names (e.g. `bug:triage` for `needs-triage`) — collect the overrides so `triage` applies existing labels instead of creating duplicates.

**Section C — Domain docs.** Default to **single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root. This fits almost every repo; write it without asking.

Offer **multi-context** — a root `CONTEXT-MAP.md` pointing to per-context `CONTEXT.md` files — only when exploration found monorepo signals. Then confirm which layout they want.

**Section D — Worktree provisioning.** Skip this section outright for a repo with no dev servers and no dev DB — there is nothing to provision. Otherwise offer `scripts/provision.sh`, adapted from the copy in this skill folder: it copies gitignored env files into a fresh worktree, stamps a non-colliding dev-server port pair, installs dependencies (`node_modules` and friends — a fresh worktree has none), and (on `provision.sh db`) clones the dev DB per worktree so divergent migrations can't corrupt the shared schema. Only its CONFIG block needs editing — port bases, the port-dependent env vars, and the DB clone. Run it inside each fresh worktree as the worktree is set up. The goal: every worktree is **manually testable the moment it's provisioned** — env set, deps installed, servers startable on their own ports.

If exploration found Docker signals, extend the CONFIG for Docker: stamp `COMPOSE_PROJECT_NAME` (or a `name:` override) per worktree so parallel stacks don't collide on the shared directory-basename default, and record in the block comment which volumes/DBs are shared vs per-worktree — `/cleanup`'s Docker teardown reads that distinction. Record the choice (Docker vs native) in `docs/agents/domain.md`'s environment note so other skills don't re-detect it.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and `docs/agents/triage-labels.md` (the last only when `triage` is installed)

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Include the `### Triage labels` sub-block, and write `docs/agents/triage-labels.md`, only when `triage` is installed and Section B ran. When it isn't, both are omitted.

Then write the docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./triage-labels.md) — label mapping (only if `triage` is installed)
- [domain.md](./domain.md) — domain doc consumer rules + layout
- [provision.sh](./provision.sh) — worktree provisioner, copied to `scripts/provision.sh` (only if Section D ran)

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later — re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.
