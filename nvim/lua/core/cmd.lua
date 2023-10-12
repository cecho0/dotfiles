local env = require("core.env")

local function debug_info()
  print("config: " .. env.config_home)
  print("data: " .. env.data_home)
  print("cache: " .. env.cache_home)
  print("home: " .. env.home)
  print("os: " .. env.os)
  print("modules: " .. env.modules_home)
  print("runtime:" .. vim.inspect(vim.api.nvim_list_runtime_paths()))
end

local function debug_runtime()
  print("runtime:" .. vim.inspect(vim.api.nvim_list_runtime_paths()))
end

vim.api.nvim_create_user_command("DebugInfo", function(args)
  debug_info()
end, {})

local mygrp = vim.api.nvim_create_augroup("MYGRP", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = mygrp,
  pattern = "*.lua",
  callback = function(_)
    -- auto reload neovim config
    local path = vim.fn.expand("%:p")
    if string.find(path, env.config_home) ~= nil then
      vim.cmd(string.format("source %s", path))
    end
  end
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = mygrp,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
  end,
})
