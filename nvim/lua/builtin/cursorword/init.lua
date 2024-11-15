local api = vim.api
local M = {}
local config = {
  enable = true,
  ns_name = "CursorWord",
  ns_id = nil,
  word_max = 100,
  word_min = 3,
  style = {
    fg = nil,
    underline = true,
    bg = "#808080",
  }
}

local function disable_cursorword()
  if not config.enable then
    return
  end

  if vim.w.cursorword_id ~= nil and vim.w.cursorword_id ~= 0 then
    vim.fn.matchdelete(vim.w.cursorword_id)
    vim.w.cursorword_id = nil
    vim.w.cursorword_str = nil
  end
end

local function enable_cursorword()
  if not config.enable then
    return
  end

  if api.nvim_get_mode().mode ~= "n" then
    return
  end

  -- filter some filetype
  if vim.bo.filetype == "help"
    or #vim.bo.filetype == 0
  then
    return
  end

  local bufname = api.nvim_buf_get_name(0)
  if vim.bo.buftype == "prompt" or #bufname == 0 then
    return
  end

  local column = api.nvim_win_get_cursor(0)[2]
  local line = api.nvim_get_current_line()
  local cursorword_str = vim.fn.matchstr(line:sub(1, column + 1), [[\k*$]])
    .. vim.fn.matchstr(line:sub(column + 1), [[^\k*]]):sub(2)

  if cursorword_str == vim.w.cursorword_str then
    return
  end

  vim.w.cursorword_str = cursorword_str
  if vim.w.cursorword_id ~= nil and vim.w.cursorword_id >= 1 then
    vim.call("matchdelete", vim.w.cursorword_id)
    vim.w.cursorword_id = nil
  end

  if cursorword_str == ""
    or #cursorword_str > config.word_max
    or #cursorword_str < config.word_min
    or string.find(cursorword_str, '[\192-\255]+') ~= nil
  then
    return
  end

  local pattern = [[\<]] .. cursorword_str .. [[\>]]
  vim.w.cursorword_id = vim.fn.matchadd(config.ns_name, pattern, -1)
end

function M.status()
  return config.enable and "ON" or "OFF"
end

function M.enable(enable)
  config.enable = enable
end

function M.setup()
  config.ns_id = api.nvim_create_namespace(config.ns_name)
  api.nvim_set_hl(0, config.ns_name, config.style)
  
  api.nvim_create_autocmd("CursorMoved", {
    pattern = "*",
    callback = enable_cursorword,
  })
  api.nvim_create_autocmd({ "InsertEnter", "BufWinEnter" }, {
    pattern = "*",
    callback = disable_cursorword,
  })
end

return M
