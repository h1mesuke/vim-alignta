" alignta.vim test suite

let tc = unittest#testcase(expand('<sfile>:p'))
let tc.context_file = expand('<sfile>:p:h') . '/data.txt'

"-----------------------------------------------------------------------------
" ASCII

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

function! tc.test_align_2()
  let tag = 'align_2'
  execute ':' . s:data_range(tag) . 'Alignta ={2}'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_n()
  let tag = 'align_n'
  execute ':' . s:data_range(tag) . 'Alignta ={+}'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_mp()
  let tag = 'align_mp'
  execute ':' . s:data_range(tag) . 'Alignta = /* */'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

"---------------------------------------
" Padding

" \d notation
function! tc.test_align_0pad()
  let tag = 'align_0pad'
  execute ':' . s:data_range(tag) . 'Alignta <<<0 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_3pad()
  let tag = 'align_3pad'
  execute ':' . s:data_range(tag) . 'Alignta <<<3 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

" \d\d notation
function! tc.test_align_00pad()
  let tag = 'align_0pad'
  execute ':' . s:data_range(tag) . 'Alignta <<<00 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_lpad()
  let tag = 'align_lpad'
  execute ':' . s:data_range(tag) . 'Alignta <<<31 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_rpad()
  let tag = 'align_rpad'
  execute ':' . s:data_range(tag) . 'Alignta <<<13 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

" \d\+:\d\+ notation
function! tc.test_align_00pad_colon()
  let tag = 'align_0pad'
  execute ':' . s:data_range(tag) . 'Alignta <<<0:0 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_lpad_colon()
  let tag = 'align_lpad'
  execute ':' . s:data_range(tag) . 'Alignta <<<3:1 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_rpad_colon()
  let tag = 'align_rpad'
  execute ':' . s:data_range(tag) . 'Alignta <<<1:3 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

"-----------------------------------------------------------------------------
" Multi-byte

function! tc.test_mb_align_1()
  let tag = 'mb_align_1'
  execute ':' . s:data_range(tag) . 'Alignta ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_mb_align_1_lll()
  let tag = 'mb_align_1_lll'
  execute ':' . s:data_range(tag) . 'Alignta <<< ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_mb_align_1_ccc()
  let tag = 'mb_align_1_ccc'
  execute ':' . s:data_range(tag) . 'Alignta ||| ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_mb_align_1_rrr()
  let tag = 'mb_align_1_rrr'
  execute ':' . s:data_range(tag) . 'Alignta >>> ＝'
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
  call self.puts(a:lines)
endfunction

unlet tc

" vim: filetype=vim
