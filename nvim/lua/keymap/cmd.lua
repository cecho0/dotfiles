
vim.api.nvim_create_user_command("NewFile", function()
  vim.api.nvim_command(":ene!")
end, {})

vim.api.nvim_create_user_command("Exit", function()
  vim.api.nvim_command(":qa!")
end, {})

vim.api.nvim_create_user_command("SaveAndExit", function()
  vim.api.nvim_command(":wqa")
end, {})
