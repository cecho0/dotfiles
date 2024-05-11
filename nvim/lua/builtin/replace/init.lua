local ui = require("builtin.replace.ui")
local api = vim.api
local M = {}

local function MyMouseClick()
  local cursor_row, cursor_col = unpack(api.nvim_win_get_cursor(0))
  local clicked_row, clicked_col = unpack(vim.fn.getpos("."))

  local res = vim.fn.getmousepos()
  local mouse_x = vim.fn.getmousepos()["screencol"]
  local mouse_y = vim.fn.getmousepos()["screenrow"]

  local bufnr = api.nvim_create_buf(false, true)
  local success, winid = pcall(api.nvim_open_win, bufnr, false, {
    focusable = false,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
    relative = "editor",
    anchor = "SE",
    width = 10,
    height = 1,
    -- row = vim.o.lines - vim.o.cmdheight - 1,
    -- col = vim.o.columns,
    row = mouse_y,
    col = mouse_x,
    zindex = 100,
  })



  print(winid)

    -- print(cursor_row)
    -- print(cursor_col)
    -- 在特定位置触发点击事件
    -- if cursor_row == clicked_row and cursor_col == clicked_col then
    --     api.nvim_out_write("Mouse clicked at specific position!\n")
    -- end
end

function M.setup(opts)
  if opts then
    vim.notify("builtin replace don't need any options")
    return
  end

  ui.create_hl_group()
  ui.load_command()

  -- api.nvim_set_keymap('n', '<LeftMouse>', ':lua MyMouseClick()<CR>', { noremap = true, silent = true })
  api.nvim_set_keymap("n", "<F9>", "<cmd>SearchUIToggle<CR>", { noremap = true, silent = true })
  api.nvim_set_keymap("n", "n", "<cmd>SearchNext<CR>", { noremap = true, silent = true })
  api.nvim_set_keymap("n", "N", "<cmd>SearchPrev<CR>", { noremap = true, silent = true })
end

return M