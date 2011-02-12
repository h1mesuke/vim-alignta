" alignta's test suite

execute 'source' expand('<sfile>:p:h') . '/aligner_testcase.vim'
let tc = unittest#testcase#new('test_options', 'AlignerTestCase')

"---------------------------------------
" Alias

if exists(':AlignCtrl') != 2
  function! tc.Align_should_be_defined()
    call assert#exists(':Align')
  endfunction

  function! tc.Align_should_be_alias_of_Alignta()
    call self._test_align('Align_should_be_alias_of_Alignta', 'Align =')
  endfunction
endif

"---------------------------------------
" Filtering

function! tc.should_align_only_matching_g_pattern()
  call self._test_align('should_align_only_matching_g_pattern', 'Alignta g/^\s*# =')
endfunction

function! tc.should_align_except_matching_v_pattern()
  call self._test_align('should_align_except_matching_v_pattern', 'Alignta v/^\s*# =')
endfunction

function! tc.should_align_block_only_matching_g_pattern()
  call self._test_align_block('should_align_block_only_matching_g_pattern', 'Alignta g/^\s*# =')
endfunction

function! tc.should_align_block_except_matching_v_pattern()
  call self._test_align_block('should_align_block_except_matching_v_pattern', 'Alignta v/^\s*# =')
endfunction

"---------------------------------------
" &ignorecase

function! tc.setup_should_not_ignore_case()
  let self.save_ignorecase = &ignorecase
  set ignorecase
endfunction
function! tc.should_not_ignore_case()
  call self._test_align('should_not_ignore_case', 'Alignta! b\+')
  call assert#_(&ignorecase)
endfunction
function! tc.teardown_should_not_ignore_case()
  let &ignorecase = self.save_ignorecase
endfunction

function! tc.setup_should_ignore_case_when_c()
  let self.save_ignorecase = &ignorecase
  set noignorecase
endfunction
function! tc.should_ignore_case_when_c()
  call self._test_align('should_ignore_case_when_c', 'Alignta! \cb\+')
  call assert#not(&ignorecase)
endfunction
function! tc.teardown_should_ignore_case_when_c()
  let &ignorecase = self.save_ignorecase
endfunction

"---------------------------------------
" Options

function! tc.setup_buffer_local_options_should_take_precedence()
  let b:alignta_default_options = '>>'
endfunction
function! tc.buffer_local_options_should_take_precedence()
  call self._test_align('buffer_local_options_should_take_precedence', 'Alignta =')
endfunction
function! tc.teardown_buffer_local_options_should_take_precedence()
  unlet b:alignta_default_options
endfunction

function! tc.setup_should_align_with_default_arguments_if_no_args_given()
  let b:alignta_default_arguments = '>> ='
endfunction
function! tc.should_align_with_default_arguments_if_no_args_given()
  call self._test_align('should_align_with_default_arguments_if_no_args_given', 'Alignta')
endfunction
function! tc.teatdown_should_align_with_default_arguments_if_no_args_given()
  unlet b:alignta_default_arguments
endfunction

"---------------------------------------
" Parser

function! tc.after_p_should_be_parsed_as_pattern()
  call self._test_align('should_be_parsed_as_pattern', 'Alignta -p <<')
endfunction

function! tc.after_p_should_be_parsed_as_pattern_p()
  call self._test_align('should_be_parsed_as_pattern_p', 'Alignta -p -p')
endfunction

function! tc.last_arg_should_be_parsed_as_pattern()
  call self._test_align('should_be_parsed_as_pattern', 'Alignta <<')
endfunction

function! tc.last_arg_should_be_parsed_as_pattern_p()
  call self._test_align('should_be_parsed_as_pattern_p', 'Alignta -p')
endfunction

"---------------------------------------
" unite-alignta

function! tc.setup_extending_options_should_take_precedence()
  let b:alignta_default_options = '||'
  call alignta#reset_extending_options()
  call alignta#apply_extending_options('>>')
endfunction
function! tc.extending_options_should_take_precedence()
  call self._test_align('extending_options_should_take_precedence', 'Alignta =')
endfunction
function! tc.teardown_extending_options_should_take_precedence()
  call alignta#reset_extending_options()
  unlet b:alignta_default_options
endfunction

unlet tc

" vim: filetype=vim
