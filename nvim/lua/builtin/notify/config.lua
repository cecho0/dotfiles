local api = vim.api
local M = {
  ns_name = "Notify",
  ns_id = nil,
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
}

M.ns_name = "Notify"
M.ns_id = api.nvim_create_namespace(M.ns_name)

if api.nvim_win_set_hl_ns then
  api.nvim_set_hl(0, M.ns_name .. "NormalFloat", { fg = "#737aa2", bg = "None" })

  api.nvim_set_hl(M.ns_id, M.ns_name .. "Date", { fg = "#ffffff" })
  api.nvim_set_hl(M.ns_id, M.ns_name .. "Level", { fg = "#939124" })
  api.nvim_set_hl(M.ns_id, M.ns_name .. "Msg", { fg = "#838383" })
end

return M

