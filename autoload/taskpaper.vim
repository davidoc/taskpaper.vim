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
    let value = a:0 > 0 ? a:1 : ''
    return s:add_delete_tag(a:tag, value, 1)
endfunction

function! taskpaper#delete_tag(tag, ...)
    let value = a:0 > 0 ? a:1 : ''
    return s:add_delete_tag(a:tag, value, 0)
endfunction

function! taskpaper#toggle_tag(tag, ...)
    let value = a:0 > 0 ? a:1 : ''
    if !taskpaper#delete_tag(a:tag, '')
        call taskpaper#add_tag(a:tag, value)
    endif
endfunction

function! taskpaper#update_tag(tag, value)
    call taskpaper#delete_tag(a:tag, '')
    call taskpaper#add_tag(a:tag, a:value)
endfunction

function! taskpaper#move(projects, ...)
    let line = a:0 > 0 ? a:1 : line('.')

    let save_reg = [getreg('a'), getregtype('a')]
    call setreg('a', '')

    let depth = len(matchstr(getline(line), '^\t*'))
    let range = [line, line]

    for l in range(line + 1, line('$'))
        if depth < len(matchstr(getline(l), '^\t*'))
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
            echoe "project is not found: " . project
            return -1
        endif
        let project_depth += 1
    endfor

    let tabs = repeat("\t", project_depth)
    call setreg('a', substitute(getreg('a'), '\v(^|\n)\t{' . depth . '}',
    \           '\1' . tabs, 'g'))

    put a

    call setreg('a', save_reg[0], save_reg[1])

    return deleted
endfunction

function! taskpaper#toggle_done()
    let today = strftime(g:task_paper_date_format, localtime())
    call taskpaper#toggle_tag('done', today)
endfunction

function! taskpaper#toggle_cancelled()
    let today = strftime(g:task_paper_date_format, localtime())
    call taskpaper#toggle_tag('cancelled', today)
endfunction

function! taskpaper#update_project()
    let indent = matchstr(getline("."), '^\t*')
    let depth = len(indent) - 1

    let projects = []

    for linenr in range(line('.') - 1, 1, -1)
        let line = getline(linenr)
        let ml = matchlist(line, '\v^\t{,' . depth . '}([^\t:]+):')
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
            else
                break
            endif
        endwhile
    endif

    return moved
endfunction

let &cpo = s:save_cpo
