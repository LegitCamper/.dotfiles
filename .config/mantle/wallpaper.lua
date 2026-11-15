local theme = require("theme")
local home = assert(os.getenv("HOME"), "HOME is required for wallpapers")
local folder = (os.getenv("XDG_CONFIG_HOME") or home .. "/.config") .. "/Wallpapers"
local saved = persistent_table {
    path = (os.getenv("XDG_STATE_HOME") or home .. "/.local/state") .. "/mantle",
    name = "desktop.json", defaults = { wallpaper = "" },
}
local open = state("wallpaper_open", false)
local query = state("wallpaper_query", "")
local selected = state("wallpaper_selected", 1)
local results_scroll = scroll("wallpaper_results")
local function close() open:set(false) end

-- ponytail: one shared wallpaper, top-level files only; add per-output choices when needed.
mantle.files:watch(folder, { "png", "jpg", "jpeg", "webp" })
local listing = mantle.files:map(function(files) return files and files.folders[folder] end)
local current = computed({ listing, saved.wallpaper }, function(files, path)
    for _, entry in ipairs(files and files.entries or {}) do
        if entry.path == path then return path end
    end
    return ""
end)
local matches = computed({ listing, query }, function(files, needle)
    local entries = {}
    for _, entry in ipairs(files and files.entries or {}) do
        if needle == "" or fuzzy(entry.name, needle) then entries[#entries + 1] = entry end
    end
    return entries
end)
local function choose(entry)
    if not entry then return end
    for _, available in ipairs((listing:get() or {}).entries or {}) do
        if available.path == entry.path then saved:set("wallpaper", entry.path); close(); return end
    end
end
local function move(step)
    local count = #matches:get()
    if count == 0 then return end
    selected:set((selected:get() - 1 + step) % count + 1)
    results_scroll:reveal(selected:get())
end
local message = computed({ listing, matches, saved.wallpaper, current }, function(files, entries, path, active)
    if not files or not files.ready then return "Loading wallpapers..." end
    if files.error then return "Cannot read " .. folder .. ": " .. files.error end
    if #files.entries == 0 then return "Add PNG, JPEG or WebP images to " .. folder end
    if #entries == 0 then return "No matching wallpapers" end
    if path and path ~= "" and active == "" then return "Saved wallpaper missing. Choose another image." end
    return "Applies to all monitors. Selection restores next login."
end)

local background = panel {
    id = "wallpaper", namespace = "wallpaper", layer = "background",
    anchor = { top = true, bottom = true, left = true, right = true },
    width = "fill", height = "fill", exclusive_zone = "ignore",
    visible = current:map(function(path) return path ~= "" end),
    child = function()
        return image { id = "wallpaper_image", width = "fill", height = "fill", source = current,
            fit = "cover", async = true, transition = { duration = 250 } }
    end,
}
local picker = panel {
    id = "wallpaper_picker", layer = "overlay", output = "active",
    anchor = { top = true, bottom = true, left = true, right = true },
    width = "fill", height = "fill", exclusive_zone = "ignore", visible = open,
    keyboard_interactivity = "exclusive", reset_on_close = { query, selected, results_scroll },
    child = rect { width = "fill", height = "fill", background = "#181926b8", children = {
        rect { width = "fill", height = "fill", on_click = close, accessible_name = "Close wallpaper picker" },
        column { width = "90%", max_width = 720, height = "85%", max_height = 620,
            align_h = "center", align_v = "center", padding = 14, spacing = 10,
            radius = 16, background = theme.base, border_width = 1, border_color = theme.surface2, children = {
                text { content = "Wallpaper", font_size = 20, font_weight = 600, foreground = theme.text },
                rect { width = "fill", height = 44, radius = 10, background = theme.surface0, children = {
                    textfield { width = "fill", height = "fill", padding = 10, foreground = theme.text,
                        placeholder = "Search wallpapers", accessible_name = "Search wallpapers", autofocus = true,
                        on_change = function(value) query:set(value); selected:set(1); results_scroll:reveal(1) end,
                        on_navigate = function(key)
                            if key == "down" or key == "tab" then move(1)
                            elseif key == "up" or key == "backtab" then move(-1) end
                        end,
                        on_submit = function() choose(matches:get()[selected:get()]) end,
                        on_cancel = function(cleared) if not cleared then close() end end },
                } },
                text { content = message, width = "fill", wrap = "word", max_lines = 3, foreground = theme.subtext0 },
                list { width = "fill", height = "fill", spacing = 6, scroll = results_scroll, source = matches,
                    key = function(entry) return entry.path end,
                    itemfn = function(entry)
                        local over = hover("wallpaper_" .. entry.path)
                        return row { width = "fill", padding = 8, spacing = 12, radius = theme.radius,
                            hover = over, cursor = "pointer", accessible_name = "Set wallpaper " .. entry.name,
                            on_click = function() choose(entry) end,
                            background = computed({ matches, selected, over }, function(entries, index, hovered)
                                return hovered and theme.surface2 or (entries[index] and entries[index].path == entry.path and theme.surface1 or "#00000000")
                            end),
                            children = {
                                image { source = entry.path, width = 112, height = 64, fit = "cover", async = true },
                                text { content = entry.name, width = "fill", elide = "end", align_v = "center", foreground = theme.text },
                                text { content = "Current", align_v = "center", foreground = theme.green,
                                    visible = current:map(function(path) return path == entry.path end) },
                            },
                        }
                    end },
            },
        },
    } },
}
return { background, picker }
