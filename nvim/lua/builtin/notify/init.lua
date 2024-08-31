local api = vim.api
local M = {}
local config = {
  ns_name = "Notify",
  ns_id = nil,
  min_level = vim.log.levels.INFO,
  lifetime = 5,
  max_width = function()
    local tw = vim.o.textwidth
    local cols = vim.o.columns
    if tw > 0 and tw < cols then
        return math.floor((cols - tw) * 0.7)
    else
        return math.floor(cols / 3)
    end
  end
}
local history = {
  winid = nil,
  bufnr = nil,
  buf_is_null = true,
  cache = {},
}
local msg = {
  winid = nil,
  bufnr = nil,
  cache = {},
}

local displaywidth = vim.fn.strdisplaywidth
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

function history.check_ui_valid()
  if history.winid
      and api.nvim_win_is_valid(history.winid)
      and history.bufnr
      and api.nvim_buf_is_valid(history.bufnr) then
    return true
  else
    return false
  end
end

function history.create_win()
  -- check if winid and bufnr already exist, don't create a new window
  if history.check_ui_valid() then
    return
  end

  if not history.bufnr or not api.nvim_buf_is_valid(history.bufnr) then
    history.bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(history.bufnr, "modifiable", false)
    history.buf_is_null = true
  end

  local success, winid = pcall(api.nvim_open_win, history.bufnr, true, {
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
    history.winid = winid
    api.nvim_win_set_option(history.winid, "winblend", 0)
  end
end

function history.add(line, level)
  if not history.bufnr or not api.nvim_buf_is_valid(history.bufnr) then
    history.bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(history.bufnr, "modifiable", false)
    history.buf_is_null = true
  end

  local date = get_format_date()
  local level_str = get_level(level)
  local format_line = ("%s [%s]: %s"):format(date, level_str, line)

  -- add lines
  if history.buf_is_null then
    history.buf_is_null = false
  end

  api.nvim_buf_set_option(history.bufnr, "modifiable", true)
  api.nvim_buf_set_lines(history.bufnr, -1, -1, false, { format_line })
  api.nvim_buf_set_option(history.bufnr, "modifiable", false)
  history.cache[#history.cache] = format_line
end

function history.clear()
  if not history.bufnr or not api.nvim_buf_is_valid(history.bufnr) or history.buf_is_null then
    return
  end

  api.nvim_buf_set_lines(history.bufnr, 0, -1, false, { "" })
  history.cache = {}
  history.buf_is_null = true
end

function history.toggle()
  if history.check_ui_valid() then
    api.nvim_win_hide(history.winid)
    history.winid = nil
  else
    history.create_win()
  end
end

local function get_max_width()
  if type(config.max_width) == "function" then
    return config.max_width()
  else
    return config.max_width
  end
end

function msg.check_ui_valid()
  if msg.winid
      and api.nvim_win_is_valid(msg.winid)
      and msg.bufnr
      and api.nvim_buf_is_valid(msg.bufnr) then
    return true
  else
    return false
  end
end

function msg.create_win()
  -- check if winid and bufnr already exist, don't create a new window
  if msg.check_ui_valid() then
    return
  end

  msg.bufnr = api.nvim_create_buf(false, true)
  local success, winid = pcall(api.nvim_open_win, msg.bufnr, false, {
    focusable = false,
    style = "minimal",
    border = "none",
    noautocmd = true,
    relative = "editor",
    anchor = "SE",
    width = get_max_width(),
    height = 3,
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = vim.o.columns,
    zindex = 100,
  })

  if not success then
    return
  end

  msg.winid = winid
  api.nvim_win_set_hl_ns(msg.winid, config.ns_id)
end

function msg.delete_win()
  if msg.winid and api.nvim_win_is_valid(msg.winid) then
    api.nvim_win_close(msg.winid, { force = true })
  end

  if msg.bufnr and api.nvim_buf_is_valid(msg.bufnr) then
    api.nvim_buf_delete(msg.bufnr, { force = true })
  end

  msg.winid = nil
  msg.bufnr = nil
end

local function adjust_width(str, space_width)
  return string.rep(" ", space_width) .. str
end

local function add_line(content, level)
  local message_lines = vim.split(content, "\n", { plain = true, trimempty = true })
  local max_width = get_max_width()

  local lines = {}

  for _, line in ipairs(message_lines) do
    local tmp_line = nil
    local words = vim.split(line, "%s", { trimempty = true })

    for _, word in ipairs(words) do
      if displaywidth(word) > max_width then
        return
      end

      if not tmp_line then
        tmp_line = word
      elseif displaywidth(tmp_line .. " " .. word) > max_width then
        lines[#lines + 1] = tmp_line
        tmp_line = word
      else
        tmp_line = tmp_line .. " " .. word
      end
    end

    lines[#lines + 1] = tmp_line
  end

  message_lines = lines

  local res = {}
  local fmt_msg = nil
  if #message_lines == 1 then
    local pad_len = max_width - displaywidth(message_lines[1])
    fmt_msg = adjust_width(message_lines[1], pad_len)
    table.insert(res, fmt_msg)
  else
    for i, line in ipairs(message_lines) do
      fmt_msg = line
      table.insert(res, fmt_msg)
    end
  end

  msg.cache[#msg.cache + 1] = res
  local replace_str = string.gsub(content, "\n", " ")
  history.add(replace_str, level)
end

local function redraw()
  local line_num = 0
  local lines = {}
  for _, v in ipairs(msg.cache) do
    line_num = line_num + #v
    for _, line in ipairs(v) do
      lines[#lines + 1] = line
    end
  end
  api.nvim_win_set_height(msg.winid, line_num)
  api.nvim_buf_clear_namespace(msg.bufnr, config.ns_id, 0, -1)
  api.nvim_buf_set_lines(msg.bufnr, 0, -1, false, lines)
end

function msg.push_msg(content, level)
  msg.create_win()
  if not msg.check_ui_valid() then
    return
  end

  add_line(content, level)
  redraw()
end

function msg.pop_msg()
  table.remove(msg.cache, 1)
  if #msg.cache == 0 then
    msg.delete_win()
    return
  end

  redraw()
end

function msg.create_autocmd()
  api.nvim_create_autocmd("VimResized", {
    group = config.ns_id,
    callback = function()
      msg.delete_win()
    end,
  })
end

function msg.create_usercmd()
  api.nvim_create_user_command("NotifyHistoryShow", function(args)
    history.toggle()
  end, {})

  api.nvim_create_user_command("NotifyHistoryClear", function(args)
    history.clear()
  end, {})
end

local function notify(content, level)
  if not content then
    return
  end

  level = level or vim.log.levels.INFO

  msg.push_msg(content, level)
  if level < config.min_level then
    return
  end

  if config.lifetime > 0 then
    vim.defer_fn(function()
      msg.pop_msg()
    end, config.lifetime * 1000)
  end
end

function M.setup()
  config.ns_id = api.nvim_create_namespace(config.ns_name)
  api.nvim_set_hl(config.ns_id, "NormalFloat", { fg = "#737aa2", bg = "None" })

  msg.create_autocmd()
  msg.create_usercmd()
  vim.notify = notify
end

return M
