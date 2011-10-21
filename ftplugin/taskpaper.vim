" plugin to handle the TaskPaper to-do list format
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2011-10-21
" Changes By: Filipe Silva <d4rchangel@gmail.com>

if exists("loaded_task_paper")
	finish
endif
let loaded_task_paper = 1

"Altered by Filipe Silva @ 21/10/2011
"Em
"Variables to control the scope of the @active tag removal 
"when switching active tasks
"
"Possible removal scopes:
" "FILE": When setting a task as active, remove all other active tags
"         from the whole file (allows only 1 active tag) 
"         (This is the default value)
" "PROJECT": When setting a task as active, remove other active tags
"            from the current project only (allows 1 active tag per project)
" "NOTHING": When setting a task as active, do not remove other active tags
"
if exists("b:task_paper_active_rag_removal_scope")
	let s:task_paper_active_rag_removal_scope=b:task_paper_active_rag_removal_scope
else
	if exists("t:task_paper_active_rag_removal_scope")
		let s:task_paper_active_rag_removal_scope=t:task_paper_active_rag_removal_scope
	else
		if exists("w:task_paper_active_rag_removal_scope")
			let s:task_paper_active_rag_removal_scope=w:task_paper_active_rag_removal_scope
		else
			if exists("g:task_paper_active_rag_removal_scope")
				let s:task_paper_active_rag_removal_scope=g:task_paper_active_rag_removal_scope
			else
				let s:task_paper_active_rag_removal_scope="FILE"
			endif
		endif
	endif
endif

" Define a default date format
if !exists('task_paper_date_format') | let task_paper_date_format = "%Y-%m-%d" | endif

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

	let line = getline(".")
	if (line =~ '^\s*- ')
		let repl = line
		if (line =~ '@done')
			let repl = substitute(line, "@done\(.*\)", "", "g")
			echo "undone!"
		else
			let today = strftime(g:task_paper_date_format, localtime())
			let done_str = " @done(" . today . ")"
			let repl = substitute(line, "$", done_str, "g")
			echo "done!"
		endif
		call setline(".", repl)
	else 
		echo "not a task."
	endif

endfunction

" toggle @cancelled context tag on a task
function! s:ToggleCancelled()

	let line = getline(".")
	if (line =~ '^\s*- ')
		let repl = line
		if (line =~ '@cancelled')
			let repl = substitute(line, "@cancelled\(.*\)", "", "g")
			echo "uncancelled!"
		else
			let today = strftime(g:task_paper_date_format, localtime())
			let cancelled_str = " @cancelled(" . today . ")"
			let repl = substitute(line, "$", cancelled_str, "g")
			echo "cancelled!"
		endif
		call setline(".", repl)
	else 
		echo "not a task."
	endif

endfunction

"Altered by Filipe Silva <d4rchangel@gmail.com>
"Toggle @active context in a task
"Ensures there is only one active task at any given time

function! s:ToggleActive()

	"TODO: Function to get the boundaries of a project (if not already existing)
	"TODO: Limit the tag deletion to the scope of a project
	let line = getline(".")
	if (line =~ '^\s*- ')
		let repl = line
		let this_line = getpos(".")[1]
		let this_column = getpos(".")[2]
		if (line =~ '@active')
			let repl = substitute(repl, "@active\(.*\)", "", "g")
			let repl = substitute(repl, "@active", "", "g")
			echo "Not active!"
		else
			"Delete all @active tags in the current scope
			if s:task_paper_active_rag_removal_scope != "NOTHING"
				"if s:task_paper_active_rag_removal_scope == "PROJECT"

				let active_pos = search("^\\s*-\\s.*\@[Aa]ctive.*$")
				while active_pos != 0
					let active_line = getline(active_pos)
					"Replace regardless of the tag having a parameter or not
					let active_line = substitute(active_line, "@active\(.*\)", "", "g")
					let active_line = substitute(active_line, "@active", "", "g")
					call setline(active_pos, active_line)
					let active_pos = search("^\\s*-\\s.*\@[Aa]ctive.*$")
				endwhile
			endif

			"return to the line where we were
			let active_str = " @active"
			let repl = substitute(line, "$", active_str, "g")
			call cursor(this_line, this_column)
			echo "Active!"
		endif
		call setline(this_line, repl)
	else 
		echo "Not a task."
	endif

endfunction

" Set up mappings
noremap <unique> <script> <Plug>ToggleDone       :call <SID>ToggleDone()<CR>
noremap <unique> <script> <Plug>ToggleCancelled   :call <SID>ToggleCancelled()<CR>
noremap <unique> <script> <Plug>ShowContext      :call <SID>ShowContext()<CR>
noremap <unique> <script> <Plug>ShowAll          :call <SID>ShowAll()<CR>
noremap <unique> <script> <Plug>FoldAllProjects  :call <SID>FoldAllProjects()<CR>
"Altered by Filipe Silva <d4rchangel@gmail.com>
noremap <unique> <script> <Plug>ToggleActive       :call <SID>ToggleActive()<CR>
map <buffer> <silent> <Leader>tq <Plug>ToggleActive

map <buffer> <silent> <Leader>td <Plug>ToggleDone
map <buffer> <silent> <Leader>tx <Plug>ToggleCancelled
map <buffer> <silent> <Leader>tc <Plug>ShowContext
map <buffer> <silent> <Leader>ta <Plug>ShowAll
map <buffer> <silent> <Leader>tp <Plug>FoldAllProjects
