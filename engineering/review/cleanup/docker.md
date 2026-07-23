# Docker teardown

A repo with a compose file leaves containers, volumes, images and build cache that git teardown never touches. Sort them into two piles before removing anything:

- **Keyed** — the artifact carries this ticket's name or path. Yours to destroy.
- **Dangling** — untagged images and anonymous volumes attributable to no branch at all. Machine-global debris; reclaim it deliberately, never as a side effect.

## Why almost nothing is keyed by default

Compose resolves the project name in this order: `name:` in the compose file → `-p` flag → `COMPOSE_PROJECT_NAME` → **basename of the directory holding the compose file**. That last default is the usual one, and a worktree mirrors the repo's layout — `<primary>/backend/` and `<worktree>/backend/` both yield project `backend`.

So every worktree drives the *same* stack: same containers, same named volumes (`<project>_<volume>`), same network, same built image tag (`<project>-<service>`). Nothing carries the branch, and a search keyed to the branch correctly returns nothing.

Meanwhile the stack still sheds debris on every run: a rebuild retags `<project>-<service>` and orphans the previous image, and each container recreation abandons its anonymous volumes (`- /app/.venv` and friends) when brought down without `-v`.

## Detect the shape

Compose stamps the launch site onto every container it creates:

```bash
docker ps -a --format '{{.Names}}\t{{.Label "com.docker.compose.project"}}\t{{.Label "com.docker.compose.project.working_dir"}}'
docker volume ls --format '{{.Name}}\t{{.Label "com.docker.compose.project"}}'
```

- **Keyed** — the project name contains the branch or ticket, or `working_dir` points inside the worktree you're removing. Tear the stack down *before* `git worktree remove`; compose needs its config file to resolve the project:
  ```bash
  docker compose -p <project> down --volumes --remove-orphans --rmi local
  ```
- **Shared** — the project name is a plain directory basename that the primary checkout and other worktrees also drive. Leave containers, named volumes and the network alone: dropping `<project>_pgdata` destroys the shared dev DB every other branch is using. Only the dangling pile below is yours.

## The dangling pass

Report before removing — this is machine-global, not ticket-scoped, and a dangling volume can still hold data if its container was removed without it.

```bash
docker system df                      # totals + what's reclaimable
docker images -f dangling=true        # untagged images left by rebuilds
docker volume ls -f dangling=true     # anonymous volumes left by recreated containers
```

Show the user that list with sizes, then on their go-ahead:

```bash
docker image prune -f
docker volume rm <the ids reviewed above>
docker builder prune --filter until=168h -f
```

Reclaim only what the report named. `docker system prune -a --volumes` deletes named volumes and every image not backing a running container — it takes the shared dev DB with it.
