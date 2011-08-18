"=============================================================================
" Align Them All!
"
" File    : autoload/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-08-19
" Version : 0.2.1
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

function! alignta#align(region_args, align_args, ...)
  let use_regexp = (a:0 ? a:1 : 0)
  let aligner = s:Aligner.new(a:region_args, a:align_args, use_regexp)
  call aligner.align()
endfunction

function! alignta#get_config_variable(name)
  if exists('b:' . a:name)
    execute 'let value = b:' . a:name
  elseif exists('g:' . a:name)
    execute 'let value = g:' . a:name
  else
    throw "alignta: Undefined variable `" . a:name . "'"
  endif
  return value
endfunction

" API for unite-alignta
function! alignta#apply_extending_options(options)
  call s:Aligner.apply_extending_options(a:options)
  call s:print_debug("extending options", s:Aligner.extending_options)
endfunction

function! alignta#reset_extending_options()
  call s:Aligner.reset_extending_options()
  call s:print_debug("extending options", s:Aligner.extending_options)
endfunction

"-----------------------------------------------------------------------------
" Constant

let s:HUGE_VALUE = 9999

"-----------------------------------------------------------------------------
" Aligner

let s:Region = alignta#region#import()
let s:Vimenv = alignta#vimenv#import()
let s:String = alignta#string#import()

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let s:Aligner = alignta#oop#class#new('Aligner', s:SID)

let s:Aligner.DEFAULT_OPTIONS = {
      \ 'field_align': ['<', '<', '<'],
      \ 'L_margin'   : 1,
      \ 'R_margin'   : 1,
      \ 'g_pattern'  : '',
      \ 'v_pattern'  : '',
      \ }

let s:Aligner.extending_options = {}

function! s:Aligner_apply_extending_options(options) dict
  let opts = (type(a:options) == type("") ? s:Aligner.parse_options(a:options) : a:options)
  call extend(s:Aligner.extending_options, opts, 'force')
endfunction
call s:Aligner.class_method('apply_extending_options')

function! s:Aligner_reset_extending_options() dict
  let s:Aligner.extending_options = {}
endfunction
call s:Aligner.class_method('reset_extending_options')

function! s:Aligner_initialize(region_args, align_args, use_regexp) dict
  let self.region = call(s:Region.new, a:region_args, s:Region)
  let self.region.had_indent_tab = 0
  let self.arguments  = a:align_args
  let self.use_regexp = a:use_regexp
  call self.init_options()
  let self.align_count = 0

  " Normalize Tabs for indentation to Spaces.
  if self.region.has_indent_tab()
    call self.region.detab_indent()
    let self.region.had_indent_tab = 1
  endif
  " Initialize the lines to align.
  let self.lines = s:Fragments.new(self.region.lines)
  " Initialize the buffer where the aligned parts will be appended.
  let size = len(self.region.lines)
  let col  = (self.region.type ==# 'block' ? self.region.block_begin_col - 1 : 0)
  let self.aligned = s:Aligned.new(size, col)
endfunction
call s:Aligner.method('initialize')

function! s:Aligner_init_options() dict
  let self.options = copy(s:Aligner.DEFAULT_OPTIONS)
  call self.apply_options(alignta#get_config_variable('alignta_default_options'))
  call self.apply_options(s:Aligner.extending_options)
endfunction
call s:Aligner.method('init_options')

function! s:Aligner_apply_options(options) dict
  let opts = (type(a:options) == type("") ? self.parse_options(a:options) : a:options)
  call extend(self.options, opts, 'force')
endfunction
call s:Aligner.method('apply_options')

function! s:Aligner_align() dict
  call s:print_debug("region",    self.region)
  call s:print_debug("lines",     self.lines)
  call s:print_debug("arguments", self.arguments)

  if self.region.is_broken
    call alignta#print_error("alignta: The selected region is invalid.")
    return
  endif

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let start_time = reltime()
  endif

  let vimenv = s:Vimenv.new('.', '&ignorecase')
  set noignorecase
  " NOTE: s:String.width() for Vim 7.2 or older has a side effect that changes
  " the cursor's position.

  let argc = len(self.arguments)
  let is_pattern = 0

  " Process arguments.
  let idx = 0
  while idx < argc
    let value = self.arguments[idx]
    if idx == argc - 1
      let is_pattern = 1
    elseif !is_pattern && value =~ '^-p\%[attern]$'
      let is_pattern = 1
      let idx += 1
      continue
    endif
    let opts = self.parse_options(value)
    if !is_pattern && !empty(opts)
      " options
      call self.apply_options(opts)
    else
      " pattern
      let [pattern, times] = self.parse_pattern(value)
      call self._align_at(pattern, times)
    endif
    let is_pattern = 0
    let idx += 1
  endwhile

  for [idx, line] in self.lines.each()
    call self.aligned.append(idx, line)
  endfor
  call self.aligned.rstrip()

  if self.region.type ==# 'block'
    " Keep the block width as possible.
    let block_width = self.region.block_width
    for [idx, line] in self.aligned.each()
      if (line =~ '^\s*$' || self.region.line_is_short(idx)) | continue | endif
      let line_width = self.aligned.width(idx)
      if line_width < block_width
        let line .= s:String.padding(block_width - line_width)
        call self.aligned.set(idx, line)
      endif
    endfor
  endif

  let self.region.lines = self.aligned.to_list()

  if self.region.had_indent_tab
    call self.region.entab_indent()
  endif

  " Update!
  call self.region.update()

  call vimenv.restore()

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    echomsg "alignta: used=" . used_time . "s"
  endif
endfunction
call s:Aligner.method('align')

function! s:Aligner_parse_options(value) dict
  let opts = {}
  for opts_str in split(a:value, '\(\(^\|[^\\]\)\(\\\{2}\)*\)\@<=\s\s*')

    " Padding Alignment Options
    "   {L_fld_align}{M_fld_align}...[L_fld_align][margin]
    let matched_list = matchlist(opts_str,
          \ '^\([<|>=]\{2,}\)\%(\(\d\)\(\d\)\=\|\(\d\+\):\(\d\+\)\)\=$')
    if len(matched_list) > 0
      let opts.method = 'pad'
      let opts.field_align = split(matched_list[1], '\zs')
      if matched_list[2] != ''
        " 1 or 11
        let opts.L_margin = str2nr(matched_list[2])
        let opts.R_margin = (matched_list[3] != '' ? str2nr(matched_list[3]) : opts.L_margin)
      endif
      if matched_list[4] != ''
        " 1:1
        let opts.L_margin = str2nr(matched_list[4])
        let opts.R_margin = str2nr(matched_list[5])
      endif
      call s:print_debug("parsed options", opts)
      continue
    endif

    " Shifting Alignment Options
    "   <-[margin] or <--[margin] or
    "   ->[margin] or -->[margin]
    let matched_list = matchlist(opts_str, '^\(<--\=\|--\=>\)\(\d\+\)\=$')
    if len(matched_list) > 0
      let opts.method = 'shift'
      let opts.method .= (matched_list[1] =~ '<'  ? '_left' : '_right')
      let opts.method .= (matched_list[1] =~ '--' ? '_tab'  : '')
      if matched_list[2] != ''
        let opts.L_margin = str2nr(matched_list[2])
      endif
      call s:print_debug("parsed options", opts)
      continue
    endif

    " Margin Options
    let matched_list = matchlist(opts_str,
          \ '^@\%(\(\d\)\(\d\)\=\|\(\d\+\):\(\d\+\)\)\=$')
    if len(matched_list) > 0
      if matched_list[1] != ''
        " 1 or 11
        let opts.L_margin = str2nr(matched_list[1])
        let opts.R_margin = (matched_list[2] != '' ? str2nr(matched_list[2]) : opts.L_margin)
      endif
      if matched_list[3] != ''
        " 1:1
        let opts.L_margin = str2nr(matched_list[3])
        let opts.R_margin = str2nr(matched_list[4])
      endif
      call s:print_debug("parsed options", opts)
      continue
    endif

    " Filtering Pattern
    let matched_list = matchlist(opts_str, '^\([gv]\)/\(.*\)$')
    if len(matched_list) > 0
      if matched_list[1] ==# 'g'
        " g/pattern
        let opts.g_pattern = matched_list[2]
      else
        " v/pattern
        let opts.v_pattern = matched_list[2]
      endif
      call s:print_debug("parsed options", opts)
      continue
    endif
  endfor

  return opts
endfunction
call s:Aligner.class_method('parse_options')
call s:Aligner.method('parse_options')

function! s:Aligner_parse_pattern(value) dict
  let times_str = matchstr(a:value, '{\zs\(\d\+\|+\)\ze}$')
  let pattern = substitute(a:value, '{\(\d\+\|+\)}$', '', '')
  if !self.use_regexp
    let pattern = s:String.escape_regexp(pattern)
  endif
  if times_str == ''
    if self.options.method ==# 'pad'
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
call s:Aligner.method('parse_pattern')

function! s:Aligner__align_at(pattern, times) dict
  call s:print_debug("options", self.options)
  call s:print_debug("pattern", a:pattern)

  let lines = self._filter_lines()

  if self.align_count == 0 && self.options.method ==# 'pad'
    call self._keep_min_leading(lines)
  endif

  let fields = self._split_to_fields(lines, a:pattern, a:times)
  call self._join_fields(fields)
  let self.align_count += 1

  call s:print_debug("lines", self.lines)
endfunction
call s:Aligner.method('_align_at')

function! s:Aligner__filter_lines() dict
  let lines = self.lines.dup()
  for [idx, line] in lines.each()
    let orig_line = self.region.original_lines[idx]
    if ((self.options.g_pattern != '' && orig_line !~# self.options.g_pattern) ||
      \ (self.options.v_pattern != '' && orig_line =~# self.options.v_pattern))
      call lines.remove(idx)
    endif
  endfor
  return lines
endfunction
call s:Aligner.method('_filter_lines')

function! s:Aligner__keep_min_leading(lines) dict
  let leading = s:String.padding(a:lines.min_leading_width())
  call a:lines.lstrip(1)

  for [idx, line] in a:lines.each()
    call self.lines.set(idx, line)
    call self.aligned.append(idx, leading)
  endfor
endfunction
call s:Aligner.method('_keep_min_leading')

function! s:Aligner__split_to_fields(lines, pattern, times) dict
  let fields = []
  let n = 0 | let rest = a:lines
  while n < a:times
    let matched_count = 0
    let L_fld = s:Fragments.new() | " Left
    let M_fld = s:Fragments.new() | " Matched
    let R_fld = s:Fragments.new() | " Right
    " Match and split.
    for [idx, line] in rest.each()
      let match_beg = match(line, a:pattern)
      if match_beg >= 0
        let match_end = matchend(line, a:pattern)
        call L_fld.set(idx, strpart(line, 0, match_beg))
        call M_fld.set(idx, strpart(line, match_beg, match_end - match_beg))
        call R_fld.set(idx, strpart(line, match_end))
        let matched_count += 1
      elseif n > 0
        call L_fld.set(idx, line)
      endif
    endfor
    if matched_count > 0
      call add(fields, L_fld)
      call add(fields, M_fld)
      let rest = R_fld
    else
      break
    endif
    let n += 1
  endwhile

  let sentinel = s:Fragments.new()
  let fields += [rest, sentinel, sentinel]

  return fields
endfunction
call s:Aligner.method('_split_to_fields')

function! s:Aligner__join_fields(fields) dict
  call s:print_debug("fields", map(copy(a:fields), 'v:val.each()'))

  let fld_idx = 0
  while fld_idx < len(a:fields) - 2
    let [L_fld, M_fld]= a:fields[fld_idx : fld_idx + 1]

    if exists('g:alignta_debug') && g:alignta_debug
      call s:print_debug(printf("[%02d] L_fld:before", fld_idx),     L_fld)
      call s:print_debug(printf("[%02d] M_fld:before", fld_idx + 1), M_fld)
    endif

    call call(self['_' . self.options.method . '_align_fields'],
          \ [L_fld, M_fld, fld_idx, (fld_idx == len(a:fields) - 3)], self)

    " Join fields.
    for [idx, line] in L_fld.each()
      if M_fld.has(idx)
        let line = L_fld.line(idx) . M_fld.line(idx)
        call self.aligned.append(idx, line)
      else
        " Last field
        " The next pattern matching will start from the beginning of it.
        call self.lines.set(idx, line)
      endif
    endfor

    if exists('g:alignta_debug') && g:alignta_debug
      call s:print_debug(printf("[%02d] L_fld:after",  fld_idx),     L_fld)
      call s:print_debug(printf("[%02d] M_fld:after",  fld_idx + 1), M_fld)
      call s:print_debug("aligned", self.aligned)
    endif
    let fld_idx += 2
  endwhile
endfunction
call s:Aligner.method('_join_fields')

" NOTE:
"
"   A ... Aligned
"   L ... Left
"   M ... Matched
"   R ... Right
"   AL .. Aligned and Left

function! s:Aligner__pad_align_fields(L_fld, M_fld, fld_idx, is_last) dict
  let L_fld_align = self._get_field_align(a:fld_idx, a:is_last)
  let M_fld_align = self._get_field_align(a:fld_idx + 1)

  " Left field
  call a:L_fld.strip(L_fld_align == '=')

  let AL_flds_width = max(map(a:L_fld.each(), '
        \ self.aligned.width(v:val[0]) +
        \ s:String.width(v:val[1], self.aligned.width(v:val[0]))
        \'))

  for [idx, line] in a:L_fld.each()
    let width = AL_flds_width - self.aligned.width(idx)
    let line = s:String.justify(line, width, L_fld_align)
    call a:L_fld.set(idx, line)
  endfor

  " Matched field
  let L_margin = (a:L_fld.is_blank() ? '' : s:String.padding(self.options.L_margin))
  let R_margin = s:String.padding(self.options.R_margin)

  let M_fld_width = max(map(a:M_fld.to_list(), 's:String.width(v:val, AL_flds_width)'))

  for [idx, line] in a:M_fld.each()
    let line = L_margin . s:String.justify(line, M_fld_width, M_fld_align) . R_margin
    call a:M_fld.set(idx, line)
  endfor
endfunction
call s:Aligner.method('_pad_align_fields')

function! s:Aligner__get_field_align(fld_idx, ...) dict
  let fld_align = self.options.field_align
  let is_last = (a:0 ? a:1 : 0)

  if len(fld_align) % 2 == 1
    if is_last | return fld_align[-1] | endif
    let fld_align = fld_align[:-2]
  endif
  return fld_align[a:fld_idx % len(fld_align)]
endfunction
call s:Aligner.method('_get_field_align')

function! s:Aligner__shift_align_fields(L_fld, M_fld, fld_idx, is_last, shift_left, use_tab) dict
  if self.align_count == 0 && a:fld_idx == 0
    " Save the Left/Right Most column position of matches
    " before rstripping of L_fld.
    let al_widths = map(filter(a:L_fld.each(), 'a:M_fld.has(v:val[0])'), '
          \ self.aligned.width(v:val[0]) +
          \ s:String.width(v:val[1], self.aligned.width(v:val[0]))
          \')
    let LRM_match_col = (a:shift_left ? min(al_widths) : max(al_widths)) + 1
  else
    let LRM_match_col = 0
  endif

  call a:L_fld.rstrip()

  let AL_flds_width = max(map(filter(a:L_fld.each(), 'a:M_fld.has(v:val[0])'), '
        \ self.aligned.width(v:val[0]) +
        \ s:String.width(v:val[1], self.aligned.width(v:val[0]))
        \'))

  let margin = self.options.L_margin
  let AL_flds_width = max([AL_flds_width + margin, LRM_match_col - 1])
  let Padding_func = s:String.padding
  if a:use_tab
    let AL_flds_width = s:tabstop_ceil(AL_flds_width)
    if !&l:expandtab
      let Padding_func = s:String.tab_padding
    endif
  endif

  for [idx, line] in a:L_fld.each()
    let col = self.aligned.width(idx)
    let col += s:String.width(line, col)
    let line .= call(Padding_func, [AL_flds_width - col, col])
    call a:L_fld.set(idx, line)
  endfor
endfunction
call s:Aligner.method('_shift_align_fields')

function! s:Aligner__shift_left_align_fields(...) dict
  call call(self._shift_align_fields, a:000 + [1, 0], self)
endfunction
call s:Aligner.method('_shift_left_align_fields')

function! s:Aligner__shift_right_align_fields(...) dict
  call call(self._shift_align_fields, a:000 + [0, 0], self)
endfunction
call s:Aligner.method('_shift_right_align_fields')

function! s:Aligner__shift_left_tab_align_fields(...) dict
  call call(self._shift_align_fields, a:000 + [1, 1], self)
endfunction
call s:Aligner.method('_shift_left_tab_align_fields')

function! s:Aligner__shift_right_tab_align_fields(...) dict
  call call(self._shift_align_fields, a:000 + [0, 1], self)
endfunction
call s:Aligner.method('_shift_right_tab_align_fields')

function! s:tabstop_ceil(w)
  let ts = &l:tabstop
  return (a:w % ts == 0 ? a:w : ts * (a:w / ts + 1))
endfunction

"-----------------------------------------------------------------------------
" Fragments

let s:Fragments = alignta#oop#class#new('Fragments', s:SID)

" Fragments.new( [{lines}])
function! s:Fragments_initialize(...) dict
  let self._lines = {}
  if a:0
    let lines = a:1
    let idx = 0
    while idx < len(lines)
      let self._lines[idx] = lines[idx]
      let idx += 1
    endwhile
  endif
endfunction
call s:Fragments.method('initialize')

function! s:Fragments_append(idx, str) dict
  if !has_key(self._lines, a:idx)
    let self._lines[a:idx] = ""
  endif
  let self._lines[a:idx] .= a:str
endfunction
call s:Fragments.method('append')

function! s:Fragments_min_leading_width() dict
  let lines = filter(self.to_list(), 'v:val =~ "\\S"')
  return min(map(map(lines, 'matchstr(v:val, "^\\s*")'), 'strlen(v:val)'))
endfunction
call s:Fragments.method('min_leading_width')

function! s:Fragments_dump() dict
  for [idx, line] in self.each()
    call s:echomsg(printf('%03x: ', idx) . string(line))
  endfor
endfunction
call s:Fragments.method('dump')

function! s:Fragments_dup() dict
  let obj = copy(self)
  let obj._lines = copy(self._lines)
  return obj
endfunction
call s:Fragments.method('dup')

function! s:Fragments_each() dict
  let items = []
  for idx in s:sort_numbers(keys(self._lines))
    call add(items, [idx, self._lines[idx]])
  endfor
  return items
endfunction
call s:Fragments.method('each')

function! s:Fragments_has(idx) dict
  return has_key(self._lines, a:idx)
endfunction
call s:Fragments.method('has')

function! s:Fragments_is_blank() dict
  return (len(filter(values(self._lines), 'v:val =~ "^\\s*$"')) == len(self._lines))
endfunction
call s:Fragments.method('is_blank')

function! s:Fragments_line(idx) dict
  return self._lines[a:idx]
endfunction
call s:Fragments.method('line')

function! s:Fragments_set(idx, str) dict
  let self._lines[a:idx] = a:str
endfunction
call s:Fragments.method('set')

function! s:Fragments_remove(idx) dict
  unlet self._lines[a:idx]
endfunction
call s:Fragments.method('remove')

" Fragments.strip( [{strip_min_leading}])
function! s:Fragments_strip(...) dict
  call self.lstrip(a:0 ? a:1 : 0)
  call self.rstrip()
endfunction
call s:Fragments.method('strip')

" Fragments.lstrip( [{strip_min_leading}])
function! s:Fragments_lstrip(...) dict
  let strip_min_leading =  (a:0 ? a:1 : 0)
  if strip_min_leading
    let leading = s:String.padding(self.min_leading_width())
    for [idx, line] in self.each()
      call self.set(idx, substitute(line, '^' . leading, '', ''))
    endfor
  else
    call map(self._lines, 's:String.lstrip(v:val)')
  endif
endfunction
call s:Fragments.method('lstrip')

function! s:Fragments_rstrip() dict
  call map(self._lines, 's:String.rstrip(v:val)')
endfunction
call s:Fragments.method('rstrip')

function! s:Fragments_to_list() dict
  return map(self.each(), 'v:val[1]')
endfunction
call s:Fragments.method('to_list')

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  let n1 = str2nr(a:n1)
  let n2 = str2nr(a:n2)
  return n1 == n2 ? 0 : n1 > n2 ? 1 : -1
endfunction

"-----------------------------------------------------------------------------
" Aligned

let s:Aligned = alignta#oop#class#new('Aligned', s:SID)

function! s:Aligned_initialize(size, col) dict
  let empties = []
  let self._width = {}
  let self._col = a:col
  let idx = 0
  while idx < a:size
    call add(empties, "")
    let self._width[idx] = 0
    let idx += 1
  endwhile
  let self._fragments = s:Fragments.new(empties)
endfunction
call s:Aligned.method('initialize')

function! s:Aligned_append(idx, str) dict
  call self._fragments.append(a:idx, a:str)
  if !has_key(self._width, a:idx)
    let self._width[a:idx] = 0
  endif
  let col = self._col + self._width[a:idx]
  let self._width[a:idx] += s:String.width(a:str, col)
endfunction
call s:Aligned.method('append')

function! s:Aligned_dump() dict
  call self._fragments.dump()
endfunction
call s:Aligned.method('dump')

function! s:Aligned_each() dict
  return self._fragments.each()
endfunction
call s:Aligned.method('each')

function! s:Aligned_line(idx) dict
  return self._fragments.line(a:idx)
endfunction
call s:Aligned.method('line')

function! s:Aligned_width(idx) dict
  return self._width[a:idx]
endfunction
call s:Aligned.method('width')

function! s:Aligned_set(idx, str) dict
  call self._fragments.set(a:idx, a:str)
  let self._width[a:idx] = s:String.width(a:str, self._col)
endfunction
call s:Aligned.method('set')

function! s:Aligned_rstrip() dict
  call self._fragments.rstrip()
  call self._update_width()
endfunction
call s:Aligned.method('rstrip')

function! s:Aligned__update_width() dict
  for [idx, line] in self._fragments.each()
    let self._width[idx] = s:String.width(line, self._col)
  endfor
endfunction
call s:Aligned.method('_update_width')

function! s:Aligned_to_list() dict
  return self._fragments.to_list()
endfunction
call s:Aligned.method('to_list')

"-----------------------------------------------------------------------------
" Utils

function! alignta#print_error(msg)
  echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function! s:print_debug(caption, value)
  if exists('g:alignta_debug') && g:alignta_debug
    call s:echomsg("")
    call s:echomsg("ALIGNTA-DEBUG: " . a:caption)
    if alignta#oop#is_object(a:value)
      if a:value.is_a(s:Fragments)
        call a:value.dump()
      else
        call s:echomsg(a:value.to_s())
      endif
    else
      call s:echomsg(alignta#oop#string(a:value))
    endif
  endif
endfunction
function! s:echomsg(msg)
  if exists('*unittest#is_running') && unittest#is_running()
    let results = unittest#results()
    call results.puts(a:msg)
  else
    echomsg a:msg
  endif
endfunction

" vim: filetype=vim
