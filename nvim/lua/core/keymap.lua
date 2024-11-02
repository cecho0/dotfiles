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

-- terminal
map("t", "<Esc>", "<C-\\><C-N>", opt)

-- write
map({"n", "i"}, "<leader>w", "<CMD>write<CR><Esc>", opt)

-- quit
map({"i", "n", "t"}, "<leader>q", "<CMD>quit<CR>", opt)

-- global exit
map({"n", "i"}, "ZZ", "<CMD>SaveAndExit<CR>", opt)
map({"n", "i"}, "Zz", "<CMD>Exit<CR>", opt)

-- jump to line head and tail
map({"n", "v"}, "<leader>a", "^", opt)
map({"n", "v"}, "<leader>d", "$", opt)

-- select pane
map("n", "<C-h>", "<C-w>h", opt)
map("n", "<C-j>", "<C-w>j", opt)
map("n", "<C-k>", "<C-w>k", opt)
map("n", "<C-l>", "<C-w>l", opt)

-- go
map({"n", "v"}, "ge", "G", opt)
map({"n", "v"}, "G", "<Nop>", opt)

-- do not yank with x
map("n", "x", '"_x', opt)
map("v", "x", '"_x', opt)

-- tab index
map("v", "<TAB>", ">gv", opt)
map("v", "<S-TAB>", "<gv", opt)

-- macro
map("n", "Q", "q", opt)
map("n", "q", "<Nop>", opt)

-- buffer
map("n", "<leader>x", "<CMD>bn<CR>", opt)
map("n", "<leader>z", "<CMD>bp<CR>", opt)
map("n", "<leader>c", "<CMD>bd<CR>", opt)

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

-- spectre
-- map("n", "<Tab>", "<cmd>lua require('spectre').tab()<cr>", opt)
-- map("n", "<S-Tab>", "<cmd>lua require('spectre').tab_shift()<cr>", opt)
map("n", "<leader>S", "<cmd>lua require('spectre').toggle()<CR>", opt)
map("n", "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", opt)
map("n", "<leader>sf", "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>", opt)
-- map("n", "dd", "<cmd>lua require('spectre').toggle_line()<CR>", opt)
-- map("n", "<cr>", "<cmd>lua require('spectre.actions').select_entry()<CR>", opt)
-- map("n", "<leader>sd", "<cmd>lua require('spectre.actions').send_to_qf()<CR>", opt)
-- map("n", "<leader>c", "<cmd>lua require('spectre.actions').replace_cmd()<CR>", opt)
-- map("n", "<leader>o", "<cmd>lua require('spectre').show_options()<CR>", opt)
-- map("n", "<leader>rc", "<cmd>lua require('spectre.actions').run_current_replace()<CR>", opt)
-- map("n", "<leader>R", "<cmd>lua require('spectre.actions').run_replace()<CR>", opt)
-- map("n", "<leader>v", "<cmd>lua require('spectre').change_view()<CR>", opt)

map({"n", "c"}, "<A-x>", "<CMD>ToggleCommandMode<CR>", opt)

