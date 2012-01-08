"=============================================================================
" File    : lib/string.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2012-01-08
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

let s:save_cpo = &cpo
set cpo&vim

" Inspired by Yukihiro Nakadaira's nsexample.vim
" https://gist.github.com/867896
"
let s:lib = expand('<sfile>:p:h:gs?[\\/]?#?:s?^.*#autoload#??')
" => path#to#lib

function! {s:lib}#string#import()
  return s:String
endfunction

"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:String = {s:lib}#oop#module#new('String', s:SID)

function! s:String_escape_regexp(str)
  return escape(a:str, '^$[].*\~')
endfunction
call s:String.function('escape_regexp')

" String.justify( {str}, {width}, {align} [, {col}])
function! s:String_justify(str, width, align, ...)
  if ((a:align == '<' || a:align =~# 'l\%[eft]') ||
    \ (a:align == '=' || a:align =~# 'a\%[ppend]'))
    let col = (a:0 ? a:1 : 0)
    let str_w = s:String_width(a:str, col)
    let lpad = ''
    let rpad = s:String_padding(a:width - str_w)
  elseif a:str =~ '\t'
    throw "StringError: The string contains a Tab."
  else
    let str_w = s:String_width(a:str)
    if a:align == '|' || a:align =~# 'c\%[enter]'
      let lpad_w = (a:width - str_w) / 2
      let lpad = s:String_padding(lpad_w)
      let rpad = s:String_padding(a:width - lpad_w - str_w)
    elseif a:align == '>' || a:align =~# 'r\%[ight]'
      let lpad = s:String_padding(a:width - str_w)
      let rpad = ''
    endif
  endif
  return lpad . a:str . rpad
endfunction
call s:String.function('justify')

" Returns concatenated Spaces for padding.
"
" NOTE: This function's interface must be same as String.tab_padding's.
" Don't remove "...".
"
function! s:String_padding(width, ...)
  return repeat(' ', a:width)
endfunction
call s:String.function('padding')

" Returns concatenated Tabs and Spaces for padding. The returned padding
" string occupies {width} in display cells from column {col}+1 on the screen.
"
" If 'tabstop' is 8:
"
"   String.tab_padding(10, 0) => 1 Tab  and 2 Spaces
"   String.tab_padding(10, 4) => 1 Tab  and 6 Spaces
"
"   String.tab_padding(20, 0) => 2 Tabs and 4 Spaces
"   String.tab_padding(20, 4) => 3 Tabs and 0 Space
"
" String.tab_padding( {width} [, {col}])
function! s:String_tab_padding(width, ...)
  let col = (a:0 ? a:1 : 0) | let ts = &l:tabstop
  let rem = (col % ts)
  let width = rem + a:width
  let n_Tab =  width / ts
  let n_Spc = (width % ts) - (n_Tab > 0 ? 0 : rem)
  return repeat("\t", n_Tab) . repeat(' ', n_Spc)
endfunction
call s:String.function('tab_padding')

function! s:String_strip(str)
  return substitute(substitute(a:str, '^\s*', '', ''), '\s*$', '', '')
endfunction
call s:String.function('strip')

function! s:String_lstrip(str)
  return substitute(a:str, '^\s*', '', '')
endfunction
call s:String.function('lstrip')

function! s:String_rstrip(str)
  return substitute(a:str, '\s*$', '', '')
endfunction
call s:String.function('rstrip')

if v:version >= 703
  " String.width( str [, {col}])
  function! s:String_width(str, ...)
    let col = (a:0 ? a:1 : 0)
    return strdisplaywidth(a:str, col)
  endfunction
  call s:String.function('width')
else
  " String.width( str [, {col}])
  function! s:String_width(str, ...)
    if a:str =~ '^[\x00-\x08\x0a-\x7f]*$'
      " NOTE: If the given string consists of only 7-bit ASCII characters
      " excluding Tab, we can use strlen() to calculate the width of it.
      return strlen(a:str)
    endif

    let col = (a:0 ? a:1 : 0)

    " Derived from Charles Campbell's Align.vim
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
  call s:String.function('width')
endif

let &cpo = s:save_cpo
unlet s:save_cpo
