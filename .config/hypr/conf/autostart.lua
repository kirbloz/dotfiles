-- conf/autostart.lua
-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- main apps
    hl.exec_cmd(terminal)
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper -c '/home/giovanni/.config/hypr/hyprpaper.conf'")

    -- tray and sys services
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd(applet_removable_media)

    -- bluetooth is accessed via wayland module
    --hl.exec_cmd(applet_bluetooth)

    -- network is accessed via wayland module
    --hl.exec_cmd(applet_network)

    hl.exec_cmd(notif_manager)
    hl.exec_cmd(polkit_agent)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)
