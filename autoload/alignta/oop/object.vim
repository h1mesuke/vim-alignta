"=============================================================================
" vim-oop
" Class-based OOP Layer for Vim script <Mininum Edition>
"
" File    : oop/object.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-02-01
" Version : 0.1.6
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

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

function! alignta#oop#object#_initialize()
  let SID = s:get_SID()

  let s:object_id = 1001
  let s:Object = alignta#oop#class#new('Object', '__nil__')

  call s:Object.bind(SID, 'initialize')
  call s:Object.bind(SID, 'attributes')
  call s:Object.bind(SID, 'inspect')
  call s:Object.bind(SID, 'is_kind_of')
  call s:Object.alias('is_a', 'is_kind_of')
  call s:Object.bind(SID, 'to_s')

  return s:Object
endfunction

function! alignta#oop#object#_get_object_id()
  let s:object_id += 1
  return s:object_id
endfunction

"-----------------------------------------------------------------------------

function! s:Object_initialize(...) dict
endfunction

function! s:Object_attributes(...) dict
  let attrs = filter(copy(self), 'type(v:val) != type(function("tr"))')
  let all = (a:0 ? a:1 : 0)
  if !all
    call s:remove_attrs(attrs, ['class', 'object_id', 'superclass'])
  else
    let attrs.__class__ = attrs.class
    unlet attrs.class
  endif
  return attrs
endfunction

function! s:remove_attrs(dict, attrs)
  for attr in a:attrs
    if has_key(a:dict, attr)
      call remove(a:dict, attr)
    endif
  endfor
endfunction

function! s:Object_inspect() dict
  let _self = map(copy(self), 'alignta#oop#is_object(v:val) ? v:val.to_s() : v:val')
  return string(_self)
endfunction

function! s:Object_is_kind_of(class) dict
  let kind_class = alignta#oop#class#get(a:class)
  for class in self.class.ancestors(1)
    if class is kind_class
      return 1
    endif
  endfor
  return 0
endfunction

function! s:Object_to_s() dict
  return '<' . self.class.name . ':0x' . printf('%08x', self.object_id) . '>'
endfunction

if !alignta#oop#_is_initialized()
  call alignta#oop#_initialize()
endif

" vim: filetype=vim
