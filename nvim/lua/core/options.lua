local env = require("core.env")
local api = vim.api
local opt = vim.opt

-- leader
vim.g.mapleader = ","

-- disable some plugins
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
-- vim.g.loaded_netrwSettings = 1
-- vim.g.loaded_netrwFileHandlers = 1

-- common
opt.termguicolors  = true
opt.number         = true
opt.mouse          = "nv"
opt.errorbells     = true
opt.visualbell     = true
opt.autoindent     = true
opt.history        = 2000
opt.laststatus     = 3
-- the cursor don't move to the first char when do command
opt.startofline    = false
opt.ambiwidth      = "single"
opt.clipboard      = "unnamedplus"
opt.virtualedit    = "block"

-- syntax
opt.syntax         = "enable"
opt.synmaxcol      = 2500

-- encode
opt.fileformat     = "unix"
opt.fileformats    = "unix,mac,dos"
-- 内部使用的编码方式
opt.encoding       = "utf-8"
-- 自动识别的字符编码
opt.fileencodings  = "utf-8,gb2312,ucs-bom,gb18030,gbk,cp936"
-- 在保存文件时，指定编码
opt.fileencoding   = "utf-8"

-- cache file
opt.backup         = false
opt.writebackup    = false
opt.swapfile       = false
opt.undofile       = true
opt.directory      = env:join_path(env.cache_home, "swap")
opt.undodir        = env:join_path(env.cache_home, "undo")
opt.backupdir      = env:join_path(env.cache_home, "backup")
opt.viewdir        = env:join_path(env.cache_home, "view")
opt.spellfile      = env:join_path(env.cache_home, "spell", "en.uft-8.add")
-- the time of reflash swap file
opt.updatetime     = 100

-- code timeout
opt.timeout        = true
opt.ttimeout       = true
opt.timeoutlen     = 500
opt.ttimeoutlen    = 10

-- tab
opt.smarttab       = true
opt.shiftround     = true
opt.expandtab      = true
opt.shiftwidth     = 4
opt.tabstop        = 4
opt.softtabstop    = -1

-- buffer & tab bar & statusline
-- opt.showtabline    = 4;
opt.showmode       = false
opt.showcmd        = false
opt.ruler          = false
opt.switchbuf      = "useopen"
-- opt.colorcolumn    = "100"

-- win size
opt.winwidth       = 30
opt.winminwidth    = 10
opt.winblend       = 10
opt.pumheight      = 15
opt.pumblend       = 10
opt.helpheight     = 12
opt.previewheight  = 12

-- editor
opt.hidden         = true
opt.autoread       = true
opt.showmatch      = true
opt.backspace      = "indent,eol,start"
opt.diffopt        = "filler,iwhite,internal,algorithm:patience"

-- fold
opt.foldenable     = true
opt.foldlevelstart = 99

-- search
opt.incsearch      = true
opt.wrapscan       = true
opt.smartcase      = true
opt.ignorecase     = true
-- 除了$、.、*、^、[ ]外其他正则表达式的符号需要加\转义
opt.magic          = true
opt.hlsearch       = true

-- cursor highlight
opt.cursorline     = true
opt.cursorcolumn   = false

-- complete
opt.complete       = ".,w,b,k"
opt.completeopt    = "menu,menuone,noselect"
opt.inccommand     = "nosplit"

-- command mode complete
opt.wildmenu       = true
opt.infercase      = true
opt.wildignorecase = true
opt.wildignore     = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"

-- grep
if vim.fn.executable('rg') == 1 then
  opt.grepformat   = "%f:%l:%c:%m"
  opt.grepprg      = 'rg --hidden --vimgrep --smart-case --'
end

-- scrolloff
opt.scrolloff      = 2
opt.sidescrolloff  = 5

-- wrap
opt.textwidth      = 0
opt.showbreak      = "↳  "
opt.wrap           = true
opt.linebreak      = true
opt.breakat        = [[\ \	;:,!?]]
opt.whichwrap      = "h,l"
opt.breakindent    = true
opt.breakindentopt = "shift:4,min:20"

-- list
opt.list           = true
opt.listchars      = "tab:»·,nbsp:+,space: ,trail:·,extends:→,precedes:←"
opt.fillchars      = "eob: "

-- conceal
opt.conceallevel   = 0
opt.concealcursor  = "niv"

-- pane split
opt.equalalways    = false
opt.splitbelow     = true
opt.splitright     = true

-- command height
opt.cmdheight      = 0
opt.cmdwinheight   = 5

-- other
opt.redrawtime     = 1500;
opt.display        = "lastline"
opt.signcolumn     = "yes"

if vim.loop.os_uname().sysname == 'Darwin' then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0
  }
  -- vim.g.python_host_prog = '/usr/bin/python'
  -- vim.g.python3_host_prog = '/usr/local/bin/python3'
elseif vim.loop.os_uname().sysname == 'Windows_NT' then
  if vim.fn.executable('win32yank') == 1 then
    vim.g.clipboard = {
      name = "win32yank",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
      cache_enabled = 0
    }
  end
else
  -- vim.g.python_host_prog = '/usr/bin/python'
  -- vim.g.python3_host_prog = '/usr/local/bin/python3'
end

local function get_signs(name)
  return function()
    local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local it = vim
      .iter(api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, { details = true, type = "sign" }))
      :find(function(item)
        return item[2] == vim.v.lnum - 1
          and item[4].sign_hl_group
          and item[4].sign_hl_group:find(name)
      end)
    return not it and "  " or ("%%#%s#%s%%*"):format(it[4].sign_hl_group, it[4].sign_text)
  end
end

function _G.show_stc()
  local stc_diagnostic = get_signs("Diagnostic")
  local stc_gitsign = get_signs("GitSign")

  local function show_break()
    if vim.v.virtnum > 0 then
      return (" "):rep(math.floor(math.ceil(math.log10(vim.v.lnum))) - 1) .. "↳"
    elseif vim.v.virtnum < 0 then
      return ""
    else
      return vim.v.lnum
    end
  end
  return ('%s%%=%s%s'):format(stc_diagnostic(), show_break(), stc_gitsign())
end

vim.opt.stc = "%!v:lua.show_stc()"

