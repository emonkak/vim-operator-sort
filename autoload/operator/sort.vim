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
function! operator#sort#sort(motion_wiseness)  "{{{2
  if a:motion_wiseness == 'char'
    let reg_u = [@", getregtype('"')]

    normal! `[v`]y
    let separater = escape(nr2char(getchar()), '\')
    let [xs, ys] = s:partition(@", '\V\[\n ]\*' . separater . '\[\n ]\*')

    let sorter = {}
    function! sorter.compare(x, y) dict
      return a:x == '' || a:y == '' ? 0 : a:x > a:y ? 1 : -1
    endfunction
    call sort(xs, sorter.compare, sorter)

    let @" = join(map(s:transpose([xs, ys]), 'join(v:val, "")'), '')
    normal! `[v`]P`[

    call setreg('"', reg_u[0], reg_u[1])
  else  " line or block
    '[,']sort
  endif
endfunction




" Misc.  "{{{1
function! s:partition(expr, pattern)  "{{{2
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




function! s:transpose(xss)  "{{{2
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
