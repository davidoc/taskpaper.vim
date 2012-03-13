" plugin to handle the TaskPaper to-do list format
" Language:     Taskpaper (http://hogbaysoftware.com/projects/taskpaper)
" Maintainer:   David O'Callaghan <david.ocallaghan@cs.tcd.ie>
" URL:          https://github.com/davidoc/taskpaper.vim
" Last Change:  2012-03-07

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

function! taskpaper#swap_tag(oldtag, newtag)
    call taskpaper#delete_tag(a:oldtag)
    call taskpaper#add_tag(a:newtag, '')
endfunction

function! taskpaper#swap_tags(oldtags, newtags)
    for oldtag in a:oldtags
        call taskpaper#delete_tag(oldtag)
    endfor
    for newtag in a:newtags
        call taskpaper#add_tag(newtag, '')
    endfor
endfunction

function! taskpaper#toggle_tag(tag, ...)
    if !taskpaper#delete_tag(a:tag, '')
        let args = a:0 > 0 ? [a:tag, a:1] : [a:tag]
        call call("taskpaper#add_tag", args)
    endif
endfunction

function! taskpaper#has_tag(tag)
    let cur_line = getline(".")
    let m = matchstr(cur_line, '@'.a:tag)
    if m != ''
        return 1
    else
        return 0
endfunction

function! taskpaper#cycle_tags(...)
    let tags_index = 0
    let tag_list = a:000
    let tag_added = 0
    for tag_name in tag_list
        let tags_index = tags_index + 1
        if tags_index == len(tag_list)
            let tags_index = 0
        endif
        let has_tag = taskpaper#has_tag(tag_name)
        if has_tag == 1
            let tag_added = 1
            call taskpaper#delete_tag(tag_name)
            let new_tag = tag_list[tags_index]
            if new_tag != ''
                call taskpaper#add_tag(new_tag, '')
            endif
            break
        endif
    endfor
    if tag_added == 0
        call taskpaper#add_tag(tag_list[0], '')
    endif
endfunction

function! taskpaper#update_tag(tag, ...)
    call taskpaper#delete_tag(a:tag, '')
    let args = a:0 > 0 ? [a:tag, a:1] : [a:tag]
    call call("taskpaper#add_tag", args)
endfunction

function! taskpaper#date()
    return strftime(g:task_paper_date_format, localtime())
endfunction

function! taskpaper#complete_project(lead, cmdline, pos)
    let lnum = 1
    let list = []
    let stack = ['']
    let depth = 0

    while lnum <= line('$')
        let line = getline(lnum)
        let ml = matchlist(line, '\v\C^\t*(.+):(\s+\@[^ \t(]+(\([^)]*\))?)*$')

        if !empty(ml)
            let d = len(matchstr(line, '^\t*'))

            while d < depth
                call remove(stack, -1)
                let depth -= 1
            endwhile

            while d > depth
                call add(stack, '')
                let depth += 1
            endwhile

            let stack[d] = ml[1]

            let candidate = join(stack, ':')
            if candidate =~ '^' . a:lead
                call add(list, join(stack, ':'))
            endif
        endif

        let lnum += 1
    endwhile

    return list
endfunction

function! taskpaper#go_to_project()
    let res = input('Project: ', '', 'customlist,taskpaper#complete_project')

    if res != ''
        call taskpaper#search_project(split(res, ':'))
    endif
endfunction

function! taskpaper#next_project()
    return search('^\t*\zs.\+:\(\s\+@[^\s(]\+\(([^)]*)\)\?\)*$', 'w')
endfunction

function! taskpaper#previous_project()
    return search('^\t*\zs.\+:\(\s\+@[^\s(]\+\(([^)]*)\)\?\)*$', 'bw')
endfunction

function! s:search_project(project, depth, begin, end)
    call cursor(a:begin, 1)
    return search('\v^\t{' . a:depth . '}\V' . a:project . ':', 'c', a:end)
endfunction

function! taskpaper#search_project(projects)
    if empty(a:projects)
        return 0
    endif

    let save_pos = getpos('.')

    let begin = 1
    let end = line('$')
    let depth = 0

    for project in a:projects
        if !s:search_project(project, depth, begin, end)
            call setpos('.', save_pos)
            return 0
        endif

        let begin = line('.')
        let end = taskpaper#search_end_of_item(begin)
        let depth += 1
    endfor

    call cursor(begin, 1)
    normal! ^

    return begin
endfunction

function! taskpaper#search_end_of_item(...)
    let lnum = a:0 > 0 ? a:1 : line('.')
    let flags = a:0 > 1 ? a:2 : ''

    let depth = len(matchstr(getline(lnum), '^\t*'))

    let end = lnum
    let lnum += 1
    while lnum <= line('$')
        let line = getline(lnum)

        if line =~ '^\s*$'
            " Do nothing
        elseif depth < len(matchstr(line, '^\t*'))
            let end = lnum
        else
            break
        endif

        let lnum += 1
    endwhile

    if flags !~# 'n'
        call cursor(end, 0)
        normal! ^
    endif

    return end
endfunction

function! taskpaper#delete(...)
    let start = a:0 > 0 ? a:1 : line('.')
    let reg = a:0 > 1 ? a:2 : '"'
    let kill_indent = a:0 > 2 ? a:3 : 0

    let reg_save = ''
    if kill_indent && reg =~# '\u'
        let reg = tolower(reg)
        let reg_save = getreg(reg)
    endif

    let save_fen = &l:foldenable
    setlocal nofoldenable

    let depth = len(matchstr(getline(start), '^\t*'))

    let end = taskpaper#search_end_of_item(start)
    silent execute start . ',' . end . 'delete ' . reg

    let &l:foldenable = save_fen

    if kill_indent
        let pat = '\(^\|\n\)\t\{' . depth . '\}'
        let content = substitute(getreg(reg), pat, '\1', 'g')
        if reg_save != ''
            let content = reg_save . content
        endif
        call setreg(reg, content)
    endif

    return end - start + 1
endfunction

function! taskpaper#put(...)
    let projects = a:0 > 0 ? a:1 : []
    let reg = a:0 > 1 ? a:2 : '"'
    let indent = a:0 > 2 ? a:3 : 0

    let save_fen = &l:foldenable
    setlocal nofoldenable

    if !empty(projects) && !taskpaper#search_project(projects)
        let &l:foldenable = save_fen
        return 0
    endif

    if indent > 0
        let project_depth = len(matchstr(getline('.'), '^\t*'))
        let tabs = repeat("\t", project_depth + indent)
    else
        let tabs = ''
    endif

    execute 'put' reg
    silent execute "'[,']" . 's/^\ze./' . tabs

    let &l:foldenable = save_fen

    return line("']") - line("'[") + 1
endfunction

function! taskpaper#move(projects, ...)
    let lnum = a:0 > 0 ? a:1 : line('.')

    let save_fen = &l:foldenable
    setlocal nofoldenable

    if !taskpaper#search_project(a:projects)
        let &l:foldenable = save_fen
        return 0
    endif

    let reg = 'a'
    let save_reg = [getreg(reg), getregtype(reg)]

    let nlines = taskpaper#delete(lnum, reg, 1)
    call taskpaper#put(a:projects, reg, 1)

    let &l:foldenable = save_fen
    call setreg(reg, save_reg[0], save_reg[1])
        if g:task_paper_follow_move == 0
            execute lnum
        endif
    return nlines
endfunction

function! taskpaper#move_to_project()
    let res = input('Project: ', '', 'customlist,taskpaper#complete_project')
    call taskpaper#move(split(res, ':'))
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

    let save_fen = &l:foldenable
    let save_reg = [getreg('a'), getregtype('a')]
    setlocal nofoldenable
    call setreg('a', '')

    call cursor(1, 1)
    let deleted = 0

    while 1
        let lnum = search('@done', 'W', archive_start - deleted)
        if lnum == 0
            break
        endif

        call taskpaper#update_project()
        let deleted += taskpaper#delete(lnum, 'A', 1)
    endwhile

    if archive_end != 0
        call cursor(archive_end, 1)

        while 1
            let lnum = search('@done', 'W')
            if lnum == 0
                break
            endif

            call taskpaper#update_project()
            let deleted += taskpaper#delete(lnum, 'A', 1)
        endwhile
    endif

    if deleted != 0
        call taskpaper#put([g:task_paper_archive_project], 'a', 1)
    else
        echo 'No done items.'
    endif

    let &l:foldenable = save_fen
    call setreg('a', save_reg[0], save_reg[1])

    return deleted
endfunction

function! taskpaper#fold(lnum, pat, ipat)
    let line = getline(a:lnum)
    let level = foldlevel(a:lnum)

    if line =~? a:pat && (a:ipat == '' || line !~? a:ipat)
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

        if line =~? a:pat && (a:ipat == '' || line !~? a:ipat)
            return 0
        endif
    endfor
    return 1
endfunction

function! taskpaper#search(...)
    let pat = a:0 > 0 ? a:1 : input('Search: ')
    let ipat = a:0 > 1 ? a:2 : ''
    if pat == ''
        return
    endif

    setlocal foldexpr=taskpaper#fold(v:lnum,pat,ipat)
    setlocal foldminlines=0 foldtext=''
    setlocal foldmethod=expr foldlevel=0 foldenable
endfunction

function! taskpaper#fold_except_range(lnum, begin, end)
    if a:lnum > a:end
        return 1
    elseif a:lnum >= a:begin
        return 0
    elseif synIDattr(synID(a:lnum, 1, 1), "name") != 'taskpaperProject'
        return 1
    elseif level != -1
        return level
    endif

    if a:end <= taskpaper#search_end_of_item(a:lnum, 'n')
        return 0
    endif

    return 1
endfunction

function! taskpaper#focus_project()
    let pos = getpos('.')

    normal! $
    let begin = taskpaper#previous_project()
    if begin == 0
        call setpos('.', pos)
        return
    endif

    let end = taskpaper#search_end_of_item(begin, 'n')

    " Go to the top level project
    while taskpaper#previous_project()
        if getline('.') =~ '^[^\t]'
            break
        endif
    endwhile

    setlocal foldexpr=taskpaper#fold_except_range(v:lnum,begin,end)
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
        let ipat = (g:task_paper_search_hide_done == 1)?'\<@done\>':''
        call taskpaper#search('\<@' . tag . '\>', ipat)
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


function! taskpaper#tag_style(...)
    if a:0 > 0
        let tag_name = a:1
    endif

    if a:0 > 1
        let tag_style = a:2
        let tag_style_name = 'taskpaperAutoStyle_' . tag_name
        execute 'syn match' tag_style_name  '/\s\zs@'.tag_name.'\(([^)]*)\)\?/'
        execute 'hi' tag_style_name tag_style
        if version < 508
            execute 'hi link'  tag_style_name tag_style_name
        else
            execute 'hi def link' tag_style_name tag_style_name
        endif
    else
        echo "No style specified."
        return ''
    endif
endfunction

function! taskpaper#tag_style_dict(tsd)
    for tag_name in keys(a:tsd)
        call taskpaper#tag_style(tag_name,a:tsd[tag_name])
    endfor
endfunction

let &cpo = s:save_cpo
