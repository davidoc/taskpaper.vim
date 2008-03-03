" plugin to handle the TaskPaper to-do list format
" http://hogbaysoftware.com/projects/taskpaper
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		http://www.cs.tcd.ie/David.OCallaghan/taskpaper.vim/
" Version:	0.3
" Last Change:  2008-03-03


if exists("loaded_task_paper")
    finish
endif
let loaded_task_paper = 1

"add '@' to keyword character set so that we can complete contexts as keywords
setlocal iskeyword+=@-@

"set default folding: by project (syntax), open (up to 99 levels), disabled 
setlocal foldmethod=syntax
setlocal foldlevel=99
setlocal nofoldenable

"show tasks from context under the cursor
function! s:ShowContext()
    let s:wordUnderCursor = expand("<cword>")
    if(s:wordUnderCursor =~ "@\k*")
        let @/ = "\\<".s:wordUnderCursor."\\>"
        "adapted from http://vim.sourceforge.net/tips/tip.php?tip_id=282
        setlocal foldexpr=(getline(v:lnum)=~@/)?0:1
        setlocal foldmethod=expr foldlevel=0 foldcolumn=1 foldminlines=0
        setlocal foldenable
    else
        echo "'" s:wordUnderCursor "' is not a context."    
    endif
endfunction

function! s:ShowAll()
    setlocal foldmethod=syntax
    %foldopen!
    setlocal nofoldenable
endfunction  

function! s:FoldAllProjects()
    setlocal foldmethod=syntax
    setlocal foldenable
    %foldclose! 
endfunction

" toggle @done context tag on a task
function! s:ToggleDone()
    if (getline(".") =~ '^\s*- ')
        let isdone = strridx(getline("."),"@done")
        if (isdone != -1)
            substitute/ @done//
            echo "undone!"
        else
            substitute/$/ @done/
            echo "done!"
        endif
    else 
        echo "not a task."
    endif

endfunction

" Set up mappings
noremap <unique> <script> <Plug>ToggleDone       :call <SID>ToggleDone()<CR>
noremap <unique> <script> <Plug>ShowContext      :call <SID>ShowContext()<CR>
noremap <unique> <script> <Plug>ShowAll          :call <SID>ShowAll()<CR>
noremap <unique> <script> <Plug>FoldAllProjects  :call <SID>FoldAllProjects()<CR>

map <buffer> <silent> <LocalLeader>td <Plug>ToggleDone
map <buffer> <silent> <LocalLeader>tc <Plug>ShowContext
map <buffer> <silent> <LocalLeader>ta <Plug>ShowAll
map <buffer> <silent> <LocalLeader>tp <Plug>FoldAllProjects
