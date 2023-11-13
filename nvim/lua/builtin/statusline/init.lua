local co, api = coroutine, vim.api
local whk = {}

local function stl_format(name, val)
  return '%#Whisky' .. name .. '#' .. val .. '%*'
end

local function stl_hl(name, attr)
  if not attr.bg then
    attr.bg = "NONE"
  end
  api.nvim_set_hl(0, "Whisky" .. name, attr)
end

local function default()
  local p = require("builtin.statusline.provider")
  local comps = {
    --
    p.space(),
    p.mode(),
    p.space(),
    p.fileicon(),
    p.fileinfo(),
    p.modified(),
    --
    p.pad(),
    p.lsp(),
    p.diagError(),
    p.diagWarn(),
    p.diagInfo(),
    p.diagHint(),
    p.pad(),
    --
    p.space(),
    p.gitadd(),
    p.gitchange(),
    p.gitdelete(),
    p.space(),
    p.branch(),
    --
    p.space(),
    p.lnumcol(),
    p.space(),
    p.encoding(),
    p.space(),
    p.eol(),
    p.space(),
    --
  }

  local e, pieces = {}, {}
  vim.iter(ipairs(comps))
    :map(function(key, item)
      if type(item.stl) == "string" then
        pieces[#pieces + 1] = stl_format(item.name, item.stl)
      else
        pieces[#pieces + 1] = item.default and stl_format(item.name, item.default) or ""
        for _, event in ipairs({ unpack(item.event or {}) }) do
          if not e[event] then
            e[event] = {}
          end
          e[event][#e[event] + 1] = key
        end
      end

      if item.attr and item.name then
        stl_hl(item.name, item.attr)
      end
    end)
    :totable()
  return comps, e, pieces
end

local function render(comps, events, pieces)
  return co.create(function(args)
    while true do
      local event = args.event == "User" and args.event .. " " .. args.match or args.event
      for _, idx in ipairs(events[event]) do
        pieces[idx] = stl_format(comps[idx].name, comps[idx].stl(args))
      end

      if #pieces[6] == 0 then
        pieces[6] = stl_format(comps[6].name, comps[6].stl(args))
      end

      vim.opt.stl = table.concat(pieces)
      args = co.yield()
    end
  end)
end

function whk.setup(opts)
  if opts then
    vim.notify("builtin statusline don't need any options")
    return
  end

  local comps, events, pieces = default()
  local stl_render = render(comps, events, pieces)
  for _, e in ipairs(vim.tbl_keys(events)) do
    local tmp = e
    local pattern
    if e:find("User") then
      pattern = vim.split(e, "%s")[2]
      tmp = "User"
    end

    api.nvim_create_autocmd(tmp, {
      pattern = pattern,
      callback = function(args)
        vim.schedule(function()
          local ok, res = co.resume(stl_render, args)
          if not ok then
            vim.notify("[Whisky] render failed " .. res, vim.log.levels.ERROR)
          end
        end)
      end,
    })
  end
end

return whk

