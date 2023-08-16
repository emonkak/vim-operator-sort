function! operator#sort#sort(motion_wiseness) abort
  call s:do_operator(a:motion_wiseness, function('s:compare_asc'))
endfunction

function! operator#sort#sort_numeric(motion_wiseness) abort
  call s:do_operator(a:motion_wiseness, function('s:compare_numeric_asc'))
endfunction

function! operator#sort#sort_numeric_reversed(motion_wiseness) abort
  call s:do_operator(a:motion_wiseness, function('s:compare_numeric_desc'))
endfunction

function! operator#sort#sort_reversed(motion_wiseness) abort
  call s:do_operator(a:motion_wiseness, function('s:compare_desc'))
endfunction

function! s:ask_separator_character() abort
  return nr2char(getchar())
endfunction

function! s:compare_asc(x, y) abort
  if a:x <# a:y
    return -1
  elseif a:x ># a:y
    return 1
  end
  return 0
endfunction

function! s:compare_desc(x, y) abort
  if a:x ># a:y
    return -1
  elseif a:x <# a:y
    return 1
  end
  return 0
endfunction

function! s:compare_numeric_asc(x, y) abort
  " This algorithm is copied from `:sort n` command.
  " https://github.com/vim/vim/blob/v8.0.0000/src/ex_cmds.c#L312
  let x_is_num = s:is_number(a:x)
  let y_is_num = s:is_number(a:y)
  if x_is_num == y_is_num
    if x_is_num
      return str2nr(a:x, 10) - str2nr(a:y, 10)
    else
      return a:x == a:y ? 0 : a:x > a:y ? 1 : -1
    endif
  else
    return x_is_num - y_is_num
  endif
endfunction

function! s:compare_numeric_desc(x, y) abort
  return s:compare_numeric_asc(a:y, a:x)
endfunction

function! s:do_operator(motion_wiseness, comparer) abort
  if a:motion_wiseness == 'char'
    call s:sort_charwise(s:ask_separator_character(), a:comparer)
  elseif a:motion_wiseness ==# 'block'
    call s:sort_blockwise(a:comparer)
  else  " line
    '[,']call s:sort_linewise(a:comparer)
  endif
endfunction

function! s:is_number(x) abort
  return a:x =~ '^\s*-\?\d'
endfunction

function! s:partition(text, pattern) abort
  let xs = []
  let ys = []
  let cursor = 0

  while 1
    let start = match(a:text, a:pattern, cursor)
    if start < 0
      break
    endif
    call add(xs, strpart(a:text, cursor, start - cursor))

    let end = matchend(a:text, a:pattern, start)
    if end <= start
      break
    endif
    call add(ys, strpart(a:text, start, end - start))

    let cursor = end
  endwhile

  if cursor < len(a:text)
    call add(xs, strpart(a:text, cursor))
  endif

  return [xs, ys]
endfunction

function! s:sort_charwise(separator, comparer) abort
  let reg_value = getreg('"')
  let reg_type = getregtype('"')
  try
    let pattern = '\V\%(\n\|\s\)\*\%(\n\|'
    \           . escape(a:separator, '\\')
    \           . '\)\%(\n\|\s\)\*'
    normal! `[v`]""y
    let [xs, ys] = s:partition(@", pattern)
    call sort(xs, a:comparer)
    call setreg(
    \   '"',
    \   join(map(s:transpose([xs, ys]), 'join(v:val, "")'), ''),
    \   'c'
    \ )
    normal! `[v`]""P`[
  finally
    call setreg('"', reg_value, reg_type)
  endtry
endfunction

function! s:sort_blockwise(comparer) abort
  let reg_value = getreg('"')
  let reg_type = getregtype('"')
  try
    execute "normal!" '`['. "\<C-v>" . '`]""y'
    let lines = split(@", "\n")
    call sort(lines, a:comparer)
    call setreg('"', join(lines, "\n"), 'b')
    execute "normal!" '`['. "\<C-v>" . '`]""p'
  finally
    call setreg('"', reg_value, reg_type)
  endtry
endfunction

function! s:sort_linewise(comparer) abort range
  let lines = getline(a:firstline, a:lastline)
  call sort(lines, a:comparer)
  call setline(a:firstline, lines)
endfunction

function! s:transpose(xss) abort
  let results = []

  for x in a:xss[0]
    call add(results, [x])
  endfor
  for xs in a:xss[1:]
    for i in range(min([len(results), len(xs)]))
      call add(results[i], xs[i])
    endfor
  endfor

  return results
endfunction
