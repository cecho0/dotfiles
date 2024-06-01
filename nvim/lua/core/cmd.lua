local env = require("core.env")
local api = vim.api

local function debug_info()
  print("config: " .. env.config_home)
  print("data: " .. env.data_home)
  print("cache: " .. env.cache_home)
  print("home: " .. env.home)
  print("os: " .. env.os)
  print("modules: " .. env.modules_home)
  print("runtime:" .. vim.inspect(api.nvim_list_runtime_paths()))
end

local function toggle_command_mode()
  local mode = api.nvim_get_mode().mode
  if mode ~= "n" and mode ~= "c" then
    return
  end

  if mode == "n" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":", true, false, true), "n", true)
  elseif mode == "c" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "c", true)
  end
end

api.nvim_create_user_command("DebugInfo", function(args)
  debug_info()
end, {})

api.nvim_create_user_command("NewFile", function()
  api.nvim_command(":ene!")
end, {})

api.nvim_create_user_command("Exit", function()
  api.nvim_command(":qa!")
end, {})

api.nvim_create_user_command("SaveAndExit", function()
  api.nvim_command(":wqa")
end, {})

api.nvim_create_user_command("ToggleCommandMode", function()
  toggle_command_mode()
end, {})

local mygrp = api.nvim_create_augroup("MYGRP", { clear = true })
api.nvim_create_autocmd("BufWritePost", {
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

api.nvim_create_autocmd("TextYankPost", {
  group = mygrp,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
  end,
})
