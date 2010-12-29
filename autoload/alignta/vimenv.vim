"=============================================================================
" Align Them All!
"
" File    : autoload/alignta/vimenv.vim
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

function! alignta#vimenv#new(...)
  return call(s:Vimenv.new, a:000, s:Vimenv)
endfunction

let s:Vimenv = alignta#object#extend()

function! s:Vimenv.initialize(...)
  let args = a:000
  let save_cursor = 0
  let save_marks  = []
  let save_opts   = []
  let save_regs   = []
  let save_vsel   = 0

  " parse args
  for value in args
    if value == '.'
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
      throw "Vimenv: ArgumentError: invalid name " . string(value)
    endif
  endfor

  " save cursor
  if save_cursor
    let self.cursor = getpos('.')
  endif
  " save marks
  if !empty(save_marks)
    let saved_marks = {}
    for mark_name in save_marks
      let saved_marks[mark_name] = getpos("'".mark_name)
    endfor
    let self.marks = saved_marks
  endif
  " save options
  if !empty(save_opts)
    let saved_opts = {}
    for opt_name in save_opts
      execute 'let saved_opts[opt_name] = &'.opt_name
    endfor
    let self.options = saved_opts
  endif
  " save registers
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
  " save the visual selection
  if save_vsel
    let saved_vsel = {
          \ 'mode' : visualmode,
          \ 'start': getpos("'<"),
          \ 'end'  : getpos("'>"),
          \ }
    let self.selection = saved_vsel
  endif
endfunction

function! s:Vimenv.restore()
  " restore marks
  if has_key(self, 'marks')
    for [mark_name, mark_pos] in items(self.marks)
      call setpos("'".mark_name, mark_pos)
    endfor
  endif
  " restore options
  if has_key(self, 'options')
    for [opt_name, opt_val] in items(self.options)
      execute 'let &'.opt_name.' = opt_val'
    endfor
  endif
  " restore registers
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
  " restore the visual selection
  if has_key(self, 'selection')
    let vsel = self.selection
    let save_cursor = getpos('.')
    call setpos('.', vsel.start)
    execute 'normal!' vsel.mode  
    call setpos('.', vsel.end)
    execute 'normal!' vsel.mode                                  
    call setpos('.', save_cursor)
  endif
  " restore the cursor
  if has_key(self, 'cursor')
    call setpos('.', self.cursor)
  endif
endfunction

" vim: filetype=vim
