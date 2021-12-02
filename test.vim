#!/usr/bin/env -S vim -u NONE -i NONE -N -n -e -s --cmd "source %"

function s:bootstrap(plugin_dir)
  let &runtimepath .= ',' . a:plugin_dir
  let &runtimepath .= ',' . a:plugin_dir . '/test/.deps/*'

  let v:errors = []

  for test in globpath(a:plugin_dir, 'test/**/*.vim', 0, 1)
    verbose source `=test`
  endfor

  if len(v:errors) > 0
    for error in v:errors
      verbose echo error
    endfor
    cquit!
  else
    qall!
  endif
endfunction

call s:bootstrap(expand('<sfile>:p:h'))
