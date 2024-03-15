local wezterm = require("wezterm")
local M = {}

M.setup = function()
  wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local workspace = wezterm.mux.get_workspace_names()
    local workspace_str = ""
    for index, value in ipairs(workspace) do
      if #workspace > 1 and value == wezterm.mux.get_active_workspace() then
        workspace_str = string.format("<%d/%d>%s  ", index, #workspace, value)
        break
      end
    end

    local zoomed = ""
    if tab.active_pane.is_zoomed then
      zoomed = "[Z] "
    end

    local index = ""
    if #tabs > 1 then
      index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end

    return workspace_str .. zoomed .. index .. tab.active_pane.title
  end)
end

return M
