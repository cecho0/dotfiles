local api = vim.api
local M = {}

local local_M = {
  ns_name = "SearchUI",
  ns_id = 0,
  last_winid = nil,
  last_bufnr = nil,
  mark_id = 0,
}

local_M.ns_id = api.nvim_create_namespace(local_M.ns_name)

local function inlay_text(bufnr, line, text)
  local line_num = line
  local col_num = 1

  local opts = {
    end_line = line,
    id = 1,
    virt_text = { { text, local_M.ns_name .. "Lable"} },
    virt_text_pos = "eol",
  }

  local_M.mark_id = api.nvim_buf_set_extmark(bufnr, local_M.ns_id, line_num, col_num, opts)
end

local function search(value, forward)
  local pos = vim.fn.searchpos(value, forward)
  if pos[1] == 0 and pos[2] == 0 then
    -- can't find search keyword
    return;
  end

  pos[2] = pos[2] - 1
  local_M.last_winid = api.nvim_get_current_win()
  local_M.last_bufnr = vim.fn.bufnr("%")

  api.nvim_win_set_cursor(local_M.last_winid, pos)

  local idx_msg = vim.fn.searchcount({ maxcount = -1 })
  local cur_idx = idx_msg["current"]
  local max_idx = idx_msg["total"]
  local hint_text = "[" .. cur_idx .. "/" .. max_idx .. "]"
  if local_M.mark_id ~= 0 then
    api.nvim_buf_del_extmark(local_M.last_bufnr, local_M.ns_id, local_M.mark_id)
  end
  inlay_text(local_M.last_bufnr, pos[1] - 1, hint_text)
end

local function jump(forward)
  local value = vim.fn.getreg("/")
  if #value == 0 then
    return
  end

  vim.v.hlsearch = 1
  search(value, forward)
end

local disable_search_label_grp = api.nvim_create_augroup("disable_search_label_grp", { clear = true })
api.nvim_create_autocmd({ "BufLeave", "InsertEnter" }, {
  group = disable_search_label_grp,
  callback = function()
    if local_M.mark_id ~= 0 then
      api.nvim_buf_del_extmark(local_M.last_bufnr, local_M.ns_id, local_M.mark_id)
      local_M.mark_id = 0
    end
  end,
})

function M.create_hl_group()
  api.nvim_set_hl(0, local_M.ns_name .. "Lable", { bg = "NONE", fg = "#445555" })
end

function M.load_command()
  api.nvim_create_user_command("SearchNext", function()
    jump('n')
  end, {})

  api.nvim_create_user_command("SearchPrev", function()
    jump('b')
  end, {})
end

return M

