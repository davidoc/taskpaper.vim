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

" Change 'comments' to continue to write a task item.
setlocal comments=b:-

"show tasks from context under the cursor
function! s:ShowContext()
    let cword = expand('<cword>')
    if cword =~ '@\k*'
        call taskpaper#search('\<' . cword . '\>')
    else
        echo '"' . cword . '" is not a context.'
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
nnoremap <unique> <script> <Plug>TaskPaperFoldProjects
\       :<C-u>call taskpaper#fold_projects()<CR>
nnoremap <unique> <script> <Plug>TaskPaperSearch
\       :<C-u>call taskpaper#search()<CR>

nnoremap <unique> <script> <Plug>TaskPaperNextProject
\       :<C-u>call taskpaper#next_project()<CR>
nnoremap <unique> <script> <Plug>TaskPaperPreviousProject
\       :<C-u>call taskpaper#previous_project()<CR>

nnoremap <unique> <script> <Plug>TaskPaperArchiveDone
\       :<C-u>call taskpaper#archive_done()<CR>
nnoremap <unique> <script> <Plug>TaskPaperShowToday
\       :<C-u>call taskpaper#search('\<@today\>')<CR>
nnoremap <unique> <script> <Plug>TaskPaperShowCancelled
\       :<C-u>call taskpaper#search('\<@cancelled\>')<CR>
nnoremap <unique> <script> <Plug>TaskPaperHideNotes
\       :<C-u>call taskpaper#search('\v^(\s*\|\t+-\s+.*\|.+:)$')<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleCancelled
\       :call taskpaper#toggle_tag('cancelled', taskpaper#date())<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleDone
\       :call taskpaper#toggle_tag('done', taskpaper#date())<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleToday
\       :call taskpaper#toggle_tag('today', '')<CR>

nmap <buffer> <silent> <Leader>tc <Plug>ShowContext
nmap <buffer> <silent> <Leader>ta <Plug>ShowAll
nmap <buffer> <silent> <Leader>tp <Plug>TaskPaperFoldProjects
nmap <buffer> <silent> <Leader>ts <Plug>TaskPaperSearch

nmap <buffer> <silent> <Leader>tj <Plug>TaskPaperNextProject
nmap <buffer> <silent> <Leader>tk <Plug>TaskPaperPreviousProject

nmap <buffer> <silent> <Leader>tD <Plug>TaskPaperArchiveDone
nmap <buffer> <silent> <Leader>tT <Plug>TaskPaperShowToday
nmap <buffer> <silent> <Leader>tX <Plug>TaskPaperShowCancelled
nmap <buffer> <silent> <Leader>t. <Plug>TaskPaperHideNotes
nmap <buffer> <silent> <Leader>td <Plug>TaskPaperToggleDone
nmap <buffer> <silent> <Leader>tt <Plug>TaskPaperToggleToday
nmap <buffer> <silent> <Leader>tx <Plug>TaskPaperToggleCancelled

let &cpo = s:save_cpo
