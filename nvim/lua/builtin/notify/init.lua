local cfg = require("builtin.notify.config")
local msg = require("builtin.notify.msg")
local M = {}

local function notify(content, level)
  if not content then
    return
  end

  level = level or vim.log.levels.INFO

  msg.push_msg(content, level)
  if level < cfg.min_level then
    return
  end

  if cfg.lifetime > 0 then
    vim.defer_fn(function()
      msg.pop_msg()
    end, cfg.lifetime * 1000)
  end
end

function M.setup(opts)
  if opts then
    vim.notify("builtin notify don't need any options")
    return
  end

  msg.create_autocmd()
  msg.create_usercmd()
  vim.notify = notify
end

return M
