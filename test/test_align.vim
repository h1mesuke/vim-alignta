" alignta.vim test suite

let tc = unittest#testcase(expand('<sfile>:p'))
let tc.context_file = expand('<sfile>:p:h') . '/data.txt'

function! tc.test_align_1()
  let tag = 'align_1'
  execute ':' . s:data_range(tag) . 'Alignta ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_lll()
  let tag = 'align_1_lll'
  execute ':' . s:data_range(tag) . 'Alignta <<< ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_ccc()
  let tag = 'align_1_ccc'
  execute ':' . s:data_range(tag) . 'Alignta ||| ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_rrr()
  let tag = 'align_1_rrr'
  execute ':' . s:data_range(tag) . 'Alignta >>> ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

"---------------------------------------
" Utils

function! s:tag_range(tag)
  call search('^# TEST_' . toupper(a:tag) . '_BEGIN', 'w')
  let from = line('.') + 1
  call search('^# TEST_' . toupper(a:tag) . '_END', 'w')
  let to = line('.') - 1
  return [from, to]
endfunction

function! s:data_range(tag)
  let range = s:tag_range(a:tag . '_data')
  return range[0] . ',' . range[1]
endfunction

function! s:data_lines(tag)
  let range = s:tag_range(a:tag . '_data')
  return getline(range[0], range[1])
endfunction

function! s:expected_lines(tag)
  let range = s:tag_range(a:tag . '_expected')
  return getline(range[0], range[1])
endfunction

function! tc.print_lines(lines)
  call self.puts()
  for line in a:lines
    call self.puts(line)
  endfor
endfunction

unlet tc

" vim: filetype=vim
