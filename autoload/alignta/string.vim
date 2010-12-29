"=============================================================================
" Align Them All!
"
" File    : autoload/alignta/string.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2010-12-29
" Version : 0.1.2
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

function! alignta#string#escape_regexp(str)
  return escape(a:str, '^$[].*\~')
endfunction

function! alignta#string#is_ascii(str)
  return (a:str =~ '^[\x00-\x7f]*$')
endfunction

function! alignta#string#pad(str, width, align, ...)
  let str_w = alignta#string#width(a:str)
  if str_w >= a:width
    return a:str
  endif
  let no_trailing = (a:0 ? a:1 : 0)
  if a:align ==# 'left'
    let lpad = ""
    let rpad = alignta#string#padding(a:width - str_w)
  elseif a:align ==# 'center'
    let lpad_w = (a:width - str_w) / 2
    let lpad = alignta#string#padding(lpad_w)
    let rpad = alignta#string#padding(a:width - lpad_w - str_w)
  elseif a:align ==# 'right'
    let lpad = alignta#string#padding(a:width - str_w)
    let rpad = ""
  else
    let lpad = ""
    let rpad = ""
  endif
  return lpad . a:str . (no_trailing ? "" : rpad)
endfunction

function! alignta#string#padding(width, ...)
  let char = (a:0 ? a:1 : ' ')
  return repeat(char, a:width)
endfunction

function! alignta#string#strip(str)
  return substitute(substitute(a:str, '^\s*', '', ''), '\s*$', '', '')
endfunction

function! alignta#string#rstrip(str)
  return substitute(a:str, '\s*$', '', '')
endfunction

if v:version >= 703
  function! alignta#string#width(str)
    return strwidth(a:str)
  endfunction

else
  function! alignta#string#width(str)
    if alignta#string#is_ascii(a:str)
      return strlen(a:str)
    endif
    " borrowed from Charles Campbell's Align.vim
    " http://www.vim.org/scripts/script.php?script_id=294
    "
    " NOTE: This code has a side effect that changes the cursor's position.
    let save_mod = &l:modified
    execute "normal! o\<Esc>"
    call setline(line('.'), a:str)
    let width = virtcol('$') - 1
    silent delete _
    let &l:modified = save_mod
    return width
  endfunction
endif

" vim: filetype=vim
