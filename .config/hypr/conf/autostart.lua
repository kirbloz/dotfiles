-- conf/autostart.lua
-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- graph env
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk")
    
    -- main apps
    hl.exec_cmd(terminal)
    hl.exec_cmd(bar)
    hl.exec_cmd("hyprpaper -c '/home/YOU/.config/hypr/hyprpaper.conf'")

    -- tray and sys services
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- AS OF NOVEMBER 2026 HYPRLAND HAS ISSUES WITH IDLE, LOCK, DRM ETC
    -- commenting this one out to avoid many headaches for the time being
    --hl.exec_cmd("hypridle")
    --hl.exec_cmd("hyprsunset")
    hl.exec_cmd("sunsetr")
    -- using systemd service
    --hl.exec_cmd("selftrack daemon")
    -- bluetooth is accessed via wayland module
    --hl.exec_cmd(applet_bluetooth)
    -- network is accessed via wayland module
    --hl.exec_cmd(applet_network)

    hl.exec_cmd(notif_manager)
    hl.exec_cmd(polkit_agent)
end)
