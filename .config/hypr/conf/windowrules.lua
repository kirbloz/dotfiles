--[[ # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

#windowrule = float,title:^(galculator|org.gnome.Calculator|azote)$
#windowrule = idleinhibit fullscreen,class:^.*$$

#windowrule = workspace 1, title:^(.*Alacritty.*)$
#windowrule = workspace 2, title:^(.*Firefox.*)$
#windowrule = workspace 2, title:^(.*Chromium.*)$
#windowrule = workspace 10, title:^(.*Steam.*)$
#windowrule = workspace 3, title:^(.*Obsidian.*)$
#windowrule = workspace 3, class:^(.*mpv.*)$

#Steam Friend List
# -> i dont plan on having steam here
#windowrule = float, title:^(.*Friends List.*)$
#windowrulev2 = size 350 700, title:^(.*Friends List.*)$
#windowrule = center, title:^(.*Friends List.*)$ ]]--

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})


hl.window_rule({ 
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|blueman-manager|nm-connection-editor)$" },
    float = true,
    min_size = { 700, 700 }
})

hl.window_rule({ 
    match = { title = ".*Settings.*"},
    float = true,
    min_size = { 700, 700 }
})

hl.window_rule({
  match = { title = ".*Friends List.*|.*Extension.*Bitwarden.*" },
  float = true,
  size = { 350, 700 },
  center = true
})


hl.window_rule({
  match = { title = ".*Picture-In-Picture.*" },
  float = true,
  size = { 700, 350 },
  center = true
})
