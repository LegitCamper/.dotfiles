# Qtile workspaces

from libqtile.config import Key, Group, Match
from libqtile.lazy import lazy
from .keys import mod, keys


# Get the icons at https://www.nerdfonts.com/cheat-sheet (you need a Nerd Font)
# Icons:
# nf-fa-firefox,
# nf-fae-python,
# nf-dev-terminal,
# nf-fa-code,
# nf-oct-git_merge,
# nf-linux-docker,
# nf-mdi-image,
# nf-mdi-layers

# Groups
groups = [
    Group(name='1', label="Term", matches=[
          Match(wm_class='alacritty')], layout="monadtall"),
    Group(name='2', label="Web", matches=[
          Match(wm_class='vivaldi-stable')], layout="monadtall"),
    Group(name='3', label="Code", matches=[
          Match(wm_class='visual-studio-code-bin')], layout="monadtall"),
    Group(name='4', label="Social", matches=[
          Match(wm_class="Ferdi"), Match(wm_class='discord')], layout='monadtall'),
    Group(name='5', label="PLAY", matches=[Match(wm_class='vlc')], layout='max'),
]

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen()),

        Key([mod, "control"], i.name, lazy.window.togroup(i.name)),
    ])
