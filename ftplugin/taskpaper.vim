" plugin to handle the TaskPaper to-do list format
" http://hogbaysoftware.com/projects/taskpaper
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		http://www.cs.tcd.ie/David.OCallaghan/taskpaper.vim/
" Version:	1
" Last Change:  2007 Sep 25


"add '@' to keyword character set so that we can complete contexts as keywords
set iskeyword+=@-@

"show tasks from context under the cursor
function! ShowContext()
    let s:wordUnderCursor = expand("<cword>")
    if(s:wordUnderCursor =~ "@\k*")
        let @/ = s:wordUnderCursor
        "adapted from http://vim.sourceforge.net/tips/tip.php?tip_id=282
        set foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum)=~@/)\|\|(getline(v:lnum)=~@/)?0:1
        set foldmethod=expr foldlevel=0 foldcolumn=1 foldminlines=0
        set foldenable
    else
        echo "'" s:wordUnderCursor "' is not a context."    
    endif
endfunction

function! ShowAll()
    set nofoldenable
endfunction  

function! FoldAllProjects()
    set foldmethod=syntax
    set foldenable
    %foldclose! 
endfunction

" toggle @done context tag on a task
function! ToggleDone()
    if (getline(".") =~ "^\s*- ")
        let isdone = strridx(getline("."),"@done")
        if (isdone != -1)
            substitute/ @done//
            echo "undone!"
        else
            substitute/$/ @done/
            echo "done!"
        endif
    endif
endfunction

map <buffer> <LocalLeader>td :call ToggleDone()<cr>
map <buffer> <LocalLeader>tc :call ShowContext()<cr>
map <buffer> <LocalLeader>ta :call ShowAll()<cr>
map <buffer> <LocalLeader>tp :call FoldAllProjects()<cr>
