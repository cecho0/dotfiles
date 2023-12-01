local env = require("core.env")
local util = require("builtin.sessions.util")
local M = {}

local function session_delete(session)
  if not session or #session == 0 then
    -- delete all sessions
    local session_list = util.get_session_list()
    for _, v in ipairs(session_list) do
      vim.fn.delete(v)
    end

    vim.v.this_session = ""
    vim.notify("SessionDelete Done")
    return
  end

  if not util.check_session_valid(session) then
    vim.notify("Session Unvalid")
    return
  end

  if vim.v.this_session and vim.v.this_session == session then
    vim.v.this_session = ""
  end

  -- delete provided session
  local filename = util.get_full_encode(session)
  vim.fn.delete(filename)
  vim.notify("SessionDelete Done")
end

local function session_save(session)
  local session_name = nil
  local this_session_tmp = nil
  if not session or #session == 0 then
    if vim.v.this_session and #vim.v.this_session ~= 0 then
      -- use current session name
      session_name = util.get_full_encode(vim.v.this_session)
      this_session_tmp = vim.v.this_session
    else
      -- use default session name
      this_session_tmp = util.get_encode(vim.g.main_file)
      session_name = util.get_full_encode(this_session_tmp)
    end
  else
    -- use provided session name
    if vim.v.this_session and #vim.v.this_session ~= 0 then
      vim.fn.delete(util.get_full_encode(vim.v.this_session))
    end
    this_session_tmp = session
    session_name = util.get_full_encode(session)
  end

  util.save_buffers()
  vim.cmd(("%s %s"):format("mksession!", vim.fn.fnameescape(session_name)))
  vim.v.this_session = this_session_tmp
  vim.notify("Session Saved")
end

local function session_load(session)
  if not session or #session == 0 then
    vim.notify("SessionLoad Must Provide A Session")
    return
  end

  if not util.check_session_valid(session) then
    vim.notify("Session Unvalid")
    return
  end

  -- only from a session switch to another session will toggle
  if vim.v.this_session and #vim.v.this_session ~= 0 then
    -- if exist, first save session and delete buffers
    session_save()
  end

  vim.cmd("silent! %bwipeout!")
  -- pcall(vim.cmd, "silent! %bwipeout!")

  local session_file = util.get_full_encode(session)
  vim.cmd(("silent! source %s"):format(vim.fn.fnameescape(session_file)))
  vim.v.this_session = session
  vim.notify("Session Loaded")
end

local function session_rename(old_session, new_session)
  if not old_session
      or #old_session == 0
      or not new_session
      or #new_session == 0
  then
    vim.notify("SessionRename Must Provide Old And New Sessions")
    return
  end

  if not util.check_session_valid(old_session) then
    vim.notify("Session Unvalid")
    return
  end

  if vim.tbl_contains(util.get_session_list(), util.get_full_encode(new_session)) then
    vim.notify("Session Already Exist")
    return
  end

  if vim.v.this_session == old_session then
    vim.v.this_session = new_session
  end

  vim.fn.rename(util.get_full_encode(old_session), util.get_full_encode(new_session))
  vim.notify("SessionRename Done")
end

local function session_new_project(project, session)
  if not project or #project == 0 or not util.file_is_readable(project) then
    vim.notify("Project Unvalid")
    return
  end

  local new_session = nil
  if session and #session ~= 0 then
    if vim.tbl_contains(util.get_session_list(), util.get_full_encode(session)) then
      vim.notify("Session Already Exist")
      return
    end
    new_session = session
  else
    new_session = util.get_encode(vim.g.main_file)
  end

  vim.g.project = vim.fn.resolve(vim.fn.fnamemodify(project, ":p:h"))
  vim.g.main_file = vim.fn.resolve(vim.fn.fnamemodify(project, ":p" ))

  if vim.v.this_session and #vim.v.this_session ~= 0 then
    session_save()
  end

  vim.cmd("silent! %bwipeout")
  vim.v.this_session = new_session
  vim.fn.chdir(vim.g.project)
  vim.cmd(("edit %s"):format(project))
  vim.notify("Create Project Done")
end

local function edit_config()
  local file = env:join_path(env.config_home, "init.lua")
  local session = "NvimConfig"
  if util.file_is_readable(util.get_full_encode(session)) then
    session_load(session)
    return
  end

  if vim.v.this_session and #vim.v.this_session ~= 0 then
    session_save()
    vim.cmd("silent! %bwipeout")
  end

  vim.g.project = vim.fs.dirname(file)
  vim.g.main_file = file
  vim.v.this_session = session
  vim.fn.chdir(vim.g.project)

  vim.cmd(("edit %s"):format(file))
  vim.notify("Create Neovim Configuration Done")
end

function M.create_usercmd()
  -- session delete
  vim.api.nvim_create_user_command("SessionDelete", function(args)
    session_delete(args.args)
  end, {
    nargs = "?",
    complete = util.get_complete_list,
  })

  -- session save
  vim.api.nvim_create_user_command("SessionSave", function(args)
    session_save(args.args)
  end, {
    nargs = "?",
    complete = util.get_complete_list,
  })

  -- session load
  vim.api.nvim_create_user_command("SessionLoad", function(args)
    session_load(args.args)
  end, {
    nargs = "?",
    complete = util.get_complete_list,
  })

  -- session rename
  vim.api.nvim_create_user_command("SessionRename", function(args)
    local arg_list = vim.split(args.args, " ", { trimempty = true } )
    session_rename(arg_list[1], arg_list[2])
  end, {
    nargs = "?",
    complete = util.get_complete_list,
  })

  -- session new project
  vim.api.nvim_create_user_command("SessionNewProject", function(args)
    local arg_list = vim.split(args.args, " ", { trimempty = true } )
    session_new_project(arg_list[1], arg_list[2])
  end, {
    nargs = "?",
    complete = "file",
  })

  -- edit nvim config
  vim.api.nvim_create_user_command("EditConfig", function()
    edit_config()
  end, {})
end

function M.create_autocmd()
  local LoadSessGrp = vim.api.nvim_create_augroup("LoadSess", { clear = true })
  local SaveSessGrp = vim.api.nvim_create_augroup("SaveSess", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = LoadSessGrp,
    pattern = "*",
    once = true,
    callback = function()
      vim.g.project = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand("%:p"), ":p:h"))
      vim.g.root = vim.uv.cwd()
      vim.g.main_file = vim.fn.resolve(vim.fn.expand("%:p"))

      vim.fn.chdir(vim.g.project)

      local session = util.get_encode(vim.g.main_file)
      -- no target file
      if not session or #session == 0 then
        return
      end

      if util.file_is_readable(util.get_full_encode(session)) then
        session_load(session)
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = SaveSessGrp,
    pattern = "*",
    once = true,
    callback = function()
      if not vim.v.this_session or #vim.v.this_session == 0 then
        return
      end

      session_save()
      vim.fn.chdir(vim.g.root)
    end
  })
end

return M

