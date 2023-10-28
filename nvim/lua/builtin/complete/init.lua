
vim.opt.completeopt = "menu,menuone,noselect"

vim.cmd[[
"tab complete

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
]]

