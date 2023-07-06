-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then config = wezterm.config_builder() end

-- This is where you actually apply your config choices
config.default_cwd = "/home/sawyer/"

config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = "Catppuccin Mocha"

config.font = wezterm.font 'JetBrains Mono'

config.window_background_opacity = 0.85

config.default_prog = {'fish'}

config.hide_mouse_cursor_when_typing = false

config.mouse_bindings = {
    -- Right click sends "woot" to the terminal
    {
        event = {Down = {streak = 1, button = 'Right'}},
        mods = 'NONE',
        action = act.SendString 'woot'
    }, -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'NONE',
        action = act.CompleteSelection 'ClipboardAndPrimarySelection'
    }, -- and make CTRL-Click open hyperlinks
    {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor
    }, -- NOTE that binding only the 'Up' event can give unexpected behaviors.
    -- Read more below on the gotcha of binding an 'Up' event only.
    -- Scrolling up while holding CTRL increases the font size
    {
        event = {Down = {streak = 1, button = {WheelUp = 1}}},
        mods = 'CTRL',
        action = act.IncreaseFontSize
    }, -- Scrolling down while holding CTRL decreases the font size
    {
        event = {Down = {streak = 1, button = {WheelDown = 1}}},
        mods = 'CTRL',
        action = act.DecreaseFontSize
    }, -- Bind 'Up' event of CTRL-Click to open hyperlinks
    {
        event = {Up = {streak = 1, button = 'Left'}},
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor
    },
    -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
    {
        event = {Down = {streak = 1, button = 'Left'}},
        mods = 'CTRL',
        action = act.Nop
    }
}

-- and finally, return the configuration to wezterm
return config
