
if not vim.g.vscode then
  return
end

-- keymap
local function remap(mode, key, action, options)
  if type(mode) == "string" then
    vim.api.nvim_set_keymap(mode, key, action, options)
    return
  end

  for _, v in pairs(mode) do
    vim.api.nvim_set_keymap(v, key, action, options)
  end
end

local opt = {
  noremap = true,
  silent = true,
  expr = false,
  nowait = false,
}

-- write
remap({"n", "i"}, "<leader>w", "<CMD>call VSCodeCall('workbench.action.files.save')<CR><Esc>", opt)

-- quit
-- remap({"i", "n", "t"}, "<leader>q", "<CMD>quit<CR>", opt)

-- move
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
remap("n", "<leader>a", "^", opt)
remap("n", "<leader>d", "$", opt)

-- buffer
remap("n", "<leader>z", "<CMD>call VSCodeCall('workbench.action.previousEditor')<CR>", opt)
remap("n", "<leader>x", "<CMD>call VSCodeCall('workbench.action.nextEditor')<CR>", opt)
remap("n", "<leader>c", "<CMD>call VSCodeCall('workbench.action.closeActiveEditor')<CR>", opt)

-- file explorer
remap("n", "<leader>fs", "<CMD>call VSCodeCall('workbench.files.action.focusFilesExplorer')<CR>", opt)

-- lsp
remap("n", "gd", "<CMD>call VSCodeCall('editor.action.revealDeclaration')", opt)
remap("n", "gr", "<CMD>call VSCodeCall('editor.action.rename')", opt)
remap("n", "go", "<CMD>call VSCodeCall('editor.action.quickFix')", opt)
--remap("n", "<leader>d", "<CMD>call VSCodeCall('editor.action.triggerSuggest')", opt)
remap("n", "K", "<CMD>call VSCodeCall('editor.action.showHover')", opt)

