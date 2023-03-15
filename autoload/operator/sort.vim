function! operator#sort#sort(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:sort_charwise(s:ask_separator_character(),
    \                    function('s:compare'))
  else  " line or block
    '[,']sort
  endif
endfunction

function! operator#sort#sort_numeric(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:sort_charwise(s:ask_separator_character(),
    \                    function('s:compare_numeric'))
  else  " line or block
    '[,']sort n
  endif
endfunction

function! operator#sort#sort_numeric_reversed(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:sort_charwise(s:ask_separator_character(),
    \                    function('s:compare_numeric_reversed'))
  else  " line or block
    '[,']sort! n
  endif
endfunction

function! operator#sort#sort_reversed(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:sort_charwise(s:ask_separator_character(),
    \                    function('s:compare_reversed'))
  else  " line or block
    '[,']sort!
  endif
endfunction

function! s:ask_separator_character() abort
  return nr2char(getchar())
endfunction

function! s:compare_numeric(x, y) abort
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

function! s:compare_numeric_reversed(x, y) abort
  return s:compare_numeric(a:y, a:x)
endfunction

function! s:compare(x, y) abort
  if a:x < a:y
    return -1
  else
    return 1
  end
  return 0
endfunction

function! s:compare_reversed(x, y) abort
  return s:compare(a:y, a:x)
endfunction

function! s:is_number(x) abort
  return a:x =~ '^-\?\d\+'
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
  let reg_u = [@", getregtype('"')]
  let pattern = '\V\%(\n\|\s\)\*\%(\n\|'
  \           . escape(a:separator, '\\')
  \           . '\)\%(\n\|\s\)\*'
  try
    normal! `[v`]""y
    let [xs, ys] = s:partition(@", pattern)
    call sort(xs, a:comparer)

    let @" = join(map(s:transpose([xs, ys]), 'join(v:val, "")'), '')
    normal! `[v`]""P`[
  finally
    call setreg('"', reg_u[0], reg_u[1])
  endtry
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
