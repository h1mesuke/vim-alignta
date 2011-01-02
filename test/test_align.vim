" alignta.vim test suite

let tc = unittest#testcase(expand('<sfile>:p'))
let tc.context_file = expand('<sfile>:p:h') . '/data.txt'

"=============================================================================
" Padding Alignment

function! tc.should_align_at_1_pattern()
  call self._test('should_align_at_1_pattern', 'Alignta =')
endfunction

function! tc.should_align_at_1_pattern_lll()
  call self._test('should_align_at_1_pattern_lll', 'Alignta <<< =')
endfunction

function! tc.should_align_at_1_pattern_ccc()
  call self._test('should_align_at_1_pattern_ccc', 'Alignta ||| =')
endfunction

function! tc.should_align_at_1_pattern_rrr()
  call self._test('should_align_at_1_pattern_rrr', 'Alignta >>> =')
endfunction

function! tc.should_align_at_1_pattern_lcr()
  call self._test('should_align_at_1_pattern_lcr', 'Alignta <|> =')
endfunction

function! tc.should_align_at_1_pattern_rcl()
  call self._test('should_align_at_1_pattern_rcl', 'Alignta >|< =')
endfunction

function! tc.should_align_at_1_pattern_2_times()
  call self._test('should_align_at_1_pattern_2_times', 'Alignta ={2}')
endfunction

function! tc.should_align_at_1_pattern_2_times_lll()
  call self._test('should_align_at_1_pattern_2_times_lll', 'Alignta <<< ={2}')
endfunction

function! tc.should_align_at_1_pattern_2_times_ccc()
  call self._test('should_align_at_1_pattern_2_times_ccc', 'Alignta ||| ={2}')
endfunction

function! tc.should_align_at_1_pattern_2_times_rrr()
  call self._test('should_align_at_1_pattern_2_times_rrr', 'Alignta >>> ={2}')
endfunction

function! tc.should_align_at_1_pattern_2_times_lcr()
  call self._test('should_align_at_1_pattern_2_times_lcr', 'Alignta <|> ={2}')
endfunction

function! tc.should_align_at_1_pattern_2_times_rcl()
  call self._test('should_align_at_1_pattern_2_times_rcl', 'Alignta >|< ={2}')
endfunction

function! tc.should_align_at_1_pattern_n_times()
  call self._test('should_align_at_1_pattern_n_times', 'Alignta ={+}')
endfunction

function! tc.should_align_at_1_pattern_n_times_lll()
  call self._test('should_align_at_1_pattern_n_times_lll', 'Alignta <<< ={+}')
endfunction

function! tc.should_align_at_1_pattern_n_times_ccc()
  call self._test('should_align_at_1_pattern_n_times_ccc', 'Alignta ||| ={+}')
endfunction

function! tc.should_align_at_1_pattern_n_times_rrr()
  call self._test('should_align_at_1_pattern_n_times_rrr', 'Alignta >>> ={+}')
endfunction

function! tc.should_align_at_1_pattern_n_times_lcr()
  call self._test('should_align_at_1_pattern_n_times_lcr', 'Alignta <|> ={+}')
endfunction

function! tc.should_align_at_1_pattern_n_times_rcl()
  call self._test('should_align_at_1_pattern_n_times_rcl', 'Alignta >|< ={+}')
endfunction

function! tc.should_align_at_1_pattern_x_times()
  call self._test('should_align_at_1_pattern_x_times', 'Alignta ={+}')
endfunction

function! tc.should_align_at_1_pattern_x_times_lll()
  call self._test('should_align_at_1_pattern_x_times_lll', 'Alignta <<< ={+}')
endfunction

function! tc.should_align_at_1_pattern_x_times_ccc()
  call self._test('should_align_at_1_pattern_x_times_ccc', 'Alignta ||| ={+}')
endfunction

function! tc.should_align_at_1_pattern_x_times_rrr()
  call self._test('should_align_at_1_pattern_x_times_rrr', 'Alignta >>> ={+}')
endfunction

function! tc.should_align_at_1_pattern_x_times_lcr()
  call self._test('should_align_at_1_pattern_x_times_lcr', 'Alignta <|> ={+}')
endfunction

function! tc.should_align_at_1_pattern_x_times_rcl()
  call self._test('should_align_at_1_pattern_x_times_rcl', 'Alignta >|< ={+}')
endfunction

function! tc.should_align_at_multi_patterns()
  call self._test('should_align_at_multi_patterns', 'Alignta = /* */')
endfunction

function! tc.should_align_at_multi_patterns_lll()
  call self._test('should_align_at_multi_patterns_lll', 'Alignta <<< = /* */')
endfunction

function! tc.should_align_at_multi_patterns_ccc()
  call self._test('should_align_at_multi_patterns_ccc', 'Alignta ||| = /* */')
endfunction

function! tc.should_align_at_multi_patterns_rrr()
  call self._test('should_align_at_multi_patterns_rrr', 'Alignta >>> = /* */')
endfunction

function! tc.should_align_at_multi_patterns_lcr()
  call self._test('should_align_at_multi_patterns_lcr', 'Alignta <|> = /* */')
endfunction

function! tc.should_align_at_multi_patterns_rcl()
  call self._test('should_align_at_multi_patterns_rcl', 'Alignta >|< = /* */')
endfunction

function! tc.should_align_at_complex_multi_patterns()
  call self._test('should_align_at_complex_multi_patterns', 'Alignta = : /* */')
endfunction

function! tc.should_align_at_complex_multi_patterns_lll()
  call self._test('should_align_at_complex_multi_patterns_lll', 'Alignta <<< = : /* */')
endfunction

function! tc.should_align_at_complex_multi_patterns_ccc()
  call self._test('should_align_at_complex_multi_patterns_ccc', 'Alignta ||| = : /* */')
endfunction

function! tc.should_align_at_complex_multi_patterns_rrr()
  call self._test('should_align_at_complex_multi_patterns_rrr', 'Alignta >>> = : /* */')
endfunction

function! tc.should_align_at_complex_multi_patterns_lcr()
  call self._test('should_align_at_complex_multi_patterns_lcr', 'Alignta <|> = : /* */')
endfunction

function! tc.should_align_at_complex_multi_patterns_rcl()
  call self._test('should_align_at_complex_multi_patterns_rcl', 'Alignta >|< = : /* */')
endfunction

"---------------------------------------
" Block

function! tc.should_align_block()
  call self._test('should_align_block', 'Alignta =')
endfunction

function! tc.should_align_block_with_ragged_rights()
  call self._test('should_align_block_with_ragged_rights', 'Alignta =')
endfunction

function! tc.should_align_block_with_short_rights()
  call self._test('should_align_block_with_short_rights', 'Alignta =')
endfunction

"---------------------------------------
" Padding

function! tc.minimum_leadings_should_ignore_blank_lines()
  call self._test('minimum_leadings_should_ignore_blank_lines', 'Alignta =')
endfunction

function! tc.Lpad_should_be_0_if_blank_L_flds()
  call self._test('Lpad_should_be_0_if_blank_L_flds', 'Alignta! \w\+')
endfunction

function! tc.aligned_part_should_be_frozen()
  call self._test('aligned_part_should_be_frozen', 'Alignta! \S\+{+}')
endfunction

" @\d notation
function! tc.padding_should_be_00_d()
  call self._test('padding_should_be_00', 'Alignta @0 =')
endfunction

function! tc.padding_should_be_33_d()
  call self._test('padding_should_be_33', 'Alignta @3 =')
endfunction

" @\d\d notation
function! tc.padding_should_be_00_dd()
  call self._test('padding_should_be_00', 'Alignta @00 =')
endfunction

function! tc.padding_should_be_31_dd()
  call self._test('padding_should_be_31', 'Alignta @31 =')
endfunction

function! tc.padding_should_be_13_dd()
  call self._test('padding_should_be_13', 'Alignta @13 =')
endfunction

" @\d\+:\d\+ notation
function! tc.padding_should_be_00_d_colon_d()
  call self._test('padding_should_be_00', 'Alignta @0:0 =')
endfunction

function! tc.padding_should_be_31_d_colon_d()
  call self._test('padding_should_be_31', 'Alignta @3:1 =')
endfunction

" <<<\d notation
function! tc.padding_should_be_00_aaa_d()
  call self._test('padding_should_be_00', 'Alignta <<<0 =')
endfunction

function! tc.padding_should_be_33_aaa_d()
  call self._test('padding_should_be_33', 'Alignta <<<3 =')
endfunction

" <<<\d\d notation
function! tc.padding_should_be_00_aaa_dd()
  call self._test('padding_should_be_00', 'Alignta <<<00 =')
endfunction

function! tc.padding_should_be_31_aaa_dd()
  call self._test('padding_should_be_31', 'Alignta <<<31 =')
endfunction

function! tc.padding_should_be_13_aaa_dd()
  call self._test('padding_should_be_13', 'Alignta <<<13 =')
endfunction

" <<<\d\+:\d\+ notation
function! tc.padding_should_be_00_aaa_d_colon_d()
  call self._test('padding_should_be_00', 'Alignta <<<0:0 =')
endfunction

function! tc.padding_should_be_31_aaa_d_colon_d()
  call self._test('padding_should_be_31', 'Alignta <<<3:1 =')
endfunction

function! tc.padding_should_be_13_aaa_d_colon_d()
  call self._test('padding_should_be_13', 'Alignta <<<1:3 =')
endfunction

"---------------------------------------
" Regex

function! tc.should_align_at_1_regex_pattern()
  call self._test('should_align_at_1_regex_pattern', 'Alignta! \d\+')
endfunction

function! tc.should_align_at_1_regex_pattern_2_times()
  call self._test('should_align_at_1_regex_pattern_2_times', 'Alignta! \d\+{2}')
endfunction

function! tc.should_align_at_1_regex_pattern_n_times()
  call self._test('should_align_at_1_regex_pattern_n_times', 'Alignta! \d\+{+}')
endfunction

"---------------------------------------
" Tabs

function! tc.setup_align_region_has_tab()
  let self.save_confirm = g:alignta_confirm_for_retab
  let g:alignta_confirm_for_retab = 0
endfunction
function! tc.should_align_region_has_tab()
  call self._test('should_align_region_has_tab', 'Alignta =')
endfunction
function! tc.teardown_align_region_has_tab()
  let g:alignta_confirm_for_retab = self.save_confirm
endfunction

function! tc.setup_align_region_has_tab_if_noexpandtab()
  let self.save_expandtab = &l:expandtab
  setlocal noexpandtab
endfunction
function! tc.should_align_region_has_tab_if_noexpandtab()
  call self._test('should_align_region_has_tab_if_noexpandtab', 'Alignta =')
endfunction
function! tc.teardown_align_region_has_tab_if_noexpandtab()
  let &l:expandtab = self.save_expandtab
endfunction

function! tc.should_error_if_block_has_tab()
  call self._test('should_error_if_block_has_tab', 'Alignta =')
endfunction

"=============================================================================
" Shifting Alignment

function! tc.should_shift_align_at_1_pattern()
  call self._test('should_shift_align_at_1_pattern', 'Alignta <= b')
endfunction

function! tc.should_shift_align_at_1_pattern_l()
  call self._test('should_shift_align_at_1_pattern_l', 'Alignta <= b')
endfunction

function! tc.should_shift_align_at_1_pattern_c()
  call self._test('should_shift_align_at_1_pattern_c', 'Alignta |= b')
endfunction

function! tc.should_shift_align_at_1_pattern_r()
  call self._test('should_shift_align_at_1_pattern_r', 'Alignta >= b')
endfunction

function! tc.should_shift_align_at_1_pattern_2_times()
  call self._test('should_shift_align_at_1_pattern_2_times', 'Alignta! <= b\+{2}')
endfunction

function! tc.should_shift_align_at_1_pattern_n_times()
  call self._test('should_shift_align_at_1_pattern_n_times', 'Alignta! <= b\+{+}')
endfunction

"---------------------------------------
" Padding

function! tc.Lpad_should_be_0()
  call self._test('Lpad_should_be_0', 'Alignta <=0 b')
endfunction

function! tc.Lpad_should_be_3()
  call self._test('Lpad_should_be_3', 'Alignta <=3 b')
endfunction

"---------------------------------------
" Block

function! tc.should_shift_align_block()
  call self._test('should_shift_align_block', 'Alignta <= b')
endfunction

"=============================================================================
" Filtering

function! tc.should_align_g_pattern_filtering()
  call self._test('should_align_g_pattern_filtering', 'Alignta g/^\s*# =')
endfunction

function! tc.should_align_v_pattern_filtering()
  call self._test('should_align_v_pattern_filtering', 'Alignta v/^\s*# =')
endfunction

function! tc.should_align_block_g_pattern_filtering()
  call self._test('should_align_block_g_pattern_filtering', 'Alignta g/^\s*# =')
endfunction

function! tc.should_align_block_v_pattern_filtering()
  call self._test('should_align_block_v_pattern_filtering', 'Alignta v/^\s*# =')
endfunction

"=============================================================================
" Multi-byte

function! tc.should_align_multibyte_at_1_pattern()
  call self._test('should_align_multibyte_at_1_pattern', 'Alignta ＝')
endfunction

function! tc.should_align_multibyte_at_1_pattern_lll()
  call self._test('should_align_multibyte_at_1_pattern_lll', 'Alignta <<< ＝')
endfunction

function! tc.should_align_multibyte_at_1_pattern_ccc()
  call self._test('should_align_multibyte_at_1_pattern_ccc', 'Alignta ||| ＝')
endfunction

function! tc.should_align_multibyte_at_1_pattern_rrr()
  call self._test('should_align_multibyte_at_1_pattern_rrr', 'Alignta >>> ＝')
endfunction

function! tc.should_align_multibyte_at_ambiwidth_pattern_when_ambw_double()
  let save_ambiwidth = &ambiwidth
  set ambiwidth=double
  call self._test('should_align_multibyte_at_ambiwidth_pattern_when_ambw_double', 'Alignta ＝')
  let &ambiwidth = save_ambiwidth
endfunction

function! tc.should_align_multibyte_at_ambiwidth_pattern_when_ambw_single()
  let save_ambiwidth = &ambiwidth
  set ambiwidth=single
  call self._test('should_align_multibyte_at_ambiwidth_pattern_when_ambw_single', 'Alignta ＝')
  let &ambiwidth = save_ambiwidth
endfunction

"---------------------------------------
" Block

function! tc.should_align_multibyte_block()
  call self._test('should_align_multibyte_block', 'Alignta ＝')
endfunction

function! tc.should_error_if_multibyte_block_is_broken()
  call self._test('should_error_if_multibyte_block_is_broken', 'Alignta ＝')
endfunction

"=============================================================================
" Misc

function! tc.setup_should_not_ignore_case()
  let self.save_ignorecase = &ignorecase
  set ignorecase
endfunction
function! tc.should_not_ignore_case()
  call self._test('should_not_ignore_case', 'Alignta! b\+')
  call assert#true(&ignorecase)
endfunction
function! tc.teardown_should_not_ignore_case()
  let &ignorecase = self.save_ignorecase
endfunction

function! tc.setup_should_ignore_case_when_c()
  let self.save_ignorecase = &ignorecase
  set noignorecase
endfunction
function! tc.should_ignore_case_when_c()
  call self._test('should_ignore_case_when_c', 'Alignta! \cb\+')
  call assert#false(&ignorecase)
endfunction
function! tc.teardown_should_ignore_case_when_c()
  let &ignorecase = self.save_ignorecase
endfunction

"---------------------------------------
" -p

function! tc.should_escape_pattern()
  call self._test('should_escape_pattern', 'Alignta -p <<<')
endfunction

function! tc.should_escape_escape()
  call self._test('should_escape_escape', 'Alignta -p -p')
endfunction

"-----------------------------------------------------------------------------
" Utils

function! tc._test(tag, align_command)
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

function! tc._test_block(tag, align_command)
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
