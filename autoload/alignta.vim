"=============================================================================
" Align Them All!
"
" File    : autoload/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-02-11
" Version : 0.1.8
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
    throw "alignta: undefined variable `" . a:name . "'"
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
" Constants

let s:HUGE_VALUE = 9999

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()

"-----------------------------------------------------------------------------
" Aligner

let s:Aligner = alignta#oop#class#new('Aligner')

let s:Aligner.DEFAULT_OPTIONS = {
      \ 'field_align': ['<', '<', '<'],
      \ 'L_margin'   : 1,
      \ 'R_margin'   : 1,
      \ 'g_pattern'  : '',
      \ 'v_pattern'  : '',
      \ }

let s:Aligner.extending_options = {}

function! s:class_Aligner_apply_extending_options(options) dict
  let opts = (type(a:options) == type("") ? s:Aligner.parse_options(a:options) : a:options)
  call extend(s:Aligner.extending_options, opts, 'force')
endfunction
call s:Aligner.class_bind(s:SID, 'apply_extending_options')

function! s:class_Aligner_reset_extending_options() dict
  let s:Aligner.extending_options = {}
endfunction
call s:Aligner.class_bind(s:SID, 'reset_extending_options')

function! s:Aligner_initialize(region_args, align_args, use_regexp) dict
  let self.region = call('alignta#region#new', a:region_args)
  let self.region.had_indent_tab = 0
  let self.arguments = a:align_args
  let self.use_regexp = a:use_regexp
  call self.init_options()
  let self.align_count = 0

  if self.region.has_indent_tab()
    call self.region.detab_indent()
    let self.region.had_indent_tab = 1
  endif

  " initialize the lines to align
  let self.lines = s:Lines.new(self.region.lines)

  " initialize the buffer where the aligned parts will be appended
  let begin_col = (self.region.type ==# 'block' ? self.region.block_begin_col : 1)
  let self.aligned = s:Lines.new(map(copy(self.region.lines), '""'), begin_col)
endfunction
call s:Aligner.bind(s:SID, 'initialize')

function! s:Aligner_init_options() dict
  let self.options = copy(s:Aligner.DEFAULT_OPTIONS)
  call self.apply_options(alignta#get_config_variable('alignta_default_options'))
  call self.apply_options(s:Aligner.extending_options)
endfunction
call s:Aligner.bind(s:SID, 'init_options')

function! s:Aligner_apply_options(options) dict
  let opts = (type(a:options) == type("") ? self.parse_options(a:options) : a:options)
  call extend(self.options, opts, 'force')
endfunction
call s:Aligner.bind(s:SID, 'apply_options')

function! s:Aligner_align() dict
  call s:print_debug("region",    self.region)
  call s:print_debug("lines",     self.lines)
  call s:print_debug("arguments", self.arguments)

  if self.region.is_broken
    call alignta#print_error("alignta: the region is invalid")
    return
  endif

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let start_time = reltime()
  endif

  let vimenv = alignta#vimenv#new('.', '&ignorecase')
  set noignorecase
  " NOTE: alignta#string#width() for Vim 7.2 or older has a side effect that changes
  " the cursor's position.

  let argc = len(self.arguments)
  let is_pattern = 0

  " process arguments
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
    " keep the block width as possible
    call self.aligned.update_width()
    let block_width = self.region.block_width
    for [idx, line] in self.aligned.each()
      if (line =~ '^\s*$' || self.region.line_is_short(idx)) | continue | endif
      let line_width = self.aligned.get_width(idx)
      if line_width < block_width
        let line .= alignta#string#padding(block_width - line_width)
        call self.aligned.set(idx, line)
      endif
    endfor
  endif

  let self.region.lines = self.aligned.to_a()

  if self.region.had_indent_tab
    call self.region.entab_indent()
  endif

  " update!
  call self.region.update()

  call vimenv.restore()

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    echomsg "alignta: used=" . used_time . "s"
  endif
endfunction
call s:Aligner.bind(s:SID, 'align')

function! s:Aligner_parse_options(value) dict
  let opts = {}
  for opts_str in split(a:value, '\(\(^\|[^\\]\)\(\\\{2}\)*\)\@<=\s\s*')

    " padding alignment options
    " {N_fld_align}{M_fld_align}...[L_fld_align][margin]
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

    " shifting alignment options
    " ->[margin] or -->[margin]
    let matched_list = matchlist(opts_str, '^\(--\=>\)\(\d\+\)\=$')
    if len(matched_list) > 0
      let opts.method = 'shift'
      if matched_list[1] == '-->'
        let opts.method .= '_tab'
      endif
      if matched_list[2] != ''
        let opts.L_margin = str2nr(matched_list[2])
      endif
      call s:print_debug("parsed options", opts)
      continue
    endif

    " margin options
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
      call s:print_debug("parsed options", opts)
      continue
    endif
  endfor

  return opts
endfunction
call s:Aligner.bind(s:SID, 'parse_options')
call s:Aligner.export('parse_options')

function! s:Aligner_parse_pattern(value) dict
  let times_str = matchstr(a:value, '{\zs\(\d\+\|+\)\ze}$')
  let pattern = substitute(a:value, '{\(\d\+\|+\)}$', '', '')
  if !self.use_regexp
    let pattern = alignta#string#escape_regexp(pattern)
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
call s:Aligner.bind(s:SID, 'parse_pattern')

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
call s:Aligner.bind(s:SID, '_align_at')

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
call s:Aligner.bind(s:SID, '_filter_lines')

function! s:Aligner__keep_min_leading(lines) dict
  let leading = alignta#string#padding(a:lines.min_leading_width())
  call a:lines.lstrip(1)

  for [idx, line] in self.aligned.each()
    call self.aligned.append(idx, leading)
  endfor
endfunction
call s:Aligner.bind(s:SID, '_keep_min_leading')

function! s:Aligner__split_to_fields(lines, pattern, times) dict
  let fields = []
  let n = 0 | let rest = a:lines
  while n < a:times
    let matched_count = 0
    let L_fld = s:Lines.new() | " Left
    let M_fld = s:Lines.new() | " Matched
    let R_fld = s:Lines.new() | " Right
    " match and split
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

  let sentinel = s:Lines.new()
  let fields += [rest, sentinel, sentinel]

  return fields
endfunction
call s:Aligner.bind(s:SID, '_split_to_fields')

" NOTE:
" fields -> N, M, N, M, ..., N, M, Last
"
" N...Not matched
" M...Matched
"
function! s:Aligner__join_fields(fields) dict
  call s:print_debug("fields", map(copy(a:fields), 'v:val.each()'))

  let fld_idx = 0
  while fld_idx < len(a:fields) - 2
    let [N_fld, M_fld]= a:fields[fld_idx : fld_idx + 1]

    if exists('g:alignta_debug') && g:alignta_debug
      call s:print_debug(printf("[%02d] N_fld:before", fld_idx),     N_fld)
      call s:print_debug(printf("[%02d] M_fld:before", fld_idx + 1), M_fld)
    endif

    call call(self['_' . self.options.method . '_align_fields'],
          \ [N_fld, M_fld, fld_idx, (fld_idx == len(a:fields) - 3)], self)

    " join fields
    for [idx, line] in N_fld.each()
      if M_fld.has(idx)
        let line = N_fld.get(idx) . M_fld.get(idx)
        call self.aligned.append(idx, line)
      else
        " Last field
        " the next pattern matching will start from the beginning of it
        call self.lines.set(idx, line)
      endif
    endfor

    if exists('g:alignta_debug') && g:alignta_debug
      call s:print_debug(printf("[%02d] N_fld:after",  fld_idx),     N_fld)
      call s:print_debug(printf("[%02d] M_fld:after",  fld_idx + 1), M_fld)
      call s:print_debug("aligned", self.aligned)
    endif

    let fld_idx += 2
  endwhile
endfunction
call s:Aligner.bind(s:SID, '_join_fields')

function! s:Aligner__pad_align_fields(N_fld, M_fld, fld_idx, is_last) dict
  let N_fld_align = self._get_field_align(a:fld_idx, a:is_last)
  let M_fld_align = self._get_field_align(a:fld_idx + 1)

  "---------------------------------------
  " Not-matched field

  call a:N_fld.strip(N_fld_align == '=')

  let AN_fld_width = max(map(a:N_fld.each(), '
        \ self.aligned.get_width(v:val[0]) +
        \ alignta#string#width(v:val[1], self.aligned.get_width(v:val[0]))
        \'))

  for [idx, line] in a:N_fld.each()
    let width = AN_fld_width - self.aligned.get_width(idx)
    let line = alignta#string#pad(line, width, N_fld_align)
    call a:N_fld.set(idx, line)
  endfor

  "---------------------------------------
  " Matched field

  let L_margin = (a:N_fld.is_blank() ? '' : alignta#string#padding(self.options.L_margin))
  let R_margin = alignta#string#padding(self.options.R_margin)

  let M_fld_width = max(map(a:M_fld.to_a(), '
        \ alignta#string#width(v:val, AN_fld_width)
        \'))

  for [idx, line] in a:M_fld.each()
    let line = L_margin . alignta#string#pad(line, M_fld_width, M_fld_align) . R_margin
    call a:M_fld.set(idx, line)
  endfor
endfunction
call s:Aligner.bind(s:SID, '_pad_align_fields')

function! s:Aligner__get_field_align(fld_idx, ...) dict
  let is_last = (a:0 ? a:1 : 0)
  if len(self.options.field_align) % 2 == 1
    if is_last
      return self.options.field_align[-1]
    endif
    let fld_align = self.options.field_align[:-2]
  else
    let fld_align = self.options.field_align
  endif
  return fld_align[a:fld_idx % len(fld_align)]
endfunction
call s:Aligner.bind(s:SID, '_get_field_align')

function! s:Aligner__shift_align_fields(N_fld, M_fld, fld_idx, is_last) dict
endfunction
call s:Aligner.bind(s:SID, '_shift_align_fields')

function! s:Aligner__shift_tab_align_fields(N_fld, M_fld, fld_idx, is_last) dict
endfunction
call s:Aligner.bind(s:SID, '_shift_tab_align_fields')

"-----------------------------------------------------------------------------
" Lines

let s:Lines = alignta#oop#class#new('Lines')

function! s:Lines_initialize(...) dict
  let self._lines = {}
  let self._width = {}
  let self._calc_width = (len(a:000) >= 2)

  if self._calc_width
    let self._begin_col = get(a:000, 1, 1)
  endif

  let lines = get(a:000, 0, [])
  let idx = 0
  while idx < len(lines)
    call self.append(idx, lines[idx])
    let idx += 1
  endwhile
endfunction
call s:Lines.bind(s:SID, 'initialize')

function! s:Lines_append(idx, str) dict
  if !has_key(self._lines, a:idx)
    let self._lines[a:idx] = ""
    let self._width[a:idx] = 0
  endif
  let self._lines[a:idx] .= a:str

  if self._calc_width
    let col = (self._begin_col - 1) + self._width[a:idx]
    let self._width[a:idx] += alignta#string#width(a:str, col)
  endif
endfunction
call s:Lines.bind(s:SID, 'append')

function! s:Lines_min_leading_width() dict
  let lines = filter(self.to_a(), 'v:val =~ "\\S"')
  return min(map(map(lines, 'matchstr(v:val, "^\\s*")'), 'strlen(v:val)'))
endfunction
call s:Lines.bind(s:SID, 'min_leading_width')

function! s:Lines_dump() dict
  for [idx, line] in self.each()
    call s:echomsg(printf('%03x: ', idx) . string(line))
  endfor
endfunction
call s:Lines.bind(s:SID, 'dump')

function! s:Lines_dup() dict
  let obj = copy(self)
  let obj._lines = copy(self._lines)
  let obj._width = copy(self._width)
  return obj
endfunction
call s:Lines.bind(s:SID, 'dup')

function! s:Lines_each() dict
  let items = []
  for idx in s:sort_numbers(keys(self._lines))
    call add(items, [idx, self._lines[idx]])
  endfor
  return items
endfunction
call s:Lines.bind(s:SID, 'each')

function! s:Lines_get(idx) dict
  return self._lines[a:idx]
endfunction
call s:Lines.bind(s:SID, 'get')

function! s:Lines_get_width(idx) dict
  return self._width[a:idx]
endfunction
call s:Lines.bind(s:SID, 'get_width')

function! s:Lines_has(idx) dict
  return has_key(self._lines, a:idx)
endfunction
call s:Lines.bind(s:SID, 'has')

function! s:Lines_is_blank() dict
  return (len(filter(values(self._lines), 'v:val =~ "^\\s*$"')) == len(self._lines))
endfunction
call s:Lines.bind(s:SID, 'is_blank')

function! s:Lines_set(idx, str) dict
  if has_key(self._lines, a:idx)
    call self.remove(a:idx)
  endif
  call self.append(a:idx, a:str)
endfunction
call s:Lines.bind(s:SID, 'set')

function! s:Lines_remove(idx) dict
  unlet self._lines[a:idx]
  unlet self._width[a:idx]
endfunction
call s:Lines.bind(s:SID, 'remove')

function! s:Lines_strip(...) dict
  call self.lstrip(a:0 ? a:1 : 0)
  call self.rstrip()
endfunction
call s:Lines.bind(s:SID, 'strip')

function! s:Lines_lstrip(...) dict
  let strip_min_leading =  (a:0 ? a:1 : 0)
  if strip_min_leading
    let leading = alignta#string#padding(self.min_leading_width())
    for [idx, line] in self.each()
      call self.set(idx, substitute(line, '^' . leading, '', ''))
    endfor
  else
    call map(self._lines, 'alignta#string#lstrip(v:val)')
  endif
endfunction
call s:Lines.bind(s:SID, 'lstrip')

function! s:Lines_rstrip() dict
  call map(self._lines, 'alignta#string#rstrip(v:val)')
endfunction
call s:Lines.bind(s:SID, 'rstrip')

function! s:Lines_to_a() dict
  return map(self.each(), 'v:val[1]')
endfunction
call s:Lines.bind(s:SID, 'to_a')

function! s:Lines_update_width() dict
  if self._calc_width
    let col = self._begin_col - 1
    for [idx, line] in self.each()
      let self._width[idx] = alignta#string#width(line, col)
    endfor
  endif
endfunction
call s:Lines.bind(s:SID, 'update_width')

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunction

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
      if a:value.is_a(s:Lines)
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
    call unittest#results().puts(a:msg)
  else
    echomsg a:msg
  endif
endfunction

" vim: filetype=vim
