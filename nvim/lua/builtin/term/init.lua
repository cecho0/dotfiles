local api = vim.api
local M = {}
local local_M = {
  ns_name = "Term",
  winid = nil,
  bufnr = nil,
  jobid = nil,
}

local function get_max_width()
  local columns = vim.o.columns
  return math.floor(columns * 0.8 )
end

local function get_max_height()
  local lines = vim.o.lines

  return math.floor(lines * 0.8)
end

local function get_cmd()
  if vim.uv.os_uname().sysname == "Windows_NT" then
    if vim.fn.executable("nu.exe") == 1 then
      return "nu.exe"
    else
      return "cmd.exe"
    end
  else
    return os.getenv("SHELL")
  end
end

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

local function delete_win()
  if local_M.winid and api.nvim_win_is_valid(local_M.winid) then
    api.nvim_win_close(local_M.winid, { force = true })
  end

  if local_M.bufnr and api.nvim_buf_is_valid(local_M.bufnr) then
    api.nvim_buf_delete(local_M.bufnr, { force = true })
  end

  local_M.winid = nil
  local_M.bufnr = nil
end

local function create_win()
  -- check if winid and bufnr already exist, don't create a new window
  if check_ui_valid() then
    return
  end

  if not local_M.bufnr or not api.nvim_buf_is_valid(local_M.bufnr) then
    local_M.bufnr = api.nvim_create_buf(false, true)
  end

  local success, winid = pcall(api.nvim_open_win, local_M.bufnr, true, {
    focusable = false,
    style = "minimal",
    border = "single",
    noautocmd = true,
    relative = "editor",
    anchor = "SE",
    width = get_max_width(),
    height = get_max_height(),
    row = math.floor(vim.o.lines * 0.9),
    col = math.floor(vim.o.columns * 0.9),
    zindex = 200,
  })

  if not success then
    return
  end

  local_M.winid = winid
  api.nvim_win_set_option(local_M.winid, "winblend", 0)

  if not local_M.jobid then
    local_M.jobid = vim.fn.termopen(get_cmd(), {
      on_exit = function()
      end
    })
    vim.cmd("startinsert!")
  end

  local close_grp = api.nvim_create_augroup(local_M.ns_name .. "Close", { clear = true })
  local resize_grp = api.nvim_create_augroup(local_M.ns_name .. "Resize", { clear = true })
  local resize_cmd = api.nvim_create_autocmd({"VimResized"}, {
    group = resize_grp,
    buffer = local_M.bufnr,
    nested = true,
    callback = function(opts)
      api.nvim_win_hide(local_M.winid)
      local_M.winid = nil
      create_win()
    end
  })

  api.nvim_create_autocmd({"QuitPre"}, {
    group = close_grp,
    buffer = local_M.bufnr,
    nested = true,
    callback = function(opts)
      vim.fn.jobstop(local_M.jobid)
      local_M.jobid = nil
      delete_win()

      api.nvim_del_augroup_by_id(resize_grp)
      api.nvim_del_augroup_by_id(close_grp)
      api.nvim_del_autocmd(opts.id)
      api.nvim_del_autocmd(resize_cmd)
    end
  })
end

local function toggle_term()
  if check_ui_valid() then
    api.nvim_win_hide(local_M.winid)
    local_M.winid = nil
  else
    create_win()
  end
end

local function load_command(keymap)
  api.nvim_create_user_command("TermToggle", function()
      toggle_term()
  end, {})

  api.nvim_set_keymap("n", keymap, "<CMD>TermToggle<CR>", {
    noremap = true,
    silent = true,
    expr = false,
    nowait = false,
  })

  api.nvim_set_keymap("t", keymap, "<CMD>TermToggle<CR>", {
    noremap = true,
    silent = true,
    expr = false,
    nowait = false,
  })
end

function M.setup()
  load_command("<A-d>")
end

return M

