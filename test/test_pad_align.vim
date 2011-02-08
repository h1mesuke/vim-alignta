" alignta's test suite

execute 'source' expand('<sfile>:p:h') . '/aligner_testcase.vim'
let tc = unittest#testcase#new('test_pad_align', 'AlignerTestCase')

"-----------------------------------------------------------------------------

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
" Regexp

function! tc.should_align_at_1_regexp_pattern()
  call self._test('should_align_at_1_regexp_pattern', 'Alignta! \d\+')
endfunction

function! tc.should_align_at_1_regexp_pattern_2_times()
  call self._test('should_align_at_1_regexp_pattern_2_times', 'Alignta! \d\+{2}')
endfunction

function! tc.should_align_at_1_regexp_pattern_n_times()
  call self._test('should_align_at_1_regexp_pattern_n_times', 'Alignta! \d\+{+}')
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

unlet tc

" vim: filetype=vim
