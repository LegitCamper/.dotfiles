#!/bin/bash

cd ~/projects/.dotfiles

rm -rf ~/.config/.bashrc ~/.config/fish ~/.wakatime*

stow -t ~ --adopt -S terminals editors shells hyprlandwm

git restore

cd -
