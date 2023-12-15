-- local api = vim.api
-- vim.keybinds = {
--   gmap = api.nvim_set_keymap,
--   bmap = api.nvim_buf_set_keymap,
--   dgmap = api.nvim_del_keymap,
--   dbmap = api.nvim_buf_del_keymap,
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

