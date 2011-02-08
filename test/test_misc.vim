" alignta's test suite

execute 'source' expand('<sfile>:p:h') . '/aligner_testcase.vim'
let tc = unittest#testcase#new('test_misc', 'AlignerTestCase')

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

function! tc.should_escape_option_string()
  call self._test('should_escape_option_string', 'Alignta -p <<<')
endfunction

function! tc.should_escape_escape()
  call self._test('should_escape_escape', 'Alignta -p -p')
endfunction

"---------------------------------------
" Alias

if exists(':AlignCtrl') != 2
  function! tc.Align_should_be_defined()
    call assert#exists(':Align')
  endfunction

  function! tc.Align_should_be_alias_of_Alignta()
    call self._test('Align_should_be_alias_of_Alignta', 'Align =')
  endfunction
endif

"---------------------------------------
" Filtering

function! tc.should_align_only_matching_g_pattern()
  call self._test('should_align_only_matching_g_pattern', 'Alignta g/^\s*# =')
endfunction

function! tc.should_align_except_matching_g_pattern()
  call self._test('should_align_except_matching_g_pattern', 'Alignta v/^\s*# =')
endfunction

function! tc.should_align_block_only_matching_g_pattern()
  call self._test('should_align_block_only_matching_g_pattern', 'Alignta g/^\s*# =')
endfunction

function! tc.should_align_block_except_matching_g_pattern()
  call self._test('should_align_block_except_matching_g_pattern', 'Alignta v/^\s*# =')
endfunction

"---------------------------------------
" Options

function! tc.setup_buffer_local_options_should_take_precedence()
  let b:alignta_default_options = '>>>'
endfunction
function! tc.buffer_local_options_should_take_precedence()
  call self._test('buffer_local_options_should_take_precedence', 'Alignta =')
endfunction
function! tc.teardown_buffer_local_options_should_take_precedence()
  unlet b:alignta_default_options
endfunction

function! tc.setup_extending_options_should_take_precedence()
  let b:alignta_default_options = '|||'
  call alignta#reset_extending_options()
  call alignta#apply_extending_options('>>>')
endfunction
function! tc.extending_options_should_take_precedence()
  call self._test('extending_options_should_take_precedence', 'Alignta =')
endfunction
function! tc.teardown_extending_options_should_take_precedence()
  call alignta#reset_extending_options()
  unlet b:alignta_default_options
endfunction

function! tc.setup_should_align_with_default_arguments_if_no_args_given()
  let b:alignta_default_arguments = '>>> ='
endfunction
function! tc.should_align_with_default_arguments_if_no_args_given()
  call self._test('should_align_with_default_arguments_if_no_args_given', 'Alignta')
endfunction
function! tc.teatdown_should_align_with_default_arguments_if_no_args_given()
  unlet b:alignta_default_arguments
endfunction

unlet tc

" vim: filetype=vim
