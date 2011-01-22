"=============================================================================
" Align Them All!
"
" File    : autoload/unite/sources/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-23
" Version : 0.1.7
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

function! unite#sources#alignta#define()
  return s:source
endfunction

"-----------------------------------------------------------------------------
" Variables

if !exists('g:unite_source_alignta_preset_arguments')
  let g:unite_source_alignta_preset_arguments = []
endif

if !exists('g:unite_source_alignta_preset_options')
  let g:unite_source_alignta_preset_options = [
        \ '|||',
        \ '>>>',
        \ '<=',
        \ '@0',
        \ '@01',
        \ '@10',
        \ ]
endif

"-----------------------------------------------------------------------------
" Source

let s:source = {
      \ 'name': 'alignta',
      \ 'description': "candidates from alignta's preset arguments",
      \ 'is_volatile': 1,
      \ }

function! s:source.gather_candidates(args, context)
  try
    let mode = (len(a:args) > 0 ? a:args[0] : 'unknown')
    let cands = []

    if mode =~? '^v\%[isual]$' || mode ==# 'unknown'
      " preset arguments
      let preset_args = alignta#get_config_variable('unite_source_alignta_preset_arguments')
      for arg_list in preset_args
        let arg_list = substitute(substitute(arg_list, '^\s*', '', ''), '^!\@!', ' ', '')
        let command_line = "'<,'>Alignta" . arg_list
        call add(cands, {
              \ 'word'  : command_line,
              \ 'source': 'alignta',
              \ 'kind'  : 'command',
              \ 'action__command': command_line,
              \ })
      endfor
    endif

    if mode =~? '^n\%[ormal]$' || mode ==# 'unknown'
      " preset options
      let preset_opts = alignta#get_config_variable('unite_source_alignta_preset_options')
      let idx = 0
      while idx < len(preset_opts)
        let opts_str = 'alignta#get_config_variable(' .
              \ '"unite_source_alignta_preset_options")[' . idx . ']'
        call add(cands, {
              \ 'word'  : "Options: " . preset_opts[idx],
              \ 'source': 'alignta',
              \ 'kind'  : 'command',
              \ 'action__command': 'call alignta#apply_extending_options(' . opts_str . ')',
              \ })
        let idx += 1
      endwhile

      " reset
      call add(cands, {
            \ 'word'  : "Options: <RESET>",
            \ 'source': 'alignta',
            \ 'kind'  : 'command',
            \ 'action__command': 'call alignta#reset_extending_options()',
            \ })
    endif

    return cands
  catch
    call unite#print_error(v:throwpoint)
    call unite#print_error(v:exception)
    return []
  endtry
endfunction

" vim: filetype=vim
