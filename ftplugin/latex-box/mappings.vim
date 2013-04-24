" LaTeX Box mappings

if exists("g:LatexBox_no_mappings")
	finish
endif

" latexmk {{{
map <buffer> <LocalLeader>ll :Latexmk<CR>
map <buffer> <LocalLeader>lL :Latexmk!<CR>
map <buffer> <LocalLeader>lc :LatexmkClean<CR>
map <buffer> <LocalLeader>lC :LatexmkClean!<CR>
map <buffer> <LocalLeader>lg :LatexmkStatus<CR>
map <buffer> <LocalLeader>lG :LatexmkStatus!<CR>
map <buffer> <LocalLeader>lk :LatexmkStop<CR>
map <buffer> <LocalLeader>le :LatexErrors<CR>
" }}}

" View {{{
map <buffer> <LocalLeader>lv :LatexView<CR>
" }}}

" TOC {{{
map <silent> <buffer> <LocalLeader>lt :LatexTOC<CR>
" }}}

" Jump to match {{{
if !exists('g:LatexBox_loaded_matchparen')
	nmap <buffer> % <Plug>LatexBox_JumpToMatch
	vmap <buffer> % <Plug>LatexBox_JumpToMatch
	omap <buffer> % <Plug>LatexBox_JumpToMatch
endif
" }}}

" Define text objects {{{
vmap <buffer> ie <Plug>LatexBox_SelectCurrentEnvInner
vmap <buffer> ae <Plug>LatexBox_SelectCurrentEnvOuter
omap <buffer> ie :normal vie<CR>
omap <buffer> ae :normal vae<CR>
vmap <buffer> i$ <Plug>LatexBox_SelectInlineMathInner
vmap <buffer> a$ <Plug>LatexBox_SelectInlineMathOuter
omap <buffer> i$ :normal vi$<CR>
omap <buffer> a$ :normal va$<CR>
" }}}

" Jump between sections {{{
function! s:LatexBoxNextSection(direction,mode,...)
	let save_search = @/
	let sections = [
		\ '\(sub\)*section',
		\ 'chapter',
		\ 'part',
		\ 'appendix',
		\ 'frontmatter',
		\ 'backmatter',
		\ 'mainmatter',
		\ ]
	if a:mode ==? 'v'
		normal! gv
	endif
	call search('\s*\\\(' . join(sections,'\|') . '\)\>',a:direction . 'W')
	if a:0 > 0
		execute "normal " . a:1
	endif
	let @/ = save_search
endfunction
nnoremap <buffer> <silent> ]] :call <SID>LatexBoxNextSection('','')<CR>
nnoremap <buffer> <silent> ][ :call <SID>LatexBoxNextSection('','','k')<CR>
nnoremap <buffer> <silent> [] :call <SID>LatexBoxNextSection('b','','j')<CR>
nnoremap <buffer> <silent> [[ :call <SID>LatexBoxNextSection('b','')<CR>
vnoremap <buffer> <silent> ]] :call <SID>LatexBoxNextSection('','v')<CR>
vnoremap <buffer> <silent> ][ :call <SID>LatexBoxNextSection('','v','k')<CR>
vnoremap <buffer> <silent> [] :call <SID>LatexBoxNextSection('b','v','j')<CR>
vnoremap <buffer> <silent> [[ :call <SID>LatexBoxNextSection('b','v')<CR>
onoremap <buffer> <silent> ]] :call <SID>LatexBoxNextSection('','')<CR>
onoremap <buffer> <silent> ][ :call <SID>LatexBoxNextSection('','','k')<CR>
onoremap <buffer> <silent> [] :call <SID>LatexBoxNextSection('b','','j')<CR>
onoremap <buffer> <silent> [[ :call <SID>LatexBoxNextSection('b','')<CR>
" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
