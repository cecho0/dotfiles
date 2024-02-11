local api = vim.api
local opt = {
  noremap = true,
  silent = true,
  expr = false,
  nowait = false,
}

local function remap(mode, key, action, options)
  if type(mode) == "string" then
    api.nvim_set_keymap(mode, key, action, options)
    return
  end

  for _, v in pairs(mode) do
    api.nvim_set_keymap(v, key, action, options)
  end
end

-- terminal
remap("t", "<Esc>", "<C-\\><C-N>", opt)

-- write
remap({"n", "i"}, "<leader>w", "<CMD>write<CR><Esc>", opt)

-- quit
remap({"i", "n", "t"}, "<leader>q", "<CMD>quit<CR>", opt)

-- global exit
remap({"n", "i"}, "ZZ", "<CMD>SaveAndExit<CR>", opt)
remap({"n", "i"}, "Zz", "<CMD>Exit<CR>", opt)

-- jump to line head and tail
remap({"n", "v"}, "<leader>a", "^", opt)
remap({"n", "v"}, "<leader>d", "$", opt)

-- select pane
remap("n", "<C-h>", "<C-w>h", opt)
remap("n", "<C-j>", "<C-w>j", opt)
remap("n", "<C-k>", "<C-w>k", opt)
remap("n", "<C-l>", "<C-w>l", opt)

-- go
remap({"n", "v"}, "ge", "G", opt)
remap({"n", "v"}, "G", "<Nop>", opt)

-- do not yank with x
remap("n", "x", '"_x', opt)
remap("v", "x", '"_x', opt)

-- tab index
remap("v", "<TAB>", ">gv", opt)
remap("v", "<S-TAB>", "<gv", opt)

-- macro
remap("n", "Q", "q", opt)
remap("n", "q", "<Nop>", opt)

-- buffer
remap("n", "<leader>x", "<CMD>bn<CR>", opt)
remap("n", "<leader>z", "<CMD>bp<CR>", opt)
remap("n", "<leader>c", "<CMD>bd<CR>", opt)
