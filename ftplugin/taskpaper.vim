" plugin to handle the TaskPaper to-do list format
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2011-02-15

if exists("loaded_task_paper")
    finish
endif
let loaded_task_paper = 1

let s:save_cpo = &cpo
set cpo&vim

" Define a default date format
if !exists('g:task_paper_date_format')
    let g:task_paper_date_format = "%Y-%m-%d"
endif

" Define a default archive project name
if !exists('g:task_paper_archive_project')
    let g:task_paper_archive_project = "Archive"
endif

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

" Set up mappings
nnoremap <unique> <script> <Plug>ShowContext      :call <SID>ShowContext()<CR>
nnoremap <unique> <script> <Plug>ShowAll          :call <SID>ShowAll()<CR>
nnoremap <unique> <script> <Plug>FoldAllProjects  :call <SID>FoldAllProjects()<CR>

nnoremap <unique> <script> <Plug>TaskPaperArchiveDone
\                               :<C-u>call taskpaper#archive_done()<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleCancelled
\                               :call taskpaper#toggle_cancelled()<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleDone
\                               :call taskpaper#toggle_done()<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleToday
\                               :call taskpaper#toggle_tag('today')<CR>

nmap <buffer> <silent> <Leader>tc <Plug>ShowContext
nmap <buffer> <silent> <Leader>ta <Plug>ShowAll
nmap <buffer> <silent> <Leader>tp <Plug>FoldAllProjects

nmap <buffer> <silent> <Leader>tD <Plug>TaskPaperArchiveDone
nmap <buffer> <silent> <Leader>td <Plug>TaskPaperToggleDone
nmap <buffer> <silent> <Leader>tt <Plug>TaskPaperToggleToday
nmap <buffer> <silent> <Leader>tx <Plug>TaskPaperToggleCancelled

let &cpo = s:save_cpo
