"=============================================================================
" Align Them All!
"
" File    : alignta.vim
" Author  : h1mesuke
" Updated : 2010-10-21
" Version : 0.0.1
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

if &cp || exists("g:loaded_alignta")
  finish
endif
let g:loaded_alignta = 1

let s:saved_cpo = &cpo
set cpo&vim

command! -range -nargs=+ Alignta <line1>,<line2>call <SID>alignta(<f-args>)

if !exists(':Align')
  " :Align is mine, hehehe
  command! -range -nargs=+ Align Alignta <args>
endif

function! s:alignta(...) range
  let data = {
        \ 'lines': getline(a:firstline, a:lastline),
        \ 'aligned': s:blank_lines(a:lastline - a:firstline + 1),
        \ 'align_options': s:align_options_defaults(),
        \ }
  for arg in a:000
    if match(arg, '^{\(.*\)}$') == 0
      call s:align_options_apply(data, arg)
    else
      call s:align(data, arg)
    endif
  endfor
  call s:lines_concat(data.aligned, data.lines)
  call s:set_lines(a:firstline, data.aligned)
endfunction

function! s:align(data, sep)
  let matched = 0
  let l_flds = []
  let s_flds = []
  let r_flds = []

  " the max width of fields
  let l_fld_max = 0
  let s_fld_max = 0
  let r_fld_max = 0

  " phase 1
  for line in a:data.lines
    let matches = matchlist(line, '^\(.*\)\(' . a:sep . '\)\(.*\)$')
    if !empty(matches)
      let matched = 1
      " left field
      let fld = substitute(matches[1], '\s*$', '', '')
      let w = len(fld)
      if w > l_fld_max
        let l_fld_max = w
      endif
      call add(l_flds, fld)
      " separator field
      let fld = matches[2]
      let w = len(fld)
      if w > s_fld_max
        let s_fld_max = w
      endif
      call add(s_flds, fld)
      " right field
      let fld = substitute(matches[-1], '^\s*', '', '')
      let w = len(fld)
      if w > r_fld_max
        let r_fld_max = w
      endif
      call add(r_flds, fld)
    else
      " skip
      call add(l_flds, 0)
      call add(s_flds, 0)
      call add(r_flds, 0)
    endif
  endfor

  " phase 2
  let idx = len(a:data.lines) - 1
  while idx > 0
    let idx -= 1
  endwhile

  call s:lines_concat(a:data.aligned, l_flds)
  call s:lines_concat(a:data.aligned, s_flds)
  call s:lines_replace(a:data.lines, r_flds)
  return matched
endfunction

"-----------------------------------------------------------------------------
" Options

function! s:align_options_init(data)
  let a:data.align_options = s:align_options_defaults()
endfunction

function! s:align_options_apply(data, opts)
  if match(a:opts, '^{defaults\=}$')
    call s:align_options_init(a:data)
  else
  endif
endfunction

function! s:align_options_defaults()
  return {
        \ 'l_fld_align': 'l',
        \ 's_fld_align': 'l',
        \ 'r_fld_align': 'l',
        \ 's_fld_lpad': '1',
        \ 's_fld_rpad': '1',
        \ }
endfunction

"-----------------------------------------------------------------------------
" Utilities

function! s:lines_concat(lines_a, lines_b)
  let idx = len(a:lines_b) - 1
  while idx >= 0
    if type(a:lines_b[idx]) == 1 " is a string
      let a:lines_a[idx] .= a:lines_b[idx]
    endif
    let idx -= 1
  endwhile
endfunction

function! s:lines_replace(lines_a, lines_b)
  let idx = len(a:lines_b) - 1
  while idx >= 0
    if type(a:lines_b[idx]) == 1 " is a string
      let a:lines_a[idx] = a:lines_b[idx]
    endif
    let idx -= 1
  endwhile
endfunction

function! s:blank_lines(n)
  let lines = []
  let n = a:n
  while n > 0
    call add(lines, "")
    let n -= 1
  endwhile
  return lines
endfunction

function! s:set_lines(rbeg, lines)
  let nr = a:rbeg
  for line in a:lines
    call setline(nr, line)
    let nr += 1
  endfor
endfunction

let &cpo = s:saved_cpo
unlet s:saved_cpo

" vim: filetype=vim
