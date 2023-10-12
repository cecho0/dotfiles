local M = {
  hl_grp = {},
  base = {
    min_level = vim.log.levels.INFO,
    lifetime = 5,
    max_width = function()
      local tw = vim.o.textwidth
      local cols = vim.o.columns
      if tw > 0 and tw < cols then
         return math.floor((cols - tw) * 0.7)
      else
         return math.floor(cols / 3)
      end
    end
  },
}

M.hl_grp.ns_name = "Notify"
M.hl_grp.ns_id = vim.api.nvim_create_namespace(M.hl_grp.ns_name)

if vim.api.nvim_win_set_hl_ns then
  vim.api.nvim_set_hl(M.hl_grp.ns_id, "NormalFloat", { bg = "NONE" })
  vim.api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Content", { fg = "#737aa2" })

  vim.api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Date", { fg = "#ffffff" })
  vim.api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Level", { fg = "#939124" })
  vim.api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Msg", { fg = "#838383" })
end

return M
