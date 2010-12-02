" alignta.vim test suite

let tc = unittest#testcase(expand('<sfile>:p'))
let tc.context_file = expand('<sfile>:p:h') . '/data.txt'

"=============================================================================
" Padding Alignment

function! tc.test_align_1_pattern()
  call self._test_align('1_pattern', 'Alignta =')
endfunction

function! tc.test_align_1_pattern_lll()
  call self._test_align('1_pattern_lll', 'Alignta <<< =')
endfunction

function! tc.test_align_1_pattern_ccc()
  call self._test_align('1_pattern_ccc', 'Alignta ||| =')
endfunction

function! tc.test_align_1_pattern_rrr()
  call self._test_align('1_pattern_rrr', 'Alignta >>> =')
endfunction

function! tc.test_align_1_pattern_lcr()
  call self._test_align('1_pattern_lcr', 'Alignta <|> =')
endfunction

function! tc.test_align_1_pattern_rcl()
  call self._test_align('1_pattern_rcl', 'Alignta >|< =')
endfunction

function! tc.test_align_1_pattern_2_times()
  call self._test_align('1_pattern_2_times', 'Alignta ={2}')
endfunction

function! tc.test_align_1_pattern_2_times_lll()
  call self._test_align('1_pattern_2_times_lll', 'Alignta <<< ={2}')
endfunction

function! tc.test_align_1_pattern_2_times_ccc()
  call self._test_align('1_pattern_2_times_ccc', 'Alignta ||| ={2}')
endfunction

function! tc.test_align_1_pattern_2_times_rrr()
  call self._test_align('1_pattern_2_times_rrr', 'Alignta >>> ={2}')
endfunction

function! tc.test_align_1_pattern_2_times_lcr()
  call self._test_align('1_pattern_2_times_lcr', 'Alignta <|> ={2}')
endfunction

function! tc.test_align_1_pattern_2_times_rcl()
  call self._test_align('1_pattern_2_times_rcl', 'Alignta >|< ={2}')
endfunction

function! tc.test_align_1_pattern_n_times()
  call self._test_align('1_pattern_n_times', 'Alignta ={+}')
endfunction

function! tc.test_align_1_pattern_n_times_lll()
  call self._test_align('1_pattern_n_times_lll', 'Alignta <<< ={+}')
endfunction

function! tc.test_align_1_pattern_n_times_ccc()
  call self._test_align('1_pattern_n_times_ccc', 'Alignta ||| ={+}')
endfunction

function! tc.test_align_1_pattern_n_times_rrr()
  call self._test_align('1_pattern_n_times_rrr', 'Alignta >>> ={+}')
endfunction

function! tc.test_align_1_pattern_n_times_lcr()
  call self._test_align('1_pattern_n_times_lcr', 'Alignta <|> ={+}')
endfunction

function! tc.test_align_1_pattern_n_times_rcl()
  call self._test_align('1_pattern_n_times_rcl', 'Alignta >|< ={+}')
endfunction

function! tc.test_align_multi_patterns()
  call self._test_align('multi_patterns', 'Alignta = /* */')
endfunction

function! tc.test_align_multi_patterns_lll()
  call self._test_align('multi_patterns_lll', 'Alignta <<< = /* */')
endfunction

function! tc.test_align_multi_patterns_ccc()
  call self._test_align('multi_patterns_ccc', 'Alignta ||| = /* */')
endfunction

function! tc.test_align_multi_patterns_rrr()
  call self._test_align('multi_patterns_rrr', 'Alignta >>> = /* */')
endfunction

function! tc.test_align_multi_patterns_lcr()
  call self._test_align('multi_patterns_lcr', 'Alignta <|> = /* */')
endfunction

function! tc.test_align_multi_patterns_rcl()
  call self._test_align('multi_patterns_rcl', 'Alignta >|< = /* */')
endfunction

function! tc.test_align_complex_multi_patterns()
  call self._test_align('complex_multi_patterns', 'Alignta = : /* */')
endfunction

function! tc.test_align_complex_multi_patterns_lll()
  call self._test_align('complex_multi_patterns_lll', 'Alignta <<< = : /* */')
endfunction

function! tc.test_align_complex_multi_patterns_ccc()
  call self._test_align('complex_multi_patterns_ccc', 'Alignta ||| = : /* */')
endfunction

function! tc.test_align_complex_multi_patterns_rrr()
  call self._test_align('complex_multi_patterns_rrr', 'Alignta >>> = : /* */')
endfunction

function! tc.test_align_complex_multi_patterns_lcr()
  call self._test_align('complex_multi_patterns_lcr', 'Alignta <|> = : /* */')
endfunction

function! tc.test_align_complex_multi_patterns_rcl()
  call self._test_align('complex_multi_patterns_rcl', 'Alignta >|< = : /* */')
endfunction

" need to restruct
function! tc.test_align_blank_L_flds()
  call self._test_align('blank_L_flds', 'Alignta! \w\+')
endfunction

function! tc.test_align_freeze_aligned()
  call self._test_align('freeze_aligned', 'Alignta! \S\+{+}')
endfunction

"---------------------------------------
" Block

function! tc.test_align_block()
  call self._test_align('block', 'Alignta =')
endfunction

function! tc.test_align_block_with_ragged_rights()
  call self._test_align('block_with_ragged_rights', 'Alignta =')
endfunction

function! tc.test_align_block_with_short_rights()
  call self._test_align('block_with_short_rights', 'Alignta =')
endfunction

function! tc.test_align_block_has_tab()
  let tag = 'test_align_block_has_tab'
  let range = s:data_range(tag)
  execute range[0]
  execute "normal! 06l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  call assert#raise(":'<,'>Alignta =", 'tabs')
endfunction

"---------------------------------------
" Padding

" \d notation
function! tc.test_align_0pad_d()
  call self._test_align('0pad', 'Alignta <<<0 =')
endfunction

function! tc.test_align_3pad_d()
  call self._test_align('3pad', 'Alignta <<<3 =')
endfunction

" \d\d notation
function! tc.test_align_0pad_dd()
  call self._test_align('0pad', 'Alignta <<<00 =')
endfunction

function! tc.test_align_lpad_dd()
  call self._test_align('lpad', 'Alignta <<<31 =')
endfunction

function! tc.test_align_rpad()
  call self._test_align('rpad', 'Alignta <<<13 =')
endfunction

" \d\+:\d\+ notation
function! tc.test_align_0pad_d_colon_d()
  call self._test_align('0pad', 'Alignta <<<0:0 =')
endfunction

function! tc.test_align_lpad_d_colon_d()
  call self._test_align('lpad', 'Alignta <<<3:1 =')
endfunction

function! tc.test_align_rpad_d_colon_d()
  call self._test_align('rpad', 'Alignta <<<1:3 =')
endfunction

"---------------------------------------
" Regex

function! tc.test_align_regex_1_pattern()
  call self._test_align('regex_1_pattern', 'Alignta! \d\+')
endfunction

function! tc.test_align_regex_1_pattern_2_times()
  call self._test_align('regex_1_pattern_2_times', 'Alignta! \d\+{2}')
endfunction

function! tc.test_align_regex_1_pattern_n_times()
  call self._test_align('regex_1_pattern_n_times', 'Alignta! \d\+{+}')
endfunction

"---------------------------------------
" Tabs

function! tc.test_align_region_has_tab()
  let save_confirm = g:alignta_confirm_for_retab
  let g:alignta_confirm_for_retab = 0

  call self._test_align('region_has_tab', 'Alignta =')

  let g:alignta_confirm_for_retab = save_confirm
endfunction

function! tc.test_align_region_has_tab_noexpandtab()
  let save_confirm = g:alignta_confirm_for_retab
  let g:alignta_confirm_for_retab = 0

  let save_expandtab = &l:expandtab
  setlocal noexpandtab

  call self._test_align('region_has_tab_noexpandtab', 'Alignta =')

  let &l:expandtab = save_expandtab
  let g:alignta_confirm_for_retab = save_confirm
endfunction

"=============================================================================
" Shifting Alignment

function! tc.test_align_shift_1_pattern()
  call self._test_align('shift_1_pattern', 'Alignta <= b')
endfunction

function! tc.test_align_shift_1_pattern_l()
  call self._test_align('shift_1_pattern_l', 'Alignta <= b')
endfunction

function! tc.test_align_shift_1_pattern_c()
  call self._test_align('shift_1_pattern_c', 'Alignta |= b')
endfunction

function! tc.test_align_shift_1_pattern_r()
  call self._test_align('shift_1_pattern_r', 'Alignta >= b')
endfunction

function! tc.test_align_shift_1_pattern_2_times()
  call self._test_align('shift_1_pattern_2_times', 'Alignta! <= b\+{2}')
endfunction

function! tc.test_align_shift_1_pattern_n_times()
  call self._test_align('shift_1_pattern_n_times', 'Alignta! <= b\+{+}')
endfunction

"---------------------------------------
" Padding

function! tc.test_align_shift_0pad()
  call self._test_align('shift_0pad', 'Alignta <=0 b')
endfunction

function! tc.test_align_shift_3pad()
  call self._test_align('shift_3pad', 'Alignta <=3 b')
endfunction

"---------------------------------------
" Block

function! tc.test_align_shift_block()
  call self._test_align('shift_block', 'Alignta <= b')
endfunction

"=============================================================================
" Multi-byte

function! tc.test_align_mb_1_pattern()
  call self._test_align('mb_1_pattern', 'Alignta ＝')
endfunction

function! tc.test_align_mb_1_pattern_lll()
  call self._test_align('mb_1_pattern_lll', 'Alignta <<< ＝')
endfunction

function! tc.test_align_mb_1_pattern_ccc()
  call self._test_align('mb_1_pattern_ccc', 'Alignta ||| ＝')
endfunction

function! tc.test_align_mb_1_pattern_rrr()
  call self._test_align('mb_1_pattern_rrr', 'Alignta >>> ＝')
endfunction

"---------------------------------------
" Block

function! tc.test_align_mb_block()
  call self._test_align('mb_block', 'Alignta ＝')
endfunction

function! tc.test_align_mb_block_is_broken()
  let tag = 'test_align_mb_block_is_broken'
  let range = s:data_range(tag)
  execute range[0]
  execute "normal! 06l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  call assert#raise(":'<,'>Alignta ＝", 'broken')
endfunction

"=============================================================================
" Misc

"---------------------------------------
" -p

function! tc.test_align_pattern_escape()
  call self._test_align('pattern_escape', 'Alignta -p <<<')
endfunction

function! tc.test_align_pattern_escape_escape()
  call self._test_align('pattern_escape_escape', 'Alignta -p -p')
endfunction

"-----------------------------------------------------------------------------
" Utils

function! tc._test_align(tag, align_command)
  let tag = 'test_align_' . a:tag
  if tag =~# '_block'
    call self._test_align_block(tag, a:align_command)
    return
  endif
  execute ':' . join(s:data_range(tag), ',') . a:align_command
  let value = s:data_lines(tag)
  silent undo
  let expected = s:expected_lines(tag)
  call assert#equal_C(expected, value)
  call self.print_lines(expected)
  call self.print_lines(value)
endfunction

function! tc._test_align_block(tag, align_command)
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
  for line in a:lines
    call self.puts(string(line))
  endfor
endfunction

unlet tc

" vim: filetype=vim
