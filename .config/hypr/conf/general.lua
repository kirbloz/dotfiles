-- See https://wiki.hyprland.org/Configuring/Variables/ for more
--[[ general {
    gaps_in = 5
    gaps_out = 5
    border_size = 2
    col.active_border = rgba(666666aa)
    col.inactive_border = rgb(171717)
    layout = dwindle
    resize_on_border = true

    #no_border_on_floating = false
    #extend_border_grab_area = true
    #hover_icon_on_border = true
} ]]--

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 5,
        border_size = 2,

        col = {
            active_border   =  "rgba(666666aa)",
            inactive_border = "rgba(00171717)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },
})

