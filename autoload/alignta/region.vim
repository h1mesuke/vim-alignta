"=============================================================================
" File    : lib/region.vim
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

function! {s:lib}#region#import()
  return s:Region
endfunction

"-----------------------------------------------------------------------------

let s:Vimenv = {s:lib}#vimenv#import()
let s:String = {s:lib}#string#import()

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

" Region is a class that represents the user-selected region on a Vim's
" buffer. It provides an easy way to get and modify the content of the
" selection.
"
" == Example
"
"   let region = s:Region.new(visualmode())
"   let idx = 0
"   while idx < len(region.lines)
"     let line = region.lines[idx]
"     " Do something.
"     let region.lines[idx] = line
"   endwhile
"   call region.update()
"
let s:Region = {s:lib}#oop#class#new('Region', s:SID)

" Region.new( {args})
function! s:Region_initialize(...) dict
  let [type, line_range, char_range] = self._parse_arguments(a:000)
  let self.type = type
  let self.is_broken = 0
  let self.line_range = line_range
  let self.char_range = char_range
  let self.original_lines = getline(line_range[0], line_range[1])

  " Capture the selection.
  call self._get_selection()

  if type !=# 'line'
    " Select the appropriate command for writing the region's content back.
    for writeback_command in ['P', 'p']
      let self.writeback_command = writeback_command
      call self.update()
      let lines = getline(line_range[0], line_range[1])
      silent undo
      if lines ==# self.original_lines
        return
      endif
    endfor
    " Both 'P' and 'p' failed. We will never update the region without
    " destroying the selection...
    let self.is_broken = 1
  endif
endfunction
call s:Region.method('initialize')

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
    throw "ArgumentError: Wrong number of arguments (" . argc . " for 1..2)"
  endif
  return [type, line_range, char_range]
endfunction
call s:Region.method('_parse_arguments')

function! s:Region__get_selection() dict
  let self._ragged = {}
  let self._short  = {}

  if self.type ==# 'line'
    " Linewise
    let self.lines = getline(self.line_range[0], self.line_range[1])
  else
    " Characterwise or Blockwise

    " Save the Vim's environment.
    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
    let vimenv = s:Vimenv.new('cursor', '&selection', '@v', vismode)
    try
      set selection=inclusive

      " Get the selection via register 'v'.
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
          call cursor(lnum, 1)
          let line_endcol = virtcol('$')
          if line_endcol <= block_begcol
            " Collect lnums of lines that cause ragged rights to avoid the extra
            " spaces issue on s:Region.update()
            let self._ragged[lnum] = 1
            let self.lines[lnum - self.line_range[0]] = ''
          elseif line_endcol <= block_endcol
            let self._short[lnum] = 1
          endif
        endfor
      endif
      " Don't catch anything.
    finally
      " Restore the Vim's environment.
      call vimenv.restore()
    endtry
  endif
endfunction
call s:Region.method('_get_selection')

function! s:Region_detab_indent() dict
  let col = (self.type ==# 'block' ? self.block_begin_col - 1 : 0)
  call map(self.lines, 's:detab_indent(v:val, col)')
endfunction
call s:Region.method('detab_indent')

function! s:detab_indent(str, col)
  let indent = matchstr(a:str, '^\s*')
  let indent = s:String.padding(s:String.width(indent, a:col))
  return substitute(a:str, '^\s*', indent, '')
endfunction

function! s:Region_entab_indent() dict
  let col = (self.type ==# 'block' ? self.block_begin_col - 1 : 0)
  call map(self.lines, 's:entab_indent(v:val, col)')
endfunction
call s:Region.method('entab_indent')

function! s:entab_indent(str, col)
  let indent = matchstr(a:str, '^\s*')
  let indent = s:String.tab_padding(strlen(indent), a:col)
  return substitute(a:str, '^\s*', indent, '')
endfunction

" Region.has_indent_tab( [{orig}])
function! s:Region_has_indent_tab(...) dict
  let orig = (a:0 ? a:1 : 0)
  let lines = copy(orig ? self.original_lines : self.lines)
  let indents = map(lines, 'matchstr(v:val, "^\\s*")')
  return !empty(filter(indents, 'v:val =~ "\\t"'))
endfunction
call s:Region.method('has_indent_tab')

function! s:Region_original_has_indent_tab(...) dict
  return self.has_indent_tab(1)
endfunction
call s:Region.method('original_has_indent_tab')

" Region.has_tab( [{orig}])
function! s:Region_has_tab(...) dict
  let orig = (a:0 ? a:1 : 0)
  let lines = copy(orig ? self.original_lines : self.lines)
  return !empty(filter(lines, 'v:val =~ "\\t"'))
endfunction
call s:Region.method('has_tab')

function! s:Region_original_has_tab(...) dict
  return self.has_tab(1)
endfunction
call s:Region.method('original_has_tab')

function! s:Region_line_is_ragged(line_idx) dict
  return has_key(self._ragged, self.line_range[0] + a:line_idx)
endfunction
call s:Region.method('line_is_ragged')

function! s:Region_line_is_short(line_idx) dict
  return has_key(self._short, self.line_range[0] + a:line_idx)
endfunction
call s:Region.method('line_is_short')

function! s:Region_update() dict
  if self.is_broken
    throw "RegionError: The region is broken."
  endif

  if self.type ==# 'line'
    call setline(self.line_range[0], self.lines)
  else
    " Save the Vim's environment.
    let vimenv = s:Vimenv.new('cursor', '@v')
    try
      let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
      let regtype = vismode

      if self.type ==# 'block'
        " Calculate the block width.
        let col = self.block_begin_col - 1
        let max_width = max(map(copy(self.lines), 's:String.width(v:val, col)'))
        " NOTE: If the block contains any multi-byte characters, Vim fails to
        " count the number of paddings and append extra spaces. So, justify the
        " lines here beforehand.
        call map(self.lines, '
              \ (self.line_is_short(v:key) || v:val =~ "^\\s*$")
              \   ? v:val
              \   : s:String.justify(v:val, max_width, "left", col)
              \')
        let regtype .= max_width
      endif

      call setreg('v', join(self.lines, "\n"), regtype)
      call setpos('.', self.char_range[0])
      execute 'normal!' vismode
      call setpos('.', self.char_range[1])
      silent execute 'normal!' '"_d"v' . self.writeback_command . '`<'

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
      " Don't catch anything.
    finally
      " Restore the Vim's environment.
      call vimenv.restore()
    endtry
  endif
endfunction
call s:Region.method('update')

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
