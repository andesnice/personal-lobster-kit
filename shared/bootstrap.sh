#!/usr/bin/env bash
set -euo pipefail
kit_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v openclaw >/dev/null 2>&1; then
  printf '%s\n' 'Installing official OpenClaw without onboarding...'
  installer="$(mktemp "${TMPDIR:-/tmp}/openclaw-installer.XXXXXX")"
  trap 'rm -f -- "$installer"' EXIT
  curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh --output "$installer"
  bash "$installer" --no-onboard
  export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.openclaw/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
  hash -r
fi
if ! command -v openclaw >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
  printf '%s\n' 'STOP: installation/PATH incomplete. Reopen a terminal and rerun. Review official installer errors.' >&2
  exit 1
fi
node "$kit_root/shared/deploy.mjs" "${1:-setup}"
