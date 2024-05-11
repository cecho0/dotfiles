-- load pack
local env = require("core.env")

local pack = {}
pack.__index = pack

function pack:load_modules_packages()
  local modules_home = env.modules_home
  self.repos = {}

  local list = vim.fs.find(
    'plugins.lua',
    {
      path = modules_home,
      type = 'file',
      limit = 20
    }
  )

  if #list == 0 then
    return
  end

  if env.is_windows then
    modules_home = modules_home:gsub("\\", "/")
  end

  local disable_modules = {}

  for _, f in pairs(list) do
    local _, pos = f:find(modules_home)
    f = f:sub(pos - 6, #f - 4)
    require(f)
  end
end

function pack:init_plugins()
  if not env.enable_plugin then
    return
  end

  local lazy_path = env:join_path(env.data_home, "lazy", "lazy.nvim")
  local state = vim.uv.fs_stat(lazy_path)
  if not state then
    vim.notify("Install Lazy.nvim")
    vim.fn.system({
      "git",
      "clone",
      "https://github.com/folke/lazy.nvim.git",
      lazy_path,
    })
  end
  vim.opt.runtimepath:prepend(lazy_path)

  local lazy = require("lazy")
  local opts = {
    lockfile = env:join_path(env.data_home, "lazy-lock.json"),
    ui = {
      border = "rounded",
    },
    install = {
      colorscheme = { "onenord", "oxygen" },
    }
  }
  self:load_modules_packages()
  lazy.setup(self.repos, opts)
end

function pack.package(repo)
  if not pack.repos then
    pack.repos = {}
  end
  table.insert(pack.repos, repo)
end

return pack
