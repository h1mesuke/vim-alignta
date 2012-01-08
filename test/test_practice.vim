" alignta's test suite

let s:save_cpo = &cpo
set cpo&vim

let s:tc = unittest#testcase#new('test_practice', alignta#testcase#class())

"-----------------------------------------------------------------------------

" Equivalent to Align.vim's <Leader>a?
function! s:tc.test_leader_a_q()
  call self._test_align('test_leader_a?', 'Alignta @01 \ ? \ :')
endfunction

" Equivalent to Align.vim's <Leader>a<
function! s:tc.test_leader_a_lt()
  call self._test_align('test_leader_a<', 'Alignta -p <<')
endfunction

" Equivalent to Align.vim's <Leader>a=
function! s:tc.test_leader_a_eq()
  call self._test_align('test_leader_a=', 'Alignta :=')
endfunction

" Equivalent to Align.vim's <Leader>acom
function! s:tc.test_leader_acom()
  call self._test_align('test_leader_acom', 'Alignta -> \(/\*\|\S\@<=\s*$\) \*/')
endfunction

" Equivalent to Align.vim's <Leader>aocom
function! s:tc.test_leader_aocom()
  call self._test_align('test_leader_aocom', 'Alignta -> /* */')
endfunction

" Equivalent to Align.vim's <Leader>ascom
function! s:tc.test_leader_ascom()
  call self._test_align('test_leader_ascom', 'Alignta v/^\s*/\* -> /* */')
endfunction

"" Equivalent to Align.vim's <Leader>adec
"function! s:tc.test_leader_adec()
" call self._test_align('test_leader_adec', 'Alignta _args_')
"endfunction

"" Equivalent to Align.vim's <Leader>anum
"function! s:tc.test_leader_anum()
" call self._test_align('test_leader_anum', 'Alignta _args_')
"endfunction

" Equivalent to Align.vim's <Leader>t=
function! s:tc.test_leader_t_eq()
  call self._test_align('test_leader_t=', 'Alignta =')
endfunction

" Equivalent to Align.vim's <Leader>T=
function! s:tc.test_leader_T_eq()
  call self._test_align('test_leader_T=', 'Alignta >> =')
endfunction

" Equivalent to Align.vim's <Leader>t|
function! s:tc.test_leader_t_bar()
  call self._test_align('test_leader_t|', 'Alignta @0 |')
endfunction

" Equivalent to Align.vim's <Leader>T|
function! s:tc.test_leader_T_bar()
  call self._test_align('test_leader_T|', 'Alignta >>0 |')
endfunction

" Equivalent to Align.vim's <Leader>t:
function! s:tc.test_leader_t_colon()
  call self._test_align('test_leader_t:', 'Alignta :')
endfunction

" Equivalent to Align.vim's <Leader>T:
function! s:tc.test_leader_T_colon()
  call self._test_align('test_leader_T:', 'Alignta >> :')
endfunction

" Equivalent to Align.vim's <Leader>tab
function! s:tc.setup_leader_tab()
  let self.save_expandtab = &l:expandtab
  set noexpandtab
endfunction
function! s:tc.test_leader_tab()
  call self._test_align('test_leader_tab', 'Alignta <--2 \S\+{+}')
endfunction
function! s:tc.teardown_leader_tab()
  let &l:expandtab = self.save_expandtab
endfunction

" Equivalent to Align.vim's <Leader>tml
function! s:tc.test_leader_tml()
  call self._test_align('test_leader_tml', 'Alignta \\\\$')
endfunction

" Equivalent to Align.vim's <Leader>tsp
function! s:tc.test_leader_tsp()
  call self._test_align('test_leader_tsp', 'Alignta \S\+')
endfunction

" Equivalent to Align.vim's <Leader>Tsp
function! s:tc.test_leader_Tsp()
  call self._test_align('test_leader_Tsp', 'Alignta >> \S\+')
endfunction

" Equivalent to Align.vim's <Leader>tsq
function! s:tc.test_leader_tsq()
  call self._test_align('test_leader_tsq', 'Alignta \("[^"]*"\|' . "'[^']*'" . '\|\S\+\)')
endfunction

" Equivalent to Align.vim's <Leader>Htd
function! s:tc.test_leader_Htd()
  call self._test_align('test_leader_Htd', 'Alignta @0 \c</\=td>')
endfunction

" Equivalent to Align.vim's <Leader>tt
function! s:tc.test_leader_tt()
  call self._test_align('test_leader_tt', 'Alignta & -e \\\\')
endfunction

"-----------------------------------------------------------------------------

unlet s:tc

let &cpo = s:save_cpo
unlet s:save_cpo
