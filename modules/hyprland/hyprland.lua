-- Hyprland (Lua config, 0.57+). Appended to the file home-manager generates,
-- after the stylix colours. Rounded corners, a soft shadow and animations; no blur,
-- the integrated GPU on the T480 has enough to do.

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 4,
        border_size = 1,
        layout      = "dwindle",
    },

    decoration = {
        rounding = 10,
        shadow   = {
            enabled      = true,
            range        = 12,
            render_power = 3,
        },
        blur     = { enabled = false },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },

    input = {
        -- Same pair as the Macs: Italian, plus US International with dead keys.
        -- Super+Shift+Space switches between them (bound below; Alt+Shift was too easy to
        -- hit by accident). The bar shows the active one.
        kb_layout  = "it,us",
        kb_variant = ",intl",

        follow_mouse = 1,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },
})

-- Animations: the slide/pop feel Hyprland is known for, at speeds the T480's iGPU can hold.
-- No blur or window transparency: those are the expensive ones.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("quick",        { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "easy",         style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.0,  bezier = "quick",        style = "popin 90%" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 1.5,  bezier = "quick",        style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7,    bezier = "quick" })

-- Three-finger swipe between workspaces
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

local mod = "SUPER"

-- herdr's vim-herdr-navigation owns Ctrl+h/j/k/l (modules/herdr). Let shells keep
-- them: Ctrl+L clears, Ctrl+K kills the line. Leave shell panes with prefix+h/j/k/l.
hl.env("HERDR_NAV_PASSTHROUGH_RE", "^(zsh|bash)$")

-- Programs. Super+Return opens Ghostty on herdr, like Cmd+Alt+Return on the Macs (modules/skhd)
hl.bind(mod .. " + Return",         hl.dsp.exec_cmd("ghostty -e herdr"))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd("ghostty"))
-- Launcher (modules/vicinae), like Cmd+Space with Raycast on the Macs
hl.bind(mod .. " + Space",          hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mod .. " + B",              hl.dsp.exec_cmd("librewolf"))
-- File manager, also where udiskie's mounted drives show up
hl.bind(mod .. " + E",              hl.dsp.exec_cmd("nautilus --no-default-window"))
-- Another wallpaper from ~/Pictures/Wallpapers (modules/awww)
hl.bind(mod .. " + W",              hl.dsp.exec_cmd("wallpaper-next"))
hl.bind(mod .. " + SHIFT + Space",  hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
-- Clipboard history
hl.bind(mod .. " + SHIFT + V",      hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/clipboard/history"))
hl.bind(mod .. " + Escape",         hl.dsp.exec_cmd("loginctl lock-session"))
-- Log out. Four keys on purpose: it closes every app without asking
hl.bind(mod .. " + CTRL + SHIFT + E", hl.dsp.exit())

-- Windows
hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mod .. " + M",         hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + T",         hl.dsp.layout("togglesplit"))

-- Focus and move with vim keys
local directions = { H = "left", J = "down", K = "up", L = "right" }
for key, direction in pairs(directions) do
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ direction = direction }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Resize with Super+Ctrl+hjkl
hl.bind(mod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }),  { repeating = true })
hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }),  { repeating = true })

-- Workspaces 1-10 (key 0 is workspace 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Mouse: Super+drag moves, Super+right-drag resizes
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots: region to clipboard, or the whole screen to ~/Pictures
hl.bind("Print",         hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("mkdir -p ~/Pictures && f=~/Pictures/$(date +%F-%H%M%S).png && grim $f && notify-send -t 2000 Screenshot $f"))

-- ThinkPad media keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

-- Stop apps from maximising themselves
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Small utility windows float in the middle instead of taking half the screen
hl.window_rule({
    name  = "float-dialogs",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|pinentry-qt|hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" },

    float  = true,
    center = true,
})
