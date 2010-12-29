"=============================================================================
" Align Them All!
"
" File    : autoload/alignta/region.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2010-12-29
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

let s:Region = alignta#object#extend()
let s:Region.normalize_tabs = 1

function! s:Region.initialize(...)
  let [type, line_range, char_range] = self._parse_arguments(a:000)
  let self.type = type
  let self.has_tab = 0 | let self.is_broken = 0
  let self.line_range = line_range
  let self.char_range = char_range
  let self.original_lines = getline(line_range[0], line_range[1])

  " initialize self.lines
  call self._get_selection()

  if type ==# 'block'
    " check the block for any broken multi-byte chars
    call self.update()
    let lines = getline(line_range[0], line_range[1])
    let self.is_broken = (lines !=# self.original_lines)
    silent undo
  endif

  let self.has_tab = !empty(filter(copy(self.lines), 'v:val =~ "\\t"'))
  if self.has_tab && self.normalize_tabs
    " NOTE: If the selection contains any tabs, expand them all to normalize
    " the selection text for subsequent alignments.
    let save_et = &l:expandtab
    setlocal expandtab
    execute line_range[0] . ',' . line_range[1] . 'retab'
    call self._get_selection()
    silent undo
    let &l:expandtab = save_et
  endif
endfunction

function! s:Region._parse_arguments(args)
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
    throw "Region: ArgumentError: wrong number of arguments (" . argc . " for 1..2)"
  endif
  return [type, line_range, char_range]
endfunction

function! s:Region._get_selection()
  let self._ragged = {}
  let self._short  = {}

  if self.type ==# 'line'
    " Linewise
    let self.lines = getline(self.line_range[0], self.line_range[1])
  else
    " Characterwise or Blockwise
    " get the selection via register 'v'
    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
    let save_vimenv = alignta#vimenv#new('.', '&selection', '@v', vismode)
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
      for lnum in range(self.line_range[0], self.line_range[1])
        execute lnum
        let line_endcol = virtcol('$')
        if line_endcol <= block_begcol
          " collect lnums of lines that cause ragged rights to avoid the extra
          " spaces issue on s:Region.update()
          let self._ragged[lnum] = 1
          let self.lines[lnum - self.line_range[0]] = ""
        elseif line_endcol <= block_endcol
          let self._short[lnum] = 1
        endif
      endfor
    endif

    call save_vimenv.restore()
  endif
endfunction

function! s:Region.update()
  if self.has_tab && s:Region.normalize_tabs && !&l:expandtab
    call map(self.lines, 's:retab(v:val)')
  endif

  if self.type ==# 'line'
    call setline(self.line_range[0], self.lines)
  else              
    let save_vimenv = alignta#vimenv#new('.', '@v')

    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
    let regtype = vismode
    if self.type ==# 'block'
      " calculate the block width
      let max_width = max(map(copy(self.lines), 'alignta#string#width(v:val)'))
      " NOTE: If the block contains any multi-byte characters, Vim may fail to
      " count the number of paddings and append extra spaces. So, pad them
      " here.
      call map(self.lines, 'alignta#string#pad(v:val, max_width, "left",
            \ (has_key(self._short, self.line_range[0] + v:key) || v:val =~ "^\\s*$"))')
      let regtype .= max_width
    endif
    call setreg('v', join(self.lines, "\n"), regtype)
    call setpos('.', self.char_range[0])
    execute 'normal!' vismode
    call setpos('.', self.char_range[1])
    silent normal! "_d"vP`<

    call save_vimenv.restore()

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

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunction

function! s:retab(line)
  let nsp = len(matchstr(a:line, '^ \+'))
  let ntab = nsp / &l:tabstop | let nsp = nsp % &l:tabstop
  let indent = alignta#string#padding(ntab, '\t') . alignta#string#padding(nsp)
  return substitute(a:line, '^ \+', indent, '')
endfunction

" vim: filetype=vim
