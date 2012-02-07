" Vim syntax file
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2012-02-07

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

syn match  taskpaperComment "^.*$"
syn match  taskpaperProject       /^\t*.\+:\s*$/
syn match  taskpaperLineContinue ".$" contained
syn match  taskpaperListItem  "^\t*[-+]\s\+" 
syn match  taskpaperContext  "@[A-Za-z0-9_]\+"
syn match  taskpaperDone "^\t*[-+]\s\+.*@[Dd]one.*$"
syn match  taskpaperCancelled "^\t*[-+]\s\+.*@[Cc]ancelled.*$"

"Project old region starts like a Project and ends like a blank line
syn region taskpaperProjectFold start=/^.\+:\s*$/ end=/^\s*$/ transparent fold

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
