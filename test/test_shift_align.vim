" alignta's test suite

let tc = unittest#testcase#new('test_shift_align', alignta#testcase#class())

"-----------------------------------------------------------------------------
" shift_left

function! tc.SL_should_align_at_1_pattern()
  call self._test_align('SL_should_align_at_1_pattern', 'Alignta <- b')
endfunction

function! tc.SL_should_align_at_1_pattern_2_times()
  call self._test_align('SL_should_align_at_1_pattern_2_times', 'Alignta! <- b\+{2}')
endfunction

function! tc.SL_should_align_at_1_pattern_n_times()
  call self._test_align('SL_should_align_at_1_pattern_n_times', 'Alignta! <- b\+{+}')
endfunction

function! tc.SL_should_align_at_1_pattern_x_times()
  call self._test_align('SL_should_align_at_1_pattern_x_times', 'Alignta! <- b\+{+}')
endfunction

function! tc.SL_should_align_at_multi_patterns()
  call self._test_align('SL_should_align_at_multi_patterns', 'Alignta! <- b\+{2} c\+ \d\+')
endfunction

"---------------------------------------
" Margin

function! tc.SL_margin_should_be_0()
  call self._test_align('SL_margin_should_be_0', 'Alignta <-0 b')
endfunction

function! tc.SL_margin_should_be_3()
  call self._test_align('SL_margin_should_be_3', 'Alignta <-3 b')
endfunction

"---------------------------------------
" Multi-byte

function! tc.SL_should_align_mb_at_1_pattern()
  call self._test_align('SL_should_align_mb_at_1_pattern', 'Alignta <- 伊')
endfunction

function! tc.SL_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SL_should_align_mb_at_1_pattern_2_times', 'Alignta! <- 伊\+{2}')
endfunction

function! tc.SL_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SL_should_align_mb_at_1_pattern_n_times', 'Alignta! <- 伊\+{+}')
endfunction

function! tc.SL_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SL_should_align_mb_at_1_pattern_x_times', 'Alignta! <- 伊\+{+}')
endfunction

function! tc.SL_should_align_mb_at_multi_patterns()
  call self._test_align('SL_should_align_mb_at_multi_patterns', 'Alignta! <- 伊\+{2} 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------
" shift_right

function! tc.SR_should_align_at_1_pattern()
  call self._test_align('SR_should_align_at_1_pattern', 'Alignta -> b')
endfunction

function! tc.SR_should_align_at_1_pattern_2_times()
  call self._test_align('SR_should_align_at_1_pattern_2_times', 'Alignta! -> b\+{2}')
endfunction

function! tc.SR_should_align_at_1_pattern_n_times()
  call self._test_align('SR_should_align_at_1_pattern_n_times', 'Alignta! -> b\+{+}')
endfunction

function! tc.SR_should_align_at_1_pattern_x_times()
  call self._test_align('SR_should_align_at_1_pattern_x_times', 'Alignta! -> b\+{+}')
endfunction

function! tc.SR_should_align_at_multi_patterns()
  call self._test_align('SR_should_align_at_multi_patterns', 'Alignta! -> b\+{2} c\+ \d\+')
endfunction

"---------------------------------------
" Multi-byte

function! tc.SR_should_align_mb_at_1_pattern()
  call self._test_align('SR_should_align_mb_at_1_pattern', 'Alignta -> 伊')
endfunction

function! tc.SR_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SR_should_align_mb_at_1_pattern_2_times', 'Alignta! -> 伊\+{2}')
endfunction

function! tc.SR_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SR_should_align_mb_at_1_pattern_n_times', 'Alignta! -> 伊\+{+}')
endfunction

function! tc.SR_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SR_should_align_mb_at_1_pattern_x_times', 'Alignta! -> 伊\+{+}')
endfunction

function! tc.SR_should_align_mb_at_multi_patterns()
  call self._test_align('SR_should_align_mb_at_multi_patterns', 'Alignta! -> 伊\+{2} 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------
" shift_left_tab

function! tc.setup_expand_tabs_when_expandtab()
  let self.save_expandtab = &l:expandtab
  set expandtab
endfunction
function! tc.should_expand_tabs_when_expandtab()
  call self._test_align('should_expand_tabs_when_expandtab', 'Alignta <-- b')
endfunction
function! tc.teardown_expand_tabs_when_expandtab()
  let &l:expandtab = self.save_expandtab
endfunction

function! tc.SLT_should_align_at_1_pattern()
  call self._test_align('SLT_should_align_at_1_pattern', 'Alignta <-- b')
endfunction

function! tc.SLT_should_align_at_1_pattern_2_times()
  call self._test_align('SLT_should_align_at_1_pattern_2_times', 'Alignta! <-- b\+{2}')
endfunction

function! tc.SLT_should_align_at_1_pattern_n_times()
  call self._test_align('SLT_should_align_at_1_pattern_n_times', 'Alignta! <-- b\+{+}')
endfunction

function! tc.SLT_should_align_at_1_pattern_x_times()
  call self._test_align('SLT_should_align_at_1_pattern_x_times', 'Alignta! <-- b\+{+}')
endfunction

function! tc.SLT_should_align_at_multi_patterns()
  call self._test_align('SLT_should_align_at_multi_patterns', 'Alignta! <-- b\+{2} c\+ \d\+')
endfunction

"---------------------------------------
" Multi-byte

function! tc.SLT_should_align_mb_at_1_pattern()
  call self._test_align('SLT_should_align_mb_at_1_pattern', 'Alignta <-- 伊')
endfunction

function! tc.SLT_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SLT_should_align_mb_at_1_pattern_2_times', 'Alignta! <-- 伊\+{2}')
endfunction

function! tc.SLT_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SLT_should_align_mb_at_1_pattern_n_times', 'Alignta! <-- 伊\+{+}')
endfunction

function! tc.SLT_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SLT_should_align_mb_at_1_pattern_x_times', 'Alignta! <-- 伊\+{+}')
endfunction

function! tc.SLT_should_align_mb_at_multi_patterns()
  call self._test_align('SLT_should_align_mb_at_multi_patterns', 'Alignta! <-- 伊\+{2} 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------
" shift_right_tab

function! tc.SRT_should_align_at_1_pattern()
  call self._test_align('SRT_should_align_at_1_pattern', 'Alignta --> b')
endfunction

function! tc.SRT_should_align_at_1_pattern_2_times()
  call self._test_align('SRT_should_align_at_1_pattern_2_times', 'Alignta! --> b\+{2}')
endfunction

function! tc.SRT_should_align_at_1_pattern_n_times()
  call self._test_align('SRT_should_align_at_1_pattern_n_times', 'Alignta! --> b\+{+}')
endfunction

function! tc.SRT_should_align_at_1_pattern_x_times()
  call self._test_align('SRT_should_align_at_1_pattern_x_times', 'Alignta! --> b\+{+}')
endfunction

function! tc.SRT_should_align_at_multi_patterns()
  call self._test_align('SRT_should_align_at_multi_patterns', 'Alignta! --> b\+{2} c\+ \d\+')
endfunction

"---------------------------------------
" Multi-byte

function! tc.SRT_should_align_mb_at_1_pattern()
  call self._test_align('SRT_should_align_mb_at_1_pattern', 'Alignta --> 伊')
endfunction

function! tc.SRT_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SRT_should_align_mb_at_1_pattern_2_times', 'Alignta --> 伊\+{2}')
endfunction

function! tc.SRT_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SRT_should_align_mb_at_1_pattern_n_times', 'Alignta --> 伊\+{+}')
endfunction

function! tc.SRT_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SRT_should_align_mb_at_1_pattern_x_times', 'Alignta --> 伊\+{+}')
endfunction

function! tc.SRT_should_align_mb_at_multi_patterns()
  call self._test_align('SRT_should_align_mb_at_multi_patterns', 'Alignta --> 伊\+{2} 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------

unlet tc

" vim: filetype=vim
