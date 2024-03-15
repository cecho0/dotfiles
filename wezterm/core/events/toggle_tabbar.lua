local wezterm = require("wezterm")
local M = {}

M.setup = function()
  wezterm.on("toggle-tabbar", function(window, pane)
    local overrides = window:get_config_overrides() or {}

    if window:effective_config().enable_tab_bar == true then
      overrides.enable_tab_bar = false
    else
      overrides.enable_tab_bar = true
    end

    window:set_config_overrides(overrides)
  end)
end

return M
