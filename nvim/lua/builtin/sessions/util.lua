local env = require("core.env")
local config = require("builtin.sessions.config")
local M = {}

function M.check_dir_valid()
  if vim.fn.isdirectory(config.sessions_dir) ~= 1 then
    local ok, _ = pcall(vim.fn.mkdir, config.sessions_dir, "p")
    if not ok then
      vim.notify(("SessionDir %s Create Failed"):format(config.sessions_dir))
      return false
    end
  end

  return true
end

function M.file_is_readable(path)
 return vim.fn.isdirectory(path) ~= 1 and vim.fn.getfperm(path):sub(1, 1) == "r"
end

function M.get_full_path()
  return vim.fn.expand("%:p")
end

function M.get_filename(path)
  return vim.fn.fnamemodify(path, ":t")
end

function M.get_encode(path)
  local encode_path = nil
  if path ~= nil and #path ~= 0 then
    encode_path = string.gsub(path, env.sep, config.path_replacer)
    encode_path = string.gsub(encode_path, "%.", config.dot_replacer)
  end

  return encode_path
end

function M.get_full_encode(session)
  return config.sessions_dir .. env.sep .. session .. ".vim"
end

function M.save_buffers()
  local unsave_bufs = vim.tbl_filter(function(bufnr)
    return vim.api.nvim_buf_get_option(bufnr, "modified") and vim.api.nvim_buf_get_option(bufnr, "buflisted")
  end, vim.api.nvim_list_bufs())

  if #unsave_bufs > 0 then
    vim.cmd("wa")
  end
end

function M.get_session_list()
  return vim.split(vim.fn.globpath(config.sessions_dir, "*.vim"), "\n")
end

function M.get_complete_list()
  local session_list = M.get_session_list()
  session_list = vim.tbl_map(function(k)
    local tbl = vim.split(k, env.sep, { trimempty = true })
    return vim.fn.fnamemodify(tbl[#tbl], ":r")
  end, session_list)

  return session_list
end

function M.check_session_valid(session)
  local path = M.get_full_encode(session)
  return M.file_is_readable(path)
end

return M

