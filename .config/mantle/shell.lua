fonts {
    "Adwaita Sans",
    "JetBrainsMono Nerd Font Mono",
}

local bar_surfaces = require("bar")
local launcher = require("launcher")
local notifications = require("notifications")
local clipboard = require("clipboard")
local lock_screen = require("lock")
local osd = require("osd")
local wallpaper = require("wallpaper")

return { bar_surfaces[1], bar_surfaces[2], bar_surfaces[3], launcher, notifications, clipboard, lock_screen, osd, wallpaper[1], wallpaper[2] }
