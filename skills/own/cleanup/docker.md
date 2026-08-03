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

- **Keyed** — the project name contains the branch or ticket. Yours end to end. Tear the stack down *before* `git worktree remove`; compose needs its config file to resolve the project:
  ```bash
  docker compose -p <project> down --volumes --remove-orphans --rmi local
  ```
- **Shared** — the project name is a plain directory basename that the primary checkout and other worktrees also drive. Leave containers, named volumes and the network alone: dropping `<project>_pgdata` destroys the shared dev DB every other branch is using. Only the dangling pile below is yours.
- **Worktree-local under a shared name** — the overlap the two bullets above miss, and the usual case: the project name is shared (`backend`) but the *container's* `working_dir` points inside the worktree you're about to remove (check `com.docker.compose.project.working_dir`). Its `config_files` is the worktree's `docker-compose.yml`, which vanishes with the worktree — so it must come down *before* `git worktree remove`, or it strands (see recovery below). But the named volume is shared, so **do not** pass `--volumes`. Stop and drop the worktree's containers only:
  ```bash
  docker compose -p <project> stop && docker compose -p <project> rm -f   # run from inside the worktree, no -v
  ```

**Always, before `git worktree remove`:** list containers whose `working_dir` is inside the worktree and bring them down first — a stopped-but-present container strands just as a running one does.
```bash
docker ps -a --filter "label=com.docker.compose.project.working_dir=<worktree>/backend" --format '{{.Names}}'
```

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

## Orphaned-stack recovery

If the worktree was already removed while a container from it survived, that container's compose project still points `config_files` at a `docker-compose.yml` that no longer exists. Any `docker compose` call against the project then fails with:

```
open .../worktrees/<name>/backend/docker-compose.yml: no such file or directory
```

Compose can't clean this up — it needs the missing file to resolve the project. Remove the container directly instead (stop first if it's running), never `docker compose down`:

```bash
docker ps -a --format '{{.Names}}\t{{.Label "com.docker.compose.project.config_files"}}'  # find the one pointing at a gone path
docker rm -f <container>                                                                    # e.g. backend-db-1
```

Do **not** add `-v` — the named volume (`<project>_pgdata`) is the shared dev DB. Removing the last container clears the stale entry from `docker compose ls -a` on its own.
