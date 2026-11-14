local theme = require("theme")
local open = state("clipboard_open", false)
local query = state("clipboard_query", "")
local rows = state("clipboard_rows", {})
local selected = state("clipboard_selected", 1)
local message = state("clipboard_message", "")
local copying = state("clipboard_copying", false)
local results_scroll = scroll("clipboard_results")
local text_collector = session_process { name = "clipboard_text" }
local image_collector = session_process { name = "clipboard_image" }
local request = 0
local view = 0
local function close() open:set(false) end

local function refresh()
    request = request + 1
    local current = request
    local executable
    rows:set({})
    selected:set(1)
    results_scroll:scroll_to(0)
    message:set("Loading clipboard...")
    process.run("sh", { "-c", 'command -v cliphist || { test -x "$HOME/.local/bin/cliphist" && printf "%s\\n" "$HOME/.local/bin/cliphist"; }' },
        function(line, stream) if stream == "stdout" then executable = line end end,
        function(code)
            if current ~= request then return end
            if code ~= 0 or not executable then
                message:set("Clipboard unavailable: install cliphist on the host (just clipboard-setup).")
                return
            end
            text_collector:start("wl-paste", { "--type", "text", "--watch", executable, "store" })
            image_collector:start("wl-paste", { "--type", "image", "--watch", executable, "store" })
            local items = {}
            process.run(executable, { "list" }, function(line, stream)
                if stream == "stdout" then items[#items + 1] = line end
            end, function(status)
                if current ~= request then return end
                rows:set(status == 0 and items or {})
                message:set(status == 0 and "" or "Could not read clipboard history. Close and reopen to retry.")
            end)
        end)
end

open:on_change(function(value)
    view = view + 1
    if value then refresh() end
end)
refresh()

local matches = computed({ rows, query }, function(items, needle)
    local out = {}
    for _, line in ipairs(items) do
        if needle == "" or fuzzy(line, needle) then out[#out + 1] = line end
        if #out >= 50 then break end
    end
    return out
end)

local function copy(line)
    if not line or copying:get() then return end
    local current_view = view
    copying:set(true)
    message:set("Copying...")
    process.run(mantle.config_dir .. "/scripts/cliphist-copy.sh", { line }, function() end, function(code)
        copying:set(false)
        if current_view ~= view then return end
        if code == 0 then message:set(""); close()
        else message:set("Copy failed. Existing clipboard kept if decoding failed; choose another item or retry.") end
    end)
end

local function move(step)
    local count = #matches:get()
    if count == 0 then return end
    selected:set((selected:get() - 1 + step) % count + 1)
    results_scroll:reveal(selected:get())
end

return panel {
    id = "clipboard", layer = "overlay", output = "active", anchor = { top = true, bottom = true, left = true, right = true },
    width = "fill", height = "fill", exclusive_zone = "ignore", visible = open, keyboard_interactivity = "exclusive",
    reset_on_close = { query, selected, results_scroll },
    child = rect { width = "fill", height = "fill", background = "#181926b8", children = {
        rect { width = "fill", height = "fill", on_click = close, accessible_name = "Close clipboard" },
        column { width = "90%", max_width = 650, align_h = "center", align_v = "center", padding = 14, spacing = 8, radius = 16, background = theme.base, children = {
            rect { width = "fill", height = 44, radius = 10, background = theme.surface0, children = {
                textfield { width = "fill", height = "fill", padding = 10, foreground = theme.text, placeholder = "Search clipboard", accessible_name = "Search clipboard", autofocus = true,
                    on_change = function(value) query:set(value); selected:set(1); results_scroll:reveal(1) end,
                    on_navigate = function(key) if key == "down" or key == "tab" then move(1) elseif key == "up" or key == "backtab" then move(-1) end end,
                    on_submit = function() copy(matches:get()[selected:get()]) end,
                    on_cancel = function(cleared) if not cleared then close() end end },
            } },
            text { content = message, width = "fill", wrap = "word", foreground = theme.yellow, visible = message:map(function(value) return value ~= "" end) },
            text { content = "No matching clipboard items", foreground = theme.subtext0,
                visible = computed({ matches, message }, function(items, status) return #items == 0 and status == "" end) },
            list { width = "fill", max_height = 480, spacing = 2, scroll = results_scroll, source = matches,
                key = function(line) return line end,
                itemfn = function(line)
                    return rect { width = "fill", padding = 9, radius = 8, cursor = "pointer", accessible_name = "Copy clipboard item", on_click = function() copy(line) end,
                        background = computed({ matches, selected }, function(items, index) return items[index] == line and theme.surface2 or theme.surface0 end),
                        children = { text { content = line, width = "fill", foreground = theme.text, elide = "end" } } }
                end },
        } },
    } },
}
