local theme = require("theme")
local osd = state("level_osd", { percent = 0, kind = "volume", muted = false, n = 0 })

local function update(kind, percent, muted)
    osd:set({ percent = math.max(0, percent), kind = kind, muted = muted or false, n = osd:get().n + 1 })
end

mantle.audio:on_change(function(value, previous)
    if value and previous and previous.volume ~= nil and value.volume ~= nil and (value.volume ~= previous.volume or value.muted ~= previous.muted) then
        update("volume", value.volume, value.muted)
    end
end)

mantle.brightness:on_change(function(value, previous)
    if value and previous and previous.percent ~= nil and value.percent ~= nil and value.percent ~= previous.percent then
        update("brightness", value.percent, false)
    end
end)

local shown = pulse(osd, 1500)
local mapped = pulse(osd, 1700)
local icon_name = osd:map(function(value)
    if value.kind == "brightness" then return "display-brightness-symbolic" end
    if value.muted or value.percent == 0 then return "audio-volume-muted-symbolic" end
    if value.percent < 34 then return "audio-volume-low-symbolic" end
    if value.percent < 67 then return "audio-volume-medium-symbolic" end
    return "audio-volume-high-symbolic"
end)
local label = osd:map(function(value)
    if value.kind == "volume" and value.muted then return "Muted" end
    return math.floor(value.percent + 0.5) .. "%"
end)

return panel {
    id = "level_osd", layer = "overlay", output = "active", anchor = { bottom = true }, margin = { bottom = 80 }, visible = mapped,
    child = row {
        width = 280, height = 48, spacing = 12, padding = { left = 16, right = 16 }, align_v = "center",
        radius = 24, background = "#1e2030e6", border_width = 1, border_color = theme.surface2,
        opacity = shown:map(function(on) return on and 1 or 0 end),
        translate = shown:map(function(on) return { y = on and 0 or 12 } end),
        animate = { opacity = { duration = 150, from = 0 }, translate = { spring = { stiffness = 300, damping = 22 }, from = { y = 12 } } },
        children = {
            icon { name = icon_name, size = 20, foreground = theme.text, align_v = "center" },
            rect { width = "fill", height = 6, radius = 3, align_v = "center", background = theme.surface2, children = {
                rect { height = "fill", radius = 3, background = osd:map(function(value) return value.muted and theme.overlay0 or (value.kind == "brightness" and theme.yellow or theme.blue) end), width = osd:map(function(value) return math.min(100, value.percent) .. "%" end), animate = { width = { duration = 120, easing = "out_cubic" } } },
            } },
            text { content = label, width = 52, text_align = "end", align_v = "center", font_size = 14, foreground = theme.text },
        },
    },
}
