local theme = require("theme")
local IDLE_LOCK_ENABLED = false
mantle.lock:set_unlock_animation(200)
if IDLE_LOCK_ENABLED then mantle.idle:register_threshold(601, function() mantle.lock:lock() end, function() end) end
action("lock", function() mantle.lock:lock() end)
local up = mantle.lock:map(function(value) return value and value.active and not value.unlocking end)
local hint = mantle.lock:map(function(value)
    if not value then return "" elseif value.authenticating then return "Checking…" elseif value.error ~= "" then return "Wrong password" end
    return "Type your password and press Enter"
end)
local failed = mantle.lock:map(function(value) return value and value.error ~= "" and not value.authenticating end)
return lock { id = "lock", background = theme.crust, child = function()
    return column { width = "fill", height = "fill", align_h = "center", align_v = "center", spacing = 16, background = { gradient = "linear", angle = 160, stops = { { 0, theme.base }, { 1, theme.crust } } }, opacity = up:map(function(on) return on and 1 or 0 end), animate = { opacity = { duration = 200, from = 0 } }, children = {
        text { content = mantle.system:map(function(s) return os.date("%H:%M", s and s.time) end), font_size = 96, foreground = theme.text, align_h = "center" },
        text { content = mantle.system:map(function(s) return os.date("%A, %d %B", s and s.time) end), font_size = 20, foreground = theme.subtext1, align_h = "center" }, rect { height = 24 },
        text { content = os.getenv("USER") or "", foreground = theme.text, align_h = "center" },
        rect { width = 320, padding = { left = 16, right = 16 }, radius = 22, background = theme.mantle, border_width = 2, border_color = failed:map(function(bad) return bad and theme.red or theme.surface2 end), children = { textfield { width = "fill", height = 44, foreground = theme.text, text_align = "center", placeholder = "Password", accessible_name = "Password", secure_submit = { capability = "lock", action = "authenticate" } } } },
        text { content = hint, foreground = failed:map(function(bad) return bad and theme.red or theme.overlay0 end), align_h = "center" },
    } }
end }
