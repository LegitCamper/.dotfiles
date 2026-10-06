local theme = require("theme")
local open = state("clipboard_open", false)
local query = state("clipboard_query", "")
local rows = state("clipboard_rows", {})
local function close() open:set(false) end
local function refresh()
    local out = {}
    process.run("cliphist", { "list" }, function(line) out[#out + 1] = line end, function(code) if code == 0 then rows:set(out) end end)
end
open:on_change(function(value) if value then refresh() end end)
local matches = computed({ rows, query }, function(items, needle)
    local out = {}; for _, line in ipairs(items) do if needle == "" or fuzzy(line, needle) then out[#out + 1] = line end; if #out >= 50 then break end end; return out
end)
return panel { id = "clipboard", layer = "overlay", output = "active", anchor = { top = true, bottom = true, left = true, right = true }, width = "fill", height = "fill", exclusive_zone = "ignore", visible = open, keyboard_interactivity = "exclusive", reset_on_close = { query }, child = rect { width = "fill", height = "fill", background = "#181926b8", children = {
    rect { width = "fill", height = "fill", on_click = close, accessible_name = "Close clipboard" },
    column { width = 650, align_h = "center", margin = { top = 130 }, padding = 14, spacing = 8, radius = 16, background = theme.base, children = {
        textfield { width = "fill", height = 44, padding = 10, radius = 10, background = theme.surface0, foreground = theme.text, placeholder = "Search clipboard", accessible_name = "Search clipboard", autofocus = true, on_change = function(value) query:set(value) end, on_cancel = function(cleared) if not cleared then close() end end },
        list { width = "fill", max_height = 480, spacing = 2, source = matches, key = function(line) return line end, itemfn = function(line) return rect { width = "fill", padding = 9, radius = 8, background = theme.surface0, cursor = "pointer", accessible_name = "Copy clipboard item", on_click = function() process.detach(mantle.config_dir .. "/scripts/cliphist-copy.sh", { line }); close() end, children = { text { content = line, foreground = theme.text, elide = "end" } } } end },
    } },
} } }
