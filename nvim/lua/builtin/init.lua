local env = require("core.env")

require("builtin.notify").setup()
require("builtin.searchhl").setup()
require("builtin.cursorword").setup()
require("builtin.statusline").setup()
require("builtin.sessions").setup()
-- require("builtin.replace").setup()

if env.enable_plugin then
  return
end

require("builtin.complete")
require("builtin.term").setup()
vim.cmd("silent! colorscheme oxygen")
