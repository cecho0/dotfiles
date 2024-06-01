local session = require("builtin.sessions.session")
local util = require("builtin.sessions.util")
local M = {}

function M.setup()
  if not util.check_dir_valid() then
    return
  end

  session.create_autocmd()
  session.create_usercmd()
end

return M

