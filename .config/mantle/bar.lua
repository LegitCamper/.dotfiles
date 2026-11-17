local theme = require("theme")
local clock_label = mantle.system:map(function(s)
    if not s then return "--:--" end
    return os.date("%I:%M %p", s.time)
end)
local date_label = mantle.system:map(function(s) return s and os.date("%a %b %d, %Y", s.time) or "" end)
local menu_open = state("tray_menu_open", false)
local menu_item = state("tray_menu_item", "")
local menu_anchor = state("tray_menu_anchor", { x = 0, y = 0, width = 1, height = 1 })
local menu_expanded = state("tray_menu_expanded", {})
local details_kind = state("bar_details", "")
local details_anchor = state("bar_details_anchor", { x = 0, y = 0, width = 1, height = 1 })
local caffeine = state("caffeine", false)
local wallpaper_open = state("wallpaper_open", false)

caffeine:on_change(function(held, previous)
    if held == previous then return end
    if held then mantle.idle:inhibit("Manual keep awake") else mantle.idle:release_inhibit() end
end)

local function open_details(kind, box)
    menu_open:set(false)
    details_anchor:set(box)
    details_kind:set(kind)
end

local function close_menu() menu_open:set(false) end

local function open_menu(item, box)
    details_kind:set("")
    menu_item:set(item.id)
    menu_anchor:set(box)
    menu_expanded:set({})
    menu_open:set(true)
    mantle.tray:menu_will_show(item.id, 0)
end

local function output_of(workspaces, name)
    for _, output in ipairs(workspaces and workspaces.outputs or {}) do
        if output.name == name then return output end
    end
end

local function workspaces(name)
    return list {
        direction = "horizontal", spacing = 4, align_v = "center",
        source = mantle.workspaces:map(function(all)
            local output = output_of(all, name)
            local items = {}
            for _, workspace in ipairs(output and output.workspaces or {}) do
                if workspace.name or workspace.populated or workspace.id == output.active_workspace then
                    items[#items + 1] = { id = workspace.id, label = tostring(workspace.idx), active = workspace.id == output.active_workspace, populated = workspace.populated }
                end
            end
            return items
        end),
        key = function(item) return tostring(item.id) end,
        itemfn = function(item)
            local over = hover("workspace_" .. tostring(item.id))
            return rect {
                width = item.active and 38 or 30,
                padding = { top = 4, bottom = 4 }, radius = theme.radius,
                hover = over, cursor = "pointer", accessible_name = "Focus workspace " .. item.label,
                background = over:map(function(on) return on and theme.surface2 or (item.active and theme.mauve or "#00000000") end),
                animate = { width = { spring = { stiffness = 400, damping = 18 } }, background = theme.fast },
                on_click = function() mantle.workspaces:focus(item.id) end,
                children = { text { content = item.label, align_h = "center", font_size = 14, foreground = item.active and theme.crust or (item.populated and theme.text or theme.overlay1) } },
            }
        end,
    }
end

local function pill(label, color, click, wheel, name, max_width)
    local over = hover(name)
    return rect {
        align_v = "center", padding = { left = 6, right = 6, top = 5, bottom = 5 }, radius = theme.radius,
        visible = label:map(function(value) return value ~= nil and value ~= "" end),
        hover = over, cursor = click and "pointer" or "default", accessible_name = name, on_click = click, on_wheel = wheel,
        background = over:map(function(on) return on and theme.surface2 or "#00000000" end),
        scale = over:map(function(on) return on and 1.04 or 1 end),
        animate = { background = theme.fast, scale = { spring = { stiffness = 400, damping = 24 } } },
        children = { text { content = label, max_width = max_width, elide = "end", font_size = 14, foreground = color } },
    }
end

local function clock()
    return column {
        id = "bar_clock", width = 160, align_h = "center", align_v = "center", spacing = 1, accessible_name = "Time and date",
        children = {
            text { content = clock_label, font_size = 16, font_weight = 600, foreground = theme.text, align_h = "center" },
            text { content = date_label, font_size = 11, foreground = theme.subtext0, align_h = "center" },
        },
    }
end

local brightness = mantle.brightness:map(function(b) return b and string.format("☀ %d%%", b.percent) or "" end)
local battery = mantle.battery:map(function(b)
    if not b then return "" end
    if not b.present then
        local count = #(b.peripherals or {})
        return count > 0 and (" " .. count .. " devices") or ""
    end
    return string.format("%s %d%%", b.state == "charging" and "󰂄" or "", b.percent)
end)
local awake_label = computed({ caffeine, mantle.idle }, function(held, idle)
    if held then return idle and idle.inhibited and "Awake" or "Awake requested" end
    if idle and idle.inhibited then
        local first = (idle.inhibitors or {})[1]
        local name = first and (first.who ~= "" and first.who or first.why) or ""
        return name ~= "" and ("Awake: " .. name) or "Awake (app)"
    end
    return idle and "Idle allowed" or "Idle --"
end)
local function estimate(seconds)
    if not seconds or seconds <= 0 then return nil end
    local minutes = math.floor(seconds / 60)
    if minutes == 0 then return "<1m" end
    return string.format("%dh %02dm", math.floor(minutes / 60), minutes % 60)
end
local details_text = computed({ details_kind, mantle.battery, mantle.power, mantle.idle, caffeine }, function(kind, charge, power, idle, held)
    local lines = {}
    if kind == "idle" then
        lines[#lines + 1] = held and "Manual keep-awake requested" or "Manual keep-awake off"
        lines[#lines + 1] = idle and (idle.inhibited and "Idle inhibition reported" or "Idle allowed") or "Idle status unavailable"
        for _, holder in ipairs(idle and idle.inhibitors or {}) do
            local who = holder.who ~= "" and holder.who or "Compositor"
            lines[#lines + 1] = who .. (holder.why ~= "" and (": " .. holder.why) or "")
        end
        lines[#lines + 1] = "Left-click toggles your hold only. Manual locking stays available."
    else
        if charge and charge.present then
            lines[#lines + 1] = string.format("Battery: %d%% (%s)", charge.percent, charge.state)
            local remaining = estimate(charge.state == "charging" and charge.time_to_full or charge.state == "discharging" and charge.time_to_empty or nil)
            lines[#lines + 1] = remaining and (remaining .. (charge.state == "charging" and " until full" or " remaining")) or "Time estimate unavailable"
        else
            lines[#lines + 1] = "No system battery"
        end
        if power and power.on_battery ~= nil then lines[#lines + 1] = power.on_battery and "Power: battery" or "Power: AC" end
        if charge and charge.present and power and power.energy_rate then lines[#lines + 1] = string.format("Battery power: %.1f W", power.energy_rate) end
        if power and power.active_profile then lines[#lines + 1] = "Profile: " .. power.active_profile end
        for _, device in ipairs(charge and charge.peripherals or {}) do
            local label = device.name and device.name ~= "" and device.name or device.kind or "Device"
            local level = device.percent ~= nil and (device.percent .. "%") or device.level or "unknown"
            lines[#lines + 1] = label .. ": " .. level
        end
    end
    return table.concat(lines, "\n\n")
end)
local battery_color = mantle.battery:map(function(b)
    if b and b.present and b.state == "discharging" and b.percent <= 15 then return theme.red end
    if b and b.present and b.state == "discharging" and b.percent <= 30 then return theme.yellow end
    return theme.sapphire
end)
local output_audio = mantle.audio:map(function(a)
    if not a or a.volume == nil then return " --" end
    return a.muted and " Muted" or string.format(" %d%%", math.floor(a.volume + 0.5))
end)
local input_audio = mantle.audio:map(function(a)
    if not a or a.source_volume == nil then return " --" end
    return a.source_muted and " Muted" or string.format(" %d%%", math.floor(a.source_volume + 0.5))
end)
local bluetooth = mantle.bluetooth:map(function(b)
    if not b or not b.available or not b.enabled then return "" end
    return #b.connected_devices > 0 and (" " .. #b.connected_devices) or ""
end)
local network = mantle.network:map(function(n)
    if not n then return "NET --" end
    if not n.connected then return "Disconnected" end
    return n.ssid == "Ethernet" and ("󰱓 " .. (n.ethernet_ip or "Ethernet")) or string.format(" %s %d%%", n.ssid or "Wi-Fi", n.strength)
end)
local podman = state("podman_status", "Podman …")
local function tray(output)
    return list {
    direction = "horizontal", spacing = 4, align_v = "center", max_width = 128, scroll = scroll("tray_" .. output),
    source = mantle.tray:map(function(value)
        local items = {}
        for _, item in ipairs(value and value.items or {}) do if item.status ~= "passive" then items[#items + 1] = item end end
        return items
    end),
    key = function(item) return item.id end,
    itemfn = function(item)
        local wheel = 0
        local icon_name, icon_path = item.icon_name, item.icon_path
        if item.status == "needs_attention" and (item.attention_icon_name or item.attention_icon_path) then
            icon_name, icon_path = item.attention_icon_name, item.attention_icon_path
        end
        return rect {
            padding = 5, radius = 6, cursor = "pointer", accessible_name = item.name or item.id,
            on_click = function(box, which)
                local x, y = math.floor(box.x + box.width / 2), math.floor(box.y + box.height)
                if (which == "right" or which == "left" and item.item_is_menu) and item.menu then open_menu(item, box)
                elseif which == "left" and item.item_is_menu then mantle.tray:context_menu(item.id, x, y)
                elseif which == "left" then mantle.tray:activate(item.id, x, y)
                elseif which == "middle" then mantle.tray:secondary_activate(item.id, x, y)
                elseif which == "right" then mantle.tray:context_menu(item.id, x, y) end
            end,
            on_wheel = function(_, steps)
                wheel = wheel + steps
                local notches = wheel >= 0 and math.floor(wheel + 1e-9) or math.ceil(wheel - 1e-9)
                if notches == 0 then return end
                wheel = wheel - notches
                mantle.tray:scroll(item.id, notches, "vertical")
            end,
            children = { icon { name = icon_path or icon_name or "application-x-executable", size = 18, foreground = theme.text } },
        }
    end,
}
end

local function flatten_menu(entries, expanded, depth, result)
    for _, entry in ipairs(entries or {}) do
        result[#result + 1] = { entry = entry, depth = depth }
        if expanded[tostring(entry.id)] then flatten_menu(entry.children, expanded, depth + 1, result) end
    end
    return result
end

local menu_rows = computed({ mantle.tray, menu_item, menu_expanded }, function(value, id, expanded)
    for _, item in ipairs(value and value.items or {}) do
        if item.id == id then return flatten_menu(item.menu, expanded, 0, {}) end
    end
    return {}
end)

mantle.tray:on_change(function(value)
    if not menu_open:get() then return end
    for _, item in ipairs(value and value.items or {}) do
        if item.id == menu_item:get() and item.status ~= "passive" then return end
    end
    close_menu()
end)

local function menu_row(item)
    local entry = item.entry
    if entry.menu_type == "separator" then
        return rect { width = "fill", padding = 4, children = { rect { width = "fill", height = 1, background = theme.surface1 } } }
    end
    local label = ((entry.label or ""):gsub("__", "\0"):gsub("_", ""):gsub("%z", "_"))
    local children = entry.children or {}
    local marker = #children > 0 and ">" or (entry.toggle_state == 1 and "[x]" or (entry.toggle_state == 0 and "[ ]" or ""))
    local over = hover("tray_menu_" .. entry.id)
    return row {
        width = "fill", padding = { left = 8 + item.depth * 12, right = 8, top = 7, bottom = 7 }, spacing = 8, radius = 6,
        hover = over, cursor = entry.enabled and "pointer" or "default", accessible_name = label,
        background = over:map(function(on) return on and entry.enabled and theme.surface1 or "#00000000" end),
        opacity = entry.enabled and 1 or 0.4,
        on_click = function()
            if not entry.enabled then return end
            if #children > 0 then
                local expanded = {}
                for id, value in pairs(menu_expanded:get()) do expanded[id] = value end
                local key = tostring(entry.id)
                expanded[key] = not expanded[key] or nil
                menu_expanded:set(expanded)
                if expanded[key] then mantle.tray:menu_will_show(menu_item:get(), entry.id) end
            else
                mantle.tray:activate_menu_item(menu_item:get(), entry.id)
                close_menu()
            end
        end,
        children = {
            icon { name = entry.icon_name or "", size = 14, foreground = theme.text, visible = entry.icon_name ~= nil },
            text { content = label, width = "fill", elide = "end", foreground = theme.text },
            text { content = marker, foreground = theme.subtext0 },
        },
    }
end
local polling = false
local function poll_podman()
    if polling then return end
    polling = true
    process.run(mantle.config_dir .. "/scripts/podman.sh", { "-c", "arch-toolbox-latest" }, function(line) podman:set("󰦭 " .. line) end, function() polling = false end)
end
poll_podman()
interval(5000, poll_podman)

local bar = panel {
    id = "mantle-bar", layer = "top", anchor = { top = true, left = true, right = true }, width = "fill", height = 46, exclusive_zone = true,
    child = function(output)
        return row {
            width = "fill", height = "fill", spacing = 12, padding = { left = 10, right = 10 }, background = theme.base,
            children = {
                row {
                    id = "bar_left", width = "fill", align_h = "start", align_v = "center", spacing = 10, clip = "box", scroll = scroll("bar_left_" .. output),
                    children = {
                        workspaces(output),
                        pill(podman, theme.green, function() process.detach(mantle.config_dir .. "/scripts/podman.sh", { "-c", "arch-toolbox-latest", "toggle" }); timer(1000, poll_podman) end, nil, "Toggle arch-toolbox-latest container"),
                        pill(wallpaper_open:map(function() return "Wallpaper" end), theme.lavender, function() wallpaper_open:set(not wallpaper_open:get()) end, nil, "Choose wallpaper"),
                        pill(awake_label, computed({ caffeine, mantle.idle }, function(held, idle)
                            return held and theme.yellow or (idle and idle.inhibited and theme.peach or theme.subtext1)
                        end), function(box, button)
                            if button == "right" then open_details("idle", box) else caffeine:set(not caffeine:get()) end
                        end, nil, "Toggle keep awake; right-click for inhibitors"),
                    },
                },
                clock(),
                row {
                    id = "bar_right", width = "fill", align_h = "start", align_v = "center", spacing = 6, clip = "box", scroll = scroll("bar_right_" .. output),
                    children = {
                        rect { width = "fill" },
                        pill(brightness, theme.yellow, nil, function(_, steps) local b = mantle.brightness:get(); if b then mantle.brightness:set(math.max(1, math.min(100, b.percent + steps * 5))) end end, "Adjust brightness"),
                        pill(battery, battery_color, function(box) open_details("battery", box) end, nil, "Battery status"),
                        pill(output_audio, theme.blue, function() mantle.audio:toggle_mute() end, function(_, steps) local a = mantle.audio:get(); if a and a.volume then mantle.audio:set_volume(math.max(0, math.min(100, a.volume + steps * 5))) end end, "Toggle output mute"),
                        pill(input_audio, theme.teal, function() mantle.audio:toggle_source_mute() end, function(_, steps) local a = mantle.audio:get(); if a and a.source_volume then mantle.audio:set_source_volume(math.max(0, math.min(100, a.source_volume + steps * 5))) end end, "Toggle microphone mute"),
                        pill(bluetooth, theme.maroon, function() process.detach("blueman-manager", {}) end, nil, "Bluetooth settings"),
                        pill(network, theme.peach, function() process.detach("nm-connection-editor", {}) end, nil, "Network settings", 112), tray(output),
                    },
                },
            },
        }
    end,
}

local tray_menu = popup {
    id = "tray_menu", parent = "mantle-bar", anchor_rect = menu_anchor, anchor = "bottom", gravity = "bottom_left",
    offset = { y = 6 }, visible = menu_open, on_dismiss = close_menu, width = 280, padding = 6, radius = theme.radius,
    constraint_adjustment = { "slide_x", "flip_y", "slide_y" }, background = theme.mantle, border_width = 1, border_color = theme.surface2,
    child = list { width = "fill", max_height = 440, scroll = scroll("tray_menu"), source = menu_rows,
        key = function(item) return tostring(item.entry.id) end, itemfn = menu_row },
}

local details = popup {
    id = "bar_details_popup", parent = "mantle-bar", anchor_rect = details_anchor, anchor = "bottom", gravity = "bottom_left",
    offset = { y = 6 }, visible = details_kind:map(function(kind) return kind ~= "" end),
    on_dismiss = function() details_kind:set("") end, width = 340, padding = 14, radius = theme.radius,
    constraint_adjustment = { "slide_x", "flip_y", "slide_y" }, background = theme.mantle, border_width = 1, border_color = theme.surface2,
    child = column { width = "fill", max_height = 400, spacing = 12, scroll = scroll("bar_details"), children = {
        text { content = details_kind:map(function(kind) return kind == "idle" and "Idle inhibitors" or "Battery & power" end),
            font_size = 18, font_weight = 600, foreground = theme.text },
        text { content = details_text, width = "fill", wrap = "word", foreground = theme.subtext1 },
    } },
}

return { bar, tray_menu, details }
