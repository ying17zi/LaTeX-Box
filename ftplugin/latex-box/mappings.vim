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
	if a:mode ==? 'v'
		normal! gv
	endif
	if a:0 > 0
		if a:1 > 0
			normal! j
		else
			normal! k
		endif
	endif
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
	call search('\s*\\\(' . join(sections,'\|') . '\)\>',a:direction . 'W')
	let @/ = save_search
	if a:0 > 0
		if a:1 > 0
			normal! k
		else
			normal! j
		endif
	endif
endfunction
nnoremap <buffer> <silent> ]] :call <SID>LatexBoxNextSection('','')<CR>
nnoremap <buffer> <silent> ][ :call <SID>LatexBoxNextSection('','',1)<CR>
nnoremap <buffer> <silent> [] :call <SID>LatexBoxNextSection('b','',0)<CR>
nnoremap <buffer> <silent> [[ :call <SID>LatexBoxNextSection('b','')<CR>
vnoremap <buffer> <silent> ]] :call <SID>LatexBoxNextSection('','v')<CR>
vnoremap <buffer> <silent> ][ :call <SID>LatexBoxNextSection('','v',1)<CR>
vnoremap <buffer> <silent> [] :call <SID>LatexBoxNextSection('b','v',0)<CR>
vnoremap <buffer> <silent> [[ :call <SID>LatexBoxNextSection('b','v')<CR>
onoremap <buffer> <silent> ]] :call <SID>LatexBoxNextSection('','')<CR>
onoremap <buffer> <silent> ][ :call <SID>LatexBoxNextSection('','',1)<CR>
onoremap <buffer> <silent> [] :call <SID>LatexBoxNextSection('b','',0)<CR>
onoremap <buffer> <silent> [[ :call <SID>LatexBoxNextSection('b','')<CR>
" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
