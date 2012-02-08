" Vim syntax file
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2012-02-08

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
syn match  taskpaperSubProject       /^\t*.\+:\s*$/ contained
syn match  taskpaperListItem  "^\t*[-]\s\+"
syn match  taskpaperContext  "@[A-Za-z0-9_]\+"
syn match  taskpaperDone "^\t*[-]\s\+.*@[Dd]one.*$"
syn match  taskpaperCancelled "^\t*[-]\s\+.*@[Cc]ancelled.*$"

"syn region taskpaperProjectFold matchgroup=Title start=/^\z(\t*\)[^\t]\+:\s*$/ skip=/^\z1\t/ end=/\ze\(^\z1[^\t]\+:\s*$\)/ fold transparent extend contains=ALL
syn region taskpaperProject matchgroup=Title start=/^[^\t]\+:\s*$/ skip=/^\t/ end=/\ze\(^[^\t]\+:\s*$\)/ fold transparent extend contains=ALLBUT,taskpaperProject

syn sync fromstart

"highlighting for Taskpaper groups
HiLink taskpaperListItem      Identifier
HiLink taskpaperContext       Identifier
HiLink taskpaperSubProject    Title
HiLink taskpaperDone          NonText
HiLink taskpaperCancelled     NonText
HiLink taskpaperComment       Comment

let b:current_syntax = "taskpaper"

delcommand HiLink
" vim: ts=8
