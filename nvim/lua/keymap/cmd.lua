local api = vim.api

api.nvim_create_user_command("NewFile", function()
  api.nvim_command(":ene!")
end, {})

api.nvim_create_user_command("Exit", function()
  api.nvim_command(":qa!")
end, {})

api.nvim_create_user_command("SaveAndExit", function()
  api.nvim_command(":wqa")
end, {})
