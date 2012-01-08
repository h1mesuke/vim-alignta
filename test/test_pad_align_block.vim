" alignta's test suite

let s:save_cpo = &cpo
set cpo&vim

let tc = unittest#testcase#new('test_pad_align_block', alignta#testcase#class())

"-----------------------------------------------------------------------------

function! tc.should_align_block()
  call self._test_align_block('should_align_block', 'Alignta =')
endfunction

function! tc.should_align_block_with_ragged_rights()
  call self._test_align_block('should_align_block_with_ragged_rights', 'Alignta =')
endfunction

function! tc.should_align_block_with_short_rights()
  call self._test_align_block('should_align_block_with_short_rights', 'Alignta =')
endfunction

"---------------------------------------
" Multi-byte

function! tc.should_align_mb_block()
  call self._test_align_block('should_align_mb_block', 'Alignta ＝')
endfunction

function! tc.should_raise_if_region_is_invalid_for_mb()
  call self._test_align_block('should_raise_if_region_is_invalid_for_mb', 'Alignta ＝')
endfunction

"---------------------------------------
" Tabs

function! tc.should_detab_indent()
  call self._test_align_block('should_detab_indent', 'Alignta =')
endfunction

function! tc.should_detab_indent_aa()
  call self._test_align_block('should_detab_indent_aa', 'Alignta == =')
endfunction

function! tc.should_entab_indent()
  call self._test_align_block('should_entab_indent', 'Alignta =')
endfunction

function! tc.should_entab_indent_rr()
  call self._test_align_block('should_entab_indent_rr', 'Alignta >> =')
endfunction

function! tc.should_raise_if_region_is_invalid_for_tab()
  call self._test_align_block('should_raise_if_region_is_invalid_for_tab', 'Alignta ＝')
endfunction

"-----------------------------------------------------------------------------

unlet tc

let &cpo = s:save_cpo
unlet s:save_cpo
