local opt = {
  noremap = true,
  silent = true,
  expr = false,
  nowait = false,
}

local function map(mode, key, action, options)
  if type(mode) == "string" then
    vim.api.nvim_set_keymap(mode, key, action, options)
    return
  end

  for _, v in pairs(mode) do
    vim.api.nvim_set_keymap(v, key, action, options)
  end
end

-- tagbar
map({"n", "i", "v"}, "<F2>", "<CMD>Lspsaga outline<CR>", opt)

-- telescope
map("n", "<leader>fd", "<CMD>Telescope live_grep<CR>", opt)
map("n", "<leader>ff", "<CMD>Telescope find_files<CR>", opt)
map("n", "<leader>fb", "<CMD>Telescope buffers<CR>", opt)
map("n", "<leader>fs", "<CMD>Telescope file_browser<CR>", opt)
map("n", "<leader>ct", "<CMD>Telescope colorscheme theme=dropdown<CR>", opt)
