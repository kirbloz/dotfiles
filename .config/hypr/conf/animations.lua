--[[return {
    enabled = true,
 
    bezier = { "myBezier", 0.05, 0.9, 0.1, 1.05 },
 
    animation = {
        { "windows",    1, 7,  "myBezier" },
        { "windowsOut", 1, 7,  "default", "popin 80%" },
        { "border",     1, 10, "default" },
        { "borderangle",1, 8,  "default" },
        { "fade",       1, 7,  "default" },
        { "workspaces", 1, 6,  "default" },
    },
}]]--
hl.config({
    animations = {
        enabled = true,
    },
})

-- https://github.com/Gakuseei/Ricelin/blob/main/configs/hypr/modules/animations.lua

--[[
    pillMorph mirrors the pill's Motion.morphCurve, cubic-bezier(0.16, 1, 0.3, 1)
    at speed 4.2 (420ms), so windows, layers and workspaces speak the same motion
    language as the shell instead of a faster quint pop.
]]
hl.curve("pillMorph",      { type = "bezier", points = { { 0.16, 1.00 },    { 0.30, 1.00 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })

hl.animation({ leaf = "global",     enabled = true, speed = 4.2,   bezier = "pillMorph" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.2,   bezier = "pillMorph" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.2,   bezier = "pillMorph", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.2, bezier = "pillMorph", style = "popin 92%" })
hl.animation({ leaf = "border",     enabled = true, speed = 4.2,   bezier = "quick" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 4.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 4.2, bezier = "almostLinear" })
hl.animation({ leaf = "layers",        enabled = true, speed = 4.2, bezier = "pillMorph", style = "popin 90%" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 4.2, bezier = "pillMorph" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 4.2, bezier = "pillMorph" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.2, bezier = "pillMorph", style = "slide" })
