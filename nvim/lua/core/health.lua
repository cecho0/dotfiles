local M = {}

function M.check()
  vim.health.start("core report")
  local start = vim.health.start or vim.health.report_start 
  local ok = vim.health.ok or vim.health.report_ok
  local warn = vim.health.warn or vim.health.report_warn
  local error = vim.health.error or vim.health.report_error
  if vim.fn.has("nvim-0.10.0") == 1 then
    ok("using neovim >= 0.10.0.")
  else
    error("neovim version < 0.10.0, need update neovim.")
  end
end

return M

