local wezterm = require 'wezterm'
local act = wezterm.action

local custom_launch_menu = {}
local custom_cwd
local custom_prog
local custom_keys
local custom_key_tables
local custom_mouse_bindings
local custom_alt_key
local custom_hide_action
local custom_font_path = "fonts"
local custom_font_rules = {}

-- use for tab format
local local_tab = {}
local_tab.icons = {}
local_tab.cells = {}
local_tab.colors = {}

local_tab.icons.GLYPH_SEMI_CIRCLE_LEFT = ""
-- local GLYPH_SEMI_CIRCLE_LEFT = utf8.char(0xe0b6)
local_tab.icons.GLYPH_SEMI_CIRCLE_RIGHT = ""
-- local GLYPH_SEMI_CIRCLE_RIGHT = utf8.char(0xe0b4)
local_tab.icons.GLYPH_CIRCLE = ""
-- local GLYPH_CIRCLE = utf8.char(0xf111)
local_tab.icons.GLYPH_ADMIN = "ﱾ"

local_tab.colors = {
   default = {
      bg = "#45475a",
      fg = "#1c1b19",
   },
   is_active = {
      bg = "#7FB4CA",
      fg = "#11111b",
   },

   hover = {
      bg = "#587d8c",
      fg = "#1c1b19",
   },
}

function Basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

-- wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
--   wezterm.log_info('new-tab', window, pane, button, default_action)
--   if default_action and button == 'Left' then
--      window:perform_action(default_action, pane)
--   end

--   if default_action and button == 'Right' then
--      window:perform_action(
--         wezterm.action.ShowLauncherArgs({ title = '  Select/Search:', flags = 'FUZZY|LAUNCH_MENU_ITEMS|DOMAINS'}), pane
--      )
--   end
--   return false
-- end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local workspace = wezterm.mux.get_workspace_names()
  local workspace_str = ''
  for index, value in ipairs(workspace) do
    if #workspace > 1 and value == wezterm.mux.get_active_workspace() then
      workspace_str = string.format("<%d/%d>%s  ", index, #workspace, value)
      break
    end
  end

  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[Z] '
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  return workspace_str .. zoomed .. index .. tab.active_pane.title
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane_t = tab.active_pane
  local title = Basename(pane_t.foreground_process_name)

  local check_if_admin = function (p)
    if p:match("^Administrator: ") then
      return true
    end
    return false
  end

  local push = function(bg, fg, attribute, text)
    table.insert(local_tab.cells, { Background = { Color = bg } })
    table.insert(local_tab.cells, { Foreground = { Color = fg } })
    table.insert(local_tab.cells, { Attribute = attribute })
    table.insert(local_tab.cells, { Text = text })
 end

  local_tab.cells = {}

  local bg
  local fg
  -- local process_name = M.set_process_name(tab.active_pane.foreground_process_name)
  local is_admin = check_if_admin(tab.active_pane.title)
  -- local title = M.set_title(process_name, tab.active_pane.title, max_width, (is_admin and 8))

  if tab.is_active then
     bg = local_tab.colors.is_active.bg
     fg = local_tab.colors.is_active.fg
  elseif hover then
     bg = local_tab.colors.hover.bg
     fg = local_tab.colors.hover.fg
  else
     bg = local_tab.colors.default.bg
     fg = local_tab.colors.default.fg
  end

  local has_unseen_output = false
  for _, pane in ipairs(tab.panes) do
     if pane.has_unseen_output then
        has_unseen_output = true
        break
     end
  end

  -- Left semi-circle
  push(fg, bg, { Intensity = "Bold" }, local_tab.icons.GLYPH_SEMI_CIRCLE_LEFT)

  -- Admin Icon
  if is_admin then
     push(bg, fg, { Intensity = "Bold" }, " " .. local_tab.icons.GLYPH_ADMIN)
  end

  -- Title
  push(bg, fg, { Intensity = "Bold" }, " " .. title)

  -- Unseen output alert
  if has_unseen_output then
     push(bg, "#FFA066", { Intensity = "Bold" }, " " .. local_tab.icons.GLYPH_CIRCLE)
  end

  -- Right padding
  push(bg, fg, { Intensity = "Bold" }, " ")

  -- Right semi-circle
  push(fg, bg, { Intensity = "Bold" }, local_tab.icons.GLYPH_SEMI_CIRCLE_RIGHT)

  return local_tab.cells

  -- local title = tab_title(tab)
  -- title = wezterm.truncate_right(title, max_width - 2)
  -- if tab.tab_index == 0 then
  --   return {
  --     -- { Background = { Color = "none" } },
  --     -- { Foreground = { Color = edge_foreground } },
  --     -- { Text = "" },
  --     { Background = { Color = background } },
  --     { Foreground = { Color = foreground } },
  --     { Text = " " .. title .. " " },
  --     { Background = { Color = "none" } },
  --     { Foreground = { Color = edge_foreground } },
  --     { Text = "" },
  --   }
  -- end

  -- return {
    -- { Background = { Color = background } },
    -- { Foreground = { Color = wezterm.color.get_builtin_schemes()['tokyonight'].background } },
    -- { Text = "" },
    -- { Background = { Color = background } },
    -- { Foreground = { Color = foreground } },
    -- { Text = " " .. title .. " " },
    -- { Background = { Color = "none" } },
    -- { Foreground = { Color = edge_foreground } },
    -- { Text = "" },
  -- }
end)

wezterm.on('update-right-status', function(window, pane)
  local bat = ''
  for _, b in ipairs(wezterm.battery_info()) do
    bat = '🔋 ' .. string.format('%.0f%% ', b.state_of_charge * 100)
  end

  window:set_right_status(wezterm.format {
    { Text = bat },
  })
end)

wezterm.on('toggle-tabbar', function(window, pane)
  local overrides = window:get_config_overrides() or {}

  if window:effective_config().enable_tab_bar == true then
    overrides.enable_tab_bar = false
  else
    overrides.enable_tab_bar = true
  end

  window:set_config_overrides(overrides)
end)

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  custom_cwd = "D:\\RjDir\\RCD_916b6b7c-fe2b-4cf5-bb9a-d27d505b155c\\Desktop"
  -- custom_prog = "powershell"
  custom_prog = "nu"
  custom_alt_key = 'ALT'
  custom_hide_action = act.Hide

  table.insert(custom_launch_menu, {
    label = 'Windows',
    args = { 'powershell.exe', '-NoLogo' },
  })
  table.insert(custom_launch_menu, {
    label = 'Serial',
    args = { 'wezterm', 'serial', '--baud 9600', 'COM0' }
  })
elseif wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
  custom_cwd = "/home/cecho"
  custom_prog = "/usr/bin/bash"
  custom_alt_key = 'ALT'
  custom_hide_action = act.Hide

  table.insert(custom_launch_menu, {
    label = 'Linux',
    args = { '/usr/sbin/bash', '-l' },
  })
  table.insert(custom_launch_menu, {
    label = 'Serial',
    args = { 'wezterm', 'serial', '--baud 9600', '/dev/ttyUSB0' }
  })
elseif wezterm.target_triple == 'x86_64-apple-darwin' then
  custom_cwd = "/User/cecho"
  custom_prog = "/usr/bin/zsh"
  custom_alt_key = 'Option'
  custom_hide_action = act.HideApplication

  table.insert(custom_launch_menu, {
    label = 'MacOS',
    args = { '/usr/sbin/zsh', '-l' },
  })
end

custom_keys = {
  -- toggle tab bar Fn+0
  { key = 'F10', mods = 'NONE', action = act.EmitEvent 'toggle-tabbar' },

  -- copy mode
  { key = 'i', mods = 'LEADER', action = act.ActivateCopyMode },

  -- paste
  { key = 'p', mods = 'LEADER', action = act { PasteFrom = "Clipboard" } },

  -- search, also will into copy mode
  { key = '/', mods = 'LEADER', action = act { Search = {CaseSensitiveString = ""} } },

  -- mini
  { key = '-', mods = custom_alt_key, action = custom_hide_action },

  -- full screen
  { key = '=', mods = custom_alt_key, action = act.ToggleFullScreen },

  -- new window
  { key = 'Enter', mods = 'LEADER', action = act.SpawnWindow },

  -- new tab
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'DefaultDomain' },

  -- select tab
  { key = '[', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'LEADER', action = act.ActivateTabRelative(1) },

  -- show launch
  { key = 'l', mods = custom_alt_key, action = wezterm.action.ShowLauncher },

  -- quit
  { key = 'F4', mods = '', action = act.QuitApplication },

  -- scroll page
  { key = 'd', mods = 'LEADER', action = act.ScrollByPage(0.5) },
  { key = 'u', mods = 'LEADER', action = act.ScrollByPage(-0.5) },
  { key = 'f', mods = 'LEADER', action = act.ScrollByPage(1) },
  { key = 'b', mods = 'LEADER', action = act.ScrollByPage(-1) },

  -- select pane
  { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- select pane
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- split
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-' , mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- close pane
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true }, },
  --close tab
  { key = 't', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true, }, },
  --toggle pane ZoomState
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- resize pane
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },

  -- font
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
}

custom_key_tables = {
  -- copy mode
  copy_mode = {
    -- exit copy mode
    { key = 'i', mods = 'NONE', action = act.CopyMode 'Close' },

    -- move
    { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },

    -- move
    { key = 'LeftArrow',  mods = 'NONE', action = act.CopyMode 'MoveLeft' },
    { key = 'DownArrow',  mods = 'NONE', action = act.CopyMode 'MoveDown' },
    { key = 'UpArrow',    mods = 'NONE', action = act.CopyMode 'MoveUp' },
    { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },

    -- scroll page
    { key = 'u', mods = 'CTRL', action = act.CopyMode 'PageUp' },
    { key = 'd', mods = 'CTRL', action = act.CopyMode 'PageDown' },

    -- select
    { key = 'v', mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' }, },
    { key = 'v', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Block' }, },

    -- copy
    { key = 'y', mods = 'NONE', action = act.Multiple {
        { CopyTo   = 'ClipboardAndPrimarySelection' },
        { CopyMode = 'Close' },
      },
    },

    { key = '/', mods = '', action = act { Search = {CaseSensitiveString = ""} } },
  },

  -- search mode
  search_mode = {
    -- exit search mode
    { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },

    -- match
    { key = 'n', mods = 'CTRL',  action = act.CopyMode 'NextMatch' },
    { key = 'n', mods = 'CTRL|SHIFT', action = act.CopyMode 'PriorMatch' },

    -- match
    { key = 'UpArrow',  mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    { key = 'DownArrow',mods = 'NONE', action = act.CopyMode 'NextMatch' },
  },

  -- resize pane
  resize_pane = {
    { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1  } },
    { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1  } },
    { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1    } },
    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },

    { key = 'h', action = act.AdjustPaneSize { 'Left',  1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down',  1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up',    1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },

    { key = 'Escape', action = 'PopKeyTable' },
  },
}

custom_mouse_bindings = {
  -- select a cell
  {
    event ={ Down = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor("Cell"),
  },

  -- select a word
  {
    event ={ Down = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple {
    act.SelectTextAtMouseCursor("Word"),
      { CopyTo   = 'ClipboardAndPrimarySelection' },
    },
  },

  -- select a line
  {
    event ={ Down = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple {
      act.SelectTextAtMouseCursor("Line"),
      { CopyTo   = 'ClipboardAndPrimarySelection' },
    },
  },

  -- copy
  {
    event ={ Drag = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple {
      act.ExtendSelectionToMouseCursor("Cell"),
      { CopyTo   = 'ClipboardAndPrimarySelection' },
    },
  },

  -- paste
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act { PasteFrom = "Clipboard" },
  },

  -- scroll down
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = act.ScrollByPage(0.2)
  },

  -- scroll up
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = act.ScrollByPage(-0.2)
  },

  -- font size increases 
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },

  -- font size decreases
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },

  -- open the link
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },

  -- drag move window
  {
    event ={ Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL|SHIFT',
    action = act.StartWindowDrag,
  },
}

custom_font_rules = {
  {
    italic = false,
    font = wezterm.font_with_fallback {
      {
        family = 'ComicMono Nerd Font',
        italic = false,
      },
    }
  },
  {
    italic = true,
    font = wezterm.font_with_fallback {
      {
        family = 'Cascadia Code',
        italic = true,
      },
    }
  },
  {
    italic = false,
    intensity = 'Bold',
    font = wezterm.font_with_fallback {
      {
        family = 'ComicMono Nerd Font',
        italic = false,
        weight = 'Bold',
      },
    }
  },
  {
    italic = true,
    intensity = 'Bold',
    font = wezterm.font_with_fallback {
      {
        family = 'Cascadia Code',
        italic = true,
        weight = 'Bold',
      },
    }
  },
}

-- Windows add WSL
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  local success, wsl_list, wsl_err =
    wezterm.run_child_process { 'wsl.exe', '-l' }
  wsl_list = wezterm.utf16_to_utf8(wsl_list)

  if not wsl_err then
    for idx, line in ipairs(wezterm.split_by_newlines(wsl_list)) do
      if idx > 1 then
        local distro = line:gsub(' %(Default%)', '')

        table.insert(custom_launch_menu, {
          label = distro .. ' (WSL default shell)',
          args = { 'wsl.exe', '--distribution', distro },
        })
      end
    end
  end
end

return {
  default_cwd = custom_cwd,
  default_prog = { custom_prog },
  launch_menu = custom_launch_menu,

  enable_tab_bar = false,
  tab_bar_at_bottom = false,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,

  -- font_dirs = { 'fonts/ComicMono Nerd Font' },
  font_rules = custom_font_rules,
  adjust_window_size_when_changing_font_size = false,

  max_fps = 100,
  scrollback_lines = 3500,
  enable_scroll_bar = true,

  leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 },

  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  disable_default_quick_select_patterns = true,
  keys = custom_keys,
  key_tables = custom_key_tables,
  mouse_bindings = custom_mouse_bindings,

  color_scheme = 'tokyonight',

  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  --window_background_image = 'E:\\2.jpg',
  window_background_opacity = 1,
}

-- local CMD_ICON = utf8.char(0xe62a)
-- local NU_ICON = utf8.char(0xe7a8)
-- local PS_ICON = utf8.char(0xe70f)
-- local ELV_ICON = utf8.char(0xfc6f)
-- local WSL_ICON = utf8.char(0xf83c)
-- local YORI_ICON = utf8.char(0xf1d4)
-- local NYA_ICON = utf8.char(0xf61a)
--
-- local VIM_ICON = utf8.char(0xe62b)
-- local PAGER_ICON = utf8.char(0xf718)
-- local FUZZY_ICON = utf8.char(0xf0b0)
-- local HOURGLASS_ICON = utf8.char(0xf252)
-- local SUNGLASS_ICON = utf8.char(0xf9df)
--
-- local PYTHON_ICON = utf8.char(0xf820)
-- local NODE_ICON = utf8.char(0xe74e)
-- local DENO_ICON = utf8.char(0xe628)
-- local LAMBDA_ICON = utf8.char(0xfb26)
--
-- local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
-- local SOLID_LEFT_MOST = utf8.char(0x2588)
-- local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)
-- local ADMIN_ICON = utf8.char(0xf49c)
