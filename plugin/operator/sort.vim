if exists('g:loaded_operator_sort')
  finish
endif

call operator#user#define('sort', 'operator#sort#sort')
call operator#user#define('sort!', 'operator#sort#sort_reversed')
call operator#user#define('sort-numeric', 'operator#sort#sort_numeric')
call operator#user#define('sort-numeric!', 'operator#sort#sort_numeric_reversed')

let g:loaded_operator_sort = 1
