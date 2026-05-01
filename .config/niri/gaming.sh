#!/bin/bash
while :
do
  niri msg -j windows \
    | jq -r '.[] | select(.workspace_id == 4 and .app_id != "steam") | .id' \
    | while read -r win_id; do
        niri msg action move-window-to-workspace --window-id "$win_id" 5
      done
  sleep 1
done
