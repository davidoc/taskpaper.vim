" Vim syntax file
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2011-09-28

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

syn case ignore

syn match  taskpaperComment      "^.*$"
syn match  taskpaperProject      "^\s*[^\-].\+:"
syn match  taskpaperLineContinue ".$" contained
syn match  taskpaperListItem     "^\s*[-+]\s\+"
syn match  taskpaperContext      "@[A-Za-z0-9_]\+"
syn match  taskpaperDone         ".*@[Dd]one\%(([0-9\-]\+)\)\=.*$"
syn match  taskpaperCancelled    "^\s*[-+]\s\+.*@[Cc]ancelled.*$"

syn region taskpaperProjectFold start=/^\z(\s*\)[^-].\+:/ end=/^\ze\S\|^\zs$/ transparent fold contains=ALL

syn sync fromstart

"highlighting for Taskpaper groups
HiLink taskpaperListItem      Identifier
HiLink taskpaperContext       Identifier
HiLink taskpaperProject       Title
HiLink taskpaperDone          NonText
HiLink taskpaperCancelled     NonText
HiLink taskpaperComment       Comment

let b:current_syntax = "taskpaper"

delcommand HiLink
" vim: ts=8
