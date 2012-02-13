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

" Add '@' to keyword character set so that we can complete contexts as keywords
setlocal iskeyword+=@-@

" Tab character has special meaning on TaskPaper
setlocal noexpandtab

" Change 'comments' to continue to write a task item.
setlocal comments=b:-

" Set up mappings
nnoremap <unique> <script> <Plug>TaskPaperFoldProjects
\       :<C-u>call taskpaper#fold_projects()<CR>
nnoremap <unique> <script> <Plug>TaskPaperFoldNotes
\       :<C-u>call taskpaper#search('\v^(\s*\|\t+-\s+.*\|.+:)$')<CR>
nnoremap <unique> <script> <Plug>TaskPaperFocusProject
\       :<C-u>call taskpaper#fold_projects()<CR>zO

nnoremap <unique> <script> <Plug>TaskPaperSearch
\       :<C-u>call taskpaper#search()<CR>
nnoremap <unique> <script> <Plug>TaskPaperSearchTag
\       :<C-u>call taskpaper#search_tag()<CR>

nnoremap <unique> <script> <Plug>TaskPaperNextProject
\       :<C-u>call taskpaper#next_project()<CR>
nnoremap <unique> <script> <Plug>TaskPaperPreviousProject
\       :<C-u>call taskpaper#previous_project()<CR>

nnoremap <unique> <script> <Plug>TaskPaperArchiveDone
\       :<C-u>call taskpaper#archive_done()<CR>
nnoremap <unique> <script> <Plug>TaskPaperShowToday
\       :<C-u>call taskpaper#search_tag('today')<CR>
nnoremap <unique> <script> <Plug>TaskPaperShowCancelled
\       :<C-u>call taskpaper#search_tag('cancelled')<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleCancelled
\       :call taskpaper#toggle_tag('cancelled', taskpaper#date())<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleDone
\       :call taskpaper#toggle_tag('done', taskpaper#date())<CR>
nnoremap <unique> <script> <Plug>TaskPaperToggleToday
\       :call taskpaper#toggle_tag('today', '')<CR>

nnoremap <unique> <script> <Plug>TaskPaperNewline
\       o<C-r>=taskpaper#newline()<CR>
inoremap <unique> <script> <Plug>TaskPaperNewline
\       <CR><C-r>=taskpaper#newline()<CR>

nmap <buffer> <silent> <Leader>tp <Plug>TaskPaperFoldProjects
nmap <buffer> <silent> <Leader>t. <Plug>TaskPaperFoldNotes
nmap <buffer> <silent> <Leader>tP <Plug>TaskPaperFocusProject

nmap <buffer> <silent> <Leader>t/ <Plug>TaskPaperSearch
nmap <buffer> <silent> <Leader>ts <Plug>TaskPaperSearchTag

nmap <buffer> <silent> <Leader>tj <Plug>TaskPaperNextProject
nmap <buffer> <silent> <Leader>tk <Plug>TaskPaperPreviousProject

nmap <buffer> <silent> <Leader>tD <Plug>TaskPaperArchiveDone
nmap <buffer> <silent> <Leader>tT <Plug>TaskPaperShowToday
nmap <buffer> <silent> <Leader>tX <Plug>TaskPaperShowCancelled
nmap <buffer> <silent> <Leader>td <Plug>TaskPaperToggleDone
nmap <buffer> <silent> <Leader>tt <Plug>TaskPaperToggleToday
nmap <buffer> <silent> <Leader>tx <Plug>TaskPaperToggleCancelled

let &cpo = s:save_cpo
