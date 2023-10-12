local cfg = require("builtin.sessions.config")
local session = require("builtin.sessions.session")
local util = require("builtin.sessions.util")
local M = {}

function M.setup(opts)
  if opts then
    vim.notify("builtin sessions don't need any options")
    return
  end

  if not util.check_dir_valid() then
    return
  end

  session.create_autocmd()
  session.create_usercmd()
end

return M

