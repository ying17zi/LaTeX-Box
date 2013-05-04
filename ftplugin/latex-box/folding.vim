" Folding support for LaTeX
"
" Options
" g:LatexBox_Folding       - Turn on/off folding
" g:LatexBox_fold_preamble - Turn on/off folding of preamble
" g:LatexBox_fold_parts    - Define parts (eq. appendix, frontmatter) to fold
" g:LatexBox_fold_sections - Define section levels to fold
" g:LatexBox_fold_envs     - Turn on/off folding of environments
"

" {{{1 Set options
if exists('g:LatexBox_Folding') && g:LatexBox_Folding == 1
    setl foldmethod=expr
    setl foldexpr=LatexBox_FoldLevel(v:lnum)
    setl foldtext=LatexBox_FoldText()
endif
if !exists('g:LatexBox_fold_preamble')
    let g:LatexBox_fold_preamble=1
endif
if !exists('g:LatexBox_fold_envs')
    let g:LatexBox_fold_envs=1
endif
if !exists('g:LatexBox_fold_parts')
    let g:LatexBox_fold_parts=[
                \ "appendix",
                \ "frontmatter",
                \ "mainmatter",
                \ "backmatter"
                \ ]
endif
if !exists('g:LatexBox_fold_sections')
    let g:LatexBox_fold_sections=[
                \ "part",
                \ "chapter",
                \ "section",
                \ "subsection",
                \ "subsubsection"
                \ ]
endif

"
" The foldexpr function returns "=" for most lines, which means it can become
" slow for large files.  The following is a hack that is based on this reply to
" a discussion on the Vim Developer list:
" http://permalink.gmane.org/gmane.editors.vim.devel/14100
"
augroup FastFold
    autocmd!
    autocmd InsertEnter *.tex setlocal foldmethod=manual
    autocmd InsertLeave *.tex setlocal foldmethod=expr
augroup end

" {{{1 LatexBox_FoldLevel

" FoldLevelStart returns an integer that is used to dynamically set the correct
" fold level for sections and parts.  This way we don't need to set
" g:LatexBox_fold_sections differently for different kinds of documents.  E.g.
" in an article we typically just use section, subsection, etc, so \section
" should be foldlevel 1, whereas in a book \chapter could be foldlevel 1.
function! s:FoldLevelStart()
    "
    " Search through the document and dynamically define the initial section
    " level.  If we use more than one of the *matter commands, than we need one
    " more foldlevel.
    "
    let level = 1
    let nparts = 0
    for part in g:LatexBox_fold_parts
        let i = 1
        while i < line("$")
            if getline(i) =~ '^\s*\\' . part . '\>'
                let nparts += 1
                break
            endif
            let i += 1
        endwhile
        if nparts > 1
            let level = 2
            break
        endif
    endfor
    "
    " Set the level according to the highest level of sectioning
    "
    for part in g:LatexBox_fold_sections
        let i = 1
        while i < line("$")
            if getline(i) =~ '^\s*\\' . part . '\>'
                return level
            endif
            let i += 1
        endwhile
        let level -= 1
    endfor
    return level
endfunction
let b:LatexBox_CurrentFoldLevelStart = s:FoldLevelStart()

function! LatexBox_FoldLevel(lnum)
    let line  = getline(a:lnum)
    let nline = getline(a:lnum + 1)

    " Fold preamble
    if g:LatexBox_fold_preamble==1
        if line =~# '\s*\\documentclass'
            return ">1"
        elseif nline =~# '^\s*\\begin\s*{\s*document\s*}'
            return "<1"
        elseif line =~# '^\s*\\begin\s*{\s*document\s*}'
            return "0"
        endif
    endif

    " Never fold \end{document}
    if nline =~ '\s*\\end{document}'
        return "<1"
    endif

    " Fold parts (\frontmatter, \mainmatter, \backmatter, and \appendix)
    if line =~# '^\s*\\\%('.join(g:LatexBox_fold_parts, '\|') . '\)'
        return ">1"
    endif

    " Fold chapters and sections
    let level = b:LatexBox_CurrentFoldLevelStart
    for part in g:LatexBox_fold_sections
        if line  =~ '^\s*\\' . part . '\*\?\s*\({\|\[\)'
            return ">" . level
        endif
        if line  =~ '^\s*% Fake' . part
            return ">" . level
        endif
        let level += 1
    endfor

    " Fold environments
    let notbslash = '\%(\\\@<!\%(\\\\\)*\)\@<='
    let notcomment = '\%(\%(\\\@<!\%(\\\\\)*\)\@<=%.*\)\@<!'
    if g:LatexBox_fold_envs==1
        if line =~# notcomment . notbslash . '\\begin\s*{.\{-}}'
            return "a1"
        elseif line =~# notcomment . notbslash . '\\end\s*{.\{-}}'
            return "s1"
        endif
    endif

    " Return foldlevel of previous line
    return "="
endfunction

" {{{1 LatexBox_FoldText help functions
function! s:LabelEnv()
    let i = v:foldend
    while i >= v:foldstart
        if getline(i) =~ '^\s*\\label'
            return matchstr(getline(i), '^\s*\\label{\zs.*\ze}')
        end
        let i -= 1
    endwhile
    return ""
endfunction

function! s:CaptionEnv()
    let i = v:foldend
    while i >= v:foldstart
        if getline(i) =~ '^\s*\\caption'
            return matchstr(getline(i), '^\s*\\caption\(\[.*\]\)\?{\zs.\+')
        end
        let i -= 1
    endwhile
    return ""
endfunction

function! s:CaptionTable()
    let i = v:foldstart
    while i <= v:foldend
        if getline(i) =~ '^\s*\\caption'
            return matchstr(getline(i), '^\s*\\caption\(\[.*\]\)\?{\zs.\+')
        end
        let i += 1
    endwhile
    return ""
endfunction

function! s:CaptionFrame(line)
    " Test simple variant first
    let caption = matchstr(a:line,'\\begin\*\?{.*}{\zs.\+')

    if ! caption == ''
        return caption
    else
        let i = v:foldstart
        while i <= v:foldend
            if getline(i) =~ '^\s*\\frametitle'
                return matchstr(getline(i),
                            \ '^\s*\\frametitle\(\[.*\]\)\?{\zs.\+')
            end
            let i += 1
        endwhile

        return ""
    endif
endfunction

" {{{1 LatexBox_FoldText
function! LatexBox_FoldText()
    " Initialize
    let line = getline(v:foldstart)
    let nlines = v:foldend - v:foldstart + 1
    let level = ''
    let title = 'Not defined'

    " Fold level
    let level = strpart(repeat('-', v:foldlevel-1) . '*',0,3)
    if v:foldlevel > 3
        let level = strpart(level, 1) . v:foldlevel
    endif
    let level = printf('%-3s', level)

    " Preamble
    if line =~ '\s*\\documentclass'
        let title = "Preamble"
    endif

    " Parts, sections and fakesections
    let sections = '\(\(sub\)*section\|part\|chapter\)'
    let secpat1 = '^\s*\\' . sections . '\*\?\s*{'
    let secpat2 = '^\s*\\' . sections . '\*\?\s*\['
    if line =~ '\\frontmatter'
        let title = "Frontmatter"
    elseif line =~ '\\mainmatter'
        let title = "Mainmatter"
    elseif line =~ '\\backmatter'
        let title = "Backmatter"
    elseif line =~ '\\appendix'
        let title = "Appendix"
    elseif line =~ secpat1 . '.*}'
        let title =  matchstr(line, secpat1 . '\zs.*\ze}')
    elseif line =~ secpat1
        let title =  matchstr(line, secpat1 . '\zs.*')
    elseif line =~ secpat2 . '.*\]'
        let title =  matchstr(line, secpat2 . '\zs.*\ze\]')
    elseif line =~ secpat2
        let title =  matchstr(line, secpat2 . '\zs.*')
    elseif line =~ 'Fake' . sections . ':'
        let title =  matchstr(line,'Fake' . sections . ':\s*\zs.*')
    elseif line =~ 'Fake' . sections
        let title =  matchstr(line, 'Fake' . sections)
    endif

    " Environments
    if line =~ '\\begin'
        let env = matchstr(line,'\\begin\*\?{\zs\w*\*\?\ze}')
        if env == 'frame'
            let label = ''
            let caption = s:CaptionFrame(line)
        elseif env == 'table'
            let label = s:LabelEnv()
            let caption = s:CaptionTable()
        else
            let label = s:LabelEnv()
            let caption = s:CaptionEnv()
        endif
        if caption . label == ''
            let title = env
        elseif label == ''
            let title = printf('%-12s%s', env . ':',
                        \ substitute(caption, '}\s*$', '',''))
        elseif caption == ''
            let title = printf('%-12s%56s', env, '(' . label . ')')
        else
            let title = printf('%-12s%-30s %23s', env . ':',
                        \ strpart(substitute(caption, '}\s*$', '',''),0,34),
                        \ '(' . label . ')')
        endif
    endif

    let title = strpart(title, 0, 68)
    return printf('%-3s %-68s #%5d', level, title, nlines)
endfunction

" {{{1 Footer
" vim:fdm=marker:ff=unix:ts=4:sw=4
