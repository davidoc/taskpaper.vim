" plugin to handle the TaskPaper to-do list format
" Language:     Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:   David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:          https://github.com/davidoc/taskpaper.vim
" Last Change:  2012-01-29

let s:save_cpo = &cpo
set cpo&vim

function! s:add_delete_tag(tag, value, add)
    let cur_line = getline(".")

    let tag = " @" . a:tag
    if a:value != ''
        let tag .= "(" . a:value . ")"
    endif

    " Add tag
    if a:add
        let new_line = cur_line . tag
        call setline(".", new_line)
        return 1
    endif

    " Delete tag
    if cur_line =~# '\V' . tag
        if a:value != ''
            let new_line = substitute(cur_line, '\V' . tag, "", "g")
        else
            let new_line = substitute(cur_line, '\V' . tag . '\v(\([^)]*\))?',
            \                         "", "g")
        endif

        call setline(".", new_line)
        return 1
    endif
    return 0
endfunction

function! taskpaper#add_tag(tag, ...)
    let value = a:0 > 0 ? a:1 : input('Value: ')
    return s:add_delete_tag(a:tag, value, 1)
endfunction

function! taskpaper#delete_tag(tag, ...)
    let value = a:0 > 0 ? a:1 : ''
    return s:add_delete_tag(a:tag, value, 0)
endfunction

function! taskpaper#toggle_tag(tag, ...)
    if !taskpaper#delete_tag(a:tag, '')
	if a:0 > 0
	    call taskpaper#add_tag(a:tag, a:1)
	else
	    call taskpaper#add_tag(a:tag)
	endif
    endif
endfunction

function! taskpaper#update_tag(tag, value)
    call taskpaper#delete_tag(a:tag, '')
    call taskpaper#add_tag(a:tag, a:value)
endfunction

function! taskpaper#date()
    return strftime(g:task_paper_date_format, localtime())
endfunction

function! taskpaper#next_project()
    call search('^\t*\zs.\+:\(\s\+@[^\s(]\+\(([^)]*)\)\?\)*$', 'w')
endfunction

function! taskpaper#previous_project()
    call search('^\t*\zs.\+:\(\s\+@[^\s(]\+\(([^)]*)\)\?\)*$', 'bw')
endfunction

function! taskpaper#move(projects, ...)
    let lnum = a:0 > 0 ? a:1 : line('.')

    let save_fen = &l:foldenable
    let save_reg = [getreg('a'), getregtype('a')]

    setlocal nofoldenable

    let depth = len(matchstr(getline(lnum), '^\t*'))
    let range = [lnum, lnum]

    for l in range(lnum + 1, line('$'))
	let line = getline(l)

	if line =~ '^\s*$'
	    continue
	elseif depth < len(matchstr(line, '^\t*'))
            let range[1] = l
        else
            break
        endif
    endfor

    silent execute join(range, ',') . 'delete a'
    let deleted = range[1] - range[0] + 1

    let project_depth = 0
    call cursor(1, 1)

    for project in a:projects
        if !search('\v^\t{' . project_depth . '}\V' . project . ':', 'c')
            normal! u
	    call setreg('a', save_reg[0], save_reg[1])
	    let &l:foldenable = save_fen
            echoe "project is not found: " . project
            return -1
        endif
        let project_depth += 1
    endfor

    put a

    let tabs = repeat("\t", project_depth)
    silent execute "'[,']" . 's/^\t\{' . depth . '\}/' . tabs

    call setreg('a', save_reg[0], save_reg[1])
    let &l:foldenable = save_fen

    return deleted
endfunction

function! taskpaper#update_project()
    let indent = matchstr(getline("."), '^\t*')
    let depth = len(indent)

    let projects = []

    for linenr in range(line('.'), 1, -1)
        let line = getline(linenr)
        let ml = matchlist(line, '\v^\t{0,' . depth . '}([^\t:]+):')
        if empty(ml)
            continue
        endif

        let project = ml[1]
        if project != ""
            call add(projects, project)

            let indent = matchstr(line, '^\t*')
            let depth = len(indent) - 1

            if depth < 0
                break
            endif
        endif
    endfor

    call taskpaper#update_tag('project', join(reverse(projects), ' / '))
endfunction

function! taskpaper#archive_done()
    let archive_start = search('^' . g:task_paper_archive_project . ':', 'cw')
    if archive_start == 0
        call append('$', g:task_paper_archive_project . ':')
        let archive_start = line('$')
        let archive_end = 0
    else
        let archive_end = search('^\S\+:', 'W')
    endif

    call cursor(1, 1)
    let moved = 0

    while 1
        let line = search('@done', 'W', archive_start - moved)
        if line != 0 && line < archive_start
            call taskpaper#update_project()
            let moved += taskpaper#move([g:task_paper_archive_project])
            call cursor(line, 1)
        else
            break
        endif
    endwhile

    if archive_end != 0
        call cursor(archive_end, 1)

        while 1
            let line = search('@done', 'W')
            if line != 0 && line < line('$')
                call taskpaper#update_project()
                let moved += taskpaper#move([g:task_paper_archive_project])
                call cursor(line, 1)
            else
                break
            endif
        endwhile
    endif

    return moved
endfunction

function! taskpaper#fold(lnum, pat)
    let line = getline(a:lnum)
    let level = foldlevel(a:lnum)

    if line =~? a:pat
	return 0
    elseif synIDattr(synID(a:lnum, 1, 1), "name") != 'taskpaperProject'
	return 1
    elseif level != -1
	return level
    endif

    let depth = len(matchstr(getline(a:lnum), '^\t*'))

    for lnum in range(a:lnum + 1, line('$'))
	let line = getline(lnum)

        if depth >= len(matchstr(line, '^\t*'))
	    break
	endif

	if line =~? a:pat
	    return 0
	endif
    endfor
    return 1
endfunction

function! taskpaper#search(...)
    let pat = a:0 > 0 ? a:1 : input('Search: ')
    if pat == ''
	return
    endif

    setlocal foldexpr=taskpaper#fold(v:lnum,pat)
    setlocal foldminlines=0 foldtext=''
    setlocal foldmethod=expr foldlevel=0 foldenable
endfunction

function! taskpaper#search_tag(...)
    if a:0 > 0
	let tag = a:1
    else
	let cword = expand('<cword>')
	let tag = input('Tag: ', cword =~ '@\k\+' ? cword[1:] : '')
    endif

    if tag != ''
	call taskpaper#search('\<@' . tag . '\>')
    endif
endfunction

function! taskpaper#_fold_projects(lnum)
    if synIDattr(synID(a:lnum, 1, 1), "name") != 'taskpaperProject'
	return '='
    endif

    let line = getline(a:lnum)
    let depth = len(matchstr(line, '^\t*'))
    return '>' . (depth + 1)
endfunction

function! taskpaper#fold_projects()
    setlocal foldexpr=taskpaper#_fold_projects(v:lnum)
    setlocal foldminlines=0 foldtext=foldtext()
    setlocal foldmethod=expr foldlevel=0 foldenable
endfunction

function! taskpaper#newline()
    let lnum = line('.')
    let line = getline('.')

    if lnum == 1 || line !~ '^\s*$' ||
    \  synIDattr(synID(lnum - 1, 1, 1), "name") != 'taskpaperProject'
	return ''
    endif

    let pline = getline(lnum - 1)
    let depth = len(matchstr(pline, '^\t*'))
    call setline(lnum, repeat("\t", depth + 1) . '- ')

    return "\<End>"
endfunction

let &cpo = s:save_cpo
