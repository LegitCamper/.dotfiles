#!/usr/bin/env bash
set -euo pipefail
[[ $# -eq 1 ]] || { printf 'usage: %s RECORD\n' "$0" >&2; exit 64; }
export PATH="$PATH:$HOME/.local/bin"
umask 077
decoded=$(mktemp "${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/mantle-clipboard.XXXXXXXX")
trap 'rm -f -- "$decoded"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
printf '%s\n' "$1" | cliphist decode >"$decoded"
wl-copy <"$decoded"
