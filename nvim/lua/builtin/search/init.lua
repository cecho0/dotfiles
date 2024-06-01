local ui = require("builtin.search.ui")
local api = vim.api
local M = {}

function M.setup()
  ui.create_hl_group()
  ui.load_command()

  api.nvim_set_keymap("n", "n", "<cmd>SearchNext<CR>", { noremap = true, silent = true })
  api.nvim_set_keymap("n", "N", "<cmd>SearchPrev<CR>", { noremap = true, silent = true })
end

return M
