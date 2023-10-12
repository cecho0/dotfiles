local M = {}
local word_def_cfg = {
  max = 100,
  min = 3,
}

M.config = {
  only_nor_mode = true,
  word = {
    max = word_def_cfg.max,
    min = word_def_cfg.min,
  },
  style = {
    fg = nil,
    -- bg = "#4A708B",
    underline = true,
  },
  disable = false,
}

local function disable_cursorword()
  if vim.w.cursorword_id ~= nil and vim.w.cursorword_id ~= 0 then
    vim.fn.matchdelete(vim.w.cursorword_id)
    vim.w.cursorword_id = nil
    vim.w.cursorword_str = nil
  end
end

local function enable_cursorword()
  if M.config.only_nor_mode then
    if vim.api.nvim_get_mode().mode ~= 'n' then
      return
    end
  end

  -- filter some filetype
  if vim.bo.filetype == "help"
    or #vim.bo.filetype == 0
  then
    return
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype == "prompt" or #bufname == 0 then
    return
  end

  local column = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
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
    or #cursorword_str > M.config.word.max
    or #cursorword_str < M.config.word.min
    or string.find(cursorword_str, '[\192-\255]+') ~= nil
  then
    return
  end

  local pattern = [[\<]] .. cursorword_str .. [[\>]]
  vim.w.cursorword_id = vim.fn.matchadd("CursorWord", pattern, -1)
end

local function check_param(obj)
  local max = obj.config.word.max
  local min = obj.config.word.min
  if min > max or min <= 0 then
    M.config.word.max = word_def_cfg.max
    M.config.word.min = word_def_cfg.min
  end
end

function M.setup(opts)
  if opts then
    vim.notify("builtin cursorword don't need any options")
    return
  end

  check_param(M)
  vim.api.nvim_set_hl(0, "CursorWord", M.config.style)

  vim.api.nvim_create_autocmd("CursorMoved", {
    pattern = "*",
    callback = enable_cursorword,
  })
  vim.api.nvim_create_autocmd({ "InsertEnter", "BufWinEnter" }, {
    pattern = "*",
    callback = disable_cursorword,
  })
end

return M
