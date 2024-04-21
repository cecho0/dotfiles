local api = vim.api
local M = {}
local local_M = {
  winid = nil,
  bufnr = nil,
  is_open = false,
  is_hidden = false
}

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.max_explore_win_width = 35
vim.g.netrw_dirhistmax = 0
vim.g.netrw_bufsettings = 'noma nomod nobl nowrap ro nonumber norelativenumber cursorlineopt=line'

local function ntree_toggle()
  if local_M.is_open == false then
    vim.cmd("vs")
    vim.cmd("Explore")
    local_M.winid = api.nvim_get_current_win()
    local_M.bufnr = api.nvim_get_current_buf()
    api.nvim_win_set_width(local_M.winid, 35)
    -- vim.cmd("vertical resize 30")
    local_M.is_open = true
    local_M.is_hidden = false
    return
  end

  local cur_win = api.nvim_get_current_win()
  if local_M.is_hidden == false then
    if cur_win == local_M.winid then
      vim.cmd("wincmd w")
    end
    api.nvim_win_set_width(local_M.winid, 0)
    local_M.is_hidden = true
  else
    if cur_win ~= local_M.winid then
      vim.cmd("wincmd w")
    end
    api.nvim_win_set_width(local_M.winid, 35)
    local_M.is_hidden = false
  end
end

function M.setup()
  api.nvim_create_user_command("NTreeToggle", function()
    ntree_toggle()
  end, {})

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if local_M.winid == nil then
        return
      end

      api.nvim_win_close(local_M.winid, { force = true })
      local_M.winid = nil
      local_M.bufnr = nil
      local_M.is_open = false
      local_M.is_hidden = false
    end,
  })
end

return M

