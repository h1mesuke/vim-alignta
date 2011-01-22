" alignta.vim test suite

execute 'source' expand('<sfile>:p:h') . '/aligner_testcase.vim'
let tc = unittest#testcase#new('test_pad_align_mb', 'AlignerTestCase')

"-----------------------------------------------------------------------------

function! tc.should_align_at_1_pattern()
  call self._test('should_align_at_1_pattern', 'Alignta ＝')
endfunction

function! tc.should_align_at_1_pattern_lll()
  call self._test('should_align_at_1_pattern_lll', 'Alignta <<< ＝')
endfunction

function! tc.should_align_at_1_pattern_ccc()
  call self._test('should_align_at_1_pattern_ccc', 'Alignta ||| ＝')
endfunction

function! tc.should_align_at_1_pattern_rrr()
  call self._test('should_align_at_1_pattern_rrr', 'Alignta >>> ＝')
endfunction

function! tc.should_align_at_ambiwidth_pattern_when_ambw_double()
  let save_ambiwidth = &ambiwidth
  set ambiwidth=double
  call self._test('should_align_at_ambiwidth_pattern_when_ambw_double', 'Alignta ＝')
  let &ambiwidth = save_ambiwidth
endfunction

function! tc.should_align_at_ambiwidth_pattern_when_ambw_single()
  let save_ambiwidth = &ambiwidth
  set ambiwidth=single
  call self._test('should_align_at_ambiwidth_pattern_when_ambw_single', 'Alignta ＝')
  let &ambiwidth = save_ambiwidth
endfunction

"---------------------------------------
" Block

function! tc.should_align_block()
  call self._test('should_align_block', 'Alignta ＝')
endfunction

function! tc.should_error_if_multibyte_block_is_broken()
  call self._test('should_error_if_multibyte_block_is_broken', 'Alignta ＝')
endfunction

unlet tc

" vim: filetype=vim
