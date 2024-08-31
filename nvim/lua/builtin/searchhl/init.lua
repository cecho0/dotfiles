local api = vim.api
local M = {}
local config = {
  enable = true,
  ns_name = "SearchHL"
}

local function disable_hl()
  if not config.enable then
    return
  end

  if vim.v.hlsearch == 0 then
    return
  end

  local keycode = api.nvim_replace_termcodes("<Cmd>nohlsearch<CR>", true, false, true)
  api.nvim_feedkeys(keycode, "n", false)
end

local function enable_hl()
  if not config.enable then
    return
  end

  local search_str = vim.fn.getreg("/")
  if vim.v.hlsearch == 1 and not vim.fn.search([[\%#\zs]] .. search_str, "cnW") then
    disable_hl()
  end
end

local function enable_auto_hl(hlgroup, bufnr)
  local enable_hl_cmd = api.nvim_create_autocmd("CursorMoved", {
    buffer = bufnr,
    group = hlgroup,
    callback = function()
      enable_hl()
    end,
  })

  local disable_hl_cmd = api.nvim_create_autocmd("InsertEnter", {
    buffer = bufnr,
    group = hlgroup,
    callback = function()
      disable_hl()
    end,
  })

  api.nvim_create_autocmd("BufWinLeave", {
    buffer = bufnr,
    group = hlgroup,
    callback = function(opt)
      pcall(api.nvim_del_autocmd, enable_hl_cmd)
      pcall(api.nvim_del_autocmd, disable_hl_cmd)
      pcall(api.nvim_del_autocmd, opt.id)
    end
  })
end

function M.status()
  return config.enable and "ON" or "OFF"
end

function M.enable(enable)
  config.enable = enable
end

function M.setup()
  local search_hl_grp = api.nvim_create_augroup(config.ns_name, { clear = true })
  api.nvim_create_autocmd("BufWinEnter", {
    group = search_hl_grp,
    callback = function(opt)
      enable_auto_hl(search_hl_grp, opt.buf)
    end
  })
end

return M
