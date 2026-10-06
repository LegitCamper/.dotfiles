local theme = require("theme")
local stack_hover = hover("notification_stack")
local cards = mantle.notifications:map(function(notifications)
    local out = {}
    for _, item in ipairs(notifications and notifications.feed or {}) do
        if not item.expired and (not notifications.dnd or item.urgency == "critical") and #out < 4 then out[#out + 1] = item end
    end
    return out
end)
local function runs(spans)
    local out = {}; for _, span in ipairs(spans or {}) do if span.kind == "text" then out[#out + 1] = span end end; return out
end
local function card(item)
    local actions = {}
    for i, act in ipairs(item.actions or {}) do actions[i] = rect { width = "fill", padding = 6, radius = 6, background = theme.surface0, cursor = "pointer", accessible_name = act.label, on_click = function() mantle.notifications:invoke_action(item.id, act.key) end, children = { text { content = act.label, align_h = "center", foreground = theme.text } } } end
    return column { width = "fill", padding = 12, spacing = 6, radius = 12, background = "#24273af2", border_width = 1, border_color = item.urgency == "critical" and theme.red or theme.surface2,
        children = { row { width = "fill", spacing = 8, children = { icon { name = item.app_icon or "dialog-information-symbolic", size = 28 }, column { width = "fill", children = { text { content = item.app_name, foreground = theme.subtext0, font_size = 11 }, text { content = { { text = item.summary, bold = true } }, foreground = theme.text, elide = "end" } } }, rect { padding = 4, cursor = "pointer", accessible_name = "Dismiss notification", on_click = function() mantle.notifications:dismiss(item.id) end, children = { text { content = "×", foreground = theme.subtext1 } } } } },
            text { content = runs(item.body), visible = #(item.body or {}) > 0, foreground = theme.subtext1, wrap = "word", max_lines = 4, on_link = function(url) mantle.applications:open_url(url) end },
            row { width = "fill", spacing = 6, visible = #actions > 0, children = actions } },
        on_click = function() if item.has_default_action then mantle.notifications:invoke_action(item.id, "default") end end, accessible_name = "Open notification", cursor = "pointer" }
end
return panel { id = "notifications", layer = "overlay", anchor = { top = true, right = true }, margin = { top = 54, right = 8 }, width = 380, visible = cards:map(function(v) return #v > 0 end), child = column { width = "fill", spacing = 8, hover = stack_hover, on_hover = function(inside) mantle.notifications:hold_expiry(inside and 300 or 0) end, children = { list { width = "fill", spacing = 8, source = cards, key = function(item) return tostring(item.id) end, itemfn = card } } } }
