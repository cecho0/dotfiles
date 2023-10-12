require("builtin.buffers.buffer")
local M = {}

M.config = require("builtin.buffers.config").default

function _G.set_tabline()
  if M == nil then
    return
  end

  local buffers = gen_buffers(M)
  local line = ""

  line = format_buffers(M, buffers, nil)
  return line
end

local function create_hl_group(tbl)
  for group, value in pairs(tbl) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

function M.setup(opts)
  if opts then
    vim.notify("builtin buffers don't need any options")
    return
  end

  create_hl_group(M.config.colors)

  vim.o.tabline = "%!v:lua.set_tabline()"
end

return M
