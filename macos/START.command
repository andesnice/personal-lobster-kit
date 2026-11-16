#!/bin/bash
kit_root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
bash "$kit_root/shared/bootstrap.sh" "${1:-start}"
result=$?
printf '\nPress Enter to close...'
read -r _
exit "$result"
