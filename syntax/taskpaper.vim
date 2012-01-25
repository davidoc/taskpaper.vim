" Vim syntax file
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2011-02-15

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
syn match  taskpaperProject       /^.\+:\s*$/
syn match  taskpaperLineContinue ".$" contained
syn match  taskpaperListItem  "^\s*[-+]\s\+" 
syn match  taskpaperContext  "@[A-Za-z0-9_]\+"
syn match  taskpaperDone "^\s*[-+]\s\+.*@[Dd]one.*$"
syn match  taskpaperCancelled "^\s*[-+]\s\+.*@[Cc]ancelled.*$"

syn region taskpaperProjectFold start=/^.\+:\s*$/ end=/^\s*$/ transparent fold


syntax match taskpaperPri1 "@pri(1)"
syntax match taskpaperPri2 "@pri(2)"
syntax match taskpaperPri3 "@pri(3)"
syntax match taskpaperPri4 "@pri(4)"
syntax match taskpaperPri5 "@pri(5)"
syntax match taskpaperPri6 "@pri(6)"


syn sync fromstart

HiLink taskpaperPri1 Error 
HiLink taskpaperPri2 Statement
HiLink taskpaperPri3 Identifier
HiLink taskpaperPri4 PreProc 
HiLink taskpaperPri5 Special 
HiLink taskpaperPri6 Constant


"highlighting for Taskpaper groups
HiLink taskpaperListItem      Identifier
HiLink taskpaperContext       Identifier
HiLink taskpaperProject       Title
HiLink taskpaperDone          Comment
HiLink taskpaperCancelled     Comment
HiLink taskpaperComment       SpecialKey


let b:current_syntax = "taskpaper"

delcommand HiLink
" vim: ts=8
