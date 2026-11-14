#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir "$fixture/bin" "$fixture/runtime"
export XDG_RUNTIME_DIR="$fixture/runtime" COPY_RESULT="$fixture/result" DECODE_INPUT="$fixture/input"
export PATH="$fixture/bin:$PATH"
cat >"$fixture/bin/cliphist" <<'SH'
#!/usr/bin/env bash
case "$DECODE_MODE" in
    fail) exit 1 ;;
    partial) printf partial; exit 1 ;;
    missing) exit 127 ;;
    success) cat "$DECODE_INPUT" ;;
esac
SH
cat >"$fixture/bin/wl-copy" <<'SH'
#!/usr/bin/env bash
cat >"$COPY_RESULT"
SH
chmod +x "$fixture/bin/cliphist" "$fixture/bin/wl-copy"
printf 'previous clipboard' >"$fixture/previous"
for mode in fail partial missing; do
    cp "$fixture/previous" "$COPY_RESULT"
    if DECODE_MODE="$mode" bash .config/mantle/scripts/cliphist-copy.sh record; then
        printf 'expected decode failure: %s\n' "$mode" >&2; exit 1
    fi
    cmp "$fixture/previous" "$COPY_RESULT"
done
printf 'binary\000image\n\n' >"$DECODE_INPUT"
DECODE_MODE=success bash .config/mantle/scripts/cliphist-copy.sh record
cmp "$DECODE_INPUT" "$COPY_RESULT"
if compgen -G "$XDG_RUNTIME_DIR/mantle-clipboard.*" >/dev/null; then
    printf 'decoded clipboard files leaked\n' >&2; exit 1
fi
if bash .config/mantle/scripts/cliphist-copy.sh; then exit 1; fi
printf 'clipboard copy preserves existing data on decode failures; binary copy and cleanup passed\n'
