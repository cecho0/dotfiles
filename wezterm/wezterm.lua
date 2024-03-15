-- debug
-- set WEZTERM_LOG=warn
-- wezterm
local Config = require("core")
local wezterm = require("wezterm")

require("core.events.new_tab_button_click").setup()
require("core.events.right_status").setup()
require("core.events.format_tab_title").setup()
require("core.events.format_window_title").setup()
require("core.events.toggle_tabbar").setup()

return Config:init()
  :append(require("core.common"))
  :append(require("core.fonts"))
  :append(require("core.launch"))
  :append(require("core.domains"))
  :append(require("core.bindings")).options
