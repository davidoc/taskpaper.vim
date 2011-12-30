" plugin to handle the TaskPaper to-do list format
" Language:	Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:	David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:		https://github.com/davidoc/taskpaper.vim
" Last Change:  2011-02-15

if exists("loaded_task_paper")
    finish
endif
let loaded_task_paper = 1

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

function! s:FocusProject()
	let s:currentLine = getline('.')
	if(s:currentLine =~ ":$")
		setlocal foldenable
		setlocal foldmethod=manual

		exec "normal zE"
		let s:line = line(".")
		let s:prevLine = s:line-1
		let s:tabs = indent(".")/&ts
		execute "0,".s:prevLine."fold"
		let s:nextProject = search("^\t\\{".s:tabs."}\\S*:")

		execute s:nextProject.",".line("$")."fold"
		execute s:line
	else
		echo "'" s:currentLine "' is not a project."
	endif
	return
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
						let repl = substitute(repl, "\\s\\+$", "", "g")
            echo "undone!"
        else
            let today = strftime(g:task_paper_date_format, localtime())
            let done_str = " @done(" . today . ")"
            let repl = substitute(line, "$", done_str, "g")
						let repl = substitute(repl, "\\s\\+$", "", "g")
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

"priorities
function! s:ClearPriority()
  let line = getline(".")
  let repl = substitute(line, " @pri(.)", "", "g")
	let repl = substitute(repl, "\\s\\+$", "", "g")
  call setline(".", repl)
endfunction
function! s:SetPriority(val)
  call s:ClearPriority()
  let line = getline(".")
  let priority = " @pri(".a:val.")"
  let repl = substitute(line, "$", priority, "g")
  call setline(".", repl)
endfunction

noremap <silent> <leader>1 :call <SID>SetPriority(1)<CR>
noremap <silent> <leader>2 :call <SID>SetPriority(2)<CR>
noremap <silent> <leader>3 :call <SID>SetPriority(3)<CR>
noremap <silent> <leader>4 :call <SID>SetPriority(4)<CR>
noremap <silent> <leader>5 :call <SID>SetPriority(5)<CR>
noremap <silent> <leader>6 :call <SID>SetPriority(6)<CR>
noremap <silent> <leader>0 :call <SID>ClearPriority()<CR>

"swap lines
noremap <silent> <up> :call SwapUp()<CR>
noremap <silent> <down> :call SwapDown()<CR>

" Set up mappings
"noremap <unique> <script> <Plug>ToggleDone       :call TPToggleDone()<CR>
"noremap <unique> <script> <Plug>ToggleCancelled   :call <SID>ToggleCancelled()<CR>
"noremap <unique> <script> <Plug>ShowContext      :call <SID>ShowContext()<CR>
"noremap <unique> <script> <Plug>ShowAll          :call <SID>ShowAll()<CR>
"noremap <unique> <script> <Plug>FoldAllProjects  :call <SID>FoldAllProjects()<CR>

command! TPToggleDone :call <SID>ToggleDone()
command! TPToggleCancelled :call <SID>ToggleCancelled()
command! TPShowContext :call <SID>ShowContext()
command! TPShowAll :call <SID>ShowAll()
command! TPFoldAllProjects :call <SID>FoldAllProjects()

"map <silent> <Leader>td :call <SID>ToggleDone()<CR>
"map <silent> <Leader>tx :call <SID>ToggleCancelled()<CR>
"map <silent> <Leader>tc :call <SID>ShowContext()<CR>
"map <silent> <Leader>ta :call <SID>ShowAll()<CR>
"map <silent> <Leader>tp :call <SID>FoldAllProjects()<CR>

noremap <silent> <C-Space> :call <SID>ToggleDone()<CR>
map <silent> <Leader><Space> :call <SID>ToggleDone()<CR>

autocmd BufLeave *.taskpaper silent! wall

" Search
function! <SID>Search(path, search, sort)
	if a:sort
		let endCmd = ' @pri\((.)\).*/(\4)\3;;\1:\2/" | sort'
	else
		let endCmd = '/\3;;\1:\2/"'
	endif
	let cmd = 'find '.a:path.' | xargs grep -snIH '.a:search.' | grep -v @done | tr -d "\t" | sed -E "s/(.*taskpaper):([0-9]+):-(.*)'.endCmd
	let out = system(cmd)
	let tmpfile = "/tmp/top.tmp"
	"tempname()
	exe "redir! > " . tmpfile
	silent echon out
	redir END
	"set efm=%m||%f:%\\s%#%l
	let old_efm = &efm
	set efm=%m;;%f:%l
	execute "silent! cgetfile " . tmpfile
	let &efm = old_efm
	call delete(tmpfile)
	let s:columns = &columns
	let s:width = s:columns/2
  "execute "vertical cw | vertical resize ".s:width
  execute "cw"

endfunction

function! FindAllTasks(path)
	let search = "\- "
	call s:Search(a:path, search, 0)
endfunction

function! FindTasks(path, search, sort)
	call s:Search(a:path, a:search, a:sort)
endfunction

function! FindTasksByPriority(path, pri, sort)
	let search = '"@pri('.a:pri.')"'
	call s:Search(a:path, search, a:sort)
endfunction

"find top
map <silent> <leader>k :call FindTasksByPriority(expand('%'), '.', 1)<CR>
map <silent> <leader>t :call FindTasksByPriority(expand('%'), '[123]', 1)<CR>

map <silent> <leader>r :e ~/Dropbox/Notes/_personal.taskpaper<CR>
map <silent> <leader>p :e ~/Dropbox/Notes/_projects.taskpaper<CR>
map <silent> <leader>d :e ~/Dropbox/Notes/_dm.taskpaper<CR>
map <silent> <leader>i :e ~/Dropbox/Notes/projects/_ideas/index.taskpaper<CR>

"command! AllPersonal :call FindAllTasks("personal/*")
"command! AllProjects :call FindAllTasks("projects/*")
"command! AllDM :call FindAllTasks("demandmedia/*")

fu! FindTaskPaperFiles()
	call fuf#setOneTimeVariables(['g:fuf_coveragefile_globPatterns', ['~/Dropbox/Notes/**/*.taskpaper']]) | FufCoverageFile
endfu
"nnoremap <silent> \ :call FindTaskPaperFiles()<CR>
"nnoremap <silent> <leader>\ :FufCoverageFile<CR>
