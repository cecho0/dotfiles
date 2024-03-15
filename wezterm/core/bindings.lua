
local wezterm = require("wezterm")
local platform = require("core.utils.platform").check_platform()

local act = wezterm.action
local custom_alt_key
local custom_hide_action

if platform.is_win or platform.is_linux then
  custom_alt_key = "ALT"
  custom_hide_action = act.Hide
elseif platform.is_mac then
  custom_alt_key = "Option"
  custom_hide_action = act.HideApplication
end

local custom_keys = {
  -- toggle tab bar Fn+0
  { key = "F10", mods = "NONE", action = act.EmitEvent "toggle-tabbar" },

  -- copy mode
  { key = "i", mods = "LEADER", action = act.ActivateCopyMode },

  -- paste
  { key = "p", mods = "LEADER", action = act { PasteFrom = "Clipboard" } },

  -- search, also will into copy mode
  {
    key = "/",
    mods = "LEADER",
    action = act {
      Search = {
        CaseSensitiveString = ""
      }
    }
  },

  -- mini
  { key = "-", mods = custom_alt_key, action = custom_hide_action },

  -- full screen
  { key = "=", mods = custom_alt_key, action = act.ToggleFullScreen },

  -- new window
  { key = "Enter", mods = "LEADER", action = act.SpawnWindow },

  -- new tab
  { key = "c", mods = "LEADER", action = act.SpawnTab "DefaultDomain" },

  -- select tab
  { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine ({
        description = "Enter new name for tab",
        action = wezterm.action_callback(function(window, pane, line)
          -- line will be `nil` if they hit escape without entering anything
          -- An empty string if they just hit enter
          -- Or the actual line of text they wrote
          if line then
              window:active_tab():set_title(line)
          end
        end),
    })
  },

  -- show launch
  -- { key = "l", mods = custom_alt_key, action = act.ShowLauncher },
  {
    key = "l",
    mods = custom_alt_key,
    action = act.ShowLauncherArgs {
      title = "  Select/Search",
      flags = "LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES"
    }
  },

  -- quit
  { key = "F4", mods = "NONE", action = act.QuitApplication },

  -- scroll page
  { key = "d", mods = "LEADER", action = act.ScrollByPage(0.5) },
  { key = "u", mods = "LEADER", action = act.ScrollByPage(-0.5) },
  { key = "f", mods = "LEADER", action = act.ScrollByPage(1) },
  { key = "b", mods = "LEADER", action = act.ScrollByPage(-1) },

  -- select pane
  { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection "Left" },
  { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection "Down" },
  { key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection "Up" },
  { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection "Right" },

  -- select pane
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection "Left" },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection "Down" },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection "Up" },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection "Right" },

  -- split
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "-" , mods = "LEADER", action = act.SplitVertical   { domain = "CurrentPaneDomain" } },

  -- close pane
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true }, },
  --close tab
  { key = "t", mods = "LEADER", action = act.CloseCurrentTab { confirm = true, }, },
  --toggle pane ZoomState
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  --resize pane
  {
    key = "r",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = "resize_pane",
      one_shot = false,
    },
  },

  -- font
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
}

local custom_key_tables = {
  -- copy mode
  copy_mode = {
    -- exit copy mode
    { key = "i", mods = "NONE", action = act.CopyMode "Close" },

    -- move
    { key = "h", mods = "NONE", action = act.CopyMode "MoveLeft" },
    { key = "j", mods = "NONE", action = act.CopyMode "MoveDown" },
    { key = "k", mods = "NONE", action = act.CopyMode "MoveUp" },
    { key = "l", mods = "NONE", action = act.CopyMode "MoveRight" },

    -- move
    { key = "LeftArrow",  mods = "NONE", action = act.CopyMode "MoveLeft" },
    { key = "DownArrow",  mods = "NONE", action = act.CopyMode "MoveDown" },
    { key = "UpArrow",    mods = "NONE", action = act.CopyMode "MoveUp" },
    { key = "RightArrow", mods = "NONE", action = act.CopyMode "MoveRight" },

    -- scroll page
    { key = "u", mods = "CTRL", action = act.CopyMode "PageUp" },
    { key = "d", mods = "CTRL", action = act.CopyMode "PageDown" },

    -- select
    { key = "v", mods = "NONE",  action = act.CopyMode { SetSelectionMode = "Cell" }, },
    { key = "v", mods = "SHIFT", action = act.CopyMode { SetSelectionMode = "Block" }, },

    -- copy
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple {
        { CopyTo   = "ClipboardAndPrimarySelection" },
        { CopyMode = "Close" },
      },
    },

    {
      key = "/",
      mods = "",
      action = act { Search = { CaseSensitiveString = "" } }
    },
  },

  -- search mode
  search_mode = {
    -- exit search mode
    { key = "Escape", mods = "NONE", action = act.CopyMode "Close" },

    -- match
    { key = "n", mods = "CTRL",  action = act.CopyMode "NextMatch" },
    { key = "n", mods = "CTRL|SHIFT", action = act.CopyMode "PriorMatch" },

    -- match
    { key = "UpArrow",  mods = "NONE", action = act.CopyMode "PriorMatch" },
    { key = "DownArrow",mods = "NONE", action = act.CopyMode "NextMatch" },
  },

  -- resize pane
  resize_pane = {
    { key = "LeftArrow",  action = act.AdjustPaneSize { "Left", 1  } },
    { key = "DownArrow",  action = act.AdjustPaneSize { "Down", 1  } },
    { key = "UpArrow",    action = act.AdjustPaneSize { "Up", 1    } },
    { key = "RightArrow", action = act.AdjustPaneSize { "Right", 1 } },

    { key = "h", action = act.AdjustPaneSize { "Left",  1 } },
    { key = "j", action = act.AdjustPaneSize { "Down",  1 } },
    { key = "k", action = act.AdjustPaneSize { "Up",    1 } },
    { key = "l", action = act.AdjustPaneSize { "Right", 1 } },

    { key = "Escape", action = "PopKeyTable" },
  },
}

local custom_mouse_bindings = {
  -- select a cell
  {
    event ={ Down = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Cell"),
  },

  -- select a word
  {
    event ={ Down = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = act.Multiple {
    act.SelectTextAtMouseCursor("Word"),
      { CopyTo = "ClipboardAndPrimarySelection" },
    },
  },

  -- select a line
  {
    event ={ Down = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.Multiple {
      act.SelectTextAtMouseCursor("Line"),
      { CopyTo = "ClipboardAndPrimarySelection" },
    },
  },

  -- copy
  {
    event ={ Drag = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.Multiple {
      act.ExtendSelectionToMouseCursor("Cell"),
      { CopyTo   = "ClipboardAndPrimarySelection" },
    },
  },

  -- paste
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act { PasteFrom = "Clipboard" },
  },

  -- scroll down
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = "NONE",
    action = act.ScrollByPage(0.2)
  },

  -- scroll up
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "NONE",
    action = act.ScrollByPage(-0.2)
  },

  -- font size increases 
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "CTRL",
    action = act.IncreaseFontSize,
  },

  -- font size decreases
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = "CTRL",
    action = act.DecreaseFontSize,
  },

  -- open the link
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },

  -- drag move window
  {
    event ={ Drag = { streak = 1, button = "Left" } },
    mods = "CTRL|SHIFT",
    action = act.StartWindowDrag,
  },
}

return {
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  disable_default_quick_select_patterns = true,
  keys = custom_keys,
  key_tables = custom_key_tables,
  mouse_bindings = custom_mouse_bindings,
}
