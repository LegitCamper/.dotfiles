local theme = require("theme")

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
                if workspace.idx ~= 11 then
                    items[#items + 1] = { id = workspace.id, label = tostring(workspace.idx), active = workspace.id == output.active_workspace, populated = workspace.populated }
                end
            end
            return items
        end),
        key = function(item) return tostring(item.id) end,
        itemfn = function(item)
            local over = hover("workspace_" .. tostring(item.id))
            return rect {
                padding = { left = 8, right = 8, top = 4, bottom = 4 }, radius = theme.radius,
                hover = over, cursor = "pointer", accessible_name = "Focus workspace " .. item.label,
                background = over:map(function(on) return on and theme.surface2 or (item.active and theme.mauve or (item.populated and theme.surface1 or theme.surface0)) end),
                animate = { background = theme.fast },
                on_click = function() mantle.workspaces:focus(item.id) end,
                children = { text { content = item.label, font_size = 14, foreground = item.active and theme.crust or theme.text } },
            }
        end,
    }
end

local function pill(label, color, click, wheel, name)
    local over = hover(name)
    return rect {
        align_v = "center", padding = { left = 10, right = 10, top = 5, bottom = 5 }, radius = theme.radius,
        hover = over, cursor = "pointer", accessible_name = name, on_click = click, on_wheel = wheel,
        background = over:map(function(on) return on and theme.surface2 or theme.mantle end), animate = { background = theme.fast },
        children = { text { content = label, font_size = 14, foreground = color } },
    }
end

local brightness = mantle.brightness:map(function(b) return b and string.format("☀ %d%%", b.percent) or "" end)
local battery = mantle.battery:map(function(b)
    if not b or not b.present then return "" end
    return string.format("%s %d%%", b.state == "charging" and "󰂄" or "", b.percent)
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
local time = mantle.system:map(function(s) return os.date("%I:%M %p", s and s.time) end)
local date = mantle.system:map(function(s) return os.date("%m/%d/%Y", s and s.time) end)
local podman = state("podman_status", "Podman …")
local tray = list {
    direction = "horizontal", spacing = 4, align_v = "center",
    source = mantle.tray:map(function(value)
        local items = {}
        for _, item in ipairs(value and value.items or {}) do if item.status ~= "passive" then items[#items + 1] = item end end
        return items
    end),
    key = function(item) return item.id end,
    itemfn = function(item)
        return rect {
            padding = 5, radius = 6, cursor = "pointer", accessible_name = item.title or item.id,
            on_click = function(box, which)
                local x, y = math.floor(box.x + box.width / 2), math.floor(box.y + box.height)
                if which == "left" then mantle.tray:activate(item.id, x, y)
                elseif which == "middle" then mantle.tray:secondary_activate(item.id, x, y)
                elseif which == "right" then mantle.tray:context_menu(item.id, x, y) end
            end,
            on_wheel = function(_, steps) mantle.tray:scroll(item.id, math.tointeger(math.modf(steps)), "vertical") end,
            children = { icon { name = item.icon_name or "application-x-executable", size = 18, foreground = theme.text } },
        }
    end,
}
local polling = false
local function poll_podman()
    if polling then return end
    polling = true
    process.run(mantle.config_dir .. "/scripts/podman.sh", { "-c", "arch-toolbox-latest" }, function(line) podman:set("󰦭 " .. line) end, function() polling = false end)
end
poll_podman()
interval(5000, poll_podman)

return panel {
    id = "mantle-bar", layer = "top", anchor = { top = true, left = true, right = true }, width = "fill", height = 46, exclusive_zone = true,
    child = function(output)
        return rect {
            width = "fill", height = "fill", padding = { left = 10, right = 10 }, background = theme.base,
            children = {
                row {
                    align_h = "start", align_v = "center", spacing = 10,
                    children = {
                        workspaces(output),
                        pill(podman, theme.green, function() process.detach(mantle.config_dir .. "/scripts/podman.sh", { "-c", "arch-toolbox-latest", "toggle" }); timer(1000, poll_podman) end, nil, "Toggle arch-toolbox-latest container"),
                    },
                },
                row {
                    align_h = "center", align_v = "center", spacing = 10,
                    children = {
                        pill(time, theme.rosewater, nil, nil, "Current time"),
                        pill(date, theme.rosewater, nil, nil, "Current date"),
                    },
                },
                row {
                    align_h = "end", align_v = "center", spacing = 10,
                    children = {
                        pill(brightness, theme.yellow, nil, function(_, steps) local b = mantle.brightness:get(); if b then mantle.brightness:set(math.max(1, math.min(100, b.percent + steps * 5))) end end, "Adjust brightness"),
                        pill(battery, battery_color, nil, nil, "Battery status"),
                        pill(output_audio, theme.blue, function() mantle.audio:toggle_mute() end, function(_, steps) local a = mantle.audio:get(); if a and a.volume then mantle.audio:set_volume(math.max(0, math.min(100, a.volume + steps * 5))) end end, "Toggle output mute"),
                        pill(input_audio, theme.teal, function() mantle.audio:toggle_source_mute() end, function(_, steps) local a = mantle.audio:get(); if a and a.source_volume then mantle.audio:set_source_volume(math.max(0, math.min(100, a.source_volume + steps * 5))) end end, "Toggle microphone mute"),
                        pill(bluetooth, theme.maroon, nil, nil, "Bluetooth status"), pill(network, theme.peach, nil, nil, "Network status"), tray,
                    },
                },
            },
        }
    end,
}
