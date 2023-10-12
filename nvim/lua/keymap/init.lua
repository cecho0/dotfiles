-- vim.keybinds = {
--   gmap = vim.api.nvim_set_keymap,
--   bmap = vim.api.nvim_buf_set_keymap,
--   dgmap = vim.api.nvim_del_keymap,
--   dbmap = vim.api.nvim_buf_del_keymap,
--   opts = {
--     noremap = true,
--     silent = true,
--     expr = false,
--     nowait = false
--   }
-- }

require("keymap.cmd")
require("keymap.remap")
require("keymap.map")

