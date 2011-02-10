"=============================================================================
" Align Them All!
"
" File    : plugin/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-02-11
" Version : 0.1.8
" License : MIT license {{{
"
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

if v:version < 700 || &cp
  echoerr "alignta: Vim 7.0 or later required"
  finish
elseif exists('g:loaded_alignta')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

"-----------------------------------------------------------------------------
" Variables

if !exists('g:alignta_default_options')
  let g:alignta_default_options = '<<<1:1'
endif

"-----------------------------------------------------------------------------
" Commands

command! -range -bang -nargs=* Alignta <line1>,<line2>call <SID>align([<f-args>], '<bang>')

if exists(':Align') != 2
  " :Align is ours, hehehe
  command! -range -bang -nargs=* Align <line1>,<line2>Alignta<bang> <args>
endif

function! s:align(align_args, bang) range
  if empty(a:align_args)
    try
      let arg_list = alignta#get_config_variable('alignta_default_arguments')
      let arg_list = substitute(substitute(arg_list, '^\s*', '', ''), '^!\@!', ' ', '')
      let range = a:firstline . ',' . a:lastline
      execute range . 'Alignta' . arg_list
    catch
      call alignta#print_error("alignta: default arguments not defined")
    endtry
  else
    let vismode = visualmode()
    if vismode == "\<C-v>" && a:firstline == line("'<") && a:lastline == line("'>")
      let region_args = [vismode]
    else
      let region_args = [a:firstline, a:lastline]
    endif
    let use_regexp = (a:bang == '!')
    call alignta#align(region_args, a:align_args, use_regexp)
  endif
endfunction

"-----------------------------------------------------------------------------

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_alignta = 1

" vim: filetype=vim
