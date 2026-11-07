#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(realpath "$0")")/../.."
for tool in docker sha256sum realpath ss awk flock sed cut setsid; do command -v "$tool" >/dev/null || { echo "Required command: $tool" >&2; exit 1; }; done
umask 077
mkdir -p .private/dev
exec 9>.private/dev/setup.lock
flock 9
identity="dev-$(pwd -P | sha256sum | cut -c1-12)"
if [[ ! -e .env ]]; then
  port=$((20000 + 16#${identity:4:4} % 20000))
  while ss -H -ltn "sport = :$port" | awk 'END {exit NR == 0}'; do port=$((port+1)); done
  sed -e "s/^DEV_PROJECT=$/DEV_PROJECT=$identity/" -e "s/^DEV_PORT=$/DEV_PORT=$port/" .env.example > .env
fi
project=$(sed -n 's/^DEV_PROJECT=//p' .env)
port=$(sed -n 's/^DEV_PORT=//p' .env)
[[ "$project" == "$identity" && "$port" =~ ^[0-9]+$ && "$port" -gt 1024 && "$port" -lt 65536 ]] || { echo 'Conflicting .env; preserve it and configure DEV_PROJECT/DEV_PORT for this checkout.' >&2; exit 1; }
compose=(docker compose --env-file .env -f compose.dev.yml -p "$project")
"${compose[@]}" config --quiet
flock -u 9
child=
cleanup() {
  result=$?
  trap - EXIT INT TERM
  if [[ -n "$child" ]]; then kill -TERM -- "-$child" 2>/dev/null || true; wait "$child" 2>/dev/null || true; fi
  "${compose[@]}" stop >/dev/null || result=1
  exit "$result"
}
case "${1:-}" in
  setup) "${compose[@]}" build ;;
  run)
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    setsid "${compose[@]}" up -d --wait --wait-timeout 120 & child=$!
    wait "$child"; child=
    echo "Development URL: http://127.0.0.1:$port"
    setsid "${compose[@]}" up --watch --abort-on-container-failure & child=$!
    wait "$child"
    ;;
  stop) "${compose[@]}" stop ;;
  teardown) "${compose[@]}" down ;;
  *) echo 'Usage: environment.sh setup|run|stop|teardown' >&2; exit 2 ;;
esac
