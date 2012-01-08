" alignta's test suite

let s:save_cpo = &cpo
set cpo&vim

let s:tc = unittest#testcase#new('test_shift_align', alignta#testcase#class())

"-----------------------------------------------------------------------------
" shift_left

function! s:tc.SL_should_align_at_1_pattern()
  call self._test_align('SL_should_align_at_1_pattern', 'Alignta <- b')
endfunction

function! s:tc.SL_should_align_at_1_pattern_2_times()
  call self._test_align('SL_should_align_at_1_pattern_2_times', 'Alignta <- b\+/2')
endfunction

function! s:tc.SL_should_align_at_1_pattern_n_times()
  call self._test_align('SL_should_align_at_1_pattern_n_times', 'Alignta <- b\+/g')
endfunction

" For backward compatibility.
function! s:tc.SL_should_align_at_1_pattern_n_times_OLD()
  call self._test_align('SL_should_align_at_1_pattern_n_times', 'Alignta <- b\+{+}')
endfunction

function! s:tc.SL_should_align_at_1_pattern_x_times()
  call self._test_align('SL_should_align_at_1_pattern_x_times', 'Alignta <- b\+/g')
endfunction

function! s:tc.SL_should_align_at_multi_patterns()
  call self._test_align('SL_should_align_at_multi_patterns', 'Alignta <- b\+/2 c\+ \d\+')
endfunction

"---------------------------------------
" Margin

function! s:tc.SL_margin_should_be_0()
  call self._test_align('SL_margin_should_be_0', 'Alignta <-0 b')
endfunction

function! s:tc.SL_margin_should_be_3()
  call self._test_align('SL_margin_should_be_3', 'Alignta <-3 b')
endfunction

"---------------------------------------
" Multi-byte

function! s:tc.SL_should_align_mb_at_1_pattern()
  call self._test_align('SL_should_align_mb_at_1_pattern', 'Alignta <- 伊')
endfunction

function! s:tc.SL_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SL_should_align_mb_at_1_pattern_2_times', 'Alignta <- 伊\+/2')
endfunction

function! s:tc.SL_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SL_should_align_mb_at_1_pattern_n_times', 'Alignta <- 伊\+/g')
endfunction

function! s:tc.SL_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SL_should_align_mb_at_1_pattern_x_times', 'Alignta <- 伊\+/g')
endfunction

function! s:tc.SL_should_align_mb_at_multi_patterns()
  call self._test_align('SL_should_align_mb_at_multi_patterns', 'Alignta <- 伊\+/2 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------
" shift_right

function! s:tc.SR_should_align_at_1_pattern()
  call self._test_align('SR_should_align_at_1_pattern', 'Alignta -> b')
endfunction

function! s:tc.SR_should_align_at_1_pattern_2_times()
  call self._test_align('SR_should_align_at_1_pattern_2_times', 'Alignta -> b\+/2')
endfunction

function! s:tc.SR_should_align_at_1_pattern_n_times()
  call self._test_align('SR_should_align_at_1_pattern_n_times', 'Alignta -> b\+/g')
endfunction

function! s:tc.SR_should_align_at_1_pattern_x_times()
  call self._test_align('SR_should_align_at_1_pattern_x_times', 'Alignta -> b\+/g')
endfunction

function! s:tc.SR_should_align_at_multi_patterns()
  call self._test_align('SR_should_align_at_multi_patterns', 'Alignta -> b\+/2 c\+ \d\+')
endfunction

"---------------------------------------
" Multi-byte

function! s:tc.SR_should_align_mb_at_1_pattern()
  call self._test_align('SR_should_align_mb_at_1_pattern', 'Alignta -> 伊')
endfunction

function! s:tc.SR_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SR_should_align_mb_at_1_pattern_2_times', 'Alignta -> 伊\+/2')
endfunction

function! s:tc.SR_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SR_should_align_mb_at_1_pattern_n_times', 'Alignta -> 伊\+/g')
endfunction

function! s:tc.SR_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SR_should_align_mb_at_1_pattern_x_times', 'Alignta -> 伊\+/g')
endfunction

function! s:tc.SR_should_align_mb_at_multi_patterns()
  call self._test_align('SR_should_align_mb_at_multi_patterns', 'Alignta -> 伊\+/2 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------
" shift_left_tab

function! s:tc.setup_expand_tabs_when_expandtab()
  let self.save_expandtab = &l:expandtab
  set expandtab
endfunction
function! s:tc.should_expand_tabs_when_expandtab()
  call self._test_align('should_expand_tabs_when_expandtab', 'Alignta <-- b')
endfunction
function! s:tc.teardown_expand_tabs_when_expandtab()
  let &l:expandtab = self.save_expandtab
endfunction

function! s:tc.SLT_should_align_at_1_pattern()
  call self._test_align('SLT_should_align_at_1_pattern', 'Alignta <-- b')
endfunction

function! s:tc.SLT_should_align_at_1_pattern_2_times()
  call self._test_align('SLT_should_align_at_1_pattern_2_times', 'Alignta <-- b\+/2')
endfunction

function! s:tc.SLT_should_align_at_1_pattern_n_times()
  call self._test_align('SLT_should_align_at_1_pattern_n_times', 'Alignta <-- b\+/g')
endfunction

function! s:tc.SLT_should_align_at_1_pattern_x_times()
  call self._test_align('SLT_should_align_at_1_pattern_x_times', 'Alignta <-- b\+/g')
endfunction

function! s:tc.SLT_should_align_at_multi_patterns()
  call self._test_align('SLT_should_align_at_multi_patterns', 'Alignta <-- b\+/2 c\+ \d\+')
endfunction

"---------------------------------------
" Multi-byte

function! s:tc.SLT_should_align_mb_at_1_pattern()
  call self._test_align('SLT_should_align_mb_at_1_pattern', 'Alignta <-- 伊')
endfunction

function! s:tc.SLT_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SLT_should_align_mb_at_1_pattern_2_times', 'Alignta <-- 伊\+/2')
endfunction

function! s:tc.SLT_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SLT_should_align_mb_at_1_pattern_n_times', 'Alignta <-- 伊\+/g')
endfunction

function! s:tc.SLT_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SLT_should_align_mb_at_1_pattern_x_times', 'Alignta <-- 伊\+/g')
endfunction

function! s:tc.SLT_should_align_mb_at_multi_patterns()
  call self._test_align('SLT_should_align_mb_at_multi_patterns', 'Alignta <-- 伊\+/2 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------
" shift_right_tab

function! s:tc.SRT_should_align_at_1_pattern()
  call self._test_align('SRT_should_align_at_1_pattern', 'Alignta --> b')
endfunction

function! s:tc.SRT_should_align_at_1_pattern_2_times()
  call self._test_align('SRT_should_align_at_1_pattern_2_times', 'Alignta --> b\+/2')
endfunction

function! s:tc.SRT_should_align_at_1_pattern_n_times()
  call self._test_align('SRT_should_align_at_1_pattern_n_times', 'Alignta --> b\+/g')
endfunction

function! s:tc.SRT_should_align_at_1_pattern_x_times()
  call self._test_align('SRT_should_align_at_1_pattern_x_times', 'Alignta --> b\+/g')
endfunction

function! s:tc.SRT_should_align_at_multi_patterns()
  call self._test_align('SRT_should_align_at_multi_patterns', 'Alignta --> b\+/2 c\+ \d\+')
endfunction

"---------------------------------------
" Multi-byte

function! s:tc.SRT_should_align_mb_at_1_pattern()
  call self._test_align('SRT_should_align_mb_at_1_pattern', 'Alignta --> 伊')
endfunction

function! s:tc.SRT_should_align_mb_at_1_pattern_2_times()
  call self._test_align('SRT_should_align_mb_at_1_pattern_2_times', 'Alignta --> 伊\+/2')
endfunction

function! s:tc.SRT_should_align_mb_at_1_pattern_n_times()
  call self._test_align('SRT_should_align_mb_at_1_pattern_n_times', 'Alignta --> 伊\+/g')
endfunction

function! s:tc.SRT_should_align_mb_at_1_pattern_x_times()
  call self._test_align('SRT_should_align_mb_at_1_pattern_x_times', 'Alignta --> 伊\+/g')
endfunction

function! s:tc.SRT_should_align_mb_at_multi_patterns()
  call self._test_align('SRT_should_align_mb_at_multi_patterns', 'Alignta --> 伊\+/2 宇\+ 壱')
endfunction

"-----------------------------------------------------------------------------

unlet s:tc

let &cpo = s:save_cpo
unlet s:save_cpo
