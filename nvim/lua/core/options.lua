-- set nvim basic options
local env = require("core.env")

-- common
vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.mouse          = "nv"
vim.opt.errorbells     = true
vim.opt.visualbell     = true
vim.opt.autoindent     = true
vim.opt.history        = 2000
vim.opt.laststatus     = 3
-- the cursor don't move to the first char when do command
vim.opt.startofline    = false
vim.opt.ambiwidth      = "single"
vim.opt.clipboard      = "unnamedplus"

-- syntax
vim.opt.syntax         = "enable"
vim.opt.synmaxcol      = 2500

-- encode
vim.opt.fileformat     = "unix"
vim.opt.fileformats    = "unix,mac,dos"
-- 内部使用的编码方式
vim.opt.encoding       = "utf-8"
-- 自动识别的字符编码
vim.opt.fileencodings  = "utf-8,gb2312,ucs-bom,gb18030,gbk,cp936"
-- 在保存文件时，指定编码
vim.opt.fileencoding   = "utf-8"

-- block, insert, all, onemore
vim.opt.virtualedit    = "block"
vim.opt.viewoptions    = "folds,cursor,curdir,slash,unix"

-- session
-- vim.opt.sessionoptions = "buffers,curdir,folds,envs,terminal,slash,unix,options,localoptions"
--vim.opt.shada          = "!,'300,<50,@100,s10,h"

-- cache file
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.swapfile       = false
vim.opt.undofile       = true
vim.opt.directory      = env:join_path(env.cache_home, "swap")
vim.opt.undodir        = env:join_path(env.cache_home, "undo")
vim.opt.backupdir      = env:join_path(env.cache_home, "backup")
vim.opt.viewdir        = env:join_path(env.cache_home, "view")
vim.opt.spellfile      = env:join_path(env.cache_home, "spell", "en.uft-8.add")
vim.opt.backupskip     = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
-- the time of reflash swap file
vim.opt.updatetime     = 100

-- code timeout
vim.opt.timeout        = true
vim.opt.ttimeout       = true
vim.opt.timeoutlen     = 500
vim.opt.ttimeoutlen    = 10

-- tab
vim.opt.smarttab       = true
vim.opt.shiftround     = true
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 4
vim.opt.tabstop        = 4
vim.opt.softtabstop    = -1

-- buffer & tab bar & statusline
-- vim.opt.showtabline    = 4;
vim.opt.showmode       = false
vim.opt.showcmd        = false
vim.opt.ruler          = false
vim.opt.switchbuf      = "useopen"
vim.opt.colorcolumn    = "80"

-- win size
vim.opt.winwidth       = 30
vim.opt.winminwidth    = 10
vim.opt.winblend       = 10
vim.opt.pumheight      = 15
vim.opt.pumblend       = 10
vim.opt.helpheight     = 12
vim.opt.previewheight  = 12

-- editor
vim.opt.hidden         = true
vim.opt.autoread       = true
vim.opt.showmatch      = true
vim.opt.backspace      = "indent,eol,start"
vim.opt.diffopt        = "filler,iwhite,internal,algorithm:patience"
vim.opt.formatoptions  = "1jcroql"

-- fold
vim.opt.foldenable     = true
vim.opt.foldlevelstart = 99

-- search
vim.opt.incsearch      = true
vim.opt.wrapscan       = true
vim.opt.smartcase      = true
vim.opt.ignorecase     = true
-- 除了$、.、*、^、[ ]外其他正则表达式的符号需要加\转义
vim.opt.magic          = true
vim.opt.hlsearch       = true

-- cursor highlight
vim.opt.cursorline     = true
vim.opt.cursorcolumn   = false

-- complete
vim.opt.complete       = ".,w,b,k"
vim.opt.completeopt    = "menu,menuone,noselect"
vim.opt.inccommand     = "nosplit"

-- command mode complete
vim.opt.wildmenu       = true
--vim.opt.wildmode       = "longest:list,full"
vim.opt.infercase      = true
vim.opt.wildignorecase = true
vim.opt.wildignore     = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"

-- grep
if vim.fn.executable('rg') == 1 then
  vim.opt.grepformat   = "%f:%l:%c:%m"
  vim.opt.grepprg      = 'rg --hidden --vimgrep --smart-case --'
end

-- scrolloff
vim.opt.scrolloff      = 2
vim.opt.sidescrolloff  = 5

-- wrap
vim.opt.textwidth      = 0
vim.opt.showbreak      = "↳  "
vim.opt.wrap           = true
vim.opt.linebreak      = true
vim.opt.breakat        = [[\ \	;:,!?]]
vim.opt.whichwrap      = "h,l"
vim.opt.breakindent    = true
vim.opt.breakindentopt = "shift:4,min:20"

-- list
vim.opt.list           = true
vim.opt.listchars      = "tab:»·,nbsp:+,space: ,trail:·,extends:→,precedes:←"
vim.opt.fillchars      = "eob: "

-- conceal
vim.opt.conceallevel   = 0
vim.opt.concealcursor  = "niv"

-- pane split
vim.opt.equalalways    = false
vim.opt.splitbelow     = true
vim.opt.splitright     = true

-- command height
vim.opt.cmdheight      = 0
vim.opt.cmdwinheight   = 5

-- other
vim.opt.redrawtime     = 1500;
vim.opt.display        = "lastline"
vim.opt.jumpoptions    = "stack"
vim.opt.shortmess      = "aoOTIcF"
vim.opt.signcolumn     = "yes"

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

