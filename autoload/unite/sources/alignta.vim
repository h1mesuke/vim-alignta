"=============================================================================
" Align Them All!
"
" File    : autoload/unite/sources/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2012-01-08
" Version : 0.3.0
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

let s:save_cpo = &cpo
set cpo&vim

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
        \ ["Justify Left",      '<<' ],
        \ ["Justify Center",    '||' ],
        \ ["Justify Right",     '>>' ],
        \ ["Justify None",      '==' ],
        \ ["Shift Left",        '<-' ],
        \ ["Shift Right",       '->' ],
        \ ["Shift Left  [Tab]", '<--'],
        \ ["Shift Right [Tab]", '-->'],
        \ ["Margin 0:0",        '@0' ],
        \ ["Margin 0:1",        '@01'],
        \ ["Margin 1:0",        '@10'],
        \ ["Margin 1:1",        '@1' ],
        \]
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
    let mode = (len(a:args) > 0 ? a:args[0] : 'both')
    let cands = []

    if mode =~? '^\(a\%[rguments]\|v\%[isual]\)$' || mode ==# 'both'
      " preset arguments
      for value in g:unite_source_alignta_preset_arguments
        if type(value) == type([])
          let arg_list = value[1]
          let label = value[0]
        else
          let arg_list = value
          let label = arg_list
        endif
        let arg_list = substitute(substitute(arg_list, '^\s*', '', ''), '^!\@!', ' ', '')
        let command_line = "'<,'>Alignta" . arg_list
        call add(cands, {
              \ 'word'  : label,
              \ 'source': 'alignta',
              \ 'kind'  : 'command',
              \ 'action__command': command_line,
              \ })
        unlet value
      endfor
    endif

    if mode =~? '^\(o\%[ptions]\|n\%[ormal]\)$' || mode ==# 'both'
      " preset options
      let preset_opts = g:unite_source_alignta_preset_options
      let idx = 0
      while idx < len(preset_opts)
        let value = preset_opts[idx]
        if type(value) == type([])
          let opts_expr = 'g:unite_source_alignta_preset_options[' . idx . '][1]'
          let label = value[0]
        else
          let opts_expr = 'g:unite_source_alignta_preset_options[' . idx . ']'
          let label = value
        endif
        call add(cands, {
              \ 'word'  : "Options: " . label,
              \ 'source': 'alignta',
              \ 'kind'  : 'command',
              \ 'action__command': 'call alignta#apply_extending_options(' . opts_expr . ')',
              \ })
        let idx += 1
        unlet value
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

let &cpo = s:save_cpo
unlet s:save_cpo
