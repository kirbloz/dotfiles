
-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("HYPRSHOT_DIR","/home/giovanni/Screenshots")

-- Cursors
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("XCURSOR_THEME", "Bibata-Modern-Amber")  

-- XDG Desktop Portal & Session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt Framework
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- GTK Framework
hl.env("GDK_SCALE", "1")

-------------------------------
---- NVIDIA SPECIFIC VARS  ----
-------------------------------

-- Hardware Acceleration & Driver Setup
hl.env("LIBVA_DRIVER_NAME", "nvidia")
--hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Electron / Chromium Hardware Acceleration
hl.env("NVIDIA_DRIVER_CAPABILITIES", "all")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Prevent Flickering in Some Apps (Forces OpenGL render pipeline for EGL)
hl.env("__GL_VRR_ALLOWED", "1")
