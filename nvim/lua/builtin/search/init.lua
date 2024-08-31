local api = vim.api
local M = {}
local config = {
  enable = true,
  ns_name = "SearchLable",
  ns_id = nil,
  last_winid = nil,
  last_bufnr = nil,
  mark_id = 0,
}

local function inlay_text(bufnr, line, text)
  local line_num = line
  local col_num = 1

  local opts = {
    end_line = line,
    id = 1,
    virt_text = { { text, config.ns_name } },
    virt_text_pos = "eol",
  }

  config.mark_id = api.nvim_buf_set_extmark(bufnr, config.ns_id, line_num, col_num, opts)
end

local function search(value, forward)
  local pos = vim.fn.searchpos(value, forward)
  if pos[1] == 0 and pos[2] == 0 then
    -- can't find search keyword
    return;
  end

  pos[2] = pos[2] - 1
  config.last_winid = api.nvim_get_current_win()
  config.last_bufnr = vim.fn.bufnr("%")

  api.nvim_win_set_cursor(config.last_winid, pos)

  local idx_msg = vim.fn.searchcount({ recompute = 1, maxcount = 9999} )
  local cur_idx = idx_msg["current"]
  local max_idx = idx_msg["total"]
  local hint_text = "[" .. cur_idx .. "/" .. max_idx .. "]"
  if config.mark_id ~= 0 then
    api.nvim_buf_del_extmark(config.last_bufnr, config.ns_id, config.mark_id)
  end
  inlay_text(config.last_bufnr, pos[1] - 1, hint_text)
end

local function jump(forward)
  if not config.enable then
    return
  end

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
    if config.mark_id ~= 0 then
      api.nvim_buf_del_extmark(config.last_bufnr, config.ns_id, config.mark_id)
      config.mark_id = 0
    end
  end,
})

local function create_hl_group()
  config.ns_id = api.nvim_create_namespace(config.ns_name)
  api.nvim_set_hl(0, config.ns_name, {
    bg = "NONE",
    fg = "#445555"
  })
end

local function load_command()
  api.nvim_create_user_command("SearchNext", function()
    jump('n')
  end, {})

  api.nvim_create_user_command("SearchPrev", function()
    jump('b')
  end, {})
end

function M.status()
  return config.enable and "ON" or "OFF"
end

function M.enable(enable)
  config.enable = enable
end

function M.setup()
  create_hl_group()
  load_command()

  api.nvim_set_keymap("n", "n", "<cmd>SearchNext<CR>", { noremap = true, silent = true })
  api.nvim_set_keymap("n", "N", "<cmd>SearchPrev<CR>", { noremap = true, silent = true })
end

return M
