" alignta.vim test suite

let tc = unittest#testcase(expand('<sfile>:p'))
let tc.context_file = expand('<sfile>:p:h') . '/data.txt'

"-----------------------------------------------------------------------------
" ASCII

function! tc.test_align_1_pattern()
  let tag = 'test_align_1_pattern'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_pattern_lll()
  let tag = 'test_align_1_pattern_lll'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<< ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_pattern_ccc()
  let tag = 'test_align_1_pattern_ccc'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta ||| ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_pattern_rrr()
  let tag = 'test_align_1_pattern_rrr'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta >>> ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_pattern_2_times()
  let tag = 'test_align_1_pattern_2_times'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta ={2}'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_1_pattern_n_times()
  let tag = 'test_align_1_pattern_n_times'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta ={+}'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_multi_patterns()
  let tag = 'test_align_multi_patterns'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta = /* */'
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
function! tc.test_align_0pad_d()
  let tag = 'test_align_0pad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<0 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_3pad_d()
  let tag = 'test_align_3pad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<3 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

" \d\d notation
function! tc.test_align_0pad()
  let tag = 'test_align_0pad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<00 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_lpad()
  let tag = 'test_align_lpad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<31 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_rpad()
  let tag = 'test_align_rpad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<13 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

" \d\+:\d\+ notation
function! tc.test_align_0pad_colon()
  let tag = 'test_align_0pad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<0:0 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_lpad_colon()
  let tag = 'test_align_lpad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<3:1 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_align_rpad_colon()
  let tag = 'test_align_rpad'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<<1:3 ='
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

"---------------------------------------
" Block

function! tc.test_align_block()
  let tag = 'test_align_block'
  let range = s:data_range(tag)
  execute range[0]
  execute "normal! 06l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  execute ":'<,'>Alignta ="
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

"-----------------------------------------------------------------------------
" Multi-byte

function! tc.test_mb_align_1_pattern()
  let tag = 'test_mb_align_1_pattern'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_mb_align_1_pattern_lll()
  let tag = 'test_mb_align_1_pattern_lll'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta <<< ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_mb_align_1_pattern_ccc()
  let tag = 'test_mb_align_1_pattern_ccc'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta ||| ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc.test_mb_align_1_pattern_rrr()
  let tag = 'test_mb_align_1_pattern_rrr'
  execute ':' . join(s:data_range(tag), ',') . 'Alignta >>> ＝'
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equals_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

"---------------------------------------
" Block

function! tc.test_mb_align_block()
  let tag = 'test_mb_align_block'
  let range = s:data_range(tag)
  execute range[0]
  execute "normal! 06l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  execute ":'<,'>Alignta ＝"
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
  call search('^# ' . toupper(a:tag) . '_BEGIN', 'w')
  let from = line('.') + 1
  call search('^# ' . toupper(a:tag) . '_END', 'w')
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

function! tc.print_lines(lines)
  call self.puts()
  call self.puts(a:lines)
endfunction

unlet tc

" vim: filetype=vim
