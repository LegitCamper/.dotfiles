#!/bin/bash

echo "Script to install all my Suse Packages :)"

flatpakFlathubPackages="
  com.notepadqq.Notepadqq
  com.valvesoftware.Steam
  org.flameshot.Flameshot
  org.videolan.VLC
  net.lutris.Lutris
  com.heroicgameslauncher.hgl
  com.getpostman.Postman
  com.usebottles.bottles
  com.spotify.Client
  org.js.nuclear.Nuclear
  io.github.shiftey.Desktop
  com.github.sdv43.whaler
  net.davidotek.pupgui2
  re.sonny.Junction
  com.github.tchx84.Flatseal
  org.signal.Signal
  com.bitwarden.desktop
  com.mojang.Minecraft
  org.libreoffice.LibreOffice
  io.gitlab.librewolf-community
  io.github.prateekmedia.appimagepool
"

SusePackages="
  vivaldi-stable
  zellij
  tmux
  alacritty
  solaar
  stow
  exa
  fd
  ripgrep
  fish
  rustup
  htop
  git
  python3
  python-pip
  go
  npm
  ninja
  meson
  gcc 
  gcc-c++
  docker
  docker-compose
  neovim
  lazygit
  flameshot
  flatpak
  flatpak-xdg-utils
  swaylock
  swayidle
  swaybg
  light
  wofi
  rofi
  dunst
  pipewire
  pipewire-alsa
  wireplumber
  pipewire-pulse
  libqt5-wayland
  libqt6-wayland
  jq
  playerctl
  grim
  slurp
  mpc
  hyprland
  waybar-hyprland
  swaybg
  swayidle
  rofi
  xdg-desktop-portal-wlr
  bismuth
  timeshift
  catppuccin-gtk-theme-macchiato
  NetworkManager
  NetworkManager-applet
  fzf
  pavucontrol
  gcc
  cmake
  git
"

# Updates system and repositories
sudo zypper refresh
sudo zypper dist-upgrade -y
sudo zypper update -y

# Add repos
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub $flatpakFlathubPackages
sudo zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
sudo zypper ar -cfp 90 https://ftp.fau.de/packman/suse/openSUSE_Tumbleweed/ packman
sudo zypper dup --from packman --allow-vendor-change
sudo zypper refresh
sudo zypper in -y --allow-unsigned-rpm $SusePackages
