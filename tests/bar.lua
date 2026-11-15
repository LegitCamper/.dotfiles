package.path = ".config/mantle/?.lua;" .. package.path

local states, scrolls, processes, collectors, storage = {}, {}, {}, {}, {}
local function signal(value)
    local source = { value = value, listeners = {} }
    function source:get() return self.value end
    function source:set(next_value)
        local previous = self.value
        self.value = next_value
        for _, listener in ipairs(self.listeners) do listener(next_value, previous) end
    end
    function source:on_change(callback) self.listeners[#self.listeners + 1] = callback end
    function source:map(transform)
        local mapped = signal()
        function mapped:get() return transform(source:get()) end
        return mapped
    end
    return source
end

function state(name, value)
    states[name] = states[name] or signal(value)
    return states[name]
end
function hover() return signal(false) end
function scroll(name)
    if not scrolls[name] then
        local offset = signal(0)
        function offset:reveal(index) self.revealed = index end
        function offset:scroll_to(value) self:set(value) end
        scrolls[name] = offset
    end
    return scrolls[name]
end
function computed(sources, transform)
    local result = signal()
    function result:get()
        local values = {}
        for index, source in ipairs(sources) do values[index] = source:get() end
        return transform(table.unpack(values, 1, #sources))
    end
    return result
end
function pulse() return signal(true) end
function fuzzy(value, query) return value:find(query, 1, true) end
for _, name in ipairs({ "rect", "row", "column", "text", "icon", "image", "list", "panel", "popup", "textfield" }) do
    _G[name] = function(options) options.kind = name; return options end
end
function interval() end
function timer() end
process = {
    run = function(command, args, on_line, on_exit)
        processes[#processes + 1] = { command = command, args = args, line = on_line, exit = on_exit }
    end,
    detach = function() end,
}
function session_process(options)
    local handle = {}
    function handle:start(command, args) self.command, self.args = command, args end
    collectors[options.name] = handle
    return handle
end
mantle = { config_dir = ".config/mantle" }
for _, name in ipairs({ "system", "workspaces", "brightness", "battery", "audio", "bluetooth", "network", "tray", "power", "idle", "files" }) do
    mantle[name] = signal()
end
function persistent_table(options)
    storage.path = options.path .. "/" .. options.name
    storage.wallpaper = signal(options.defaults.wallpaper)
    function storage:set(key, value) self[key]:set(value) end
    return storage
end
local wallpaper_folder
function mantle.files:watch(path) wallpaper_folder = path end
local holds, releases = 0, 0
function mantle.idle:inhibit() holds = holds + 1 end
function mantle.idle:release_inhibit() releases = releases + 1 end

local surfaces = require("bar")
local root = surfaces[1].child("test-output")
local clock = root.children[2]
assert(root.kind == "row" and clock.width == 160)
for _, index in ipairs({ 1, 3 }) do
    assert(root.children[index].width == "fill" and root.children[index].clip == "box")
    assert(root.children[index].scroll)
end
local label = assert(clock.children[1].content, "clock must bind its local signal")
assert(label:get() == "--:--")
local timestamp = os.time({ year = 2026, month = 1, day = 2, hour = 13, min = 5 })
mantle.system:set({ time = timestamp })
assert(label:get() == os.date("%I:%M %p", timestamp))
assert(clock.children[2].content:get() == os.date("%a %b %d, %Y", timestamp))
assert(not clock.on_click and surfaces[2].id ~= "clock_popup")
local second_output = surfaces[1].child("second-output")
assert(second_output.children[1].scroll ~= root.children[1].scroll)
assert(second_output.children[2].children[1].content:get() == label:get())

local statuses = {}
for index = 2, #root.children[3].children do statuses[index - 1] = root.children[3].children[index] end
for _, index in ipairs({ 1, 2, 5 }) do assert(not statuses[index].visible:get()) end
mantle.brightness:set({ percent = 50 })
mantle.battery:set({ present = true, percent = 75, state = "discharging" })
mantle.bluetooth:set({ available = true, enabled = true, connected_devices = {} })
for _, index in ipairs({ 1, 2, 5 }) do
    assert(statuses[index].visible:get())
    assert(statuses[index].background:get() == "#00000000")
end
assert(statuses[2].cursor == "pointer")
assert(statuses[5].on_click and statuses[6].on_click)
assert(statuses[6].children[1].max_width == 112)
mantle.brightness:set(nil)
mantle.battery:set({ present = false })
mantle.bluetooth:set({ available = true, enabled = false })
for _, index in ipairs({ 1, 2, 5 }) do assert(not statuses[index].visible:get()) end

local wallpaper_button, awake = root.children[1].children[3], root.children[1].children[4]
wallpaper_button.on_click()
assert(states.wallpaper_open:get())
local anchor = { x = 30, y = 0, width = 80, height = 46 }
local details = surfaces[3]
local detail_text = details.child.children[2].content
mantle.idle:set({ inhibited = false, inhibitors = {} })
assert(awake.children[1].content:get() == "Idle allowed")
awake.on_click(anchor, "left")
assert(holds == 1 and states.caffeine:get())
assert(awake.children[1].content:get() == "Awake requested")
mantle.idle:set({ inhibited = true, inhibitors = { { who = "mpv", why = "Playing video" } } })
assert(awake.children[1].content:get() == "Awake")
states.caffeine:set(true)
assert(holds == 1)
second_output.children[1].children[4].on_click(anchor, "left")
assert(releases == 1 and not states.caffeine:get())
assert(awake.children[1].content:get() == "Awake (app)")
awake.on_click(anchor, "right")
assert(details.visible:get() and states.bar_details_anchor:get() == anchor)
assert(holds == 1 and releases == 1 and detail_text:get():find("mpv: Playing video", 1, true))
mantle.idle:set(nil)
assert(detail_text:get():find("unavailable", 1, true))
details.on_dismiss()
assert(not details.visible:get())

mantle.battery:set({ present = true, percent = 15, state = "discharging", time_to_empty = 3660,
    peripherals = { { name = "Mouse", percent = 0 }, { name = "Headset", level = "low" }, { kind = "keyboard" } } })
mantle.power:set({ on_battery = true, energy_rate = 7.5, active_profile = "balanced" })
states.tray_menu_open:set(true)
statuses[2].on_click(anchor)
assert(not states.tray_menu_open:get() and details.visible:get())
for _, expected in ipairs({ "15%", "1h 01m remaining", "7.5 W", "Profile: balanced", "Mouse: 0%", "Headset: low", "keyboard: unknown" }) do
    assert(detail_text:get():find(expected, 1, true), expected)
end
assert(statuses[2].children[1].foreground:get() == require("theme").red)
mantle.battery:set({ present = true, percent = 30, state = "discharging", time_to_empty = 0 })
assert(detail_text:get():find("Time estimate unavailable", 1, true))
assert(statuses[2].children[1].foreground:get() == require("theme").yellow)
mantle.battery:set({ present = true, percent = 90, state = "charging", time_to_full = 59, time_to_empty = 9999 })
assert(detail_text:get():find("<1m until full", 1, true))
mantle.battery:set({ present = true, percent = 100, state = "fully-charged", time_to_empty = 9999 })
assert(not detail_text:get():find("remaining", 1, true))
mantle.battery:set({ present = false, peripherals = { { name = "Mouse", percent = 80 } } })
mantle.power:set(nil)
assert(statuses[2].visible:get() and detail_text:get():find("Mouse: 80%", 1, true))
assert(detail_text:get():find("No system battery", 1, true))
assert(not detail_text:get():find("Battery power", 1, true))
mantle.battery:set(nil)
assert(not statuses[2].visible:get())

local wallpapers = require("wallpaper")
local background, picker = wallpapers[1], wallpapers[2]
local picker_content = picker.child.children[2].children
local search, message, choices = picker_content[2].children[1], picker_content[3].content, picker_content[4]
assert(storage.path:sub(-20) == "/mantle/desktop.json")
assert(not background.visible:get() and message:get() == "Loading wallpapers...")
local first = { name = "First wallpaper.jpg", path = wallpaper_folder .. "/First wallpaper.jpg" }
local second = { name = "Second.png", path = wallpaper_folder .. "/Second.png" }
local function set_wallpapers(entries, error_message)
    mantle.files:set({ folders = { [wallpaper_folder] = { ready = true, entries = entries, error = error_message } } })
end
set_wallpapers({}, "Permission denied")
assert(message:get():find("Permission denied", 1, true))
set_wallpapers({})
assert(message:get():find("Add PNG", 1, true))
set_wallpapers({ first, second })
assert(#choices.source:get() == 2)
search.on_navigate("up")
assert(states.wallpaper_selected:get() == 2 and scrolls.wallpaper_results.revealed == 2)
search.on_submit()
assert(storage.wallpaper:get() == second.path and not states.wallpaper_open:get())
assert(background.visible:get() and background.child("test-output").source:get() == second.path)
assert(background.child("second-output").source:get() == second.path)
states.wallpaper_open:set(true)
search.on_change("First")
assert(#choices.source:get() == 1 and states.wallpaper_selected:get() == 1)
search.on_submit()
assert(storage.wallpaper:get() == first.path)
states.wallpaper_open:set(true)
search.on_change("not found")
search.on_submit()
assert(storage.wallpaper:get() == first.path and states.wallpaper_open:get())
assert(message:get() == "No matching wallpapers")
search.on_change("")
local stale_choice = choices.itemfn(first)
set_wallpapers({ second })
assert(not background.visible:get() and message:get():find("missing", 1, true))
stale_choice.on_click()
assert(storage.wallpaper:get() == first.path and states.wallpaper_open:get())
storage.wallpaper:set("/outside/wallpapers.jpg")
assert(not background.visible:get())
storage.wallpaper:set(second.path)
assert(background.visible:get())
search.on_cancel(false)
assert(not states.wallpaper_open:get())

local workspaces = root.children[1].children[1]
mantle.workspaces:set({ outputs = { { name = "test-output", active_workspace = 42, workspaces = {
    { id = 42, idx = 11, populated = true }, { id = 43, idx = 12, populated = false },
    { id = 44, idx = 13, name = "named", populated = false },
} } } })
local shown = workspaces.source:get()
assert(#shown == 2 and shown[1].id == 42 and shown[1].active and shown[2].id == 44)
local focused
function mantle.workspaces:focus(id) focused = id end
workspaces.itemfn(shown[1]).on_click()
assert(focused == 42)

local tray = statuses[7]
assert(tray.max_width == 128 and tray.scroll)
local fixture = { id = "app", name = "Tray app", status = "active", icon_path = "/tmp/icon.png", item_is_menu = true,
    menu = {
        { id = 1, label = "_Open", enabled = true, children = {} },
        { id = 2, label = "_Disabled", enabled = false, children = {} },
        { id = 3, label = "Sub_menu", enabled = true, children = { { id = 4, label = "Child", enabled = true, children = {} } } },
        { id = 5, menu_type = "separator", children = {} },
    } }
local tray_call
for _, action in ipairs({ "activate", "context_menu", "secondary_activate", "menu_will_show", "activate_menu_item" }) do
    mantle.tray[action] = function(_, ...) tray_call = { action, ... } end
end
mantle.tray:set({ items = { fixture, { id = "hidden", status = "passive" } } })
assert(#tray.source:get() == 1)
local button = tray.itemfn(fixture)
assert(button.children[1].name == fixture.icon_path and button.accessible_name == fixture.name)
button.on_click({ x = 50, y = 0, width = 28, height = 28 }, "left")
assert(tray_call[1] == "menu_will_show" and states.tray_menu_open:get())
assert(not details.visible:get())
local menu = surfaces[2].child
local entries = menu.source:get()
assert(#entries == 4)
menu.itemfn(entries[2]).on_click()
assert(tray_call[1] == "menu_will_show" and states.tray_menu_open:get())
menu.itemfn(entries[3]).on_click()
assert(tray_call[3] == 3 and #menu.source:get() == 5)
menu.itemfn(entries[1]).on_click()
assert(tray_call[1] == "activate_menu_item" and tray_call[3] == 1 and not states.tray_menu_open:get())
button.on_click({ x = 0, y = 0, width = 28, height = 28 }, "right")
surfaces[2].on_dismiss()
assert(not states.tray_menu_open:get())
fixture.menu = nil
tray.itemfn(fixture).on_click({ x = 0, y = 0, width = 28, height = 28 }, "left")
assert(tray_call[1] == "context_menu")
fixture.status, fixture.attention_icon_path = "needs_attention", "/tmp/attention.png"
assert(tray.itemfn(fixture).children[1].name == fixture.attention_icon_path)
local notches = 0
function mantle.tray:scroll(_, delta) notches = notches + delta end
for _ = 1, 10 do button.on_wheel({}, 0.2) end
assert(notches == 2)
for _ = 1, 10 do button.on_wheel({}, -0.2) end
assert(notches == 0)
states.tray_menu_open:set(true)
mantle.tray:set({ items = {} })
assert(not states.tray_menu_open:get())

local clipboard = require("clipboard")
processes[#processes].exit(127)
assert(states.clipboard_message:get():find("unavailable", 1, true))
states.clipboard_open:set(true)
processes[#processes].line("/fixture/cliphist", "stdout")
processes[#processes].exit(0)
assert(collectors.clipboard_text.command == "wl-paste")
assert(collectors.clipboard_image.args[4] == "/fixture/cliphist")
local listing = processes[#processes]
listing.line("stderr must not become history", "stderr")
for index = 1, 60 do listing.line(tostring(index) .. "\tentry " .. index, "stdout") end
listing.exit(0)
assert(#states.clipboard_rows:get() == 60 and states.clipboard_message:get() == "")
local contents = clipboard.child.children[2].children
local field = contents[1].children[1]
local results = contents[4]
assert(field.kind == "textfield" and not field.background and not field.radius)
assert(results.scroll and #results.source:get() == 50)
field.on_navigate("up")
assert(states.clipboard_selected:get() == 50 and scrolls.clipboard_results.revealed == 50)
field.on_navigate("down")
assert(states.clipboard_selected:get() == 1)
field.on_submit()
local copying = processes[#processes]
copying.exit(1)
assert(states.clipboard_open:get() and states.clipboard_message:get():find("Copy failed", 1, true))
field.on_submit()
processes[#processes].exit(0)
assert(not states.clipboard_open:get())
field.on_change("no such record")
local count = #processes
field.on_submit()
assert(#processes == count and #results.source:get() == 0)
states.clipboard_open:set(true)
local stale = processes[#processes]
states.clipboard_open:set(false)
states.clipboard_open:set(true)
stale.line("/old/cliphist", "stdout"); stale.exit(0)
assert(processes[#processes] ~= stale and processes[#processes].command == "sh")
processes[#processes].line("/fixture/cliphist", "stdout"); processes[#processes].exit(0)
processes[#processes].exit(1)
assert(#states.clipboard_rows:get() == 0 and states.clipboard_message:get():find("Could not read", 1, true))

local osd = require("osd")
mantle.audio:set({ volume = 100, muted = false })
mantle.audio:set({ volume = 145, muted = false })
assert(osd.child.children[3].content:get() == "145%")
assert(osd.child.children[2].children[1].width:get() == "100%")
mantle.audio:set(nil)
mantle.brightness:set(nil)
print("bar, battery, inhibitors, wallpaper, tray, clipboard, multi-output construction, and OSD regressions passed")
