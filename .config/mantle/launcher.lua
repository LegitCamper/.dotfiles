local theme = require("theme")
local open = state("launcher_open", false)
local query = state("launcher_query", "")
local selected = state("launcher_selected", 1)
local results_scroll = scroll("launcher_results")
local function close() open:set(false) end
local function score(entry, needle)
    local best, start = fuzzy(entry.name, needle)
    for _, field in ipairs({ entry.generic_name or "", entry.comment or "", table.concat(entry.keywords or {}, " "), entry.id }) do
        local value, at = fuzzy(field, needle)
        if value and (not best or value > best) then best, start = value, at end
    end
    return best, start
end
local matches = computed({ mantle.applications, query }, function(apps, needle)
    local scored = {}
    for _, entry in ipairs(apps and apps.entries or {}) do
        local value, at = score(entry, needle)
        if not entry.no_display and value then scored[#scored + 1] = { entry = entry, score = value, start = at } end
    end
    table.sort(scored, function(a, b) if a.score ~= b.score then return a.score > b.score end; if a.start ~= b.start then return a.start < b.start end; return a.entry.id < b.entry.id end)
    local out = {}; for i = 1, math.min(#scored, 20) do out[i] = scored[i].entry end; return out
end)
local function launch(entry) if entry then mantle.applications:launch(entry.id) end; close() end
local function move(step) local count = #matches:get(); if count > 0 then selected:set((selected:get() - 1 + step) % count + 1); results_scroll:reveal(selected:get()) end end
return panel {
    id = "launcher", layer = "overlay", output = "active", anchor = { top = true, bottom = true, left = true, right = true }, width = "fill", height = "fill", exclusive_zone = "ignore", visible = open,
    reset_on_close = { query, selected, results_scroll }, keyboard_interactivity = "exclusive", on_escape = close,
    child = rect { width = "fill", height = "fill", children = {
        rect { width = "fill", height = "fill", on_click = close, accessible_name = "Close launcher" },
        column { width = 600, align_h = "center", align_v = "center", padding = 14, spacing = 8, radius = 16, background = theme.base, border_width = 1, border_color = theme.surface2, children = {
            rect { width = "fill", height = 44, radius = 10, background = theme.surface0, children = {
                textfield { width = "fill", height = "fill", padding = 10, font_size = 17, foreground = theme.text, placeholder_color = theme.overlay1, caret_color = theme.mauve, placeholder = "Search applications", accessible_name = "Search applications", autofocus = true,
                    on_change = function(value) query:set(value); selected:set(1); results_scroll:reveal(1) end,
                    on_navigate = function(key) if key == "down" or key == "tab" then move(1) elseif key == "up" or key == "backtab" then move(-1) end end,
                    on_submit = function() launch(matches:get()[selected:get()]) end },
            } },
            list { width = "fill", max_height = 450, spacing = 2, scroll = results_scroll, animate = { scroll = { duration = 160, easing = "out_cubic" } }, source = matches, key = function(entry) return entry.id end, itemfn = function(entry)
                local over = hover("app_" .. entry.id)
                return row { width = "fill", padding = 9, spacing = 12, radius = 8, opacity = 1,
                    animate = { move = 180, opacity = { duration = 180, from = 0 } }, hover = over, cursor = "pointer", accessible_name = "Launch " .. entry.name, on_click = function() launch(entry) end,
                    background = computed({ matches, selected, over }, function(entries, current, hovered) local picked = entries[current]; return hovered and theme.surface2 or (picked and picked.id == entry.id and theme.surface1 or "#00000000") end),
                    children = { icon { name = entry.icon or "application-x-executable", size = 30, align_v = "center" }, column { width = "fill", spacing = 2, children = { text { content = entry.name, font_size = 16, font_weight = 600, foreground = theme.text }, text { content = entry.comment or entry.generic_name or entry.id, foreground = theme.subtext0, font_size = 13, elide = "end" } } } } }
            end },
        } },
    } },
}
