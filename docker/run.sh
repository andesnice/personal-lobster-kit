#!/usr/bin/env bash
set -euo pipefail
kit_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$kit_root"
action="${1:-setup}"
case "$action" in setup|start|stop|login|dashboard|channels|doctor|models|logs|token) ;; *) printf '%s\n' 'Unknown Docker action' >&2; exit 1 ;; esac
docker compose version >/dev/null
if [ "$(docker info --format '{{.OSType}}')" != linux ]; then
  printf '%s\n' 'STOP: Docker must use Linux containers.' >&2; exit 1
fi
dc() { docker compose --project-directory "$kit_root" --file "$kit_root/compose.yaml" "$@"; }
existing="$(dc ps --all --quiet)"
for container in $existing; do
  if [ "$(docker inspect --format '{{ index .Config.Labels "io.personal-lobster.kit" }}' "$container")" != v1 ]; then
    printf '%s\n' 'STOP: this Compose project already contains a different installation. Choose another COMPOSE_PROJECT_NAME; no containers will be replaced.' >&2
    exit 1
  fi
done
gateway_running() {
  local ids
  if ! ids="$(dc ps --status running --quiet gateway)"; then
    printf '%s\n' 'STOP: Could not determine whether the Gateway is running; no offline container was started.' >&2
    exit 1
  fi
  [ -n "$ids" ]
}
claw() {
  if gateway_running; then dc exec -T gateway node /app/openclaw.mjs --profile personal-lobster "$@"
  else dc run --rm --no-deps gateway "$@"; fi
}
claw_interactive() {
  if gateway_running; then dc exec gateway node /app/openclaw.mjs --profile personal-lobster "$@"
  else dc run --rm --no-deps gateway "$@"; fi
}
gateway_was_running=0
if gateway_running; then gateway_was_running=1; fi
if [ "$action" = setup ] && [ "$gateway_was_running" -eq 1 ]; then
  printf '%s\n' 'Existing Gateway is running. Keeping config/login/data; opening it without reinstalling.'
  action=start
fi
if [ "$action" = setup ]; then
  dc pull gateway init
  dc run --rm --no-deps init
  dc run --rm --no-deps gateway config validate
  printf '%s\n' 'Sign in to YOUR OWN ChatGPT/Codex account using the device code shown only in this terminal.'
  dc run --rm --no-deps gateway models auth login --provider openai --device-code
fi
if [ "$action" = setup ] || [ "$action" = start ]; then
  if [ "$gateway_was_running" -eq 0 ]; then dc up -d gateway; fi
  healthy=0
  for ((i=0;i<20;i++)); do
    if dc exec -T gateway node /app/openclaw.mjs --profile personal-lobster health --json >/dev/null 2>&1; then healthy=1; break; fi
    sleep 2
  done
  if [ "$healthy" -ne 1 ]; then printf '%s\n' 'STOP: Gateway health not confirmed. Use logs; do not reset or delete the volume.' >&2; exit 1; fi
  printf '%s\n' 'Gateway health passed. First real AI reply still needs your own chat test.'
  dc exec -T gateway node /app/openclaw.mjs --profile personal-lobster dashboard --no-open
elif [ "$action" = token ]; then
  if [ "$gateway_was_running" -ne 1 ]; then printf '%s\n' 'STOP: Start the owned Gateway first; reveal its token only in your own interactive terminal.' >&2; exit 1; fi
  printf '%s\n' 'Gateway token is for YOUR local page only. Never put it in chat, screenshots or logs.'
  dc exec gateway node /app/openclaw.mjs --profile personal-lobster gateway auth-token --show
elif [ "$action" = stop ]; then dc stop gateway
elif [ "$action" = logs ]; then dc logs --tail 80 gateway
elif [ "$action" = login ]; then claw_interactive models auth login --provider openai --device-code
elif [ "$action" = channels ]; then claw_interactive configure --section channels
elif [ "$action" = doctor ]; then claw_interactive doctor
elif [ "$action" = models ]; then claw models list --all --provider openai
elif [ "$action" = dashboard ]; then dc exec -T gateway node /app/openclaw.mjs --profile personal-lobster dashboard --no-open
fi
