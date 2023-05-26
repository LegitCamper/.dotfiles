#!/bin/bash

echo "Script to install all my Arch Packages :)"

# Installs Aura - Which is used to install all my other programs
echo "Installing Aura"
yay --noconfirm --needed aura-bin

flatpakFlathubPackages="
com.notepadqq.Notepadqq
com.valvesoftware.Steam
org.flameshot.Flameshot
org.videolan.VLC
flathub org.gnu.emacs
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
org.kde.kwrite
com.github.tchx84.Flatseal
org.signal.Signal
com.bitwarden.desktop
com.mojang.Minecraft
org.libreoffice.LibreOffice
io.gitlab.librewolf-community
com.github.git_cola.git-cola
io.github.prateekmedia.appimagepool
"

pacmanPackages="
vivaldi
alacritty
solaar
stow
exa
fd
ripgrep
fish
starship
htop
git
rustup
python3
python-pip
jupyterlab
go
docker
docker-compose
neovim
lazygit
flameshot
swaylock
swayidle
swaybg
pulsemixer
light
wofi
rofi
dunst
pipewire
pipewire-alsa
wireplumber
pipewire-pulse
qt5-wayland
qt6-wayland
jq
playerctl
grim
slurp
mpc
"

archPluginPackages="
powerdevil
ttf-jetbrains-mono-nerd
noto-fonts-emoji
"

# Defines the AUR packages I want to install
aurPackages="
hyprland
waybar-hyprland
eww-wayland
xdg-desktop-portal-hyprland-git
kwin-bismuth-bin
webcord-bin
macchina-bin
betterdiscordctl
timeshift-bin
vscodium-bin
notion-app-enhanced 
catppuccin-gtk-theme-macchiato
git-credential-manager-core-bin
" # hyprpaper-git #anaconda

# Updates system and repositories
sudo aura -Syu -u --needed
sudo aura -Au

sudo aura -Syu flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && flatpak
flatpak install flathub $flatpakFlathubPackages

sudo aura -S $pacmanPackages $archPluginPackages
sudo aura -A $aurPackages

# Install cod
go get -u github.com/dim-an/cod

