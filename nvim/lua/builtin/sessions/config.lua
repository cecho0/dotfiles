local env = require("core.env")

local M = {
  sessions_dir = env:join_path(vim.fs.normalize(env.data_home), "sessions"),
  dot_replacer = "__",
  path_replacer = "_",
}

return M

