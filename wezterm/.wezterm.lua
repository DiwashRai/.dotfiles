local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Kanagawa (Gogh)'
config.font_size = 11.0 -- default 12.0
config.window_close_confirmation = 'NeverPrompt'

-- tab bar styling
config.use_fancy_tab_bar = false

config.colors = {
  tab_bar = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = '#0b0022',

    active_tab = {
      bg_color = '#2b2042',
      fg_color = '#c0c0c0',
    },

    inactive_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',
    },

    new_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,
    },
  },
}

config.keys = {
    {
        key = 'w',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    }
}

return config

