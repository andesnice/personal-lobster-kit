#!/bin/bash
kit_root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
bash "$kit_root/shared/bootstrap.sh" setup
result=$?
printf '\nPress Enter to close...'
read -r _
exit "$result"
