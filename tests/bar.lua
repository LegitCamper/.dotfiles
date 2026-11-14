package.path = ".config/mantle/?.lua;" .. package.path

local states, scrolls, processes, collectors = {}, {}, {}, {}
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
for _, name in ipairs({ "rect", "row", "column", "text", "icon", "list", "panel", "popup", "textfield" }) do
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
for _, name in ipairs({ "system", "workspaces", "brightness", "battery", "audio", "bluetooth", "network", "tray" }) do
    mantle[name] = signal()
end

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
assert(statuses[2].cursor == "default")
assert(statuses[5].on_click and statuses[6].on_click)
assert(statuses[6].children[1].max_width == 112)
mantle.brightness:set(nil)
mantle.battery:set({ present = false })
mantle.bluetooth:set({ available = true, enabled = false })
for _, index in ipairs({ 1, 2, 5 }) do assert(not statuses[index].visible:get()) end

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
print("bar, tray, clipboard, multi-output construction, and OSD regressions passed")
