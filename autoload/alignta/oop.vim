"=============================================================================
" vim-oop
" Simple OOP Layer for Vim script
"
" File    : oop.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2012-01-08
" Version : 0.2.2
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
let s:oop = expand('<sfile>:p:r:gs?[\\/]?#?:s?^.*#autoload#??')
" => path#to#oop

let s:TYPE_NUM  = type(0)
let s:TYPE_STR  = type("")
let s:TYPE_DICT = type({})
let s:TYPE_LIST = type([])
let s:TYPE_FUNC = type(function('tr'))

function! {s:oop}#_sid_prefix(sid)
  if type(a:sid) == s:TYPE_NUM
    return '<SNR>' . a:sid . '_'
  else
    return '<SNR>' . matchstr(a:sid, '\d\+') . '_'
  endif
endfunction

function! {s:oop}#is_object(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__type_Object__')
endfunction

function! {s:oop}#is_class(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__type_Class__')
endfunction

function! {s:oop}#is_instance(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__type_Instance__')
endfunction

function! {s:oop}#is_module(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, '__type_Module__')
endfunction

function! {s:oop}#string(value)
  let value_type = type(a:value)
  if value_type == s:TYPE_LIST || value_type == s:TYPE_DICT
    return s:dump_copy(a:value)
  else
    return string(a:value)
  endif
endfunction

function! s:dump_copy(value)
  let value = a:value
  let value_type = type(a:value)
  if value_type == s:TYPE_DICT
    if has_key(a:value, '__type_Class__')
      return '<Class: ' . a:value.__name__ . '>'
    elseif has_key(a:value, '__type_Module__')
      return '<Module: ' . a:value.__name__ . '>'
    elseif has_key(a:value, '__type_Instance__')
      let value = filter(copy(a:value), '
            \ !(type(v:val) == s:TYPE_FUNC || v:key =~ "^__type_")')
    endif
  endif
  if value_type == s:TYPE_LIST || value_type == s:TYPE_DICT
    return string(map(copy(value), 's:dump_copy(v:val)'))
  else
    return value
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
