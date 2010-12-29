"=============================================================================
" Align Them All!
"
" File    : autoload/alignta/object.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2010-12-29
" Version : 0.1.3
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

function! alignta#object#extend()
  return s:Object.extend()
endfunction

let s:NIL = {}
let s:Object = { 'super': s:NIL }

function! s:Object.new(...)
  " instantiate
  let obj = copy(self)
  let obj.class = self
  unlet obj.super
  " inherit methods from superclasses
  let klass = obj.class
  while klass isnot s:NIL
    call extend(obj, klass.super, 'keep')
    let klass = klass.super
  endwhile
  call call(obj.initialize, a:000, obj)
  return obj
endfunction

function! s:Object.initialize(...)
endfunction

function! s:Object.extend()
  return extend({ 'super': self }, self, 'keep')
endfunction

" vim: filetype=vim
