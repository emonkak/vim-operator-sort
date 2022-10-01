runtime! plugin/operator/sort.vim

function! s:before() abort
  new
  put ='1 a 3 c 21 123 -32 b 2 12'
  normal! ggdd
endfunction

function! s:after() abort
  close!
endfunction

function! s:test_characterwise_operator_sort() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort)
  execute 'normal _$ '
  call assert_equal(['-32', '1', '12', '123', '2', '21', '3', 'a', 'b', 'c'], split(getline(1), ' '))
  call s:after()
endfunction

function! s:test_characterwise_operator_sort_descending() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort-descending)
  execute 'normal _$ '
  call assert_equal(['c', 'b', 'a', '3', '21', '2', '123', '12', '1', '-32'], split(getline(1), ' '))
  call s:after()
endfunction

function! s:test_characterwise_operator_sort_numeric() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort-numeric)
  execute 'normal _$ '
  call assert_equal(['a', 'c', 'b', '-32', '1', '2', '3', '12', '21', '123'], split(getline(1), ' '))
  call s:after()
endfunction

function! s:test_characterwise_operator_sort_numeric_descending() abort
  call s:before()
  map <buffer> _ <Plug>(operator-sort-numeric-descending)
  execute 'normal _$ '
  call assert_equal(['123', '21', '12', '3', '2', '1', '-32', 'a', 'c', 'b'], split(getline(1), ' '))
  call s:after()
endfunction

call s:test_characterwise_operator_sort()
call s:test_characterwise_operator_sort_descending()
call s:test_characterwise_operator_sort_numeric()
call s:test_characterwise_operator_sort_numeric_descending()
