local co, api, iter = coroutine, vim.api, vim.iter
local p, hl = require("builtin.statusline.provider"), api.nvim_set_hl

local function stl_format(name, val)
  return ('%%#ModeLine%s#%s%%*'):format(name, val)
end

local function default()
  local comps = {
    p.mode(),
    p.space(),
    -- p.encoding(),
    -- p.eol(),
    -- [[%{(&modified&&&readonly?'%*':(&modified?'**':(&readonly?'%%':'--')))}  ]],
    -- p.fileinfo(),
    p.fileicon(),
    p.fileinfo(),
    p.modified(),
    -- '   %P   (L%l,C%c)  ',
    -- ' %=',
    -- [[ %{!empty(bufname()) ? '(' : ''}]],
    -- '%{!empty(&filetype) ? toupper(strpart(&filetype, 0, 1)) . strpart(&filetype, 1) : toupper(strpart(&buftype, 0, 1)) . strpart(&buftype, 1)}',
    -- [[%{!empty(bufname()) ? ')' : ''}]],
    p.pad(),
    p.lsp(),
    p.progress(),
    p.space(),
    p.diagnostic(),
    p.pad(),
    p.gitinfo(),
    p.space(),
    p.lnumcol(),
    p.space(),
    p.encoding(),
    p.space(),
    p.eol(),
    -- '%=%=',
  }

  local e, pieces, hls = {}, {}, {}
  iter(ipairs(comps)):map(function(key, item)
    if type(item) == 'string' then
      pieces[#pieces + 1] = item
    elseif type(item.stl) == 'string' then
      pieces[#pieces + 1] = stl_format(item.name, item.stl)
    else
      pieces[#pieces + 1] = item.default and stl_format(item.name, item.default) or ''
      for _, event in ipairs({ unpack(item.event or {}) }) do
        e[event] = e[event] or {}
        e[event][#e[event] + 1] = key
      end
    end

    if item.attr and item.name then
      local hl_attr = {}
      local hl_def = {}
      local all_comm = true
      for attr_k, attr_v in pairs(item.attr) do
        hl_attr[attr_k] = attr_v
        hl_def[attr_k] = attr_v
        if (type(attr_v) == "function") then
          all_comm = false
          hl_def[attr_k] = attr_v()
        end
      end

      if item.attr["bg"] then
        hl_attr["bg"] = "None"
        hl_def["bg"] = "None"
      end

      hl(0, ('ModeLine%s'):format(item.name), hl_def)

      if not all_comm then
        hls[("ModeLine%s"):format(item.name)] = hl_attr
      end
    end
  end):totable()

  return comps, e, pieces, hls
end

local function render(comps, events, pieces, hls)
  return co.create(function(args)
    while true do
      local event = args.event == 'User' and ('%s %s'):format(args.event, args.match) or args.event
      for _, idx in ipairs(events[event]) do
        if comps[idx].async then
          local child = comps[idx].stl()
          coroutine.resume(child, pieces, idx)
        else
          pieces[idx] = stl_format(comps[idx].name, comps[idx].stl(args))
          if hls[("ModeLine%s"):format(comps[idx].name)] then
            local hl_attr = {}
            for attr_k, attr_v in pairs(comps[idx].attr) do
              if (type(attr_v) == "function") then
                hl_attr[attr_k] = attr_v()
              else
                hl_attr[attr_k] = attr_v
              end
            end
            hl(0, ('ModeLine%s'):format(comps[idx].name), hl_attr)
          end
        end
      end
      vim.opt.stl = table.concat(pieces)
      args = co.yield()
    end
  end)
end

return {
  setup = function()
    local comps, events, pieces, hls = default()
    local stl_render = render(comps, events, pieces, hls)
    iter(vim.tbl_keys(events)):map(function(e)
      local tmp = e
      local pattern
      if e:find('User') then
        pattern = vim.split(e, '%s')[2]
        tmp = 'User'
      end
      api.nvim_create_autocmd(tmp, {
        pattern = pattern,
        callback = function(args)
          vim.schedule(function()
            local ok, res = co.resume(stl_render, args)
            if not ok then
              vim.notify('[ModeLine] render failed ' .. res, vim.log.levels.ERROR)
            end
          end)
        end,
      })
    end)
  end,
}