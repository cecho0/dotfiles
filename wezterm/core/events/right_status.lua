local wezterm = require("wezterm")
local math = require("core.utils.math")

local M = {}

M.separator_char = " "

M.colors = {
  date_fg = "#dac835",
  --  date_bg = "#0F2536",
  date_bg = "",
  battery_fg = "#dac835",
  battery_bg = "#0F2536",
  separator_fg = "#dccb00",
  --  separator_bg = "#0F2536",
}

M.cells = {}

-- wezterm FormatItems (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
M.push = function(text, icon, fg, bg, separate)
  table.insert(M.cells, { Foreground = { Color = fg } })
  --  table.insert(M.cells, { Background = { Color = bg } })
  table.insert(M.cells, { Attribute = { Intensity = "Bold" } })
  table.insert(M.cells, { Text = icon .. " " .. text .. " " })

  if separate then
    table.insert(M.cells, { Foreground = { Color = M.colors.separator_fg } })
    -- table.insert(M.cells, { Background = { Color = M.colors.separator_bg } })
    table.insert(M.cells, { Text = M.separator_char })
  end

  table.insert(M.cells, "ResetAttributes")
end

M.set_date = function()
  local date = wezterm.strftime(" %a %H:%M")
  --  M.push(date, "", M.colors.date_fg, M.colors.date_bg, true)
  M.push(date, "", M.colors.date_fg, M.colors.date_bg, true)
end

M.setup = function()
  wezterm.on("update-right-status", function(window, _pane)
    M.cells = {}
    M.set_date()

    window:set_right_status(wezterm.format(M.cells))
  end)
end

return M
