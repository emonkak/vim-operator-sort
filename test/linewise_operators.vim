runtime! plugin/operator/sort.vim

function! s:before() abort
  new
  put ='1'
  put ='a'
  put ='3'
  put ='c'
  put ='21'
  put ='123'
  put ='-32'
  put ='b'
  put ='2'
  put ='12'
  normal! ggdd
endfunction

function! s:after() abort
  close!
endfunction

function! s:test_linewise_operator_sort() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort)
  normal _G
  call assert_equal(['-32', '1', '12', '123', '2', '21', '3', 'a', 'b', 'c'], getline(1, '$'))
  call s:after()
endfunction

function! s:test_linewise_operator_sort_descending() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort-descending)
  normal _G
  call assert_equal(['c', 'b', 'a', '3', '21', '2', '123', '12', '1', '-32'], getline(1, '$'))
  call s:after()
endfunction

function! s:test_linewise_operator_sort_numeric() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort-numeric)
  normal _G
  call assert_equal(['a', 'c', 'b', '-32', '1', '2', '3', '12', '21', '123'], getline(1, '$'))
  call s:after()
endfunction

function! s:test_linewise_operator_sort_numeric_descending() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort-numeric-descending)
  normal _G
  call assert_equal(['123', '21', '12', '3', '2', '1', '-32', 'a', 'c', 'b'], getline(1, '$'))
  call s:after()
endfunction

call s:test_linewise_operator_sort()
call s:test_linewise_operator_sort_descending()
call s:test_linewise_operator_sort_numeric()
" call s:test_linewise_operator_sort_numeric_descending()
