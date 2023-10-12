local cfg = require("builtin.replace.config")
local M = {}

local local_M = {}
local displaywidth = vim.fn.strdisplaywidth
local_M.winid = nil
local_M.bufnr = nil
local_M.icon_case = "A"
local_M.icon_whole = "B"
local_M.icon = local_M.icon_case .. " " .. local_M.icon_whole
local_M.history = ""

local function check_ui_valid()
  if local_M.winid
      and vim.api.nvim_win_is_valid(local_M.winid)
      and local_M.bufnr
      and vim.api.nvim_buf_is_valid(local_M.bufnr) then
    return true
  else
    return false
  end
end

local function add_padding(content, icon, padding_len)
  return content .. string.rep(" ", padding_len) .. icon
end

local function adjust_win_width(content, icon)
  local win_width = vim.api.nvim_win_get_width(local_M.winid)
  local content_len = displaywidth(content)
  local icon_len = displaywidth(icon)
  if (content_len + icon_len + 1 <= win_width) and (win_width <= cfg.win_def_width) then
    local padding_len = win_width - content_len - icon_len
    return add_padding(content, icon, padding_len)
  else
    vim.api.nvim_win_set_width(local_M.winid, content_len + icon_len + 1)
    return content .. " " .. local_M.icon
  end
end

local function create_win()
  if check_ui_valid() then
    return
  end

  if not local_M.bufnr or vim.api.nvim_buf_is_valid(local_M.bufnr) then
    local_M.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_keymap(local_M.bufnr, "i", "<F9>", "", {
      callback = function()
        M.toggle_search_ui()
      end,
    })

    vim.api.nvim_buf_set_keymap(local_M.bufnr, "i", "<Esc>", "", {
      callback = function()
        M.toggle_search_ui()
      end,
    })
  end

  local success, winid = pcall(vim.api.nvim_open_win, local_M.bufnr, true, {
    title = "search",
    focusable = true,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
    relative = "editor",
    anchor = "SE",
    width = cfg.win_def_width,
    height = 1,
    row = 5,
    col = vim.o.columns,
    zindex = 100,
  })

  if success then
    local_M.winid = winid

    local line = adjust_win_width("", local_M.icon)
    local lines = { line }
    vim.api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, lines)
  end

  local search_resize_grp = vim.api.nvim_create_augroup("SearchResizeGrp", { clear = true })
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = search_resize_grp,
    buffer = local_M.bufnr,
    callback = function(opts)
      local line_str = vim.api.nvim_buf_get_lines(local_M.bufnr, 0, 1, false)[1]
      local first_word = vim.split(line_str, "%s", { trimempty = true })[1]
      if first_word == local_M.icon_case then
        local_M.history = ""
      else
        local_M.history = first_word
      end

      local line = adjust_win_width(local_M.history, local_M.icon)
      vim.api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, { line })
    end
  })

  local search_del_grp = vim.api.nvim_create_augroup("SearchDelGrp", { clear = true })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = search_del_grp,
    callback = function(opts)
      vim.api.nvim_del_augroup_by_id(search_del_grp)
      vim.api.nvim_del_autocmd(opts.id)
    end
  })
end

function M.toggle_search_ui()
  if check_ui_valid() then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    vim.api.nvim_win_hide(local_M.winid)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", true)
    return
  end

  create_win()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
end

return M

