local api = vim.api
local M = {}

local cfg = {
    win_def_width = 10,
}

local displaywidth = vim.fn.strdisplaywidth

local local_M = {
  ns_name = "SearchUI",
  ns_id = 0,
  last_winid = nil,
  last_bufnr = nil,
  mark_id = 0,
  winid = nil,
  bufnr = nil,
  icon = "",
  history = {
    content = "",
    win_width = cfg.win_def_width,
  },
}

local_M.ns_id = api.nvim_create_namespace(local_M.ns_name)

local function check_ui_valid()
  if local_M.winid
      and api.nvim_win_is_valid(local_M.winid)
      and local_M.bufnr
      and api.nvim_buf_is_valid(local_M.bufnr) then
    return true
  else
    return false
  end
end

local function add_padding(content, icon, padding_len)
  return content .. string.rep(" ", padding_len) .. icon
end

local function adjust_win_width(content, icon)
  local win_width = api.nvim_win_get_width(local_M.winid)
  local content_len = displaywidth(content)
  local icon_len = displaywidth(icon)
  if (content_len + icon_len + 1 <= win_width) and (win_width <= cfg.win_def_width) then
    local padding_len = win_width - content_len - icon_len
    return add_padding(content, icon, padding_len)
  else
    api.nvim_win_set_width(local_M.winid, content_len + icon_len + 1)
    return content .. " " .. local_M.icon
  end
end

local function inlay_text(bufnr, line, text)
  local line_num = line
  local col_num = 1

  local opts = {
    end_line = line,
    id = 1,
    virt_text = { { text, local_M.ns_name .. "Lable"} },
    virt_text_pos = "eol",
  }

  local_M.mark_id = api.nvim_buf_set_extmark(bufnr, local_M.ns_id, line_num, col_num, opts)
end

local function search(value, forward)
  local pos = vim.fn.searchpos(value, forward)
  if pos[1] == 0 and pos[2] == 0 then
    -- can't find search keyword
    return;
  end

  pos[2] = pos[2] - 1
  local_M.last_winid = api.nvim_get_current_win()
  local_M.last_bufnr = vim.fn.bufnr("%")

  api.nvim_win_set_cursor(local_M.last_winid, pos)

  local idx_msg = vim.fn.searchcount({ maxcount = -1 })
  local cur_idx = idx_msg["current"]
  local max_idx = idx_msg["total"]
  local hint_text = "[" .. cur_idx .. "/" .. max_idx .. "]"
  if local_M.mark_id ~= 0 then
    api.nvim_buf_del_extmark(local_M.last_bufnr, local_M.ns_id, local_M.mark_id)
  end
  inlay_text(local_M.last_bufnr, pos[1] - 1, hint_text)
end

local function jump(forward)
  local value = vim.fn.getreg("/")
  if #value == 0 then
    return
  end

  vim.v.hlsearch = 1
  search(value, forward)
end

local function on_submit(value)
  vim.fn.setreg("/", value)
  vim.v.hlsearch = 1
  jump("n")
end

local function on_cancel()

end

local function on_change()

end

local function create_win()
  if check_ui_valid() then
    return
  end

  if not local_M.bufnr or api.nvim_buf_is_valid(local_M.bufnr) then
    local_M.bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_keymap(local_M.bufnr, "i", "<F9>", "", {
      callback = function()
        M.toggle_search_ui()
      end,
    })

    api.nvim_buf_set_keymap(local_M.bufnr, "i", "<Esc>", "", {
      callback = function()
        M.toggle_search_ui()
      end,
    })

    api.nvim_buf_set_keymap(local_M.bufnr, "i", "<Enter>", "", {
      callback = function()
        M.toggle_search_ui()
        on_submit(local_M.history.content)
      end,
    })
  end

  if vim.o.columns < cfg.win_def_width then
    vim.notify("win width too small.")
  end

  if vim.o.lines < 10 then
    vim.notify("win height too smalll")
  end

  local success, winid = pcall(api.nvim_open_win, local_M.bufnr, true, {
    title = "Search",
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
    api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, lines)

    -- if local_M.history.content == "" then
    --   local_M.history.content = vim.fn.expand("<cword>")
    -- end

    lines = { adjust_win_width(local_M.history.content, local_M.icon) }
    api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, lines)
    api.nvim_win_set_width(local_M.winid, local_M.history.win_width)

    api.nvim_win_set_hl_ns(local_M.winid, local_M.ns_id)
    local hl_grp = "Normal:" .. local_M.ns_name .. "Text,FloatBorder:" .. local_M.ns_name .. "Border,FloatTitle:" .. local_M.ns_name .. "Title"
    api.nvim_win_set_option(local_M.winid, "winhighlight", hl_grp)
    -- api.nvim_win_set_hl_ns(local_M.winid, local_M.ns_id)
  end

  local resize_grp = api.nvim_create_augroup(local_M.ns_name .. "Resize", { clear = true })
  api.nvim_create_autocmd("TextChangedI", {
    group = resize_grp,
    buffer = local_M.bufnr,
    callback = function(opts)
      local line_str = api.nvim_buf_get_lines(local_M.bufnr, 0, 1, false)[1]
      local array = vim.split(line_str, "%s", { trimempty = true })
      local first_word = array[1]

      -- only icons
      if #array == 0 then
        first_word = ""
      end

      -- update search ui
      local line = adjust_win_width(first_word, local_M.icon)
      api.nvim_buf_set_lines(local_M.bufnr, 0, -1, false, { line })

      local_M.history.content = first_word
      local_M.history.win_width = api.nvim_win_get_width(local_M.winid)
    end
  })

  local leave_grp = api.nvim_create_augroup(local_M.ns_name .. "Leave", { clear = true })
  api.nvim_create_autocmd("BufWinLeave", {
    group = leave_grp,
    callback = function(opts)
      api.nvim_del_augroup_by_id(leave_grp)
      api.nvim_del_autocmd(opts.id)
    end
  })
end

local function toggle_search_ui()
  if check_ui_valid() then
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    api.nvim_win_hide(local_M.winid)
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Right>", true, false, true), "n", true)
    return
  end

  create_win()
  api.nvim_feedkeys(api.nvim_replace_termcodes("i", true, false, true), "n", true)
end

local disable_search_label_grp = api.nvim_create_augroup("disable_search_label_grp", { clear = true })
api.nvim_create_autocmd({ "BufLeave", "InsertEnter" }, {
  group = disable_search_label_grp,
  callback = function()
    if local_M.mark_id ~= 0 then
      api.nvim_buf_del_extmark(local_M.last_bufnr, local_M.ns_id, local_M.mark_id)
      local_M.mark_id = 0
    end
  end,
})

function M.create_hl_group()
  api.nvim_set_hl(0, local_M.ns_name .. "Text", { bg = "NONE", fg = "#cc7722" })
  api.nvim_set_hl(0, local_M.ns_name .. "Border", { bg = "NONE", fg = "#445555" })
  api.nvim_set_hl(0, local_M.ns_name .. "Title", { bg = "NONE", fg = "#445555" })
  api.nvim_set_hl(0, local_M.ns_name .. "Lable", { bg = "NONE", fg = "#445555" })
end

function M.load_command()
  api.nvim_create_user_command("SearchUIToggle", function()
    toggle_search_ui()
  end, {})

  api.nvim_create_user_command("SearchNext", function()
    jump('n')
  end, {})

  api.nvim_create_user_command("SearchPrev", function()
    jump('b')
  end, {})
end

return M