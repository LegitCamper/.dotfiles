from libqtile.config import Click, Drag
from libqtile.lazy import lazy
from .keys import mod, keys

# Drag floating layouts.
mouse = [
    Drag(["mod1"], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag(["mod1"], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click(["mod1"], "Button2", lazy.window.bring_to_front()),
]
