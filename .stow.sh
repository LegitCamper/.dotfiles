#!/bin/bash

cd ~/projects/.dotfiles

stow -t ~ --adopt -S terminals editors shells hyprlandwm

# git restore .

cd -
