local wezterm = require("wezterm")
local platform = require("core.utils.platform").check_platform()

local custom_cwd
local custom_prog

if platform.is_win then
  custom_cwd = "C:\\Users\\AI\\Desktop"
  custom_prog = "nu"
elseif platform.is_linux then
  custom_cwd = "/home/cecho"
  custom_prog = "/usr/bin/zsh"
elseif platform.is_mac then
  custom_cwd = "/User/cecho"
  custom_prog = "/usr/bin/zsh"
end

return {
  default_cwd = custom_cwd,
  default_prog = { custom_prog },

  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",

  enable_tab_bar = true,
  tab_bar_at_bottom = false,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = true,

  max_fps = 100,
  scrollback_lines = 3500,
  enable_scroll_bar = true,

  -- color_scheme = "tokyonight",
  -- color_scheme_dirs = { 'e:/_config/wezterm/colors' },

  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  window_background_image = wezterm.config_dir .. "/core/resource/image/space.jpg",
  -- window_background_opacity = 1,
}