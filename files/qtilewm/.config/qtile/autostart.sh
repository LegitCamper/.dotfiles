#!/bin/sh

# EXTRAS
xrandr -s 1.0x1.0
lxsession &
picom --experimental-backend &
#megasync &
dunst &
nitrogen --restore &
