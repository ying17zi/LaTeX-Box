" {{{1 Settings
setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal nobuflisted
setlocal noswapfile
setlocal nowrap
setlocal cursorline
setlocal nonumber
setlocal nolist
setlocal tabstop=8
setlocal cole=0
setlocal cocu=nvic
if g:LatexBox_fold_toc
    setlocal foldmethod=expr
    setlocal foldexpr=TOCFoldLevel(v:lnum)
endif
" }}}1

" {{{1 Functions
" {{{2 TOCClose
function! s:TOCClose()
    bwipeout
    if g:LatexBox_split_resize
        silent exe "set columns-=" . g:LatexBox_split_width
    endif
endfunction

" {{{2 TOCToggleNumbers
function! s:TOCToggleNumbers()
    if b:toc_numbers
        setlocal conceallevel=3
        let b:toc_numbers = 0
    else
        setlocal conceallevel=0
        let b:toc_numbers = 1
    endif
endfunction

" {{{2 EscapeTitle
function! s:EscapeTitle(titlestr)
    " Credit goes to Marcin Szamotulski for the following fix.  It allows to
    " match through commands added by TeX.
    let titlestr = substitute(a:titlestr, '\\\w*\>\s*\%({[^}]*}\)\?', '.*', 'g')

    let titlestr = escape(titlestr, '\')
    let titlestr = substitute(titlestr, ' ', '\\_\\s\\+', 'g')

    return titlestr
endfunction

" {{{2 TOCActivate
function! s:TOCActivate(close)
    let n = getpos('.')[1] - 1

    if n >= len(b:toc)
        return
    endif

    let entry = b:toc[n]

    let titlestr = s:EscapeTitle(entry['text'])

    " Search for duplicates
    "
    let i=0
    let entry_hash = entry['level'].titlestr
    let duplicates = 0
    while i<n
        let i_entry = b:toc[n]
        let i_hash = b:toc[i]['level'].s:EscapeTitle(b:toc[i]['text'])
        if i_hash == entry_hash
            let duplicates += 1
        endif
        let i += 1
    endwhile
    let toc_bnr = bufnr('%')
    let toc_wnr = winnr()

    execute b:calling_win . 'wincmd w'

    let bnr = bufnr(entry['file'])
    if bnr == -1
        execute 'badd ' . entry['file']
        let bnr = bufnr(entry['file'])
    endif

    execute 'buffer! ' . bnr

    " skip duplicates
    while duplicates > 0
        if search('\\' . entry['level'] . '\_\s*{' . titlestr . '}', 'ws')
            let duplicates -= 1
        endif
    endwhile

    if search('\\' . entry['level'] . '\_\s*{' . titlestr . '}', 'ws')
        normal zt
    endif

    if a:close
        execute 'bwipeout ' . toc_bnr
        if g:LatexBox_split_resize
            silent exe "set columns-=" . g:LatexBox_split_width
        endif
    else
        execute toc_wnr . 'wincmd w'
    endif
endfunction

" {{{2 TOCFoldLevel
function! TOCFoldLevel(lnum)
    let line  = getline(a:lnum)

    " Fold simply based on section numbers such as 12.4.2
    if line =~# '^[A-Za-z0-9]\+\s'
        return ">1"
    endif

    " Don't fold options
    if line =~# '^\s*$'
        return 0
    endif

    " Return previous fold level
    return "="
endfunction
" }}}1

" {{{1 Mappings
nnoremap <buffer> <silent> s :call <SID>TOCToggleNumbers()<CR>
nnoremap <buffer> <silent> q :call <SID>TOCClose()<CR>
nnoremap <buffer> <silent> <Esc> :call <SID>TOCClose()<CR>
nnoremap <buffer> <silent> <Space> :call <SID>TOCActivate(0)<CR>
nnoremap <buffer> <silent> <CR> :call <SID>TOCActivate(1)<CR>
nnoremap <buffer> <silent> <leftrelease> :call <SID>TOCActivate(0)<cr>
nnoremap <buffer> <silent> <2-leftmouse> :call <SID>TOCActivate(1)<cr>
nnoremap <buffer> <silent> G G4k
nnoremap <buffer> <silent> <Esc>OA k
nnoremap <buffer> <silent> <Esc>OB j
nnoremap <buffer> <silent> <Esc>OC l
nnoremap <buffer> <silent> <Esc>OD h
" }}}1

" vim:fdm=marker:ff=unix:et:ts=4:sw=4
