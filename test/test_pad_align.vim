" alignta's test suite

let s:save_cpo = &cpo
set cpo&vim

let s:tc = unittest#testcase#new('test_pad_align', alignta#testcase#class())

"-----------------------------------------------------------------------------

function! s:tc.should_align_at_1_pattern()
  call self._test_align('should_align_at_1_pattern', 'Alignta =')
endfunction

function! s:tc.should_align_at_1_pattern_ll()
  call self._test_align('should_align_at_1_pattern_ll', 'Alignta << =')
endfunction

function! s:tc.should_align_at_1_pattern_cc()
  call self._test_align('should_align_at_1_pattern_cc', 'Alignta || =')
endfunction

function! s:tc.should_align_at_1_pattern_rr()
  call self._test_align('should_align_at_1_pattern_rr', 'Alignta >> =')
endfunction

function! s:tc.should_align_at_1_pattern_aa()
  call self._test_align('should_align_at_1_pattern_aa', 'Alignta == =')
endfunction

function! s:tc.should_align_at_1_pattern_lcr()
  call self._test_align('should_align_at_1_pattern_lcr', 'Alignta <|> =')
endfunction

function! s:tc.should_align_at_1_pattern_rcl()
  call self._test_align('should_align_at_1_pattern_rcl', 'Alignta >|< =')
endfunction

function! s:tc.should_align_at_1_pattern_2_times()
  call self._test_align('should_align_at_1_pattern_2_times', 'Alignta =/2')
endfunction

" For backward compatibility.
function! s:tc.should_align_at_1_pattern_2_times_OLD()
  call self._test_align('should_align_at_1_pattern_2_times', 'Alignta ={2}')
endfunction

function! s:tc.should_align_at_1_pattern_2_times_ll()
  call self._test_align('should_align_at_1_pattern_2_times_ll', 'Alignta << =/2')
endfunction

function! s:tc.should_align_at_1_pattern_2_times_cc()
  call self._test_align('should_align_at_1_pattern_2_times_cc', 'Alignta || =/2')
endfunction

function! s:tc.should_align_at_1_pattern_2_times_rr()
  call self._test_align('should_align_at_1_pattern_2_times_rr', 'Alignta >> =/2')
endfunction

function! s:tc.should_align_at_1_pattern_2_times_aa()
  call self._test_align('should_align_at_1_pattern_2_times_aa', 'Alignta == =/2')
endfunction

function! s:tc.should_align_at_1_pattern_2_times_lcr()
  call self._test_align('should_align_at_1_pattern_2_times_lcr', 'Alignta <|> =/2')
endfunction

function! s:tc.should_align_at_1_pattern_2_times_rcl()
  call self._test_align('should_align_at_1_pattern_2_times_rcl', 'Alignta >|< =/2')
endfunction

function! s:tc.should_align_at_1_pattern_n_times()
  call self._test_align('should_align_at_1_pattern_n_times', 'Alignta =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_ll()
  call self._test_align('should_align_at_1_pattern_n_times_ll', 'Alignta << =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_cc()
  call self._test_align('should_align_at_1_pattern_n_times_cc', 'Alignta || =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_rr()
  call self._test_align('should_align_at_1_pattern_n_times_rr', 'Alignta >> =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_aa()
  call self._test_align('should_align_at_1_pattern_n_times_aa', 'Alignta == =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_lcr()
  call self._test_align('should_align_at_1_pattern_n_times_lcr', 'Alignta <|> =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_rcl()
  call self._test_align('should_align_at_1_pattern_n_times_rcl', 'Alignta >|< =')
endfunction

function! s:tc.should_align_at_1_pattern_n_times_llclrle()
  call self._test_align('should_align_at_1_pattern_n_times_llclrle', 'Alignta <<|<><= =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times()
  call self._test_align('should_align_at_1_pattern_x_times', 'Alignta =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times_ll()
  call self._test_align('should_align_at_1_pattern_x_times_ll', 'Alignta << =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times_cc()
  call self._test_align('should_align_at_1_pattern_x_times_cc', 'Alignta || =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times_rr()
  call self._test_align('should_align_at_1_pattern_x_times_rr', 'Alignta >> =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times_aa()
  call self._test_align('should_align_at_1_pattern_x_times_aa', 'Alignta == =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times_lcr()
  call self._test_align('should_align_at_1_pattern_x_times_lcr', 'Alignta <|> =')
endfunction

function! s:tc.should_align_at_1_pattern_x_times_rcl()
  call self._test_align('should_align_at_1_pattern_x_times_rcl', 'Alignta >|< =')
endfunction

function! s:tc.should_align_at_multi_patterns()
  call self._test_align('should_align_at_multi_patterns', 'Alignta = /* */')
endfunction

function! s:tc.should_align_at_multi_patterns_ll()
  call self._test_align('should_align_at_multi_patterns_ll', 'Alignta << = /* */')
endfunction

function! s:tc.should_align_at_multi_patterns_cc()
  call self._test_align('should_align_at_multi_patterns_cc', 'Alignta || = /* */')
endfunction

function! s:tc.should_align_at_multi_patterns_rr()
  call self._test_align('should_align_at_multi_patterns_rr', 'Alignta >> = /* */')
endfunction

function! s:tc.should_align_at_multi_patterns_aa()
  call self._test_align('should_align_at_multi_patterns_aa', 'Alignta == = /* */')
endfunction

function! s:tc.should_align_at_multi_patterns_lcr()
  call self._test_align('should_align_at_multi_patterns_lcr', 'Alignta <|> = /* */')
endfunction

function! s:tc.should_align_at_multi_patterns_rcl()
  call self._test_align('should_align_at_multi_patterns_rcl', 'Alignta >|< = /* */')
endfunction

function! s:tc.should_align_at_complex_patterns()
  call self._test_align('should_align_at_complex_patterns', 'Alignta = { } /* */')
endfunction

function! s:tc.should_align_at_complex_patterns_ll()
  call self._test_align('should_align_at_complex_patterns_ll', 'Alignta << = { } /* */')
endfunction

function! s:tc.should_align_at_complex_patterns_cc()
  call self._test_align('should_align_at_complex_patterns_cc', 'Alignta || = { } /* */')
endfunction

function! s:tc.should_align_at_complex_patterns_rr()
  call self._test_align('should_align_at_complex_patterns_rr', 'Alignta >> = { } /* */')
endfunction

function! s:tc.should_align_big_data()
  call self._test_align('should_align_big_data', 'Alignta =')
endfunction

function! s:tc.should_freeze_aligned_parts()
  call self._test_align('should_freeze_aligned_parts', 'Alignta \S\+')
endfunction

"---------------------------------------
" Leading

function! s:tc.should_keep_mininum_leading()
  call self._test_align('should_keep_mininum_leading', 'Alignta =')
endfunction

"---------------------------------------
" Margin

function! s:tc.L_margin_should_be_0_if_N_fld_is_blank()
  call self._test_align('L_margin_should_be_0_if_N_fld_is_blank', 'Alignta \S\+')
endfunction

" <<\d notation
function! s:tc.margin_should_be_0_0_d()
  call self._test_align('margin_should_be_0_0', 'Alignta <<0 =')
endfunction

function! s:tc.margin_should_be_3_3_d()
  call self._test_align('margin_should_be_3_3', 'Alignta <<3 =')
endfunction

" <<\d\d notation
function! s:tc.margin_should_be_0_0_dd()
  call self._test_align('margin_should_be_0_0', 'Alignta <<00 =')
endfunction

function! s:tc.margin_should_be_3_1_dd()
  call self._test_align('margin_should_be_3_1', 'Alignta <<31 =')
endfunction

function! s:tc.margin_should_be_1_3_dd()
  call self._test_align('margin_should_be_1_3', 'Alignta <<13 =')
endfunction

" <<\d\+:\d\+ notation
function! s:tc.margin_should_be_0_0_d_colon_d()
  call self._test_align('margin_should_be_0_0', 'Alignta <<0:0 =')
endfunction

function! s:tc.margin_should_be_3_1_d_colon_d()
  call self._test_align('margin_should_be_3_1', 'Alignta <<3:1 =')
endfunction

function! s:tc.margin_should_be_1_3_d_colon_d()
  call self._test_align('margin_should_be_1_3', 'Alignta <<1:3 =')
endfunction

" @\d notation
function! s:tc.margin_should_be_0_0_at_d()
  call self._test_align('margin_should_be_0_0', 'Alignta @0 =')
endfunction

function! s:tc.margin_should_be_3_3_at_d()
  call self._test_align('margin_should_be_3_3', 'Alignta @3 =')
endfunction

" @\d\d notation
function! s:tc.margin_should_be_0_0_at_dd()
  call self._test_align('margin_should_be_0_0', 'Alignta @00 =')
endfunction

function! s:tc.margin_should_be_3_1_at_dd()
  call self._test_align('margin_should_be_3_1', 'Alignta @31 =')
endfunction

function! s:tc.margin_should_be_1_3_at_dd()
  call self._test_align('margin_should_be_1_3', 'Alignta @13 =')
endfunction

" @\d\+:\d\+ notation
function! s:tc.margin_should_be_0_0_at_d_colon()
  call self._test_align('margin_should_be_0_0', 'Alignta @0:0 =')
endfunction

function! s:tc.margin_should_be_3_1_at_d_colon()
  call self._test_align('margin_should_be_3_1', 'Alignta @3:1 =')
endfunction

function! s:tc.margin_should_be_1_3_at_d_colon()
  call self._test_align('margin_should_be_1_3', 'Alignta @1:3 =')
endfunction

" \d notation
function! s:tc.margin_should_be_0_0_d()
  call self._test_align('margin_should_be_0_0', 'Alignta 0 =')
endfunction

function! s:tc.margin_should_be_3_3_d()
  call self._test_align('margin_should_be_3_3', 'Alignta 3 =')
endfunction

" \d\d notation
function! s:tc.margin_should_be_0_0_dd()
  call self._test_align('margin_should_be_0_0', 'Alignta 00 =')
endfunction

function! s:tc.margin_should_be_3_1_dd()
  call self._test_align('margin_should_be_3_1', 'Alignta 31 =')
endfunction

function! s:tc.margin_should_be_1_3_dd()
  call self._test_align('margin_should_be_1_3', 'Alignta 13 =')
endfunction

" \d\+:\d\+ notation
function! s:tc.margin_should_be_0_0_d_colon_d()
  call self._test_align('margin_should_be_0_0', 'Alignta 0:0 =')
endfunction

function! s:tc.margin_should_be_3_1_d_colon_d()
  call self._test_align('margin_should_be_3_1', 'Alignta 3:1 =')
endfunction

function! s:tc.margin_should_be_1_3_d_colon_d()
  call self._test_align('margin_should_be_1_3', 'Alignta 1:3 =')
endfunction

"---------------------------------------
" Multi-byte

function! s:tc.should_align_mb_at_1_pattern()
  call self._test_align('should_align_mb_at_1_pattern', 'Alignta ＝')
endfunction

function! s:tc.should_align_mb_at_1_pattern_ll()
  call self._test_align('should_align_mb_at_1_pattern_ll', 'Alignta << ＝')
endfunction

function! s:tc.should_align_mb_at_1_pattern_cc()
  call self._test_align('should_align_mb_at_1_pattern_cc', 'Alignta || ＝')
endfunction

function! s:tc.should_align_mb_at_1_pattern_rr()
  call self._test_align('should_align_mb_at_1_pattern_rr', 'Alignta >> ＝')
endfunction

function! s:tc.should_align_mb_at_1_pattern_aa()
  call self._test_align('should_align_mb_at_1_pattern_aa', 'Alignta == ＝')
endfunction

function! s:tc.should_align_mb_at_1_pattern_lcr()
  call self._test_align('should_align_mb_at_1_pattern_lcr', 'Alignta <|> ＝')
endfunction

function! s:tc.should_align_mb_at_1_pattern_rcl()
  call self._test_align('should_align_mb_at_1_pattern_rcl', 'Alignta >|< ＝')
endfunction

function! s:tc.setup_align_mb_when_ambw_double()
  let self.save_ambiwidth = &ambiwidth
  set ambiwidth=double
endfunction
function! s:tc.should_align_mb_when_ambw_double()
  call self._test_align('should_align_mb_when_ambw_double', 'Alignta ＝')
endfunction

function! s:tc.setup_align_mb_when_ambw_single()
  let self.save_ambiwidth = &ambiwidth
  set ambiwidth=single
endfunction
function! s:tc.should_align_mb_when_ambw_single()
  call self._test_align('should_align_mb_when_ambw_single', 'Alignta ＝')
endfunction

function! s:tc.teardown_align_mb_when_ambw()
  let &ambiwidth = self.save_ambiwidth
endfunction

"---------------------------------------
" Tabs

function! s:tc.should_detab_indent()
  call self._test_align('should_detab_indent', 'Alignta =')
endfunction

function! s:tc.should_detab_indent_aa()
  call self._test_align('should_detab_indent_aa', 'Alignta == =')
endfunction

function! s:tc.should_entab_indent()
  call self._test_align('should_entab_indent', 'Alignta =')
endfunction

function! s:tc.should_entab_indent_rr()
  call self._test_align('should_entab_indent_rr', 'Alignta >> =')
endfunction

"---------------------------------------
" Zero-width

function! s:tc.should_not_raise_if_zero_width_match()
  call self._test_align('should_not_raise_if_zero_width_match', 'Alignta \ze,')
endfunction

"-----------------------------------------------------------------------------

unlet s:tc

let &cpo = s:save_cpo
unlet s:save_cpo
