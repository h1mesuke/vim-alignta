"=============================================================================
" Align Them All!
"
" File		: autoload/alignta.vim
" Author	: h1mesuke <himesuke@gmail.com>
" Updated : 2010-11-23
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

function! alignta#aligner(region, args, escape_regex)
  return s:Aligner.new(a:region, a:args, a:escape_regex)
endfunction

"-----------------------------------------------------------------------------
" Aligner

let s:Aligner = {
      \ 'defalut_options': {
      \   'L_fld_align': 'left',
      \   'M_fld_align': 'left',
      \   'R_fld_align': 'left',
      \   'L_padding': 1,
      \   'R_padding': 1,
      \ },
      \}

function! s:Aligner.new(region, args, escape_regex)
  let obj = copy(self)
  let obj.class = s:Aligner
  call obj.initialize(a:region, a:args, a:escape_regex)
  return obj
endfunction

function! s:Aligner.initialize(region, args, escape_regex)
  let self.region = s:Region.new(a:region)
  let self.arguments = a:args
  let self.escape_regex = a:escape_regex
  call self.init_options()
  let self._lines = copy(self.region.lines)
  if self.region.type ==# 'block'
    call map(self._lines, 'substitute(v:val, "\\s*$", "", "")')
  endif
  let self._match_start = map(range(0, len(self._lines) - 1), '0')
endfunction

function! s:Aligner.init_options()
  let self.options = copy(s:Aligner.defalut_options)
endfunction

function! s:Aligner.apply_options(opts)
  call extend(self.options, a:opts, 'force')
endfunction

function! s:parse_options(value)
  let align = { '<': 'left', '|': 'center', '>': 'right' }
  let opts = {}

  " <<< or <<<1 or <<<11 or <<<1:1
  let matched = matchlist(a:value,
        \ '^\([<|>]\)\([<|>]\)\([<|>]\)\%(\(\d\)\(\d\)\=\|\(\d\+\):\(\d\+\)\)\=$')
  if len(matched) > 0
    let opts.L_fld_align = align[matched[1]]
    let opts.M_fld_align = align[matched[2]]
    let opts.R_fld_align = align[matched[3]]
    if matched[4] != ""
      let opts.L_padding = str2nr(matched[4])
      let opts.R_padding = (matched[5] != "" ? str2nr(matched[5]) : opts.L_padding)
    endif
    if matched[6] != ""
      let opts.L_padding = str2nr(matched[6])
      let opts.R_padding = str2nr(matched[7])
    endif
    call s:decho(" parsed options = " . string(opts))
    return opts
  endif

  return opts
endfunction

function! s:Aligner.align()
  if self.region.is_broken
    throw "alignta: BlockError: broken multi-byte character detected"
  endif

  call s:decho("region = " . string(self.region))
  call s:decho("arguments = " . string(self.arguments))
  call s:decho(self._lines)

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let start_time = reltime()
  endif

  for value in self.arguments
    let opts = s:parse_options(value)
    if !empty(opts)
      " options
      call self.apply_options(opts)
    else
      " pattern
      let nstr = matchstr(value, '{\zs\(\d\+\|+\)\ze}$')
      let pattern = substitute(value, '{\(\d\+\|+\)}$', '', '')
      if self.escape_regex
        let pattern = s:string_escape_regex(pattern)
      endif
      if nstr == ""
        let n = 1
      elseif nstr == '+'
        " pattern{+}
        let n = 9999
      else
        " pattern{\d\+}
        let n = str2nr(nstr)
      endif
      while n > 0
        if !self._align_with(pattern)
          break
        endif
        let n -= 1
      endwhile
    endif
  endfor

  " update!
  let self.region.lines = self._lines
  call self.region.update()

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    echomsg "alignta: used=" . used_time . "s"
  endif
endfunction

function! s:Aligner._align_with(pattern)
  call s:decho("current options = " . string(self.options))

  let L_flds = {}
  let M_flds = {}
  let R_flds = {}
  let n_lines = len(self._lines)

  " phase 1
  " match and split lines
  let matched = 0
  let idx = 0
  while idx < n_lines
    let line = self._lines[idx]
    if line != ""
      let match_beg = match(line, a:pattern, self._match_start[idx])
      if match_beg >= 0
        let match_end = matchend(line, a:pattern, self._match_start[idx])
        let L_flds[idx] = substitute(strpart(line, 0, match_beg), '\s*$', '', '')
        let M_flds[idx] = strpart(line, match_beg, match_end - match_beg)
        let R_flds[idx] = substitute(strpart(line, match_end), '^\s*', '', '')
        let matched += 1
      endif
    endif
    let idx += 1
  endwhile

  if matched == 0
    return 0
  endif

  " phase 2
  " pad and join
  let max_width = max(map(values(L_flds), 's:string_width(v:val)'))
  call map(L_flds, 's:string_pad(v:val, max_width, self.options.L_fld_align)')
  let max_width = max(map(values(M_flds), 's:string_width(v:val)'))
  call map(M_flds, 's:string_pad(v:val, max_width, self.options.M_fld_align)')
  let max_width = max(map(values(R_flds), 's:string_width(v:val)'))
  call map(R_flds, 's:string_pad(v:val, max_width, self.options.R_fld_align, 1)')

  let lpad = s:padding(self.options.L_padding)
  let rpad = s:padding(self.options.R_padding)
  let idx = 0
  while idx < n_lines
    if has_key(L_flds, idx)
      let aligned = L_flds[idx] . lpad . M_flds[idx]
      let aligned .= (R_flds[idx] != "" ? rpad : "")
      let self._lines[idx] = aligned . R_flds[idx]
      let self._match_start[idx] = strlen(aligned)
    endif
    let idx += 1
  endwhile
  call s:decho("pattern = " . string(a:pattern))
  call s:decho(self._lines)

  return 1
endfunction

function! s:print_error(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

function! s:decho(msg)
  if exists('g:alignta_debug') && g:alignta_debug
    if type(a:msg) == type([])
      for line in a:msg
        echomsg string(line)
      endfor
    else
      echomsg "alignta: " . a:msg
    endif
  endif
endfunction

"-----------------------------------------------------------------------------
" String

function! s:string_escape_regex(str)
  return escape(a:str, '^$[].*\~')
endfunction

function! s:string_is_ascii(str)
  return (a:str =~ '^[\x00-\x7f]*$')
endfunction

function! s:string_pad(str, width, align, ...)
  let str_w = s:string_width(a:str)
  if str_w >= a:width
    return a:str
  endif
  let no_trailer = (a:0 ? a:1 : 0)
  if a:align ==# 'left'
    let lpad = ""
    let rpad = s:padding(a:width - str_w)
  elseif a:align ==# 'center'
    let lpad_w = (a:width - str_w) / 2
    let lpad = s:padding(lpad_w)
    let rpad = s:padding(a:width - lpad_w - str_w)
  elseif a:align ==# 'right'
    let lpad = s:padding(a:width - str_w)
    let rpad = ""
  endif
  let rpad = (no_trailer ? "" : rpad)
  return lpad . a:str . rpad
endfunction

function! s:padding(width)
  return printf('%*s', a:width, "")
endfunction

if v:version >= 703
  function! s:string_width(str)
    return strwidth(a:str)
  endfunction

else
  function! s:string_width(str)
    if s:string_is_ascii(a:str)
      return strlen(a:str)
    endif
    " borrowed from Charles Campbell's Align.vim
    " http://www.vim.org/scripts/script.php?script_id=294
    let save_mod = &l:modified
    execute "normal! o\<Esc>"
    call setline(line('.'), a:str)
    let width = virtcol('$') - 1
    silent delete
    let &l:modified = save_mod
    return width
  endfunction
endif

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
    throw "Region: ArgumentError: wrong number of arguments (" . argc . " for 1..2)"
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

    " NOTE: If a line ends before the left most column of the blockwise
    " selection, the yanked block will be filled with spaces for the line.
    " They are "ragged right". I borrowed this term from Charles Campbell's
    " Align.vim
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
  let self.is_broken = 0

  if a:type ==# 'block'
    " check the block for any broken multi-byte chars
    let original = getline(a:line_range[0], a:line_range[1])
    call self.update()
    let self.is_broken = (getline(a:line_range[0], a:line_range[1]) !=# original)
    silent undo
  endif
endfunction

function! s:Region.has_ragged(lnum)
  return has_key(self.ragged, a:lnum)
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
      let max_width = max(map(copy(self.lines), 's:string_width(v:val)'))
      call map(self.lines, 's:string_pad(v:val, max_width, "left")')
      let regtype .= max_width
    endif
    call setreg('v', join(self.lines, "\n"), regtype)
    call setpos('.', self.char_range[0])
    execute 'normal!' vismode
    call setpos('.', self.char_range[1])
    silent normal! "_d"vP`<

    call save_vimenv.restore()

    " NOTE: Pasting a block with ragged rights appends extra white spaces to
    " the ends of their corresponding lines. To avoid this behavior, overwrite
    " the lines with their saved copies if they are still blank.
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
