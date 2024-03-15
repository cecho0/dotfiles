local wezterm = require("wezterm")

local M = {}

local tab_title = function(tab_info)
  local title = tab_info.tab_title

  if title and #title > 0 then
    return title:gsub("%.exe$", "")
  end

  return tab_info.active_pane.title:gsub("%.exe$", "")
end

M.setup = function()
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local mux_window = wezterm.mux.get_window(tab.window_id)
    local mux_tab = mux_window:active_tab()
    local mux_tab_cols = mux_tab:get_size().cols

    local tab_count = #tabs
    local inactive_tab_cols = math.floor(mux_tab_cols / tab_count)

    local active_tab_cols = mux_tab_cols - (tab_count - 1) * inactive_tab_cols

    local title = tab_title(tab)
    title = " " .. title .. " "
    local title_cols = wezterm.column_width(title)

    if tab.is_active then
      local icon = " " .. "⦿"

      local rest_cols = math.max(active_tab_cols - title_cols, 0)
      local right_cols = math.ceil(rest_cols / 2)
      local left_cols = rest_cols - right_cols
      return {
        -- left
        { Foreground = { Color = "Fuchsia" } },
        { Text = wezterm.pad_right(icon, left_cols) },
        -- center
        { Foreground = { Color = "#46BDFF" } },
        { Attribute = { Italic = true } },
        { Text = title },
        -- right
        { Text = wezterm.pad_right('', right_cols) },
      }
    else
      local icon = " "

      local rest_cols = math.max(inactive_tab_cols - title_cols, 0)
      local right_cols = math.ceil(rest_cols / 2)
      local left_cols = rest_cols - right_cols
      return {
        -- left
        { Text = wezterm.pad_right(icon, left_cols) },
        -- center
        { Text = title },
        -- right
        { Text = wezterm.pad_right('', right_cols) },
      }
    end
  end)
end

return M
