local M = {}

M.config = {
  disable = false
}

local function disable_hl()
  if vim.v.hlsearch == 0 then
    return
  end

  local keycode = vim.api.nvim_replace_termcodes("<Cmd>nohlsearch<CR>", true, false, true)
  vim.api.nvim_feedkeys(keycode, 'n', false)
end

local function enable_hl()
  local search_str = vim.fn.getreg('/')
  if vim.v.hlsearch == 1 and not vim.fn.search([[\%#\zs]] .. search_str, "cnW") then
    disable_hl()
  end
end

local function enable_auto_hl(hlgroup, bufnr)
  local enable_hl_cmd = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = bufnr,
    group = hlgroup,
    callback = function()
      enable_hl()
    end,
  })

  local disable_hl_cmd = vim.api.nvim_create_autocmd("InsertEnter", {
    buffer = bufnr,
    group = hlgroup,
    callback = function()
      disable_hl()
    end,
  })

  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = bufnr,
    group = hlgroup,
    callback = function(opt)
      pcall(vim.api.nvim_del_autocmd, enable_hl_cmd)
      pcall(vim.api.nvim_del_autocmd, disable_hl_cmd)
      pcall(vim.api.nvim_del_autocmd, opt.id)
    end
  })
end

function M.setup(opts)
  if opts then
    vim.notify("builtin searchhl don't need any options")
    return
  end

  local search_hl_grp = vim.api.nvim_create_augroup("search_hl_grp", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = search_hl_grp,
    callback = function(opt)
      enable_auto_hl(search_hl_grp, opt.buf)
    end
  })
end

return M
