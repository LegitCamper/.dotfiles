#!/usr/bin/env bash
set -euo pipefail
[[ $# -eq 1 ]] || { printf 'usage: %s RECORD\n' "$0" >&2; exit 64; }
printf '%s\n' "$1" | cliphist decode | wl-copy
