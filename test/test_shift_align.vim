" alignta.vim test suite

execute 'source' expand('<sfile>:p:h') . '/aligner_testcase.vim'
let tc = unittest#testcase#new('test_shift_align', 'AlignerTestCase')

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

unlet tc

" vim: filetype=vim
