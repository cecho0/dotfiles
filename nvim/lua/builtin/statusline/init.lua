local co, api = coroutine, vim.api
local whk = {}

local function stl_format(name, val)
  return '%#Whisky' .. name .. '#' .. val .. '%*'
end

local function stl_hl(name, attr)
  api.nvim_set_hl(0, "Whisky" .. name, attr)
end

local function default()
  local p = require("builtin.statusline.provider")
  local s = require("builtin.statusline.seperator")
  return {
    --
    s.l_left,
    p.mode,
    s.l_right,

    s.l_left,
    p.fileicon,
    p.fileinfo,
    s.l_right,

    --
    s.sep,
    p.lsp,
    -- p.pad,
    -- p.diagError,
    -- p.diagWarn,
    p.diagInfo,
    p.diagHint,
    -- p.pad,
    s.sep,
    --

    s.r_left,
    p.gitadd,
    p.gitchange,
    p.gitdelete,
    p.branch,
    s.r_right,

    s.l_left,
    p.lnumcol,
    s.l_right,
    p.lineend,
    --
    s.r_left,
    p.encoding,
    s.r_right,
  }
end

local function whk_init(event, pieces)
  whk.cache = {}
  for i, e in ipairs(whk.elements) do
    local res = e()

    if res.event and vim.tbl_contains(res.event, event) then
      local val = type(res.stl) == "function" and res.stl() or res.stl
      pieces[#pieces + 1] = stl_format(res.name, val)
    elseif type(res.stl) == "string" then
      pieces[#pieces + 1] = stl_format(res.name, res.stl)
    else
      pieces[#pieces + 1] = stl_format(res.name, "")
    end

    if res.attr then
      stl_hl(res.name, res.attr)
    end

    whk.cache[i] = {
      event = res.event,
      name = res.name,
      stl = res.stl,
    }
  end
  require("builtin.statusline.provider").initialized = true
  return table.concat(pieces, '')
end

local stl_render = co.create(function(event)
  local pieces = {}
  while true do
    if not whk.cache then
      whk_init(event, pieces)
    else
      for i, item in ipairs(whk.cache) do
        if item.event and vim.tbl_contains(item.event, event) and type(item.stl) == "function" then
          local comp = whk.elements[i]
          local res = comp()
          if res.attr then
            stl_hl(item.name, res.attr)
          end
          pieces[i] = stl_format(item.name, res.stl(event))
        end
      end
    end
    vim.opt.stl = table.concat(pieces)
    event = co.yield()
  end
end)

function whk.setup(opts)
  if opts then
    vim.notify("builtin statusline don't need any options")
    return
  end

  whk.bg = "NONE"
  whk.elements = default()

  api.nvim_create_autocmd({ 'User' }, {
    pattern = { 'LspProgressUpdate', 'GitSignsUpdate' },
    callback = function(arg)
      vim.schedule(function()
        co.resume(stl_render, arg.match)
      end)
    end,
  })

  local events =
    { 'DiagnosticChanged', 'ModeChanged', 'BufEnter', 'BufWritePost', 'LspAttach', 'LspDetach', "FileChangedRO" }
  api.nvim_create_autocmd(events, {
    callback = function(arg)
      vim.schedule(function()
        co.resume(stl_render, arg.event)
      end)
    end,
  })
end

return whk
