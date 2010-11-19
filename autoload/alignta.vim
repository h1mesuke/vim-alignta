"=============================================================================
" Align Them All!
"
" File		: autoload/alignta.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2010-11-20
" Version : 0.0.1
" License : MIT license {{{
"
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

function! alignta#aligner(region, args)
  return s:Aligner.new(a:region, a:args)
endfunction

"-----------------------------------------------------------------------------
" Aligner

let s:Aligner = {}

function! s:Aligner.new(region, args)
  let obj = copy(self)
  let obj.class = s:Aligner
  call obj.initialize(a:region, a:args)
  return obj
endfunction

function! s:Aligner.initialize(region, args)
  let self.region = s:Region.new(a:region)
  let self.arguments = a:args
endfunction

function! s:Aligner.align()
  echomsg "align!"
  echomsg "self.region = " . string(self.region)
  echomsg "self.arguments = " . string(self.arguments)
endfunction

"-----------------------------------------------------------------------------
" Region

let s:Region = {}

function! s:Region.new(...)
  let obj = copy(self)
  let obj.class = s:Region

  if a:0 == 1 && type(a:1) == type([])
    let args = a:1
  else
    let args = a:000
  endif
  let argc = len(args)

  if argc == 1
    if args[0] ==? 'v' || args[0] ==# "\<C-v>"
      " from the visual mode; s:Region.new(visualmode())
      let type = { 'v': 'char', 'V': 'line', "\<C-v>": 'block' }[args[0]]
      let line_range = [line("'<"), line("'>")]
      let char_range = [getpos("'<"), getpos("'>")]
    elseif args[0] ==# 'char' || args[0] ==# 'line' || args[0] ==# 'block'
      " from the operator-pending mode
      " NOTE: see :help g@
      let type = args[0]
      let line_range = [line("'["), line("']")]
      let char_range = [getpos("'["), getpos("']")]
    endif
  elseif argc == 2
    " from the normal mode
    let type = 'line'
    let line_range = args
    let char_range = []
  else
    throw "ArgumentError: wrong number of arguments (" . argc . " for 1..2)"
  endif

  call obj.initialize(type, line_range, char_range)
  return obj
endfunction

function! s:Region.initialize(type, line_range, char_range)
  if a:type ==# 'line'
    " linewise
    let lines = getline(a:line_range[0], a:line_range[1])
    let ragged = {}
  else
    " characterwise or blockwise
    " get the selection via register 'v'
    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[a:type]
    let save_vimenv = util#vimenv#new('.', '&selection', '@v', vismode)
    set selection=inclusive

    call setpos('.', a:char_range[0])
    execute 'normal!' vismode
    call setpos('.', a:char_range[1])
    execute 'silent normal! "vy'

    let lines = split(@v, "\n")
    let ragged = {}

    " NOTE: If a line ends before the left most column of a block, the block
    " will be filled with spaces for the line. It's "ragged right".
    "
    if a:type ==# 'block'
      " collect and copy lines that cause ragged rights to avoid the extra
      " spaces issue on s:Region.update()
      let block_begcol = s:sort_numbers([virtcol("'<"), virtcol("'>")])[0]
      for lnum in range(a:line_range[0], a:line_range[1])
        execute lnum
        if virtcol('$') <= block_begcol
          let ragged[lnum] = getline(lnum)
          let lines[lnum - a:line_range[0]] = ""
        endif
      endfor
    endif

    call save_vimenv.restore()
  endif

  let self.type = a:type
  let self.line_range = a:line_range
  let self.char_range = a:char_range
  let self.lines = lines
  let self.ragged = ragged
  let self._broken = 0

  if a:type ==# 'block'
    " check the block for any broken multi-byte chars
    call self.update()
    let self._broken = (getline(a:line_range[0], a:line_range[1]) !=# lines)
    silent undo
  endif
endfunction

function! s:Region.has_ragged(lnum)
  return has_key(self.ragged, a:lnum)
endfunction

function! s:Region.is_broken()
  return self._broken
endfunction

function! s:Region.update()
  if self.type ==# 'line'
    call setline(self.line_range[0], self.lines)
  else              
    let save_vimenv = util#vimenv#new('.', '@v')

    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
    let regtype = vismode
    if self.type ==# 'block'
      " calculate the block width
      let max_width = max(map(copy(self.lines), 'util#string#width(v:val)'))
      let regtype .= max_width
    endif
    call setreg('v', join(self.lines, "\n"), regtype)
    call setpos('.', self.char_range[0])
    execute 'normal!' vismode
    call setpos('.', self.char_range[1])
    silent normal! "_d"vP`<

    call save_vimenv.restore()

    " NOTE: Pasting a block with ragged rights appends extra white spaces to
    " the ends of their corresponding lines. To avoid this behavior, we
    " overwrite the lines with their saved copies if they are still blank.
    "
    if self.type ==# 'block'
      for [lnum, line] in items(self.ragged)
        if self.lines[lnum - self.line_range[0]] == ""
          call setline(lnum, line)
        endif
      endfor
    endif
  endif
endfunction

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunction

"-----------------------------------------------------------------------------
" Vimenv

let s:Vimenv = {}

function! s:Vimenv.new(...)
  let obj = copy(self)
  let obj.class = s:Vimenv

  if a:0 == 1 && type(a:1) == type([])
    let args = a:1
  else
    let args = a:000
  endif
  let argc = len(args)
  call obj.initialize(args)

  return obj
endfunction

function! s:Vimenv.initialize(args)
  let save_cursor = 0
  let save_marks  = []
  let save_opts   = []
  let save_regs   = []
  let save_vsel   = 0

  " parse args
  for value in a:args
    if value == '.'
      let save_cursor = 1
    elseif match(value, "^'[a-zA-Z[\\]']$") >= 0
      call add(save_marks, substitute(value, '^.', '', ''))
    elseif match(value, '^&\(l:\)\=\w\+') >= 0
      call add(save_opts,  substitute(value, '^.', '', ''))
    elseif match(value, '^@[\"a-z01-9\-*+~/]$') >= 0
      call add(save_regs,  substitute(value, '^.', '', ''))
    elseif value ==# 'R'
      let save_regs += ['1', '2', '3', '4', '5', '6', '7', '8', '9', '-']
    elseif value ==? 'v' || value == "\<C-v>"
      let save_vsel = 1
      let visualmode = value
    else
      throw "ArgumentError: invalid name " . string(value)
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
    " updates @" too. So, we need to setreg() to @" again at the last.
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
