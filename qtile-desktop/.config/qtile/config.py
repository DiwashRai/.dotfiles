
import os
import subprocess
import colors

from libqtile import bar, hook, layout, widget
from libqtile.config import Click, Drag, DropDown, Group, Key, KeyChord, Match, ScratchPad, Screen
from libqtile.lazy import lazy


mod = "mod4"
terminal = "kitty"
gap_size = 5 
widget_font = "JetBrainsMono Nerd Font"

keys = [
    # Launch common apps
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "b", lazy.spawn("brave-browser"), desc="Launch browser"),

    # rofi
    # Key([mod], "p", lazy.spawn("rofi -show drun"), desc="Launch rofi in desktop run mode"),
    Key(["mod1"], "space", lazy.spawn("rofi -show drun"), desc="Launch rofi in desktop run mode"),
    Key([mod], "p", lazy.spawn(os.path.expanduser("~/scripts/quick_access")), desc="Launch rofi quick access script"),
    Key([mod], "x", lazy.spawn(os.path.expanduser("~/scripts/powermenu")), desc="Launch rofi powermenu script"),
    Key([mod], "c", lazy.spawn(os.path.expanduser("~/scripts/confedit")), desc="Launch rofi confedit script"),

    # cheatsheets
    Key([mod], "F2", lazy.spawn(os.path.expanduser("~/scripts/tmux_cheat")), desc="Launch tmux cheatsheet"),

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.shrink(), desc="Shrink window"),
    Key([mod, "control"], "l", lazy.layout.grow(), desc="Grow window"),
    Key([mod, "control"], "m", lazy.layout.maximize(), desc="Maximise currently focused client"),
    Key([mod, "control"], "n", lazy.layout.normalize(), desc="normalize screen space"),

    # Move between screens
    Key([mod], "i", lazy.next_screen(), desc="Move to next screen"),
    Key([mod], "u", lazy.prev_screen(), desc="Move to prev screen"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle between floating"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    KeyChord([mod], "z", [
        Key([], "g", lazy.layout.grow()),
        Key([], "s", lazy.layout.shrink()),
        Key([], "n", lazy.layout.normalize()),
        Key([], "m", lazy.layout.maximize())],
        mode=True,
        name="Windows"
    ),
]

def show_keys(keys):
    """
    print current keybindings in a pretty way for a rofi/dmenu window.
    """
    key_help = "{:<30} {:<30}\n".format('Keybinds', 'Description')
    keys_ignored = (
        "XF86AudioMute",  #
        "XF86AudioLowerVolume",  #
        "XF86AudioRaiseVolume",  #
        "XF86AudioPlay",  #
        "XF86AudioNext",  #
        "XF86AudioPrev",  #
        "XF86AudioStop",
        "XF86MonBrightnessUp",
        "XF86MonBrightnessDown",
        "z"
    )
    text_replaced = {
        "mod4": "[MOD]",  #
        "control": "[CTRL]",  #
        "mod1": "[ALT]",  #
        "shift": "[SHIFT]",  #
        "Escape": "ESC",  #
    }
    for k in keys:
        if k.key in keys_ignored:
            continue

        mods = ""
        key = ""
        desc = k.desc.title()
        for m in k.modifiers:
            if m in text_replaced.keys():
                mods += text_replaced[m] + " + "
            else:
                mods += m.capitalize() + " + "

        if len(k.key) > 1:
            if k.key in text_replaced.keys():
                key = text_replaced[k.key]
            else:
                key = k.key.title()
        else:
            key = k.key

        key_line = "{:<30} {}\n".format(mods + key, desc)
        key_help += key_line

    return key_help

# this must be done AFTER all the keys have been defined
cheater = terminal + " --class='Cheater' -e sh -c 'echo \"" + show_keys(
    keys
) + "\" | fzf --prompt=\"Search for a keybind: \" --border=rounded --margin=1% --color=dark --height 100% --reverse --header=\"       QTILE CHEAT SHEET \" --info=hidden --header-first'"
keys.extend([
    Key([mod], "F1", lazy.spawn(cheater), desc="Print keyboard bindings"),
])

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod1 + number of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + number of group = move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
        ]
    )

colors, backgroundColor, foregroundColor, workspaceColor, chordColor = colors.catppuccin()

layout_theme = {
    "border_width": 2,
    "border_focus": '#4e8ca2',
    "border_normal": backgroundColor,
    "margin": gap_size
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.VerticalTile(**layout_theme),
    layout.Max(**layout_theme),
    # layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    # layout.Stack(num_stacks=2),
]

# Scratchpads
groups.append(ScratchPad("scratchpad", [
    DropDown("term", f"{terminal} --class=scratch", width=0.8, height=0.8, x=0.1, y=0.1, opacity=1),
    DropDown("music", "flatpak run com.spotify.Client", match=Match(wm_class=["Spotify", "spotify"]),
             width=0.8, height=0.8, x=0.1, y=0.1, opacity=1),
]))


keys.extend([
    Key([mod], "grave", lazy.group['scratchpad'].dropdown_toggle('term')),
    Key([mod], "m", lazy.group['scratchpad'].dropdown_toggle('music')),
])


widget_defaults = dict(
    font=widget_font,
    fontsize=14,
    padding=8,
)
extension_defaults = widget_defaults.copy()

def init_widgets_list():
    widgets_list = [
        widget.TextBox(text = u"\uE73C", fontsize = 24, foreground = colors[2], background=backgroundColor),
        widget.GroupBox(
            margin_y = 2,
            margin_x = 4,
            padding_y = 6,
            padding_x = 6,
            borderwidth = 4,
            disable_drag = True,
            active = colors[5],
            inactive = '#62677b',
            hide_unused = False,
            rounded = False,
            highlight_method = "line",
            highlight_color = [backgroundColor, backgroundColor],
            this_current_screen_border = colors[5], # this and focused
            this_screen_border = colors[1], # this not focused
            other_current_screen_border = colors[9], # other focused
            other_screen_border = colors[1], # other not focused
            urgent_alert_method = "line",
            urgent_border = colors[9],
            urgent_text = colors[1],
            foreground = foregroundColor,
            background = backgroundColor,
            use_mouse_wheel = False
        ),
        widget.WindowName(),
        widget.Sep(linewidth = 1, padding = 10, foreground = colors[5],background = backgroundColor),
        widget.TextBox(text = "", foreground = colors[2]),
        widget.CheckUpdates(
            colour_have_updates=colors[9],
            colour_no_updates=colors[5],
            no_update_string='0',
            display_format='{updates}',
            update_interval=1800,
            distro="Fedora"
        ),
        widget.Sep(linewidth = 0, padding = 10),
        widget.OpenWeather(
            app_key = "4cf3731a25d1d1f4e4a00207afd451a2",
            cityid = "2643743",
            format = '{icon} {main_temp}°',
            metric = True,
            foreground = foregroundColor,
        ),
        widget.Sep(linewidth = 0, padding = 10),
        widget.TextBox(text = "", foreground = colors[7]),
        widget.CPU(
            update_interval = 1.0,
            format = '{load_percent}%',
            foreground = foregroundColor,
            padding = 5
        ),
        widget.Sep(linewidth = 0, padding = 10),
        widget.TextBox(text = "", foreground = colors[3]),
        widget.Memory(
            foreground = foregroundColor,
            format = '{MemUsed: .0f}{mm} /{MemTotal: .0f}{mm}',
            measure_mem='G',
            padding = 5,
        ),
        widget.Sep(linewidth = 0, padding = 10),
        widget.TextBox(text = "🔊", foreground = colors[8]),
        widget.Volume(linewidth = 0, padding = 10),
        widget.Sep(linewidth = 0, padding = 10),
        widget.TextBox(text = "", foreground = colors[10]),
        widget.Clock(format='%H:%M %a %d/%m/%y', padding = 5, foreground = foregroundColor),
        widget.CurrentLayoutIcon(scale = 0.7, foreground = colors[6], background = colors[0]),
    ]
    return widgets_list

def init_primary_bar():
    widget_list = init_widgets_list()
    # widget_list.insert(-1, widget.Sep(linewidth = 0, padding = 10))
    # widget_list.insert(-1, widget.Battery(linewidth = 0, padding = 10, format='{char} {percent:2.0%}', charge_char='󱊥', discharge_char='󱊢', unknown_char='󱉞'))
    widget_list.insert(-1, widget.Systray(background = backgroundColor, icon_size = 20, padding = 4))
    widget_list.insert(-1, widget.Sep(linewidth = 1, padding = 10, foreground = colors[5], background = backgroundColor))
    return bar.Bar(widgets=widget_list, size=24)

def init_secondary_bar():
    widgets_list = init_widgets_list()
    return bar.Bar(widgets=widgets_list, size=24)

horizontal_wallpaper = "/home/diwash/Pictures/wallpapers/cosy-tokyo.jpg"
vertical_wallpaper = "/home/diwash/Pictures/wallpapers/City Lights Reflection.jpg"

screens = [
    Screen(
        top=init_secondary_bar(),
        wallpaper=vertical_wallpaper,
        right=bar.Gap(gap_size),
        bottom=bar.Gap(gap_size),
        left=bar.Gap(gap_size)
        ),
    Screen(
        top=init_primary_bar(),
        wallpaper=horizontal_wallpaper,
        right=bar.Gap(gap_size),
        bottom=bar.Gap(gap_size),
        left=bar.Gap(gap_size)
        )
    ]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="Cheater"),
        Match(wm_class="rofi_quick"),
    ]
)

@hook.subscribe.client_new
def floating_dialog_sizes(window):
    if 'Cheater' in window.get_wm_class():
        window.width = 800
        window.height = 1000

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

@hook.subscribe.startup_once
def autostart():
    start_script = os.path.expanduser("~/.config/qtile/scripts/autostart.sh")
    subprocess.run([start_script])

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
