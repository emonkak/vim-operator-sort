function! operator#sort#sort(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(), 0)
  else  " line or block
    '[,']sort
  endif
endfunction

function! operator#sort#sort_descending(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(),
    \                            function('s:compare_descending'))
  else  " line or block
    '[,']sort!
  endif
endfunction

function! operator#sort#sort_numeric(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(),
    \                            function('s:compare_numeric'))
  else  " line or block
    '[,']sort n
  endif
endfunction

function! operator#sort#sort_numeric_descending(motion_wiseness) abort
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(),
    \                            function('s:compare_numeric_descending'))
  else  " line or block
    '[,']sort! n
  endif
endfunction

function! s:do_sort_characterwise(separator, comparer) abort
  let reg_0 = [@0, getregtype('0')]

  normal! `[v`]"0y
  let [xs, ys] = s:partition(@0, '\V\[\n ]\*'
  \            . escape(a:separator, '\')
  \            . '\[\n ]\*')
  call sort(xs, a:comparer)

  let @0 = join(map(s:transpose([xs, ys]), 'join(v:val, "")'), '')
  normal! `[v`]"0P`[

  call setreg('0', reg_0[0], reg_0[1])
endfunction

function! s:compare_descending(x, y) abort
  if a:x < a:y
    return 1
  else
    return -1
  end
  return 0
endfunction

function! s:compare_numeric(x, y) abort
  " Reference: https://github.com/vim/vim/blob/db9ff9ab5d7ce1fcc2c4106e7ad49151a323996c/src/ex_cmds.c#L320
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

function! s:compare_numeric_descending(x, y) abort
  return s:compare_numeric(a:y, a:x)
endfunction

function! s:is_number(x) abort
  return a:x =~ '^-\?\d\+'
endfunction

function! s:partition(expr, pattern) abort
  let xs = []
  let ys = []
  let p = 0
  let m = match(a:expr, a:pattern)

  while m > -1
    call add(xs, strpart(a:expr, p, m - p))
    let p = m
    let m = matchend(a:expr, a:pattern, p)
    call add(ys, strpart(a:expr, p, m - p))
    let p = m
    let m = match(a:expr, a:pattern, p)
  endwhile

  if p < len(a:expr)
    call add(xs, strpart(a:expr, p))
  endif

  return [xs, ys]
endfunction

function! s:separator_character() abort
  return nr2char(getchar())
endfunction

function! s:transpose(xss) abort
  let _ = []

  for x in a:xss[0]
    call add(_, [x])
  endfor
  for xs in a:xss[1:]
    for i in range(min([len(_), len(xs)]))
      call add(_[i], xs[i])
    endfor
  endfor

  return _
endfunction
