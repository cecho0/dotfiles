local cfg = require("builtin.notify.config")
local history = require("builtin.notify.history")
local api = vim.api
local M = {}
local local_M = {}
local cache = {}

local_M.winid = nil
local_M.bufnr = nil

local displaywidth = vim.fn.strdisplaywidth

local function get_max_width()
  if type(cfg.base.max_width) == "function" then
    return cfg.base.max_width()
  else
    return cfg.base.max_width
  end
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

  local_M.bufnr = api.nvim_create_buf(false, true)
  local success, winid = pcall(api.nvim_open_win, local_M.bufnr, false, {
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

  if success then
    local_M.winid = winid
    if api.nvim_win_set_hl_ns then
      api.nvim_win_set_hl_ns(local_M.winid, cfg.hl_grp.ns_id)
    end
  end
end

local function delete_win()
  if local_M.winid and api.nvim_win_is_valid(local_M.winid) then
    api.nvim_win_close(local_M.winid, { force = true })
  end

  if local_M.bufnr and api.nvim_buf_is_valid(local_M.bufnr) then
    api.nvim_buf_delete(local_M.bufnr, { force = true })
  end

  local_M.winid = nil
  local_M.bufnr = nil
end

local function adjust_width(str, space_width)
  return string.rep(" ", space_width) .. str
end

local function add_line(content, level)
  local message_lines = vim.split(content, "\n", { plain = true, trimempty = true })
  local width = get_max_width()

  local lines = {}

  for _, line in ipairs(message_lines) do
    local tmp_line = nil
    local words = vim.split(line, "%s", { trimempty = true })

    for _, word in ipairs(words) do
      if displaywidth(word) > width then
        return
      end

      if not tmp_line then
        tmp_line = word
      elseif displaywidth(tmp_line .. " " .. word) > width then
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
    local pad_len = width - displaywidth(message_lines[1])
    fmt_msg = adjust_width(message_lines[1], pad_len)
    table.insert(res, fmt_msg)
  else
    for i, line in ipairs(message_lines) do
      fmt_msg = line
      table.insert(res, fmt_msg)
    end
  end

  cache[#cache + 1] = res
  history.history_add(content, level)
end

local function redraw()
  local line_num = 0
  local lines = {}
  for _, v in ipairs(cache) do
    line_num = line_num + #v
    for _, line in ipairs(v) do
      lines[#lines + 1] = line
    end
  end
  api.nvim_win_set_height(local_M.winid, line_num)
  api.nvim_buf_clear_namespace(local_M.bufnr, cfg.hl_grp.ns_id, 0, -1)
  api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, lines)
  for i = 1, line_num, 1 do
    api.nvim_buf_add_highlight(local_M.bufnr, cfg.hl_grp.ns_id, cfg.hl_grp.ns_name .. "Content", i - 1, 0, -1)
  end
end

function M.push_msg(content, level)
  create_win()
  if not check_ui_valid() then
    return
  end

  add_line(content, level)
  redraw()
end

function M.pop_msg()
  table.remove(cache, 1)
  if #cache == 0 then
    delete_win()
    return
  end

  redraw()
end

function M.create_autocmd()
  api.nvim_create_autocmd("VimResized", {
    group = cfg.hl_grp.ns_id,
    callback = function()
      delete_win()
    end,
  })
end

function M.create_usercmd()
  api.nvim_create_user_command("NotifyHistoryShow", function(args)
    history.history_toggle()
  end, {})

  api.nvim_create_user_command("NotifyHistoryClear", function(args)
    history.history_clear()
  end, {})
end

return M

