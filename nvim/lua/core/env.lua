local M = {}
local os_name = vim.loop.os_uname().sysname
local _enbale_plugin = true
local _enable_lsp = true
local _enable_icons = true

function M:join_path(...)
  return table.concat({ ... }, M.sep)
end

function M:load_variables()
  self.is_mac   = os_name == "Darwin"
  self.is_linux   = os_name == "Linux"
  self.is_windows = os_name == "Windows_NT"
  self.sep = M.is_windows and "\\" or "/"
  self.os = os_name

  if not self.is_windows then
    self.home = os.getenv("HOME")
    self.enable_plugin = _enbale_plugin
    self.enable_lsp = _enable_lsp
  else
    self.home = vim.fn.stdpath("data")
    self.enable_plugin = false
    self.enable_lsp = false
  end

  self.config_home = vim.fn.stdpath("config")
  self.data_home = self:join_path(vim.fn.stdpath("data"), "site")
  self.cache_home = self:join_path(self.home, ".cache", "nvim")
  self.modules_home = self:join_path(self.config_home, "lua", "modules")
  self.ft_enable = {
    "c",
    "cpp",
    "rust",
    "go",
    "lua",
    "python",
    "html",
    "css",
    "javascript",
    "vue",
    "cmake",
    "bash",
    "proto",
    "dockerfile"
  }

  self.enable_icons = _enable_icons
  vim.opt.runtimepath:append(self:join_path(self.config_home, "lua", "core"))
end

M:load_variables()

return M
