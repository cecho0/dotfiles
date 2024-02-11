local api = vim.api
local M = {}
local local_M = {
  ns_name = "CursorWord",
  ns_id = nil,
  word_max = 100,
  word_min = 3,
  style = {
    fg = nil,
    -- bg = "#4A708B",
    underline = true,
  }
}

local function disable_cursorword()
  if vim.w.cursorword_id ~= nil and vim.w.cursorword_id ~= 0 then
    vim.fn.matchdelete(vim.w.cursorword_id)
    vim.w.cursorword_id = nil
    vim.w.cursorword_str = nil
  end
end

local function enable_cursorword()
  if api.nvim_get_mode().mode ~= 'n' then
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
    vim.call('matchdelete', vim.w.cursorword_id)
    vim.w.cursorword_id = nil
  end

  if cursorword_str == ''
    or #cursorword_str > local_M.word_max
    or #cursorword_str < local_M.word_min
    or string.find(cursorword_str, '[\192-\255]+') ~= nil
  then
    return
  end

  local pattern = [[\<]] .. cursorword_str .. [[\>]]
  vim.w.cursorword_id = vim.fn.matchadd(local_M.ns_name, pattern, -1)
end

function M.setup(opts)
  if opts then
    vim.notify("builtin cursorword don't need any options")
    return
  end

  local_M.ns_id = api.nvim_create_namespace(local_M.ns_name)

  api.nvim_set_hl(0, local_M.ns_name, local_M.style)

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
