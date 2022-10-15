if exists('g:loaded_operator_sort')
  finish
endif

call operator#user#define('sort', 'operator#sort#sort')
call operator#user#define('sort-descending', 'operator#sort#sort_descending')
call operator#user#define('sort-numeric', 'operator#sort#sort_numeric')
call operator#user#define('sort-numeric-descending', 'operator#sort#sort_numeric_descending')

let g:loaded_operator_sort = 1
