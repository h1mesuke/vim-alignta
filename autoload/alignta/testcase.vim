" alignta's test suite

let s:save_cpo = &cpo
set cpo&vim

function! alignta#testcase#class()
  return s:TestCase
endfunction

"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:TestCase = unittest#oop#class#new('TestCase', s:SID, unittest#testcase#class())
let s:TestCase.test_dir = expand('<sfile>:p:h:h:h') . '/test'

function! s:TestCase_initialize(tc_name) dict
  call s:TestCase.super('initialize', self, a:tc_name)
  let self.context_file = s:TestCase.test_dir . '/' . self.name . '.dat'
endfunction
call s:TestCase.method('initialize')

function! s:TestCase_setup() dict
  let self.save_default_options = g:alignta_default_options
  let g:alignta_default_options = '<<<1:1'
endfunction
call s:TestCase.method('setup')

function! s:TestCase_teardown() dict
  let g:alignta_default_options = self.save_default_options
endfunction
call s:TestCase.method('teardown')

function! s:TestCase__test_align(tag, align_command) dict
  execute ':' . join(s:data_range(a:tag), ',') . a:align_command
  let actual = s:data_lines(a:tag)
  silent undo

  let expected = s:expected_lines(a:tag)
  call assert#equal_C(expected, actual)

  call self.print_lines(expected)
  call self.print_lines(actual)
endfunction
call s:TestCase.method('_test_align')

function! s:TestCase__test_align_block(tag, align_command) dict
  call s:select_visual_block(a:tag)
  execute ":'<,'>" . a:align_command
  let actual = s:data_lines(a:tag)
  silent undo

  let expected = s:expected_lines(a:tag)
  call assert#equal_C(expected, actual)

  call self.print_lines(expected)
  call self.print_lines(actual)
endfunction
call s:TestCase.method('_test_align_block')

function! s:goto_data(tag)
  call cursor(s:data_range(a:tag)[0], 1)
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

function! s:TestCase_print_lines(lines) dict
  call self.puts()
  for line in a:lines
    call self.puts(string(line))
  endfor
endfunction
call s:TestCase.method('print_lines')

let &cpo = s:save_cpo
unlet s:save_cpo
