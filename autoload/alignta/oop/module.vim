"=============================================================================
" vim-oop
" Simple OOP Layer for Vim script
"
" File    : oop/module.vim
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
let s:oop = expand('<sfile>:p:h:gs?[\\/]?#?:s?^.*#autoload#??')
" => path#to#oop

"-----------------------------------------------------------------------------
" Module

" path#to#oop#module#new( {name}, {sid})
"
" Creates a new module. The second argument must be the SID prefix of the
" script where the module is defined.
"
"   function! s:get_SID()
"     return matchstr(expand('<sfile>'), '<SNR>\d\+_')
"   endfunction
"   let s:SID = s:get_SID()
"   delfunction s:get_SID
"
"   s:Fizz = path#to#oop#module#new('Fizz', s:SID)
"
function! {s:oop}#module#new(name, sid)
  let module = copy(s:Module)
  let module.__name__ = a:name
  let module.__prefix__ = {s:oop}#_sid_prefix(a:sid) . a:name . '_'
  " => <SNR>10_Fizz_
  return module
endfunction

"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:Module = {
      \ '__type_Object__': 1,
      \ '__type_Module__': 1,
      \ }

" Binds a function to a module Dictionary as a module function. The name of
" the function to be bound must be prefixed by the module name followed by one
" underscore. This convention helps you to distinguish module functions from
" other functions.
"
"   function! s:Fizz_hello() dict
"   endfunction
"   call s:Fizz.function('hello')
"
" Note that however the names of module functions themselves don't include the
" prefix.
"
"   call s:Fizz.hello()
"
function! s:Module_bind(func_name, ...) dict
  let meth_name = (a:0 ? a:1 : a:func_name)
  let self[meth_name] = function(self.__prefix__  . a:func_name)
endfunction
let s:Module.__bind__ = function(s:SID . 'Module_bind')
let s:Module.function = s:Module.__bind__ | " syntax sugar

" Defines an alias of a module function.
"
"   call s:Fizz.alias('hi', 'hello')
"
function! s:Module_alias(alias, meth_name) dict
  if has_key(self, a:meth_name) &&
        \ type(self[a:meth_name]) == type(function('tr'))
    let self[a:alias] = self[a:meth_name]
  else
    throw "vim-oop: " . self.__name__ . "." . a:meth_name . "() is not defined."
  endif
endfunction
let s:Module.alias = function(s:SID . 'Module_alias')

let &cpo = s:save_cpo
unlet s:save_cpo
