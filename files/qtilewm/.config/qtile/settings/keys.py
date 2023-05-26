import os
from libqtile import qtile
from libqtile.config import Key
from libqtile.lazy import lazy

# Qtile keybindings

mod = "mod4"

keys = [Key(key[0], key[1], *key[2:]) for key in [
    # ------------ Window Configs ------------

    # Switch between windows in current stack pane
    ([mod], "Down", lazy.layout.down()),
    ([mod], "Up", lazy.layout.up()),
    ([mod], "Left", lazy.layout.left()),
    ([mod], "Right", lazy.layout.right()),

    # Change window sizes (MonadTall)
    ([mod, "control"], "Up", lazy.layout.grow()),
    ([mod, "control"], "Down", lazy.layout.shrink()),

    # Toggle floating
    ([mod, "shift"], "f", lazy.window.toggle_floating()),

    # Move windows up or down in current stack
    ([mod, "shift"], "Up", lazy.layout.shuffle_down()),
    ([mod, "shift"], "Down", lazy.layout.shuffle_up()),

    # Toggle between different layouts as defined below
    ([mod], "Tab", lazy.next_layout()),
    ([mod, "shift"], "Tab", lazy.prev_layout()),

    # Kill window
    ([mod], "q", lazy.window.kill()),

    # Switch focus of monitors
    ([mod], "period", lazy.next_screen()),
    ([mod], "comma", lazy.prev_screen()),

    # Restart Qtile
    ([mod, "shift"], "r", lazy.reload_config()),
    ([mod, "control", "shift"], "r", lazy.restart()),
    
    # Shutdown Qtile
    ([mod, "control"], "q", lazy.shutdown()),

    # ------------ App Configs ------------

    # VS-Code
    ([mod], "c", lazy.spawn("code")),
    
    # Rofi run launcher
    ([mod], "Return", lazy.spawn("rofi -show run")),

    # Window Nav
    (["mod1"], "Tab", lazy.spawn("rofi -show window")),

    # Browser
    ([mod], "b", lazy.spawn("vivaldi-stable")),

    # File Explorer
    ([mod], "t", lazy.spawn("Thunar")),

    # Terminal
    (["control", "mod1"], "t", lazy.spawn("alacritty")),

    # Redshift
    # ([mod], "r", lazy.spawn("redshift -O 2400")),
    # ([mod, "shift"], "r", lazy.spawn("redshift -x")),

    # Screenshot
    # ([mod], "s", lazy.spawn('screenshot')),
    # ([mod, "shift"], "s", lazy.spawn('screenshot select')),
    # ([mod, "control", "shift"], "s", lazy.spawn('screenshot window')),
    ([mod], "s", lazy.spawn(os.path.expanduser('~/.config/scrot/screenshot'))),
    ([mod, "shift"], "s", lazy.spawn(os.path.expanduser('~/.config/scrot/screenshot select'))),
    ([mod, "control", "shift"], "s", lazy.spawn(os.path.expanduser('~/.config/scrot/screenshot window'))),
    # ([mod], "s", lazy.spawn("scrot")),
    # ([mod, "shift"], "s", lazy.spawn("scrot -s")),
    # ([mod, "control", "shift"], "s", lazy.spawn("scrot --focused")),

    # ------------ Hardware Configs ------------

    # Volume
    ([], "XF86AudioLowerVolume", lazy.spawn(
        "pactl set-sink-volume @DEFAULT_SINK@ -5%"
    )),
    ([], "XF86AudioRaiseVolume", lazy.spawn(
        "pactl set-sink-volume @DEFAULT_SINK@ +5%"
    )),
    ([], "XF86AudioMute", lazy.spawn(
        "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    )),

    # Brightness
    ([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +15%")),
    ([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-")),
]]

