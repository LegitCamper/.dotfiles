#!/usr/bin/env bash

CONTAINER=""
ACTION="status"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c)
            CONTAINER="$2"
            shift 2
            ;;
        toggle)
            ACTION="toggle"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [[ -z "$CONTAINER" ]]; then
    echo "No container"
    exit 1
fi

is_running() {
    podman ps --format "{{.Names}}" | grep -qx "$CONTAINER"
}

if [[ "$ACTION" == "toggle" ]]; then
    if is_running; then
        podman stop "$CONTAINER"
    else
        podman start "$CONTAINER"
    fi
    exit 0
fi

# Default: status output
if is_running; then
    echo "Running"
else
    echo "Stopped"
fi
