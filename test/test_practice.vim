" alignta's test suite

let tc = unittest#testcase#new('test_practice', alignta#testcase#class())

"-----------------------------------------------------------------------------

" equivalent to Align.vim's <Leader>a?
function! tc.test_leader_a_q()
  call self._test_align('test_leader_a?', 'Alignta @01 \ ? \ :')
endfunction

" equivalent to Align.vim's <Leader>a<
function! tc.test_leader_a_lt()
  call self._test_align('test_leader_a<', 'Alignta -p <<')
endfunction

" equivalent to Align.vim's <Leader>a=
function! tc.test_leader_a_eq()
  call self._test_align('test_leader_a=', 'Alignta :=')
endfunction

" equivalent to Align.vim's <Leader>acom
function! tc.test_leader_acom()
  call self._test_align('test_leader_acom', 'Alignta! -> \(/\*\|\S\@<=\s*$\) \*/')
endfunction

" equivalent to Align.vim's <Leader>aocom
function! tc.test_leader_aocom()
  call self._test_align('test_leader_aocom', 'Alignta -> /* */')
endfunction

" equivalent to Align.vim's <Leader>ascom
function! tc.test_leader_ascom()
  call self._test_align('test_leader_ascom', 'Alignta v/^\s*/\* -> /* */')
endfunction

"" equivalent to Align.vim's <Leader>adec
"function! tc.test_leader_adec()
" call self._test_align('test_leader_adec', 'Alignta _args_')
"endfunction

"" equivalent to Align.vim's <Leader>anum
"function! tc.test_leader_anum()
" call self._test_align('test_leader_anum', 'Alignta _args_')
"endfunction

" equivalent to Align.vim's <Leader>t=
function! tc.test_leader_t_eq()
  call self._test_align('test_leader_t=', 'Alignta =')
endfunction

" equivalent to Align.vim's <Leader>T=
function! tc.test_leader_T_eq()
  call self._test_align('test_leader_T=', 'Alignta >> =')
endfunction

" equivalent to Align.vim's <Leader>t|
function! tc.test_leader_t_bar()
  call self._test_align('test_leader_t|', 'Alignta @0 |')
endfunction

" equivalent to Align.vim's <Leader>T|
function! tc.test_leader_T_bar()
  call self._test_align('test_leader_T|', 'Alignta >>0 |')
endfunction

" equivalent to Align.vim's <Leader>t:
function! tc.test_leader_t_colon()
  call self._test_align('test_leader_t:', 'Alignta :')
endfunction

" equivalent to Align.vim's <Leader>T:
function! tc.test_leader_T_colon()
  call self._test_align('test_leader_T:', 'Alignta >> :')
endfunction

" equivalent to Align.vim's <Leader>tab
function! tc.setup_leader_tab()
  let self.save_expandtab = &l:expandtab
  set noexpandtab
endfunction
function! tc.test_leader_tab()
  call self._test_align('test_leader_tab', 'Alignta! <--2 \S\+{+}')
endfunction
function! tc.teardown_leader_tab()
  let &l:expandtab = self.save_expandtab
endfunction

" equivalent to Align.vim's <Leader>tml
function! tc.test_leader_tml()
  call self._test_align('test_leader_tml', 'Alignta! \\\\$')
endfunction

" equivalent to Align.vim's <Leader>tsp
function! tc.test_leader_tsp()
  call self._test_align('test_leader_tsp', 'Alignta! \S\+')
endfunction

" equivalent to Align.vim's <Leader>Tsp
function! tc.test_leader_Tsp()
  call self._test_align('test_leader_Tsp', 'Alignta! >> \S\+')
endfunction

" equivalent to Align.vim's <Leader>tsq
function! tc.test_leader_tsq()
  call self._test_align('test_leader_tsq', 'Alignta! \("[^"]*"\|' . "'[^']*'" . '\|\S\+\)')
endfunction

" equivalent to Align.vim's <Leader>Htd
function! tc.test_leader_Htd()
  call self._test_align('test_leader_Htd', 'Alignta! @0 \c</\=td>')
endfunction

" equivalent to Align.vim's <Leader>tt
function! tc.test_leader_tt()
  call self._test_align('test_leader_tt', 'Alignta & \\\\')
endfunction

unlet tc

" vim: filetype=vim
