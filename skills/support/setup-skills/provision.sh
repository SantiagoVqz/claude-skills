#!/usr/bin/env bash
#
# provision.sh — provision the linked git worktree you are standing in.
#
#   scripts/provision.sh            # env files, dependencies, ports, databases
#   scripts/provision.sh drop       # remove the databases this worktree owns (teardown)
#
# It never creates a worktree; it sets up the one you are in, whoever made it:
# the worktree skill, `git worktree add`, or another tool. Idempotent: a second
# run copies nothing, keeps stamped ports, and finds the databases there. The
# primary checkout refuses to run it.
#
# Two database rules:
# - Each branch made from the trunk (spec/*, fix/*) owns a dev database, a
#   clone of APP_DB named <APP_DB>_<branch>. A migration there never touches
#   the primary or another branch.
# - Each worktree owns a test database, <dev name of its own branch>_test. The
#   suite truncates it, so two worktrees never share one.
# A ticket branch uses the dev database of its spec. The worktree skill records
# the spec in `git config branch.<ticket>.spec <spec-branch>`.
#
# PORTING: edit the CONFIG block only. Delete the DATABASE block for a repo
# with no database; the engine detects its absence.
set -euo pipefail

say()  { printf '▸ %s\n' "$*"; }
warn() { printf '! %s\n' "$*" >&2; }
die()  { printf '✗ %s\n' "$*" >&2; exit 1; }

sedi() {  # in-place sed on GNU and BSD
  if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi
}
get_env() {   # print KEY from an env file, nothing if absent
  [[ -f "$1" ]] || return 0
  sed -nE "s|^[[:space:]]*$2=\"?([^\"]*)\"?[[:space:]]*$|\1|p" "$1" | tail -1
}
set_env() {   # KEY="VAL" in an env file: replace the line or append it
  local file="$1" key="$2" val="$3"
  mkdir -p "$(dirname "$file")"; touch "$file"
  if grep -qE "^[[:space:]]*${key}=" "$file"; then
    sedi -E "s|^[[:space:]]*${key}=.*|${key}=\"${val}\"|" "$file"
  else
    printf '%s="%s"\n' "$key" "$val" >>"$file"
  fi
}

# ============================================================================
# CONFIG — the only part you edit per repo.
# ============================================================================

# 1. Dependencies. A fresh worktree has no node_modules and no .venv.
install_deps() {
  ( cd "$WT" && pnpm install --prefer-offline )
  ( cd "$WT/backend" && uv sync )
}

# 2. Dev-server ports, so two worktrees can run their servers at once. The
#    port is ${BASE}${NN}; NN comes from the branch number, then moves up
#    until free. Leave empty for a server that picks its own port.
FE_PORT_BASE="51"
BE_PORT_BASE="80"

# Stamp the env vars that carry those ports. Runs with $FE_PORT, $BE_PORT and
# $WT set; an empty base leaves its port empty.
stamp_ports() {
  set_env "$WT/frontend/.env" DEV_PORT     "$FE_PORT"
  set_env "$WT/frontend/.env" BACKEND_URL  "http://127.0.0.1:$BE_PORT"
  set_env "$WT/backend/.env"  BACKEND_PORT "$BE_PORT"
  set_env "$WT/backend/.env"  FRONTEND_URL "http://localhost:$FE_PORT"
}

# ============================================================================
# DATABASE — Postgres in a docker compose service, or on the host. Delete the
# whole block, down to the ENGINE header, for a repo with no database.
# ============================================================================

APP_DB="myapp"          # the primary's dev database: the template for every fork
DB_USER="myapp"
DB_PASSWORD="myapp"
DB_PORT="5432"          # the published port, shared by every worktree
DB_SERVICE="db"         # compose service; empty runs psql on the host instead

db_url() { printf 'postgresql+psycopg://%s:%s@127.0.0.1:%s/%s' "$DB_USER" "$DB_PASSWORD" "$DB_PORT" "$1"; }

stamp_database() {   # point the app at dev database $1 and test database $2
  set_env "$WT/backend/.env" DATABASE_URL      "$(db_url "$1")"
  set_env "$WT/backend/.env" TEST_DATABASE_URL "$(db_url "$2")"
}

migrate() {          # bring database $1 to head
  ( cd "$WT/backend" && DATABASE_URL="$(db_url "$1")" uv run alembic upgrade head )
}

# ============================================================================
# ENGINE — repo-independent. Leave alone.
# ============================================================================

# ---- database engine: runs only when the DATABASE block defines APP_DB ----

pg_do() {            # a postgres client tool against the shared server
  if [[ -n "$DB_SERVICE" ]]; then
    ( cd "$WT" && docker compose exec -T "$DB_SERVICE" "$1" -h 127.0.0.1 -U "$DB_USER" "${@:2}" )
  else
    PGPASSWORD="$DB_PASSWORD" "$1" -h 127.0.0.1 -p "$DB_PORT" -U "$DB_USER" "${@:2}"
  fi
}

db_exists() { pg_do psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$1'" | grep -q 1; }

create_db() {
  db_exists "$1" && { say "Database $1 is already there"; return; }
  pg_do createdb "$1"; say "Created database $1"
}

start_db_server() {
  [[ -n "$DB_SERVICE" ]] || return 0
  docker info >/dev/null 2>&1 || die "the docker daemon is not running"
  # The compose project name must be pinned in the compose file (`name:`), so
  # every worktree drives the one container instead of a copy keyed to its path.
  ( cd "$WT" && docker compose up -d "$DB_SERVICE" )
  local tries=0
  until pg_do pg_isready >/dev/null 2>&1; do
    (( ++tries > 60 )) && die "PostgreSQL did not become ready"
    sleep 1
  done
}

db_name() {          # db_name <branch>: the dev database name for a branch
  local slug
  slug="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g')"
  # 58, not 63: the _test suffix must fit in Postgres's 63-byte name limit.
  printf '%s_%s' "$APP_DB" "${slug:-branch}" | cut -c1-58
}

clone_db() {         # clone_db <template> <new>
  db_exists "$2" && { say "Database $2 is already there"; return; }
  # TEMPLATE refuses while anything holds a connection to the template, and a
  # running dev server always does. Copying works regardless.
  if pg_do psql -d postgres -q -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"$2\" TEMPLATE \"$1\";" >/dev/null 2>&1; then
    say "Cloned $1 into $2"
  else
    warn "$1 is in use, copying it instead of cloning (slower)"
    pg_do createdb "$2"
    pg_do pg_dump "$1" | pg_do psql -q -o /dev/null -d "$2"
    say "Copied $1 into $2"
  fi
}

provision_db() {
  start_db_server
  create_db "$APP_DB"
  local own; own="$(db_name "$BRANCH")"
  # The test database starts empty: the test suite migrates and truncates it.
  create_db "${own}_test"
  if [[ -n "$SPEC" ]]; then
    # A ticket uses its spec's database. Only the schema ticket migrates it.
    local dev; dev="$(db_name "$SPEC")"
    db_exists "$dev" || { clone_db "$APP_DB" "$dev"; migrate "$dev"; }
    stamp_database "$dev" "${own}_test"; DB_NAME="$dev (spec $SPEC)"
  else
    clone_db "$APP_DB" "$own"
    # The trunk can be ahead of the primary's database. Bring the clone to head.
    say "Bringing $own to head"; migrate "$own"
    stamp_database "$own" "${own}_test"; DB_NAME="$own"
  fi
  TEST_DB_NAME="${own}_test"
}

drop_db() {
  start_db_server
  local own; own="$(db_name "$BRANCH")"
  [[ "$own" == "$APP_DB" ]] && die "refusing to drop the primary's database"
  pg_do dropdb --if-exists "${own}_test"
  local dropped="${own}_test"
  # A ticket leaves its spec's database alone: the spec owns it.
  if [[ -z "$SPEC" ]] && db_exists "$own"; then pg_do dropdb "$own"; dropped="$own and $dropped"; fi
  say "Dropped $dropped"
}


MODE="provision"
case "${1:-}" in
  "")     ;;
  "drop") MODE="drop" ;;
  *)      die "usage: provision.sh [drop]" ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not inside a git repo"
GIT_DIR="$(git rev-parse --absolute-git-dir)"
COMMON="$(git rev-parse --path-format=absolute --git-common-dir)"
[[ "$GIT_DIR" != "$COMMON" ]] || die "this is the primary checkout — run provision.sh inside a worktree"
WT="$(git rev-parse --show-toplevel)"
PRIMARY="$(dirname "$COMMON")"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
SPEC="$(git config --get "branch.$BRANCH.spec" || true)"

if [[ "$MODE" == "drop" ]]; then
  # Teardown runs the same way in every repo, so a repo with no database is a no-op.
  if [[ -n "${APP_DB:-}" ]]; then drop_db; else say "No database to drop"; fi
  exit 0
fi

say "Provisioning $WT (branch $BRANCH, primary $PRIMARY)"

# Gitignored env files, first run only, so stamped values survive a rerun.
copied=0
while IFS= read -r rel; do
  [[ -z "$rel" || -e "$WT/$rel" ]] && continue
  mkdir -p "$(dirname "$WT/$rel")"
  cp "$PRIMARY/$rel" "$WT/$rel"; ((++copied))
done < <(git -C "$PRIMARY" ls-files --others --ignored --exclude-standard | grep -E '(^|/)\.env(\..*)?$' || true)
say "Copied $copied env file(s) from the primary"

if declare -f install_deps >/dev/null; then say "Installing dependencies"; install_deps; fi

FE_PORT=""; BE_PORT=""
if [[ -n "${FE_PORT_BASE:-}${BE_PORT_BASE:-}" ]]; then
  digits="$(printf '%s' "$BRANCH" | grep -oE '[0-9]+' | tail -1 || true)"
  # NN 00 is the primary's port pair, so a worktree starts at 01.
  NN="01"; [[ -n "$digits" ]] && NN="$(printf '%02d' $((10#$digits % 100)))"
  [[ "$NN" == "00" ]] && NN="01"
  port_busy() { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }
  pair_busy() { local b; for b in ${FE_PORT_BASE:-} ${BE_PORT_BASE:-}; do port_busy "$b$NN" && return 0; done; return 1; }
  # A rerun keeps the stamped pair: this worktree's own servers are what make
  # it busy, and moving them strands the browser and the API URL.
  stamped="$(get_env "$WT/frontend/.env" DEV_PORT)"
  if [[ -n "${FE_PORT_BASE:-}" && "$stamped" == "$FE_PORT_BASE"?? ]]; then
    NN="${stamped#"$FE_PORT_BASE"}"; pair_busy() { return 1; }
  fi
  tries=0
  while pair_busy; do
    NN="$(printf '%02d' $(( 10#$NN % 99 + 1 )))"
    (( ++tries > 99 )) && die "no free port pair"
  done
  [[ -n "${FE_PORT_BASE:-}" ]] && FE_PORT="$FE_PORT_BASE$NN"
  [[ -n "${BE_PORT_BASE:-}" ]] && BE_PORT="$BE_PORT_BASE$NN"
  stamp_ports
  say "Stamped ports  dev:$FE_PORT  api:$BE_PORT"
fi

DB_NAME=""; TEST_DB_NAME=""
if [[ -n "${APP_DB:-}" ]]; then provision_db; fi

say "Worktree provisioned."
printf '  branch  %s\n' "$BRANCH"
[[ -n "$FE_PORT" ]] && printf '  dev     http://localhost:%s\n' "$FE_PORT"
[[ -n "$BE_PORT" ]] && printf '  api     http://127.0.0.1:%s\n' "$BE_PORT"
[[ -n "$DB_NAME" ]] && printf '  db      127.0.0.1:%s/%s\n' "$DB_PORT" "$DB_NAME"
[[ -n "$TEST_DB_NAME" ]] && printf '  test    127.0.0.1:%s/%s\n' "$DB_PORT" "$TEST_DB_NAME"
exit 0
