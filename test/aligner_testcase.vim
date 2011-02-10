" alignta's test suite

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
  call s:AlignerTestCase.super('initialize', [a:tc_name], self)
  let self.context_file = s:AlignerTestCase.here . '/' . self.name . '.dat'
endfunction
call s:AlignerTestCase.bind(s:SID, 'initialize')

function! s:AlignerTestCase_setup() dict
  let self.save_default_options = g:alignta_default_options
  let g:alignta_default_options = '<<<1:1'
endfunction
call s:AlignerTestCase.bind(s:SID, 'setup')

function! s:AlignerTestCase_teardown() dict
  let g:alignta_default_options = self.save_default_options
endfunction
call s:AlignerTestCase.bind(s:SID, 'teardown')

function! s:AlignerTestCase__test_align(tag, align_command) dict
  execute ':' . join(s:data_range(a:tag), ',') . a:align_command
  let actual = s:data_lines(a:tag)
  silent undo

  let expected = s:expected_lines(a:tag)
  call assert#equal_C(expected, actual)

  call self.print_lines(expected)
  call self.print_lines(actual)
endfunction
call s:AlignerTestCase.bind(s:SID, '_test_align')

function! s:AlignerTestCase__test_align_block(tag, align_command) dict
  call s:select_visual_block(a:tag)
  execute ":'<,'>" . a:align_command
  let actual = s:data_lines(a:tag)
  silent undo

  let expected = s:expected_lines(a:tag)
  call assert#equal_C(expected, actual)

  call self.print_lines(expected)
  call self.print_lines(actual)
endfunction
call s:AlignerTestCase.bind(s:SID, '_test_align_block')

function! s:goto_data(tag)
  execute s:data_range(a:tag)[0]
  normal! 0
endfunction

function! s:select_visual_block(tag)
  let line_range = s:data_range(a:tag)
  let n_lines = (line_range[1] - line_range[0])

  call s:goto_data(a:tag)
  execute "normal! f|l\<C-v>" . n_lines . "jt|\<Esc>"
endfunction

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
