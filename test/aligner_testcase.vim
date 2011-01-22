" alignta.vim test suite

if exists('s:AlignerTestCase')
  finish
endif

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

let s:AlignerTestCase = unittest#oop#class#new('AlignerTestCase', unittest#testcase#class())
let s:AlignerTestCase.here = expand('<sfile>:p:h')

function! s:AlignerTestCase_initialize(tc_name) dict
  call self.super('initialize', a:tc_name)
  let self.context_file = s:AlignerTestCase.here . '/' . self.name . '.dat'
endfunction
call s:AlignerTestCase.bind(s:SID, 'initialize')

function! s:AlignerTestCase__test(tag, align_command) dict
  if a:tag =~# '_block'
    call self._test_block(a:tag, a:align_command)
    return
  endif
  execute ':' . join(s:data_range(a:tag), ',') . a:align_command
  let value = s:data_lines(a:tag)
  silent undo
  let expected = s:expected_lines(a:tag)
  call assert#equal_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction
call s:AlignerTestCase.bind(s:SID, '_test')

function! s:AlignerTestCase__test_block(tag, align_command) dict
  let range = s:data_range(a:tag)
  execute range[0]
  execute "normal! 06l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  execute ":'<,'>" . a:align_command
  let value = s:data_lines(a:tag)
  silent undo
  let expected = s:expected_lines(a:tag)
  call assert#equal_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction
call s:AlignerTestCase.bind(s:SID, '_test_block')

function! s:tag_range(tag)
  call search('^# ' . a:tag . '_begin', 'w')
  let from = line('.') + 1
  call search('^# ' . a:tag . '_end', 'w')
  let to = line('.') - 1
  return [from, to]
endfunction

function! s:data_range(tag)
  return s:tag_range(a:tag . '_data')
endfunction

function! s:data_lines(tag)
  let range = s:tag_range(a:tag . '_data')
  return getline(range[0], range[1])
endfunction

function! s:expected_lines(tag)
  let range = s:tag_range(a:tag . '_expected')
  return getline(range[0], range[1])
endfunction

function! s:AlignerTestCase_print_lines(lines) dict
  call self.puts()
  for line in a:lines
    call self.puts(string(line))
  endfor
endfunction
call s:AlignerTestCase.bind(s:SID, 'print_lines')

" vim: filetype=vim
