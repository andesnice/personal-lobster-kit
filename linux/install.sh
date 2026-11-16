#!/usr/bin/env bash
set -euo pipefail
kit_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$kit_root/shared/bootstrap.sh" setup
