"=============================================================================
" vim-oop
" Class-based OOP Layer for Vim script <Mininum Edition>
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-31
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

function! alignta#oop#class#_initialize()
  let SID = s:get_SID()

  let s:Class = { 'object_id': 1001 }
  let s:Class.class = s:Class
  let s:Class.name = 'Class'

  let s:class_table = { 'Class': s:Class, '__nil__': {} }

  " bind class methods
let s:Class.get                        = function(SID . 'class_Class_get')
let s:Class.is_defined                 = function(SID . 'class_Class_is_defined')
let s:Class.new                        = function(SID . 'class_Class_new')

let s:Class.prototype = {}

  " bind instance methods
let s:Class.prototype.class_alias      = function(SID . 'Class_class_alias')
let s:Class.prototype.class_bind       = function(SID . 'Class_class_bind')
let s:Class.prototype.class_unbind     = function(SID . 'Class_class_unbind')
let s:Class.prototype.class_super      = function(SID . 'Class_class_super')

let s:Class.prototype.alias            = function(SID . 'Class_alias')
let s:Class.prototype.ancestors        = function(SID . 'Class_ancestors')
let s:Class.prototype.bind             = function(SID . 'Class_bind')
let s:Class.prototype.unbind           = function(SID . 'Class_unbind')
let s:Class.prototype.export           = function(SID . 'Class_export')
let s:Class.prototype.is_descendant_of = function(SID . 'Class_is_descendant_of')
let s:Class.prototype.new              = function(SID . 'Class_new')
let s:Class.prototype.super            = function(SID . 'Class_super')
let s:Class.prototype.to_s             = function(SID . 'Class_to_s')

  " define underscored aliases
  for method_name in ['bind', 'unbind', 'export']
    let s:Class.prototype['__' . method_name . '__'] = s:Class.prototype[method_name]
  endfor

  call extend(s:Class, s:Class.prototype, 'keep')

  return s:Class
endfunction

function! alignta#oop#class#get(...)
  return call(s:Class.get, a:000, s:Class)
endfunction

function! alignta#oop#class#is_defined(...)
  return call(s:Class.is_defined, a:000, s:Class)
endfunction

function! alignta#oop#class#new(...)
  return call(s:Class.new, a:000, s:Class)
endfunction

"-----------------------------------------------------------------------------

function! s:class_Class_get(name) dict
  if type(a:name) == type("")
    if s:Class.is_defined(a:name)
      return s:class_table[a:name]
    else
      throw "oop: class " . a:name . " is not defined"
    endif
  elseif alignta#oop#is_class(a:name)
    return a:name
  else
    throw "oop: class required, but got " . alignta#oop#string(a:name)
  endif
endfunction

function! s:class_Class_is_defined(name) dict
  return has_key(s:class_table, a:name)
endfunction

function! s:class_Class_new(name, ...) dict
  let _self = copy(s:Class.prototype)
  let _self.object_id = alignta#oop#object#_get_object_id()
  let _self.class = s:Class
  let _self.superclass = alignta#oop#class#get(a:0 ? a:1 : 'Object')
  let _self.name  = a:name | let s:class_table[a:name] = _self
  let _self.prototype  = {}
  " inherit methods from superclasses
  for class in _self.ancestors()
    call extend(_self, class, 'keep')
    call extend(_self.prototype, class.prototype, 'keep')
  endfor
  return _self
endfunction

function! s:Class_class_alias(alias, method_name) dict
  if has_key(self, a:method_name) && type(self[a:method_name]) == type(function('tr'))
    let self[a:alias] = self[a:method_name]
  else
    throw "oop: " . self.name . "." . a:method_name . "() is not defined"
  endif
endfunction

function! s:Class_class_bind(sid, method_name) dict
  let self[a:method_name] = function(a:sid . 'class_' . self.name . '_' . a:method_name)
endfunction
function! s:Class_class_unbind(method_name) dict
  unlet self[a:method_name]
endfunction

function! s:Class_class_super(method_name, args, _self) dict
  let defined_here = (has_key(self, a:method_name) &&
        \ type(self[a:method_name]) == type(function('tr')))
  for class in self.ancestors()
    if has_key(class, a:method_name)
      if type(class[a:method_name]) != type(function('tr'))
        throw "oop: " . class.name . "." . a:method_name . " is not a method"
      elseif !defined_here ||
            \ (defined_here && self[a:method_name] != class[a:method_name])
        return call(class[a:method_name], a:args, a:_self)
      endif
    endif
  endfor
  throw "oop: " . self.name . "." . a:method_name . "()'s super implementation was not found"
endfunction

function! s:Class_alias(alias, method_name) dict
  if has_key(self.prototype, a:method_name) &&
        \ type(self.prototype[a:method_name]) == type(function('tr'))
    let self.prototype[a:alias] = self.prototype[a:method_name]
  else
    throw "oop: " . self.name . "#" . a:method_name . "() is not defined"
  endif
endfunction

function! s:Class_ancestors(...) dict
  let inclusive = (a:0 ? a:1 : 0)
  let ancestors = []
  let class = (inclusive ? self : self.superclass)
  while !empty(class)
    call add(ancestors, class)
    let class = class.superclass
  endwhile
  return ancestors
endfunction

function! s:Class_bind(sid, method_name) dict
  let self.prototype[a:method_name] = function(a:sid . self.name . '_' . a:method_name)
endfunction
function! s:Class_unbind(method_name) dict
  unlet self.prototype[a:method_name]
endfunction

function! s:Class_export(method_name) dict
  if has_key(self.prototype, a:method_name) &&
        \ type(self.prototype[a:method_name]) == type(function('tr'))
    let self[a:method_name] = self.prototype[a:method_name]
  else
    throw "oop: " . self.name . "#" . a:method_name . "() is not defined"
  endif
endfunction

function! s:Class_is_descendant_of(class) dict
  let test_class = s:Class.get(a:class)
  return (index(self.ancestors(), test_class) >= 0)
endfunction

function! s:Class_new(...) dict
  " instantiate
  let obj = copy(self.prototype)
  let obj.object_id = alignta#oop#object#_get_object_id()
  let obj.class = self
  call call(obj.initialize, a:000, obj)
  return obj
endfunction

function! s:Class_super(method_name, args, _self) dict
  let defined_here = (has_key(self.prototype, a:method_name) &&
        \ type(self.prototype[a:method_name]) == type(function('tr')))
  for class in self.ancestors()
    if has_key(class.prototype, a:method_name)
      if type(class.prototype[a:method_name]) != type(function('tr'))
        throw "oop: " . class.name . "#" . a:method_name . " is not a method"
      elseif !defined_here ||
            \ (defined_here && self.prototype[a:method_name] != class.prototype[a:method_name])
        return call(class.prototype[a:method_name], a:args, a:_self)
      endif
    endif
  endfor
  throw "oop: " . self.name . "#" . a:method_name . "()'s super implementation was not found"
endfunction

function! s:Class_to_s() dict
  return self.name
endfunction

if !alignta#oop#_is_initialized()
  call alignta#oop#_initialize()
endif

" vim: filetype=vim
