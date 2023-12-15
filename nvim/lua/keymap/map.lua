local api = vim.api
local opt = {
  noremap = true,
  silent = true,
  expr = false,
  nowait = false,
}

local function map(mode, key, action, options)
  if type(mode) == "string" then
    api.nvim_set_keymap(mode, key, action, options)
    return
  end

  for _, v in pairs(mode) do
    api.nvim_set_keymap(v, key, action, options)
  end
end

-- lspsaga
map("n", "gf", "<cmd>Lspsaga finder def+ref+imp<CR>", opt)
map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opt)
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", opt)
map("n", "go", "<cmd>Lspsaga code_action<CR>", opt)
map("v", "<leader>go", "<cmd><C-U>Lspsaga range_code_action<CR>", opt)
map({"n", "v"}, "gr", "<cmd>Lspsaga rename<CR>", opt)
map("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", opt)
map("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opt)
map("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opt)
map("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", opt)
map({"n", "i", "v"}, "<F2>", "<CMD>Lspsaga outline<CR>", opt)
map({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>", opt)

-- codewindow
map("n", "<F3>", '<CMD>lua require("codewindow").toggle_minimap()<CR>', opt )

-- telescope
map("n", "<leader>fd", "<CMD>Telescope live_grep<CR>", opt)
map("n", "<leader>ff", "<CMD>Telescope find_files<CR>", opt)
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>", opt)
map("n", "<leader>fs", "<CMD>Telescope file_browser<CR>", opt)
map("n", "<leader>ct", "<CMD>Telescope colorscheme theme=dropdown<CR>", opt)
