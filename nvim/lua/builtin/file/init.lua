local cursor_word = require("builtin.cursorword")
local search = require("builtin.search")
local searchhl = require("builtin.searchhl")
local api = vim.api
local M = {}

local function status()
  local tbl = {
    cursorword = cursor_word.status(),
    search = search.status(),
    searchhl = searchhl.status(),
  }
  vim.print(tbl)
end

function M.setup()
  api.nvim_create_user_command("ShowBuiltinStatus", function()
    status()
  end, {})

  api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    callback = function(opt)
      if vim.bo.filetype == "help"
          or #vim.bo.filetype == 0
      then
        return
      end

      local bufname = api.nvim_buf_get_name(0)
      if vim.bo.buftype == "prompt" or #bufname == 0 then
        return
      end

      if vim.fn.wordcount().bytes > 1000000 then
        cursor_word.enable(false)
        search.enable(false)
        searchhl.enable(false)
      else
        cursor_word.enable(true)
        search.enable(true)
        searchhl.enable(true)
      end
    end,
  })
end

return M
