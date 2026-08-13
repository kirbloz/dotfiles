-- INPUT DEVICES
hl.config( {
    input={
        kb_layout = "it",
        repeat_rate = 25,
        repeat_delay = 600,
        follow_mouse = 1,
        mouse_refocus = true,
        float_switch_override_focus = 1,
        touchpad = {
            disable_while_typing = false,
            scroll_factor = 1.0,
            ["tap_to_click"] = true,
        },
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
    },
})
 
