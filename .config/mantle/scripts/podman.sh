#!/usr/bin/env bash
set -u
container=""
action=status
while (($#)); do case "$1" in -c) [[ $# -ge 2 ]] || exit 64; container=$2; shift 2;; toggle) action=toggle; shift;; *) exit 64;; esac; done
[[ -n $container ]] || { printf 'missing\n'; exit 0; }
command -v podman >/dev/null 2>&1 || { printf 'missing\n'; exit 0; }
if ! podman container exists "$container" 2>/dev/null; then printf 'missing\n'; exit 0; fi
running=false
[[ $(podman inspect --format '{{.State.Running}}' "$container" 2>/dev/null) == true ]] && running=true
if [[ $action == toggle ]]; then
    lock="${XDG_RUNTIME_DIR:-/tmp}/mantle-podman-$UID.lock"
    exec 9>"$lock"; flock -n 9 || exit 0
    if $running; then podman stop "$container" >/dev/null; else podman start "$container" >/dev/null; fi
    exit
fi
$running && printf 'running\n' || printf 'stopped\n'
