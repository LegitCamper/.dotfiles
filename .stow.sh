#!/bin/bash

cd /home/sawyer/.dotfiles

rm -rf ~/.config/.bashrc ~/.config/fish ~/.wakatime*

stow -t ~ -S terminals editors shells hyprlandwm

cd -
