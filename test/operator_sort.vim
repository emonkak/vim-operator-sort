silent packadd! vim-operator-user

silent runtime! plugin/operator/sort.vim

function! s:test_characterwise() abort
  let source = '1 a 3 c 21 123 -32 b 2 12'

  call s:do_test("\<Plug>(operator-sort)$ ", source, [
  \   '-32 1 12 123 2 21 3 a b c',
  \ ])

  call s:do_test("\<Plug>(operator-sort!)$ ", source, [
  \   'c b a 3 21 2 123 12 1 -32',
  \ ])

  call s:do_test("\<Plug>(operator-sort-numeric)$ ", source, [
  \   'a b c -32 1 2 3 12 21 123',
  \ ])

  call s:do_test("\<Plug>(operator-sort-numeric!)$ ", source, [
  \   '123 21 12 3 2 1 -32 c b a',
  \ ])

  let source = '1, a, 3, c, 21, 123, -32, b, 2, 12'

  call s:do_test("\<Plug>(operator-sort)$,", source, [
  \   '-32, 1, 12, 123, 2, 21, 3, a, b, c',
  \ ])

  call s:do_test("\<Plug>(operator-sort!)$,", source, [
  \   'c, b, a, 3, 21, 2, 123, 12, 1, -32',
  \ ])

  call s:do_test("\<Plug>(operator-sort-numeric)$,", source, [
  \   'a, b, c, -32, 1, 2, 3, 12, 21, 123',
  \ ])

  call s:do_test("\<Plug>(operator-sort-numeric!)$,", source, [
  \   '123, 21, 12, 3, 2, 1, -32, c, b, a',
  \ ])
endfunction

function! s:test_linewise() abort
  let source = [
  \   '1',
  \   'a',
  \   '3',
  \   'c',
  \   '21',
  \   '123',
  \   '-32',
  \   'b',
  \   '2',
  \   '12',
  \ ]

  call s:do_test("\<Plug>(operator-sort)G", source, [
  \   '-32',
  \   '1',
  \   '12',
  \   '123',
  \   '2',
  \   '21',
  \   '3',
  \   'a',
  \   'b',
  \   'c',
  \ ])

  call s:do_test("\<Plug>(operator-sort!)G", source, [
  \   'c',
  \   'b',
  \   'a',
  \   '3',
  \   '21',
  \   '2',
  \   '123',
  \   '12',
  \   '1',
  \   '-32',
  \ ])

  call s:do_test("\<Plug>(operator-sort-numeric)G", source, [
  \   'a',
  \   'c',
  \   'b',
  \   '-32',
  \   '1',
  \   '2',
  \   '3',
  \   '12',
  \   '21',
  \   '123',
  \ ])

  call s:do_test("\<Plug>(operator-sort-numeric!)G", source, [
  \   '123',
  \   '21',
  \   '12',
  \   '3',
  \   '2',
  \   '1',
  \   '-32',
  \   'b',
  \   'c',
  \   'a',
  \ ])
endfunction

function! s:do_test(key_strokes, source, expected_result) abort
  new
  call setline(1, a:source)
  0verbose call feedkeys(a:key_strokes, 'x')
  call assert_equal(a:expected_result, getline(1, line('$')))
  close!
endfunction
