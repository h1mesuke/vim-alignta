"=============================================================================
" File    : vimenv.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2012-01-08
" Version : 0.1.5
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

function! {s:lib}#vimenv#import()
  return s:Vimenv
endfunction

"-----------------------------------------------------------------------------

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

" Vimenv is a class that help us to save/restore the current Vim's environment
" parameters.
"
" == Example
"
"   " Save the Vim's environment. 
"   let vimenv = s:Vimenv.new('cursor', '&ignorecase', '&lazyredraw') 
"   try 
"     set noignorecase 
"     set lazyredraw 
"     " Do something.
"   catch 
"     call s:print_error(v:throwpoint) 
"     call s:print_error(v:exception) 
"   finally 
"     " Restore the Vim's environment. 
"     call vimenv.restore() 
"   endtry 
" 
let s:Vimenv = {s:lib}#oop#class#new('Vimenv', s:SID)

" Vimenv.new( {args})
function! s:Vimenv_initialize(...) dict
  let args = a:000
  let save_cursor = 0
  let save_marks  = []
  let save_opts   = []
  let save_regs   = []
  let save_vsel   = 0

  " Parse arguments.
  for value in args
    if value ==? 'cursor' || value == '.'
      let save_cursor = 1
    elseif value =~# "^'[a-zA-Z[\\]']$"
      call add(save_marks, substitute(value, '^.', '', ''))
    elseif value =~# '^&\(l:\)\=\w\+'
      call add(save_opts,  substitute(value, '^.', '', ''))
    elseif value =~# '^@[\"a-z01-9\-*+~/]$'
      call add(save_regs,  substitute(value, '^.', '', ''))
    elseif value ==# 'R'
      let save_regs += ['1', '2', '3', '4', '5', '6', '7', '8', '9', '-']
    elseif value ==? 'v' || value == "\<C-v>"
      let save_vsel = 1
      let visualmode = value
    else
      throw "VimenvError: Invalid name " . string(value)
    endif
  endfor

  " Save the cursor.
  if save_cursor
    let self.cursor = getpos('.')
  endif
  " Save marks.
  if !empty(save_marks)
    let saved_marks = {}
    for mark_name in save_marks
      let saved_marks[mark_name] = getpos("'" . mark_name)
    endfor
    let self.marks = saved_marks
  endif
  " Save options.
  if !empty(save_opts)
    let saved_opts = {}
    for opt_name in save_opts
      execute 'let saved_opts[opt_name] = &' . opt_name
    endfor
    let self.options = saved_opts
  endif
  " Save registers.
  if !empty(save_regs)
    let saved_regs = {}
    for reg_name in save_regs
      let reg_data = {
            \ 'value': getreg(reg_name),
            \ 'type' : getregtype(reg_name),
            \ }
      let saved_regs[reg_name] = reg_data
    endfor
    let self.registers = saved_regs
  endif
  " Save the visual selection.
  if save_vsel
    let saved_vsel = {
          \ 'mode' : visualmode,
          \ 'start': getpos("'<"),
          \ 'end'  : getpos("'>"),
          \ }
    let self.selection = saved_vsel
  endif
endfunction
call s:Vimenv.method('initialize')

function! s:Vimenv_restore() dict
  " Restore marks.
  if has_key(self, 'marks')
    for [mark_name, mark_pos] in items(self.marks)
      call setpos("'" . mark_name, mark_pos)
    endfor
  endif
  " Restore options.
  if has_key(self, 'options')
    for [opt_name, opt_val] in items(self.options)
      execute 'let &' . opt_name .' = opt_val'
    endfor
  endif
  " Restore registers.
  if has_key(self, 'registers')
    for [reg_name, reg_data] in items(self.registers)
      call setreg(reg_name, reg_data.value, reg_data.type)
    endfor
    " NOTE: As a side effect, setreg() to numbered or named registers always
    " updates @" too. So, need to setreg() to @" again at the last.
    if has_key(self.registers, '"')
      let reg_data = self.registers['"']
      call setreg('"', reg_data.value, reg_data.type)
    endif
  endif
  " Restore the visual selection.
  if has_key(self, 'selection')
    let vsel = self.selection
    let save_cursor = getpos('.')
    call setpos('.', vsel.start)
    execute 'normal!' vsel.mode  
    call setpos('.', vsel.end)
    execute 'normal!' vsel.mode                                  
    call setpos('.', save_cursor)
  endif
  " Restore the cursor.
  if has_key(self, 'cursor')
    call setpos('.', self.cursor)
  endif
endfunction
call s:Vimenv.method('restore')

let &cpo = s:save_cpo
unlet s:save_cpo
