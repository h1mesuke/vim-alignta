" alignta.vim test suite

execute 'source' expand('<sfile>:p:h') . '/aligner_testcase.vim'
let tc = unittest#testcase#new('test_options', 'AlignerTestCase')

"---------------------------------------
" &ignorecase

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

"---------------------------------------
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

unlet tc

" vim: filetype=vim
