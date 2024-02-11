local cfg = require("builtin.notify.config")
local api = vim.api
local M = {}
local local_M = {
  winid = nil,
  bufnr = nil,
  buf_is_null = true,
  history = {},
}

local level_map = {
  "DEBUG",
  "ERROR",
  "INFO",
  "TRACE",
  "WARN",
  "OFF"
}

local function get_level(level)
  for k, v in ipairs(level_map) do
    if (level + 1) == k then
      return v
    end
  end
end

local function get_format_date()
  local date = os.date("*t")
  return ("%d/%d/%d - %d:%d:%d"):format(date.year, date.month, date.day, date.hour, date.min, date.sec)
end

local function check_ui_valid()
  if local_M.winid
      and api.nvim_win_is_valid(local_M.winid)
      and local_M.bufnr
      and api.nvim_buf_is_valid(local_M.bufnr) then
    return true
  else
    return false
  end
end

local function create_win()
  -- check if winid and bufnr already exist, don't create a new window
  if check_ui_valid() then
    return
  end

  if not local_M.bufnr or not api.nvim_buf_is_valid(local_M.bufnr) then
    local_M.bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(local_M.bufnr, "modifiable", false)
    local_M.buf_is_null = true
  end

  local success, winid = pcall(api.nvim_open_win, local_M.bufnr, true, {
    focusable = true,
    title = "Notify History",
    title_pos = "center",
    style = "minimal",
    border = "single",
    noautocmd = true,
    relative = "editor",
    anchor = "SE",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.9),
    col = math.floor(vim.o.columns * 0.9),
    zindex = 100,
  })

  if success then
    local_M.winid = winid
    api.nvim_win_set_option(local_M.winid, "winblend", 0)
  end
end

function M.history_add(line, level)
  if not local_M.bufnr or not api.nvim_buf_is_valid(local_M.bufnr) then
    local_M.bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(local_M.bufnr, "modifiable", false)
    local_M.buf_is_null = true
  end


  local date = get_format_date()
  local level_str = get_level(level)
  local format_line = ("%s [%s]: %s"):format(date, level_str, line)

  -- add lines
  if local_M.buf_is_null then
    local_M.buf_is_null = false
  end

  api.nvim_buf_set_option(local_M.bufnr, "modifiable", true)
  api.nvim_buf_set_lines(local_M.bufnr, -1, -1, false, { format_line })
  api.nvim_buf_add_highlight(local_M.bufnr, cfg.ns_id, cfg.ns_name .. "Content", 1 + #local_M.history, 0, #date)
  api.nvim_buf_add_highlight(local_M.bufnr, cfg.ns_id, cfg.ns_name .. "Level", 1 + #local_M.history, #date + 2, #level_str)
  api.nvim_buf_add_highlight(local_M.bufnr, cfg.ns_id, cfg.ns_name .. "Msg", 1 + #local_M.history, #date + 2 + #level_str + 3, -1)
  api.nvim_buf_set_option(local_M.bufnr, "modifiable", false)
  local_M.history[#local_M.history] = format_line
end

function M.history_clear()
  if not local_M.bufnr or not api.nvim_buf_is_valid(local_M.bufnr) or local_M.buf_is_null then
    return
  end

  api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, { "" })
  local_M.history = {}
  local_M.buf_is_null = true
end

function M.history_toggle()
  if check_ui_valid() then
    api.nvim_win_hide(local_M.winid)
    local_M.winid = nil
  else
    create_win()
  end
end

return M
