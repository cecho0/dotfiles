local config = {}

function config.catppuccin_nvim()
  -- latte, frappe, macchiato, mocha
  --[[ vim.g.catppuccin_flavour = "macchiato"
  require("catppuccin").setup()
  vim.cmd [[colorscheme catppuccin]]
  --]]
end

function config.tokyonight_nvim()
  --night storm day
  require("tokyonight").setup()
  vim.cmd[[colorscheme tokyonight-storm]]
end

function config.neovim()
  -- require("rose-pine").setup()
  -- vim.cmd("colorscheme rose-pine")
end

return config

