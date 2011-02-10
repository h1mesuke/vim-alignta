"=============================================================================
" File    : region.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-02-11
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

function! alignta#region#new(...)
  return call(s:Region.new, a:000, s:Region)
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

let s:Region = alignta#oop#class#new('Region')

function! s:Region_initialize(...) dict
  let [type, line_range, char_range] = self._parse_arguments(a:000)
  let self.type = type
  let self.is_broken = 0
  let self.line_range = line_range
  let self.char_range = char_range
  let self.original_lines = getline(line_range[0], line_range[1])

  " capture the selection
  call self._get_selection()

  if type !=# 'line'
    for writeback_command in ['P', 'p']
      let self.writeback_command = writeback_command
      call self.update()
      let lines = getline(line_range[0], line_range[1])
      silent undo
      if lines ==# self.original_lines
        return
      endif
    endfor
    let self.is_broken = 1
  endif
endfunction
call s:Region.bind(s:SID, 'initialize')

function! s:Region__parse_arguments(args) dict
  let argc = len(a:args)
  if argc == 1
    if a:args[0] ==? 'v' || a:args[0] ==# "\<C-v>"
      " from the visual mode; s:Region.new(visualmode())
      let type = { 'v': 'char', 'V': 'line', "\<C-v>": 'block' }[a:args[0]]
      let line_range = [line("'<"), line("'>")]
      let char_range = [getpos("'<"), getpos("'>")]
    elseif a:args[0] ==# 'char' || a:args[0] ==# 'line' || a:args[0] ==# 'block'
      " from the operator-pending mode
      " NOTE: see :help g@
      let type = a:args[0]
      let line_range = [line("'["), line("']")]
      let char_range = [getpos("'["), getpos("']")]
    endif
  elseif argc == 2
    " from the normal mode
    let type = 'line'
    let line_range = a:args
    let char_range = []
  else
    throw "ArgumentError: wrong number of arguments (" . argc . " for 1..2)"
  endif
  return [type, line_range, char_range]
endfunction
call s:Region.bind(s:SID, '_parse_arguments')

function! s:Region__get_selection() dict
  let self._ragged = {}
  let self._short  = {}

  if self.type ==# 'line'
    " Linewise
    let self.lines = getline(self.line_range[0], self.line_range[1])
  else
    " Characterwise or Blockwise
    " get the selection via register 'v'
    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]

    let vimenv = alignta#vimenv#new('.', '&selection', '@v', vismode)
    set selection=inclusive

    call setpos('.', self.char_range[0])
    execute 'normal!' vismode
    call setpos('.', self.char_range[1])
    execute 'silent normal! "vy'

    let self.lines = split(@v, "\n")

    " NOTE: If a line ends before the left most column of the blockwise
    " selection, the yanked block will be filled with spaces for the line.
    " They are "ragged right". I borrowed this term from Charles Campbell's
    " Align.vim
    "               ____________
    "               |   Block   |
    "   Ragged      |           |
    "   ========|   |@@@@@@@@@@@| <-- Ragged Right
    "               |           |
    "   Short       |           |
    "   ==================|     |
    "               |___________|
    "
    if self.type ==# 'block'
      let [block_begcol, block_endcol] = s:sort_numbers([virtcol("'<"), virtcol("'>")])
      let self.block_begin_col = block_begcol
      let self.block_width = block_endcol - block_begcol + 1
      for lnum in range(self.line_range[0], self.line_range[1])
        execute lnum
        let line_endcol = virtcol('$')
        if line_endcol <= block_begcol
          " collect lnums of lines that cause ragged rights to avoid the extra
          " spaces issue on s:Region.update()
          let self._ragged[lnum] = 1
          let self.lines[lnum - self.line_range[0]] = ''
        elseif line_endcol <= block_endcol
          let self._short[lnum] = 1
        endif
      endfor
    endif

    call vimenv.restore()
  endif
endfunction
call s:Region.bind(s:SID, '_get_selection')

function! s:Region_detab_indent() dict
  let col = (self.type ==# 'block' ? self.block_begin_col - 1 : 0)
  call map(self.lines, 's:detab_indent(v:val, col)')
endfunction
call s:Region.bind(s:SID, 'detab_indent')

function! s:detab_indent(str, col)
  let indent = matchstr(a:str, '^\s*')
  let indent = lib#string#padding(lib#string#width(indent, a:col))
  return substitute(a:str, '^\s*', indent, '')
endfunction

function! s:Region_entab_indent() dict
  let col = (self.type ==# 'block' ? self.block_begin_col - 1 : 0)
  call map(self.lines, 's:entab_indent(v:val, col)')
endfunction
call s:Region.bind(s:SID, 'entab_indent')

function! s:entab_indent(str, col)
  let indent = matchstr(a:str, '^\s*')
  let indent = lib#string#tab_padding(strlen(indent), a:col)
  return substitute(a:str, '^\s*', indent, '')
endfunction

function! s:Region_has_indent_tab(...) dict
  let orig = (a:0 ? a:1 : 0)
  let lines = copy(orig ? self.original_lines : self.lines)
  let indents = map(lines, 'matchstr(v:val, "^\\s*")')
  return !empty(filter(indents, 'v:val =~ "\\t"'))
endfunction
call s:Region.bind(s:SID, 'has_indent_tab')

function! s:Region_has_tab(...) dict
  let orig = (a:0 ? a:1 : 0)
  let lines = copy(orig ? self.original_lines : self.lines)
  return !empty(filter(lines, 'v:val =~ "\\t"'))
endfunction
call s:Region.bind(s:SID, 'has_tab')

function! s:Region_line_is_ragged(line_idx) dict
  return has_key(self._ragged, self.line_range[0] + a:line_idx)
endfunction
call s:Region.bind(s:SID, 'line_is_ragged')

function! s:Region_line_is_short(line_idx) dict
  return has_key(self._short, self.line_range[0] + a:line_idx)
endfunction
call s:Region.bind(s:SID, 'line_is_short')

function! s:Region_update() dict
  if self.is_broken
    throw "RuntimeError: the region is broken"
  endif

  if self.type ==# 'line'
    call setline(self.line_range[0], self.lines)
  else              
    let vimenv = alignta#vimenv#new('.', '@v')

    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
    let regtype = vismode

    if self.type ==# 'block'
      " calculate the block width
      let col = self.block_begin_col - 1
      let max_width = max(map(copy(self.lines), 'lib#string#width(v:val, col)'))
      " NOTE: If the block contains any multi-byte characters, Vim fails to
      " count the number of paddings and append extra spaces. So, pad the
      " lines here beforehand.
      call map(self.lines, '
            \ (self.line_is_short(v:key) || v:val =~ "^\\s*$")
            \   ? v:val
            \   : lib#string#pad(v:val, max_width, "left", col)
            \')
      let regtype .= max_width
    endif

    call setreg('v', join(self.lines, "\n"), regtype)
    call setpos('.', self.char_range[0])
    execute 'normal!' vismode
    call setpos('.', self.char_range[1])
    silent execute 'normal!' '"_d"v' . self.writeback_command . '`<'

    call vimenv.restore()

    " NOTE: Pasting a block with ragged rights appends extra spaces to the
    " ends of their corresponding lines. To avoid this behavior, overwrite the
    " lines with their saved copies if they are still blank.
    "
    if self.type ==# 'block'
      for lnum in keys(self._ragged)
        let idx = lnum - self.line_range[0]
        if self.lines[idx] == ""
          call setline(lnum, self.original_lines[idx])
        endif
      endfor
    endif
  endif
endfunction
call s:Region.bind(s:SID, 'update')

function! s:Region_to_s() dict
  let _self = filter(copy(self), 'type(v:val) != type(function("tr"))')
  unlet _self.class
  return string(_self)
endfunction
call s:Region.bind(s:SID, 'to_s')

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunction

" vim: filetype=vim
