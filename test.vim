#!/bin/env -S bash -c '${VIM-vim} -u NONE -i NONE -N -n -e -s --cmd "source %" $0'

function s:run(runtime_dir) abort
  set noswapfile

  let &runtimepath .= ',' . a:runtime_dir
  let &packpath .= ',' . a:runtime_dir

  for test in globpath(a:runtime_dir, 'test/**/*.vim', 0, 1)
    source `=test`
  endfor

  let script_paths = {}
  for line in split(execute('0verbose scriptnames'), '\n')
    let matches = matchlist(line, '^\s*\(\d\+\):\s\(.*\)')
    if empty(matches)
      continue
    endif
    let script_num = matches[1]
    let script_path = fnamemodify(matches[2], ':p')
    if stridx(script_path, a:runtime_dir . '/test/') == 0
      let script_paths[script_num] = script_path
    endif
  endfor

  let test_functions = filter(
  \   map(split(execute('0verbose function'), '\n'),
  \       { i, line ->
  \         matchstr(line, '^function \zs<SNR>\d\+_test\%(_\w\+\)\?\>') }),
  \   { i, name -> has_key(script_paths, matchstr(name, '^<SNR>\zs\d\+')) }
  \ )

  echo matchstr(execute('version'), '^\n*\zs[^\n]\+') "\n"
  echo 'running'
  \    len(test_functions)
  \    (len(test_functions) > 1 ? 'tests' : 'test')
  \    "\n"

  let failed = 0
  let passed = 0
  let ignored = 0
  let errors = []
  let start_time = reltime()

  for test_function in test_functions
    let script_num = matchstr(test_function, '^<SNR>\zs\d\+')
    let script_name = fnamemodify(script_paths[script_num], ':t:r')
    let test_name = substitute(test_function, '^<SNR>\d\+_', '', 'I')

    echon script_name '::' test_name ' ... '

    let v:errors = []
    try
      let return_value = call(test_function, [])

      if len(v:errors) > 0
        let messages = map(
        \   copy(v:errors),
        \   { i, message -> substitute(
        \       join(split(message, '\.\.')[1:], "\n"),
        \       '^\S\+\zs\s\zeline\s\d\+:',
        \       "\n",
        \       ''
        \     )
        \   }
        \ )
        let failed += 1
        call add(errors, {
        \   'script_name': script_name,
        \   'test_name': test_name,
        \   'messages': messages,
        \ })
        echon 'FAILED' "\n"
      elseif type(return_value) == v:t_string
        let ignored += 1
        call add(errors, {
        \   'script_name': script_name,
        \   'test_name': test_name,
        \   'messages': [return_value],
        \ })
        echon 'ignored' "\n"
      else
        let passed += 1
        echon 'ok' "\n"
      endif
    catch
      let message = join(split(v:throwpoint, '\.\.')[1:], "\n")
      \             . "\n"
      \             . v:exception
      call add(errors, {
      \   'script_name': script_name,
      \   'test_name': test_name,
      \   'messages': [message],
      \ })
      echon 'FAILED' "\n"
    endtry
  endfor

  let elapsed_time = substitute(reltimestr(reltime(start_time)),
  \                             '^\s*', '', '')

  for error in errors
    echo '----' error.script_name . '::' . error.test_name '----'
    for message in error.messages
      echo message "\n"
    endfor
  endfor

  echo 'test result:'
  \    (failed > 0 ? 'FAILED.' : 'ok.')
  \    passed 'passed;'
  \    failed 'failed;'
  \    ignored 'ignored;'
  \    'finished in' (elapsed_time . 's')
  \    "\n"

  if failed > 0
    cquit!
  else
    qall!
  endif
endfunction

verbose call s:run(expand('<sfile>:p:h'))
