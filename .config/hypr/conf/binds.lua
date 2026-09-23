
--------------------------
-- APPLICATION BINDS
--------------------------
hl.bind(mainMod .. " + RETURN",   hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",        hl.dsp.window.close())
hl.bind(mainMod .. " + M",        hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + F",        hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",        hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",        hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",        hl.dsp.exec_cmd("hyprpicker"))
hl.bind(mainMod .. " + J",        hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + ESCAPE",   hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + W",        hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + N",        hl.dsp.exec_cmd("echo toggle > /tmp/qs-control-center"))
hl.bind(mainMod .. " + O",        hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("qs -p ~/.config/hyprquickpaper"),
	{ description = "Open HyprQuickPaper Wallpaper Picker" }
)
hl.bind(mainMod .. " + L",        hl.dsp.exec_cmd("hyprlock"))


-------------------------
-- SUNSETR BINDS
-------------------------

hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("sunsetr preset gaming"))

-- Script & Reloads
--hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/ml4w/scripts/reload-waybar.sh"))

--------------------------
-- HYPRSHOT BINDS
--------------------------

-- Seleziona un'area (SUPER + SHIFT + S)
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m output"))

-- Finestra attiva (SUPER + Print)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))

-- Intero monitor (Print)
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))


--------------------------
-- FOCUS & MOVE WINDOWS
--------------------------
-- Change Focus (SUPER + Freccia)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move Active Window (SUPER + SHIFT + Freccia)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

--------------------------
-- WORKSPACES [1-10]
--------------------------
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspace (Scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

--------------------------
-- MOUSE BINDS
--------------------------
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

--------------------------
-- MEDIA & HARDWARE KEYS
--------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 10%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 10%-"),                          { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
