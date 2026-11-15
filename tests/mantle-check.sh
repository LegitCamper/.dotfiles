#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if command -v mantle >/dev/null 2>&1; then
    runner=(mantle)
else
    runner=(flatpak-spawn --host mantle)
fi
mkdir -p "$HOME/.cache"
fixture=$(mktemp -d "$HOME/.cache/mantle-check.XXXXXXXX")
trap 'rm -rf -- "$fixture"' EXIT
cp -R .config/mantle/. "$fixture/"
mv "$fixture/shell.lua" "$fixture/original_shell.lua"
cat >"$fixture/scenario.lua" <<'LUA'
local native_state, native_panel, native_row, native_column, native_rect, native_list = state, panel, row, column, rect, list
local measurements = {}
for _, id in ipairs({ "bar_left", "bar_clock", "bar_right" }) do measurements[id] = geometry("check_" .. id) end
measurements.first_status = geometry("check_first_status")
measurements.last_tray = geometry("check_last_tray")
measurements.tray = geometry("check_tray")
measurements.last_workspace = geometry("check_last_workspace")
rect = function(options)
    if options.accessible_name == "Adjust brightness" then options.geometry = measurements.first_status end
    if options.accessible_name == "Fixture 32" then options.geometry = measurements.last_tray end
    if options.accessible_name == "Focus workspace 20" then options.geometry = measurements.last_workspace end
    return native_rect(options)
end
list = function(options)
    if options.direction == "horizontal" and options.max_width == 128 then options.geometry = measurements.tray end
    return native_list(options)
end
row = function(options)
    if measurements[options.id] then options.geometry = measurements[options.id] end
    return native_row(options)
end
column = function(options)
    if measurements[options.id] then options.geometry = measurements[options.id] end
    return native_column(options)
end
state = function(name, initial)
    if name == "clipboard_open" or name == "launcher_open" or name == "tray_menu_open" or name == "wallpaper_open" then initial = true end
    if name == "tray_menu_item" then initial = "fixture" end
    if name == "bar_details" then initial = "battery" end
    return native_state(name, initial)
end
pulse = function() return native_state("check_pulse", true) end
panel = function(options)
    if options.id == "mantle-bar" then
        options.width = test_width
        options.anchor = { top = true, left = true }
        options.output = test_output
    end
    return native_panel(options)
end
local function capability(name, value)
    mantle[name] = native_state("check_" .. name, value)
end
local menu = {
    { id = 1, label = "_Open", menu_type = "standard", enabled = true, children = {} },
    { id = 2, label = "Disabled", menu_type = "standard", enabled = false, children = {} },
    { id = 3, menu_type = "separator", enabled = false, children = {} },
    { id = 4, label = "Submenu", menu_type = "standard", enabled = true, children = {
        { id = 5, label = "Checked", menu_type = "standard", enabled = true, toggle_state = 1, toggle_type = "checkmark", children = {} },
    } },
}
local tray = { { id = "fixture", name = "Fixture", status = "active", icon_name = "application-x-executable", item_is_menu = true, menu = menu } }
for index = 2, 32 do
    tray[index] = { id = "fixture" .. index, name = "Fixture " .. index, status = "active", icon_path = "/fixture/path-only.png", item_is_menu = false }
end
capability("tray", { items = tray })
capability("system", { time = os.time() })
capability("network", { connected = true, ssid = string.rep("W", 32), strength = 100 })
capability("audio", { volume = 145, muted = false, source_volume = 100, source_muted = false })
capability("brightness", { percent = 100 })
capability("battery", { present = true, state = "discharging", percent = 100, time_to_empty = 7200,
    peripherals = { { name = "Fixture mouse", percent = 75 }, { name = "Fixture headset", level = "low" } } })
capability("power", { on_battery = true, energy_rate = 8.5, active_profile = "balanced" })
capability("idle", { inhibited = true, inhibitors = { { who = "Fixture player", why = "Playing video" } } })
capability("bluetooth", { available = true, enabled = true, connected_devices = { {} } })
local wallpaper_folder = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/Wallpapers"
local wallpaper_path = wallpaper_folder .. "/rust.png"
local files = native_state("check_files", { folders = { [wallpaper_folder] = { ready = true, entries = {
    { name = "rust.png", path = wallpaper_path },
} } } })
mantle.files = { watch = function() end, map = function(_, transform) return files:map(transform) end }
persistent_table = function()
    return { wallpaper = native_state("check_wallpaper", wallpaper_path), set = function() error("fixture must not save wallpaper") end }
end
local workspaces = {}
for index = 1, 20 do workspaces[index] = { id = index, idx = index, name = "Workspace " .. index, populated = true } end
capability("workspaces", { outputs = { { name = test_output, active_workspace = 11, workspaces = workspaces } } })
local surfaces = require("original_shell")
local history = {}
for index = 1, 60 do history[index] = tostring(index) .. "\tClipboard fixture " .. index end
native_state("clipboard_rows", {}):set(history)
native_state("clipboard_message", ""):set("")
native_state("tray_menu_expanded", {}):set({ ["4"] = true })
native_state("level_osd", {}):set({ percent = 145, kind = "volume", muted = false, n = 1 })
if test_scroll then
    scroll("bar_left_" .. test_output):scroll_to(100000)
    scroll("bar_right_" .. test_output):scroll_to(100000)
    scroll("tray_" .. test_output):scroll_to(100000)
end
local validated = false
surfaces[#surfaces + 1] = native_panel {
    id = "layout_assertions", layer = "overlay", output = test_output, width = 1, height = 1, anchor = { top = true, left = true },
    child = text { content = computed({ measurements.bar_left, measurements.bar_clock, measurements.bar_right, measurements.first_status, measurements.tray, measurements.last_tray, measurements.last_workspace }, function(left, clock, right, first, tray_box, last, workspace)
        if clock.width == 0 or right.width == 0 then return "" end
        assert(math.abs(clock.x + clock.width / 2 - test_width / 2) <= 1, "clock not centered")
        assert(left.x + left.width <= clock.x, "left region overlaps clock")
        assert(clock.x + clock.width <= right.x, "right region overlaps clock")
        assert(right.x + right.width <= test_width, "right region exceeds bar")
        assert(clock.width >= 160, "clock reserve lost")
        if test_scroll then
            assert(last.x >= right.x - 1 and last.x + last.width <= right.x + right.width + 1, "last tray item unreachable")
            assert(last.x >= tray_box.x - 1 and last.x + last.width <= tray_box.x + tray_box.width + 1, "last tray item clipped")
            assert(workspace.x >= left.x - 1 and workspace.x + workspace.width <= left.x + left.width + 1, "last workspace unreachable")
        else
            assert(first.x >= right.x - 1, "first status unreachable at start of scroll")
        end
        if not validated then print("verified geometry " .. test_width .. " " .. test_output .. " scroll=" .. tostring(test_scroll)); validated = true end
        return ""
    end) },
}
return surfaces
LUA
for width in 1280 1920 3440; do
    for output in DP-1 test-secondary; do
        for scrolling in false true; do
            printf 'test_width = %s\ntest_output = "%s"\ntest_scroll = %s\nreturn require("scenario")\n' "$width" "$output" "$scrolling" >"$fixture/shell.lua"
            result=$("${runner[@]}" check -c "$fixture")
            printf '%s\n' "$result"
            [[ "$result" == *"verified geometry $width $output scroll=$scrolling"* ]]
        done
    done
done
printf 'native layout, battery, wallpaper, open clipboard, launcher, tray menu, and OSD checks passed\n'
