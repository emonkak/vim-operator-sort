" operator-sort - Operator for sort
" Version: 0.0.0
" Copyright (C) 2011 emonkak <emonkak@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! operator#sort#sort(motion_wiseness) abort "{{{2
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(), 0)
  else  " line or block
    '[,']sort
  endif
endfunction




function! operator#sort#sort_descending(motion_wiseness) abort  "{{{2
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(), function('s:compare_descending'))
  else  " line or block
    '[,']sort!
  endif
endfunction




function! operator#sort#sort_numeric(motion_wiseness) abort  "{{{2
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(), function('s:compare_numeric'))
  else  " line or block
    '[,']sort n
  endif
endfunction




function! operator#sort#sort_numeric_descending(motion_wiseness) abort  "{{{2
  if a:motion_wiseness == 'char'
    call s:do_sort_characterwise(s:separator_character(), function('s:compare_numeric_descending'))
  else  " line or block
    '[,']sort n
  endif
endfunction




" Misc.  "{{{1
function! s:do_sort_characterwise(separator, comparer) abort  "{{{2
  let reg_0 = [@0, getregtype('0')]

  normal! `[v`]"0y
  let [xs, ys] = s:partition(@0, '\V\[\n ]\*' . escape(a:separator, '\') . '\[\n ]\*')
  call sort(xs, a:comparer)

  let @0 = join(map(s:transpose([xs, ys]), 'join(v:val, "")'), '')
  normal! `[v`]"0P`[

  call setreg('0', reg_0[0], reg_0[1])
endfunction




function! s:compare_descending(x, y)  "{{{2
  if a:x < a:y
    return 1
  else
    return -1
  end
  return 0
endfunction




function! s:compare_numeric(x, y)  "{{{2
  " Reference: https://github.com/vim/vim/blob/db9ff9ab5d7ce1fcc2c4106e7ad49151a323996c/src/ex_cmds.c#L320
  let x_is_num = s:is_number(a:x)
  let y_is_num = s:is_number(a:y)
  if x_is_num != y_is_num
    return x_is_num - y_is_num
  else
    let x_num = x_is_num ? str2nr(a:x, 10) : 0
    let y_num = y_is_num ? str2nr(a:y, 10) : 0
    return x_num - y_num
  endif
endfunction




function! s:compare_numeric_descending(x, y)  "{{{2
  return s:compare_numeric(a:y, a:x)
endfunction




function! s:is_number(x)  "{{{2
  return a:x =~ '^-\?\d\+'
endfunction




function! s:partition(expr, pattern) abort  "{{{2
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




function! s:separator_character() abort  "{{{2
  return nr2char(getchar())
endfunction




function! s:transpose(xss) abort  "{{{2
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




" __END__  "{{{1
" vim: foldmethod=marker
