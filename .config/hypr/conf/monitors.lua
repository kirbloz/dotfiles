-- conf/monitors.lua

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- 1. Monitor Principale (HDMI-A-1) - 1080p @ 180Hz 
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@180",
    position = "1920x0",
    scale    = 1,
})

-- 2. Schermo del Portatile (eDP-1) - 1080p @ 60Hz posizionato a sx
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- 3. Fallback per qualsiasi altro monitor extra collegato
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
