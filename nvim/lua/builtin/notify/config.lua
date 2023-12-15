local api = vim.api
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
M.hl_grp.ns_id = api.nvim_create_namespace(M.hl_grp.ns_name)

if api.nvim_win_set_hl_ns then
  api.nvim_set_hl(M.hl_grp.ns_id, "NormalFloat", { bg = "NONE" })
  api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Content", { fg = "#737aa2" })

  api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Date", { fg = "#ffffff" })
  api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Level", { fg = "#939124" })
  api.nvim_set_hl(M.hl_grp.ns_id, M.hl_grp.ns_name .. "Msg", { fg = "#838383" })
end

return M
