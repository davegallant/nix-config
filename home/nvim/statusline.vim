" A lightweight statusline

" Enable statusline
set laststatus=2

" Do not show mode on last line
set noshowmode

function! ActivateStatusline()
set statusline=
set statusline+=%#Pmenu#
set statusline+=%{StatuslineMode()}
set statusline+=%#PmenuSel#
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
endfunction

" Get vim mode
function! StatuslineMode()

    let g:modeMap={
    \ 'n'      : 'NORMAL',
    \ 'i'      : 'INSERT',
    \ 'c'      : 'COMMAND',
    \ 'R'      : 'REPLACE',
    \ 's'      : 'SELECT',
    \ 'y'      : 'HELP',
    \ 't'      : 'TERM',
    \ '!'      : 'SHELL',
    \ 'v'      : 'VISUAL',
    \ 'V'      : 'VISUAL LINE',
    \ "\<C-V>" : 'VISUAL BLOCK'
    \}

    if expand('%:y') == 'help'
        let b:CurrentMode = 'HELP'
    endif

    return '  '.g:modeMap[mode()].' '

endfunction

augroup SetStatusline
    autocmd!
    autocmd BufEnter,WinEnter * call ActivateStatusline()
augroup END
