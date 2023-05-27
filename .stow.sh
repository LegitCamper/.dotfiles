#!/bin/bash

cd ~/projects/.dotfiles

rm -rf ~/.config/.bashrc ~/.config/fish ~/.wakatime*

stow -t ~ -S terminals editors shells hyprlandwm

cd -
