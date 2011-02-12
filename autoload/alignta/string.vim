"=============================================================================
" File    : string.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-02-12
" Version : 0.1.1
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

function! alignta#string#escape_regexp(str, ...)
  let chars = '^$[].*\~' . (a:0 ? a:1 : '')
  return escape(a:str, chars)
endfunction

function! alignta#string#pad(str, width, align, ...)
  if ((a:align == '<' || a:align =~# 'l\%[eft]') ||
    \ (a:align == '=' || a:align =~# 'a\%[ppend]'))
    let col = (a:0 ? a:1 : 0)
    let str_w = alignta#string#width(a:str, col)
    let lpad = ''
    let rpad = alignta#string#padding(a:width - str_w)
  elseif a:str =~ '\t'
    throw "ArgumentError: the string contains a Tab"
  else
    let str_w = alignta#string#width(a:str)
    if a:align == '|' || a:align =~# 'c\%[enter]'
      let lpad_w = (a:width - str_w) / 2
      let lpad = alignta#string#padding(lpad_w)
      let rpad = alignta#string#padding(a:width - lpad_w - str_w)
    elseif a:align == '>' || a:align =~# 'r\%[ight]'
      let lpad = alignta#string#padding(a:width - str_w)
      let rpad = ''
    endif
  endif
  return lpad . a:str . rpad
endfunction

function! alignta#string#padding(width, ...)
  return repeat(' ', a:width)
endfunction

function! alignta#string#tab_padding(width, ...)
  let col = (a:0 ? a:1 : 0) | let ts = &l:tabstop
  let col_r = (col % ts)
  let width = col_r + a:width
  let n_Tab =  width / ts
  let n_Spc = (width % ts) - (n_Tab > 0 ? 0 : col_r)
  return repeat("\t", n_Tab) . repeat(' ', n_Spc)
endfunction

function! alignta#string#strip(str)
  return substitute(substitute(a:str, '^\s*', '', ''), '\s*$', '', '')
endfunction

function! alignta#string#lstrip(str)
  return substitute(a:str, '^\s*', '', '')
endfunction

function! alignta#string#rstrip(str)
  return substitute(a:str, '\s*$', '', '')
endfunction

if v:version >= 703
  function! alignta#string#width(str, ...)
    let col = (a:0 ? a:1 : 0)
    return strdisplaywidth(a:str, col)
  endfunction

else
  function! alignta#string#width(str, ...)
    if a:str =~ '^[\x00-\x08\x0a-\x7f]*$'
      " NOTE: If the given string consists of only 7-bit ASCII characters
      " excluding Tab, we can use strlen() to calculate the width of it.
      return strlen(a:str)
    endif

    let col = (a:0 ? a:1 : 0)

    " borrowed from Charles Campbell's Align.vim
    " http://www.vim.org/scripts/script.php?script_id=294
    "
    " NOTE: This code has a side effect that changes the cursor's position.
    let save_mod = &l:modified
    execute "normal! o\<Esc>"
    call setline(line('.'), repeat(' ', col) . a:str)
    let width = virtcol('$') - col - 1
    silent delete _
    let &l:modified = save_mod
    return width
  endfunction
endif

" vim: filetype=vim
