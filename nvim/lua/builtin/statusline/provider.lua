local api, uv, lsp = vim.api, vim.uv, vim.lsp
local pd = {}

local function get_stl_bg()
  return "NONE"
end

local stl_bg
if not stl_bg then
  stl_bg = get_stl_bg()
end

local function stl_attr(group, trans)
  local color = api.nvim_get_hl(0, { name = group, link = false })
  trans = trans or false
  return {
    bg = "NONE",
    fg = color.fg,
  }
end

local function alias_mode()
  return {
    ['n'] = 'Normal',
    ['no'] = 'O-Pending',
    ['nov'] = 'O-Pending',
    ['noV'] = 'O-Pending',
    ['no\x16'] = 'O-Pending',
    ['niI'] = 'Normal',
    ['niR'] = 'Normal',
    ['niV'] = 'Normal',
    ['nt'] = 'Normal',
    ['ntT'] = 'Normal',
    ['v'] = 'Visual',
    ['vs'] = 'Visual',
    ['V'] = 'V-Line',
    ['Vs'] = 'V-Line',
    ['\x16'] = 'V-Block',
    ['\x16s'] = 'V-Block',
    ['s'] = 'Select',
    ['S'] = 'S-Line',
    ['\x13'] = 'S-Block',
    ['i'] = 'Insert',
    ['ic'] = 'Insert',
    ['ix'] = 'Insert',
    ['R'] = 'Replace',
    ['Rc'] = 'Replace',
    ['Rx'] = 'Replace',
    ['Rv'] = 'V-Replace',
    ['Rvc'] = 'V-Replace',
    ['Rvx'] = 'V-Replace',
    ['c'] = 'Command',
    ['cv'] = 'Ex',
    ['ce'] = 'Ex',
    ['r'] = 'Replace',
    ['rm'] = 'More',
    ['r?'] = 'Confirm',
    ['!'] = 'Shell',
    ['t'] = 'Terminal',
  }
end

function pd.mode()
  local alias = alias_mode()
  local result = {
    stl = function()
      local mode = api.nvim_get_mode().mode
      return alias[mode] or alias[string.sub(mode, 1, 1)] or "UNK"
    end,
    name = "mode",
    default = "Normal",
    event = { "ModeChanged" },
    attr = stl_attr("Constant")
  }
  return result
end

local function path_sep()
  return uv.os_uname().sysname == "Windows_NT" and "\\" or "/"
end

local ok, devicon = pcall(require, "nvim-web-devicons")
local icon, color
function pd.fileicon()
  return {
    stl = function()
      if ok then
        icon, color = devicon.get_icon_color_by_filetype(vim.bo.filetype, { default = true })
        api.nvim_set_hl(0, "Whiskyfileicon", { bg = stl_bg, fg = color })
        return icon .. " "
      else
        ok, devicon = pcall(require, "nvim-web-devicons")
      end
      return ""
    end,
    name = "fileicon",
    event = { "BufEnter" },
    attr = {}
  }
end

function pd.fileinfo()
  local result = {
    stl = "%t",
    name = "fileinfo",
    event = { "BufEnter" },
    attr = {}
  }
  return result
end

function pd.modified()
  local result = {
    stl = "%m",
    name = "filemodified",
    event = { "BufModifiedSet" },
    attr = {}
  }
  return result
end

function pd.lsp()
  local function lsp_stl(args)
    local client = lsp.get_client_by_id(args.data.client_id)
    local msg = client and client.name or ''
    if args.data.result then
      local val = args.data.result.value
      msg = val.title
        .. ' '
        .. (val.message and val.message .. ' ' or '')
        .. (val.percentage and val.percentage .. '%' or '')
      if not val.message or val.kind == 'end' then
        ---@diagnostic disable-next-line: need-check-nil
        msg = client.name
      end
    elseif args.event == 'LspDetach' then
      msg = ''
    end
    return '%.40{"' .. " " .. msg .. '"}'
  end

  local result = {
    stl = lsp_stl,
    name = "Lsp",
    event = { "LspProgress", "LspAttach", "LspDetach" },
    attr = {
      fg = "#a195c5",
    }
  }
  return result
end

local function gitsigns_data(bufnr, type)
  local ok, dict = pcall(api.nvim_buf_get_var, bufnr, "gitsigns_status_dict")
  if not ok or vim.tbl_isempty(dict) or not dict[type]then
    return 0
  end

  return dict[type]
end

local function git_icons(type)
  local tbl = {
    ["added"] = " ",
    ["changed"] = " ",
    ["deleted"] = " ",
  }
  return tbl[type]
end

function pd.gitadd()
  local result = {
    stl = function(args)
      local res = gitsigns_data(args.buf, "added")
      return res > 0 and git_icons("added") .. res or ""
    end,
    name = "gitadd",
    event = { "User GitSignsUpdate", "BufEnter" },
    attr = {
      fg = "#9987ce"
    }
  }
  return result
end

function pd.gitchange()
  local result = {
    stl = function(args)
      local res = gitsigns_data(args.buf, "changed")
      return res > 0 and git_icons("changed") .. res or ""
    end,
    name = "gitchange",
    event = { "User GitSignsUpdate", "BufEnter" },
    attr = {
      fg = "#9987ce"
    }
  }
  return result
end

function pd.gitdelete()
  local result = {
    stl = function(args)
      local res = gitsigns_data(args.buf, "removed" )
      return res > 0 and git_icons("deleted") .. res or ""
    end,
    name = "gitdelete",
    event = { "User GitSignsUpdate", "BufEnter" },
    attr = {
      fg = "#9987ce"
    }
  }
  return result
end

function pd.branch()
  local icon = " "
  local result = {
    stl = function(args)
      local res = gitsigns_data(args.buf, "head")
      return res and icon .. res or "UNKOWN"
    end,
    name = "gitbranch",
    event = { "User GitSignsUpdate" },
    attr = {
      fg = "#7898e1",
    },
  }
  return result
end

function pd.lnumcol()
  local result = {
    stl = "%-4.(%l:%c%) %P",
    name = "linecol",
    event = { "CursorHold" },
    attr = {
      fg = "#CDCDCD",
    },
  }
  return result
end

local function diagnostic_info(severity)
  if vim.diagnostic.is_disabled(0) then
    return ""
  end
  local count = #vim.diagnostic.get(0, { severity = severity })
  return count == 0 and "" or "⏶" .. tostring(count) .. " "
end

function pd.diagError()
  local result = {
    stl = function()
      return diagnostic_info(1)
    end,
    name = "diagError",
    event = { "DiagnosticChanged", "BufEnter" },
    attr = stl_attr("DiagnosticError")
  }
  return result
end

function pd.diagWarn()
  local result = {
    stl = function()
      return diagnostic_info(2)
    end,
    name = "diagWarn",
    event = { "DiagnosticChanged", "BufEnter" },
    attr = stl_attr("DiagnosticWarn")
  }
  return result
end

function pd.diagInfo()
  local result = {
    stl = function()
      return diagnostic_info(3)
    end,
    name = "diaginfo",
    event = { "DiagnosticChanged", "BufEnter" },
    attr = stl_attr("DiagnosticInfo"),
  }
  return result
end

function pd.diagHint()
  local result = {
    stl = function()
      return diagnostic_info(4)
    end,
    name = "diaghint",
    event = { "DiagnosticChanged", "BufEnter" },
    attr = stl_attr("DiagnosticHint")
  }
  return result
end

function pd.eol()
  return {
    name = "eol",
    stl = path_sep() == "/" and "LF" or "CRLF",
    event = { "BufEnter" },
    attr = {
      fg = "#CDCDCD",
    },
  }
end

function pd.encoding()
  local result = {
    stl = function()
      local bufnr = api.nvim_get_current_buf()
      if api.nvim_buf_is_valid(bufnr) then
        return tostring(vim.bo[bufnr].fileencoding)
      end

      return "%{&fileencoding?&fileencoding:&encoding}"
    end,
    name = "filencode",
    event = { "BufEnter", "FileChangedRO", "ModeChanged" },
    attr = {
      fg = "#CDCDCD",
    }
  }
  return result
end

function pd.pad()
  return {
    stl = "%=",
    name = "pad",
    attr = {}
  }
end

function pd.space()
  return {
    stl = " ",
    name = "space",
    attr = {}
  }
end

return pd

