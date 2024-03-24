#!/bin/sh

function handle {
  if [[ ${1:0:12} == "activewindow" ]]; then
    if [[ $(hyprctl --batch activewindow | sed -n 6p) == *"4"* ]]; then # 4 is my gaming workspace
      if [[ $(hyprctl --batch activewindow | sed -n 7p) == *"0"* ]]; then
        hyprctl --batch dispatch togglefloating active 
      fi
    fi
  fi 
}

socat -U - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done
