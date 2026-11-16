-- conf/monitors.lua

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- main screen (HDMI-A-1) - 1080p @ 180Hz 
hl.monitor({
    output   = "HDMI-A-2",
    mode     = "1920x1080@180",
    position = "1920x0",
    scale    = 1,
})

-- secondary screen (eDP-1) - 1080p @ 144Hz on the left
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})

-- fallback 
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
