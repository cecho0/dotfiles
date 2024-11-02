local env = require("core.env")

require("builtin.cursorword").setup()
require("builtin.search").setup()
require("builtin.searchhl").setup()
require("builtin.file").setup()
require("builtin.notify").setup()
require("builtin.statusline").setup()
require("builtin.sessions").setup()
require("builtin.deadcolumn").setup()

if env.enable_plugin then
  return
end
require("builtin.term").setup()

--vim.cmd("silent! colorscheme oxygen")
