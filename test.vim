#!/usr/bin/env -S vim -u NONE -i NONE -N -n -e -s --cmd "source %"

function s:run(root)
  let &runtimepath .= ',' . a:root
  let &runtimepath .= ',' . a:root . '/test/.deps/*'

  for test in globpath(a:root, 'test/**/*.vim', 0, 1)
    source `=test`
  endfor

  redir => OUTPUT
  silent 0verbose scriptnames
  redir END

  let script_names = map(
  \   split(OUTPUT, '\n'),
  \   { i, line -> fnamemodify(matchstr(line, '^\s*\d\+:\s\zs.*'), ':t:r') }
  \ )

  redir => OUTPUT
  silent 0verbose function
  redir END

  let test_functions = filter(
  \   map(split(OUTPUT, '\n'),
  \       { i, line -> matchstr(line, '^function \zs<SNR>\d\+_test\w\+') }),
  \   { i, name -> name != '' }
  \ )

  let passed = 0
  let errors = []

  echo 'running'
  \    len(test_functions)
  \    (len(test_functions) > 1 ? 'tests' : 'test')
  \    "\n"

  let start_time = reltime()

  for test_function in test_functions
    let script_num = str2nr(matchstr(test_function, '^<SNR>\zs\d\+'), 10)
    let script_name = get(script_names, script_num - 1)
    let test_name = substitute(test_function, '^<SNR>\d\+_', '', 'I')

    echon script_name '::' test_name ' ... '
    let v:errors = []
    try
      call call(test_function, [])

      if len(v:errors) > 0
        let messages = map(
        \   copy(v:errors),
        \   { i, message -> substitute(
        \       get(split(message, '\.\.'), -1),
        \       '^<SNR>\w\+\sline\s\d\+:\zs\s',
        \       "\n",
        \       ''
        \     )
        \   }
        \ )
        call add(errors, {
        \   'script_name': script_name,
        \   'test_name': test_name,
        \   'messages': messages,
        \ })
        echon 'FAILED' "\n"
      else
        let passed += 1
        echon 'ok' "\n"
      endif
    catch
      let message = get(split(v:throwpoint, '\.\.'), -1) . "\n" . v:exception
      call add(errors, {
      \   'script_name': script_name,
      \   'test_name': test_name,
      \   'messages': [message],
      \ })
      echon 'FAILED' "\n"
    endtry
  endfor

  let elapsed_time = trim(reltimestr(reltime(start_time)))

  if len(errors) > 0
    for error in errors
      echo '----' error.script_name . '::' . error.test_name '----'
      for message in error.messages
        echo message
      endfor
      echon "\n"
    endfor
  endif

  echo 'result:'
  \    (len(errors) > 0 ? "FAILED." : "ok.")
  \    passed 'passed;'
  \    len(errors) 'failed;'
  \    'finished in' (elapsed_time . 's')
  \    "\n"

  if len(errors) > 0
    cquit!
  else
    qall!
  endif
endfunction

verbose call s:run(expand('<sfile>:p:h'))
