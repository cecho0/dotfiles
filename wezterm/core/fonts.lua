local wezterm = require("wezterm")

local custom_font_rules = {
  {
    italic = false,
    font = wezterm.font_with_fallback {
      {
        family = "ComicMono Nerd Font",
        italic = false,
      },
    }
  },
  {
    italic = true,
    font = wezterm.font_with_fallback {
      {
        family = "Cascadia Code",
        italic = true,
      },
    }
  },
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font_with_fallback {
      {
        family = "ComicMono Nerd Font",
        italic = false,
        weight = "Bold",
      },
    }
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font_with_fallback {
      {
        family = "Cascadia Code",
        italic = true,
        weight = "Bold",
      },
    }
  },
}

return {
  -- font_dirs = { "fonts/ComicMono Nerd Font" },
  font_rules = custom_font_rules,
  adjust_window_size_when_changing_font_size = false,
}
