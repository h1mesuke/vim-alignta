"=============================================================================
" Align Them All!
"
" File    : autoload/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2010-12-18
" Version : 0.0.8
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

function! alignta#align(region, align_args, ...)
  let use_regex = (a:0 ? a:1 : 0)
  let aligner = s:Aligner.new(a:region, a:align_args, use_regex)
  call aligner.align()
endfunction

" API for unite-alignta
function! alignta#apply_default_options(idx)
  let opts_str = g:unite_source_alignta_preset_options[a:idx]
  call s:Aligner.apply_default_options(opts_str)
  call s:debug_echo("default options = " . string(s:Aligner.default_options))
endfunction

function! alignta#reset_default_options()
  call s:Aligner.init_default_options()
  call s:debug_echo("default options = " . string(s:Aligner.default_options))
endfunction

"-----------------------------------------------------------------------------
" Constant

let s:HUGE_VALUE = 9999

"-----------------------------------------------------------------------------
" Aligner

let s:Aligner = {}

function! s:Aligner.init_default_options()
  let s:Aligner.default_options = {
        \ 'L_fld_align': 'left',
        \ 'M_fld_align': 'left',
        \ 'R_fld_align': 'left',
        \ 'L_padding': 1,
        \ 'R_padding': 1,
        \ 'g_pattern': "",
        \ 'v_pattern': "",
        \ }
  let opts = s:Aligner._parse_options(g:alignta_default_options)
  call extend(s:Aligner.default_options, opts, 'force')
endfunction

function! s:Aligner.apply_default_options(opts_str)
  let opts = s:Aligner._parse_options(a:opts_str)
  call extend(s:Aligner.default_options, opts, 'force')
endfunction

function! s:Aligner.new(region, args, use_regex)
  let obj = copy(self)
  let obj.class = s:Aligner
  call obj.initialize(a:region, a:args, a:use_regex)
  return obj
endfunction

function! s:Aligner.initialize(region, args, use_regex)
  let self.region = s:Region.new(a:region)
  let self.arguments = a:args
  let self.use_regex = a:use_regex
  let self.options = copy(s:Aligner.default_options)

  " initialize the lines to align
  let self._lines = copy(self.region.lines)
  if self.region.type ==# 'block'
    call map(self._lines, 'substitute(v:val, "\\s*$", "", "")')
  endif
  " initialize the intermediate data
  let n_lines = len(self._lines)
  let self._line_data = map(range(0, n_lines - 1), '{
        \ "aligned_part": "",
        \ "aligned_width": 0,
        \ }')

  " keep the minimum leadings
  let leading_width = s:min_leading_width(self._lines, 1)
  let leading = s:padding(leading_width)
  let idx = 0
  " freeze leadings
  while idx < n_lines
    let line = self._lines[idx]
    if line =~ '\S'
      let line_data = self._line_data[idx]
      let line_data.aligned_part = leading
      let line_data.aligned_width = leading_width
      let self._lines[idx] = substitute(line, leading, '', '')
    endif
    let idx += 1
  endwhile
endfunction

function! s:min_leading_width(lines, ...)
  let ignore_blank = (a:0 ? a:1 : 0)
  let lines = (ignore_blank ? filter(copy(a:lines), 'v:val =~ "\\S"') : copy(a:lines))
  let leadings = map(lines, 'matchstr(v:val, "^\\s*")')
  return min(map(leadings, 'strlen(v:val)'))
endfunction

function! s:Aligner.apply_options(options)
  call extend(self.options, a:options, 'force')
endfunction

function! s:Aligner.alignment_method()
  return (self.options.M_fld_align ==# 'none' ?  'shifting' : 'padding')
endfunction

function! s:Aligner.align()
  call s:debug_echo("region = " . string(self.region))
  call s:debug_echo("arguments = " . string(self.arguments))
  call s:debug_echo("_lines:", self._lines)

  let save_cursor = getpos('.')
  " NOTE: s:string_width() for Vim 7.2 or older has a side effect that changes
  " the cursor's position.

  if self.region.type ==# 'block' && self.region.has_tab
    throw "alignta: RegionError: block contains tabs"
  endif
  if self.region.is_broken
    throw "alignta: RegionError: broken multi-byte character detected"
  endif

  if self.region.has_tab && g:alignta_confirm_for_retab
    let resp = input("Region contains tabs, alignta will use :retab, OK? [y/n] ")
    if resp !~? '\s*y\%[es]\s*$'
      return
    endif
  endif

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let start_time = reltime()
  endif

  " process arguments
  let next_as_pattern = 0
  for value in self.arguments
    if !next_as_pattern && value =~ '^-p\%[attern]$'
      let next_as_pattern = 1
      continue
    endif
    let opts = self._parse_options(value)
    if !next_as_pattern && !empty(opts)
      " options
      call self.apply_options(opts)
    else
      " pattern
      let [pattern, times] = self._parse_pattern(value)
      call self._align_at(pattern, times)
    endif
    let next_as_pattern = 0
  endfor

  " update!
  let self.region.lines = map(copy(self._line_data),
        \ 's:string_rstrip(v:val.aligned_part . self._lines[v:key])')
  call self.region.update()

  call setpos('.', save_cursor)

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    echomsg "alignta: used=" . used_time . "s"
  endif
endfunction

function! s:Aligner._parse_options(value)
  let align = { '<': 'left', '|': 'center', '>': 'right' }
  let opts = {}

  for opts_str in split(a:value, '\(\(^\|[^\\]\)\(\\\{2}\)*\)\@<=\s\s*')

    " padding alignment options
    " <<< or <<<1 or <<<11 or <<<1:1
    let matched_list = matchlist(opts_str,
          \ '^\([<|>]\)\([<|>]\)\([<|>]\)\%(\(\d\)\(\d\)\=\|\(\d\+\):\(\d\+\)\)\=$')
    if len(matched_list) > 0
      let opts.L_fld_align = align[matched_list[1]]
      let opts.M_fld_align = align[matched_list[2]]
      let opts.R_fld_align = align[matched_list[3]]
      if matched_list[4] != ""
        " 1 or 11
        let opts.L_padding = str2nr(matched_list[4])
        let opts.R_padding = (matched_list[5] != "" ? str2nr(matched_list[5]) : opts.L_padding)
      endif
      if matched_list[6] != ""
        " 1:1
        let opts.L_padding = str2nr(matched_list[6])
        let opts.R_padding = str2nr(matched_list[7])
      endif
      call s:debug_echo("parsed options = " . string(opts))
      continue
    endif

    " shifting alignment options
    " <= or <=1
    let matched_list = matchlist(opts_str, '^\([<|>]\)=\(\d\+\)\=$')
    if len(matched_list) > 0
      let opts.L_fld_align = align[matched_list[1]]
      let opts.M_fld_align = 'none'
      let opts.R_fld_align = 'none'
      if matched_list[2] != ""
        let opts.L_padding = str2nr(matched_list[2])
      endif
      call s:debug_echo("parsed options = " . string(opts))
      continue
    endif

    " padding options
    " @1 or @11 or @1:1
    let matched_list = matchlist(opts_str,
          \ '^@\%(\(\d\)\(\d\)\=\|\(\d\+\):\(\d\+\)\)\=$')
    if len(matched_list) > 0
      if matched_list[1] != ""
        " 1 or 11
        let opts.L_padding = str2nr(matched_list[1])
        let opts.R_padding = (matched_list[2] != "" ? str2nr(matched_list[2]) : opts.L_padding)
      endif
      if matched_list[3] != ""
        " 1:1
        let opts.L_padding = str2nr(matched_list[3])
        let opts.R_padding = str2nr(matched_list[4])
      endif
      call s:debug_echo("parsed options = " . string(opts))
      continue
    endif

    " filtering pattern
    let matched_list = matchlist(opts_str, '^\([gv]\)/\(.*\)$')
    if len(matched_list) > 0
      if matched_list[1] ==# 'g'
        " g/pattern
        let opts.g_pattern = matched_list[2]
      else
        " v/pattern
        let opts.v_pattern = matched_list[2]
      endif
      call s:debug_echo("parsed options = " . string(opts))
      continue
    endif
  endfor

  return opts
endfunction

function! s:Aligner._parse_pattern(value)
  let times_str = matchstr(a:value, '{\zs\(\d\+\|+\)\ze}$')
  let pattern = substitute(a:value, '{\(\d\+\|+\)}$', '', '')
  if !self.use_regex
    let pattern = s:string_escape_regex(pattern)
  endif
  if times_str == ""
    if self.alignment_method() ==# 'padding'
      let times = s:HUGE_VALUE
    else
      let times = 1
    endif
  elseif times_str == '+'
    " pattern{+}
    let times = s:HUGE_VALUE
  else
    " pattern{\d\+}
    let times = str2nr(times_str)
  endif
  return [pattern, times]
endfunction

function! s:Aligner._align_at(pattern, times)
  call s:debug_echo("options = " . string(self.options))
  call s:debug_echo("pattern = " . string(a:pattern))

  let flds_list = self._split_to_fields(a:pattern, a:times)
  call self._join_fields(flds_list)

  call s:debug_echo("aligned_parts:", map(copy(self._line_data), 'v:val.aligned_part'))
  call s:debug_echo("_lines:", self._lines)
endfunction

function! s:Aligner._filter_lines()
  let lines = {}
  let idx = 0
  while idx < len(self._lines)
    let orig_line = self.region.original_lines[idx]
    if ((self.options.g_pattern != "" && orig_line !~# self.options.g_pattern) ||
          \ (self.options.v_pattern != "" && orig_line =~# self.options.v_pattern))
      " filtered
    else
      let lines[idx] = self._lines[idx]
    endif
    let idx += 1
  endwhile
  return lines
endfunction

function! s:Aligner._split_to_fields(pattern, times)
  let flds_list = []
  let lines = self._filter_lines()
  " NOTE: _filter_lines() returns a Dictionary

  let n = 0
  while n < a:times
    let matched_count = 0
    let L_flds = {}
    let M_flds = {}
    let R_flds = {}
    " match and split
    for [idx, line] in items(lines)
      let match_beg = match(line, a:pattern)
      if match_beg >= 0
        let match_end = matchend(line, a:pattern)
        let L_flds[idx] = strpart(line, 0, match_beg)
        let M_flds[idx] = strpart(line, match_beg, match_end - match_beg)
        let R_flds[idx] = strpart(line, match_end)
        let matched_count += 1
      elseif n > 0
        let L_flds[idx] = line
      endif
    endfor
    if matched_count > 0
      call add(flds_list, L_flds)
      call add(flds_list, M_flds)
      let lines = R_flds
    else
      break
    endif
    let n += 1
  endwhile
  call add(flds_list, lines)
  return flds_list
endfunction

function! s:Aligner._join_fields(flds_list)
  let flds_list = a:flds_list + [{}, {}]
  call s:debug_echo("flds_list = " . string(flds_list))

  let method = self.alignment_method()

  let flds_idx = 0
  while flds_idx < len(flds_list) - 2
    let [L_flds, M_flds, R_flds]= flds_list[flds_idx : flds_idx + 2]
    let Last_flds = filter(copy(L_flds), '!has_key(M_flds, v:key)')

    "---------------------------------------
    " Leading

    if method ==# 'padding'
      let leading = ""
    else
      " keep the minimum leadings
      let leading_width = s:min_leading_width(values(L_flds))
      let leading = s:padding(leading_width)
    endif

    "---------------------------------------
    " Left field

    if method ==# 'padding'
      call map(L_flds, 's:string_strip(v:val)')
    else
      call map(L_flds, 'has_key(Last_flds, v:key)
            \ ? v:val
            \ : s:string_strip(v:val)
            \')
    endif

    let L_fld_width = max(values(map(copy(L_flds),
          \ 'self._line_data[v:key].aligned_width + s:string_width(v:val)')))

    call map(L_flds, 'has_key(Last_flds, v:key)
          \ ? s:string_pad(v:val,
          \     L_fld_width - self._line_data[v:key].aligned_width,
          \     self.options.R_fld_align
          \   )
          \ : s:string_pad(v:val,
          \     L_fld_width - self._line_data[v:key].aligned_width,
          \     self.options.L_fld_align
          \   )
          \')

    "---------------------------------------
    " Left padding

    let blank_L_flds = (len(filter(values(L_flds), 'v:val !~ "\\S"')) == len(L_flds))
    " NOTE: If all Left fields are blank, they should be ignored and the Left
    " padding should be set to 0.

    let lpad = (blank_L_flds ? "" : s:padding(self.options.L_padding))

    "---------------------------------------
    " Matched field

    if method ==# 'padding'
      let M_fld_width = max(map(values(M_flds), 's:string_width(v:val)'))

      call map(M_flds, 's:string_pad(v:val,
            \ M_fld_width,
            \ self.options.M_fld_align
            \ )')
    endif

    "---------------------------------------
    " Right padding

    if method ==# 'padding'
      let rpad = s:padding(self.options.R_padding)
    else
      let rpad = ""
    endif

    call s:debug_echo("L_flds:", L_flds)
    call s:debug_echo("M_flds:", M_flds)
    call s:debug_echo("R_flds:", R_flds)

    " join fields with paddings
    for idx in keys(L_flds)
      if !has_key(Last_flds, idx)
        let aligned = leading . L_flds[idx] . lpad . M_flds[idx] . rpad
        let line_data = self._line_data[idx]
        let line_data.aligned_part .= aligned
        let line_data.aligned_width += s:string_width(aligned)
      else
        " last field
        " the next pattern matching will start from the beginning of it
        let self._lines[idx] = L_flds[idx]
      endif
    endfor
    let flds_idx += 2
  endwhile
endfunction

function! s:print_error(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

function! s:debug_echo(msg, ...)
  if exists('g:alignta_debug') && g:alignta_debug
    echomsg "alignta: " . a:msg
    if a:0
      let lines = a:1
      if type(lines) == type([])
        for line in lines
          echomsg string(line)
        endfor
      elseif type(lines) == type({})
        for idx in s:sort_numbers(keys(lines))
          echomsg string(lines[idx])
        endfor
      endif
    endif
  endif
endfunction

" initialize s:Aligner itself
call s:Aligner.init_default_options()
" NOTE: This line must be evaluated AFTER the definition of
" s:Aligner._parse_options()

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
  let no_trailing = (a:0 ? a:1 : 0)
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
  else
    let lpad = ""
    let rpad = ""
  endif
  return lpad . a:str . (no_trailing ? "" : rpad)
endfunction

function! s:padding(width, ...)
  let char = (a:0 ? a:1 : ' ')
  return repeat(char, a:width)
endfunction

function! s:string_strip(str)
  return substitute(substitute(a:str, '^\s*', '', ''), '\s*$', '', '')
endfunction

function! s:string_rstrip(str)
  return substitute(a:str, '\s*$', '', '')
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
    "
    " NOTE: This code has a side effect that changes the cursor's position.
    let save_mod = &l:modified
    execute "normal! o\<Esc>"
    call setline(line('.'), a:str)
    let width = virtcol('$') - 1
    silent delete _
    let &l:modified = save_mod
    return width
  endfunction
endif

"-----------------------------------------------------------------------------
" Region

" for test-use only
function! alignta#_region(args)
  return s:Region.new(a:args)
endfunction

let s:Region = {
      \ 'normalize_tabs': 1,
      \ }

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
  let self.type = a:type
  let self.has_tab = 0 | let self.is_broken = 0
  let self.line_range = a:line_range
  let self.char_range = a:char_range
  let self.original_lines = getline(a:line_range[0], a:line_range[1])

  " initialize self.lines
  call self._get_selection()

  if a:type ==# 'block'
    " check the block for any broken multi-byte chars
    call self.update()
    let lines = getline(a:line_range[0], a:line_range[1])
    let self.is_broken = (lines !=# self.original_lines)
    silent undo
  endif

  let self.has_tab = !empty(filter(copy(self.lines), 'v:val =~ "\\t"'))
  if self.has_tab && self.normalize_tabs
    " NOTE: If the selection contains any tabs, expand them all to normalize
    " the selection text for subsequent alignments.
    let save_et = &l:expandtab
    setlocal expandtab
    execute a:line_range[0] . ',' . a:line_range[1] . 'retab'
    call self._get_selection()
    silent undo
    let &l:expandtab = save_et
  endif
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
    let save_vimenv = s:Vimenv.new('.', '&selection', '@v', vismode)
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
    let save_vimenv = s:Vimenv.new('.', '@v')

    let vismode = { 'char': 'v', 'line': 'V', 'block': "\<C-v>" }[self.type]
    let regtype = vismode
    if self.type ==# 'block'
      " calculate the block width
      let max_width = max(map(copy(self.lines), 's:string_width(v:val)'))
      " NOTE: If the block contains any multi-byte characters, Vim may fail to
      " count the number of paddings and append extra spaces. So, pad them
      " here.
      call map(self.lines, 's:string_pad(v:val, max_width, "left",
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
  let indent = s:padding(ntab, '\t') . s:padding(nsp)
  return substitute(a:line, '^ \+', indent, '')
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
