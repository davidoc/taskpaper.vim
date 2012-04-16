" Vim syntax file
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2012-03-07

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if version < 508
  command! -nargs=+ HiLink hi link <args>
else
  command! -nargs=+ HiLink hi def link <args>
endif

" Define tag styles
if !exists('g:task_paper_styles')
    let g:task_paper_styles = {'FAIL': 'guibg=Red guifg=White'}
endif

syn case ignore

syn match taskpaperComment	/^.*$/ contains=taskpaperContext
syn match taskpaperProject	/^.\+:\(\s\+@[^ \t(]\+\(([^)]*)\)\?\)*$/ contains=taskpaperContext
syn match taskpaperListItem	/^\t*-\s\+/
syn match taskpaperContext	/\s\zs@[^ \t(]\+\(([^)]*)\)\?/
syn match taskpaperDone		/^.*\s@done\(\(\s\|([^)]*)\).*\)\?$/
syn match taskpaperCancelled	/^.*\s@cancelled\(\(\s\|([^)]*)\).*\)\?$/

syn sync fromstart

"highlighting for Taskpaper groups
HiLink taskpaperListItem      Identifier
HiLink taskpaperContext       Identifier
HiLink taskpaperProject       Title
HiLink taskpaperDone          NonText
HiLink taskpaperCancelled     NonText
HiLink taskpaperComment       Comment

call taskpaper#tag_style_dict(g:task_paper_styles)

let b:current_syntax = "taskpaper"

delcommand HiLink
" vim: ts=8
