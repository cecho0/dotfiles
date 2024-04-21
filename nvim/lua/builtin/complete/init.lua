local api = vim.api
local M = {}
vim.opt.completeopt = "menu,menuone,noselect"

vim.cmd[[
"tab complete

" function! OpenNoLSPCompletion()
"     if v:char =~ '[A-Za-z_]' && !pumvisible() 
"         call feedkeys("\<C-n>", "n")
"     endif
" endfunction
"
" function! OpenFilePathCompletion()
"     if v:char =~ '[/]' && !pumvisible()
"         call feedkeys("\<C-x>\<C-f>", "n")
"     endif
" endfunction

function! EnterSelect()
  if pumvisible()
    return "\<c-y>"
  endif
  return "\<CR>"
endfunction

function! InsertTabWrapper(direction)
  if pumvisible()
    if a:direction == "forward"
      return "\<c-n>"
    else
      return "\<c-p>"
    endif
  endif

  let col = col('.') - 1
  if !col || getline('.')[col - 1] =~ '^\s*$'
    return "\<tab>"
  elseif getline(".")[col - 1] == "/"
    return "\<c-x>\<c-f>"
  elseif "backward" == a:direction
    return "\<c-p>"
  else
    return "\<c-n>"
  endif
endfunction

command! TEST call InsertTabWrapper("forward")

inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>
""inoremap <cr> <c-r>=EnterSelect ()<cr>

" augroup initAutoComplete
"     autocmd!
"     autocmd BufEnter,LspAttach * call AutoComplete()
" augroup END
"
" augroup openFilePathCompletion
"     autocmd!
"     autocmd InsertCharPre * silent! call OpenFilePathCompletion()
" augroup END
"
" " use tab for navigating the autocomplete menu
" inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
"
" " use up and down keys for navigating the autocomplete menu
" inoremap <expr> <down> pumvisible() ? "\<C-n>" : "\<down>"
" inoremap <expr> <up> pumvisible() ? "\<C-p>" : "\<up>"

]]

-- local function text_complete()
--
-- end
--
-- local function file_complete()
--
-- end
--
-- function M.setup()
--
-- end

return M

