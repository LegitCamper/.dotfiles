#!/bin/bash
# Startup for Hyprland

# Mounts game drive on desktop
if [ $(hostname) == "sawyer-asus" ]; then
  bash $HOME/Desktop/Mount_Drives.sh
fi

# Enviroment Varibles
export GTK_THEME=Catppuccin-Macchiato-Standard-Blue-Dark
export GTK_USE_PORTAL=1
export GDK_BACKEND=wayland,x11
#export XCURSOR_THEME=Breeze
#export XCURSOR_SIZE=24
export no_cursor_warps=0
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_SEAT=seat0
#export WAYLAND_DISPLAY=wayland-1
export TERM=alacritty
#export DISPLAY=:1

export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Ensure to diable nvidia drivers not on pc
if [ $(hostname) == "sawyer-asus" ]; then
  export LIBVA_DRIVER_NAME=nvidia
  export GBM_BACKEND=nvidia-drm
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export WLR_NO_HARDWARE_CURSORS=1
fi

export BROWSER=vivaldi-stable
export EDITOR=nvim
export TERM=alacritty

# Fix flatpaks in wofi
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"

# Stops some apps from loading slowly
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Starts pipewire
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user mask pulseaudio
systemctl --user --now enable pipewire pipewire-pulse wireplumber
systemctl --user --now enable pipewire pipewire-pulse pipewire-media-session

# Ensures Sway's Portal is the only one
sleep 1
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal
killall xdg-desktop-portal-kde
/usr/libexec/xdg-desktop-portal-sway &
killall xdg-desktop-portal-wlr
sleep 2
/usr/lib/xdg-desktop-portal &

# Starts Sway
if [ $(hostname) == "sawyer-asus" ]; then
  exec sway --unsupported-gpu
else
  exec sway 
fi

