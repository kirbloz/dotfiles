--See https://wiki.hyprland.org/Configuring/Variables/ for more
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = false,
        disable_splash_rendering = true,
        vrr = 0,
        mouse_move_enables_dpms = false,
        key_press_enables_dpms = false,
    --    layers_hog_keyboard_focus = true,
        focus_on_activate = false,
        mouse_move_focuses_monitor = true,
        allow_session_lock_restore = true,
      },
})

hl.layers_hog_keyboard_focus = true
