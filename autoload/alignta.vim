"=============================================================================
" Align Them All!
"
" File    : autoload/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-31
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
  call s:print_debug("extending options = " . string(s:Aligner.extending_options))
endfunction

function! alignta#reset_extending_options()
  call s:Aligner.reset_extending_options()
  call s:print_debug("extending options = " . string(s:Aligner.extending_options))
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
      \ 'L_fld_align': 'left',
      \ 'M_fld_align': 'left',
      \ 'R_fld_align': 'left',
      \ 'L_padding'  : 1,
      \ 'R_padding'  : 1,
      \ 'g_pattern'  : '',
      \ 'v_pattern'  : '',
      \ }

let s:Aligner.extending_options = {}

function! s:class_Aligner_apply_extending_options(options) dict
  let opts = (type(a:options) == type("") ? s:Aligner._parse_options(a:options) : a:options)
  call extend(s:Aligner.extending_options, opts, 'force')
endfunction
call s:Aligner.class_bind(s:SID, 'apply_extending_options')

function! s:class_Aligner_reset_extending_options() dict
  let s:Aligner.extending_options = {}
endfunction
call s:Aligner.class_bind(s:SID, 'reset_extending_options')

function! s:Aligner_initialize(region_args, align_args, use_regexp) dict
  let self.region = call('alignta#region#new', a:region_args)
  let self.arguments = a:align_args
  let self.use_regexp = a:use_regexp
  call self.init_options()

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
  let leading_width = s:get_min_leading_width(self._lines, 1)
  let leading = alignta#string#padding(leading_width)
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
call s:Aligner.bind(s:SID, 'initialize')

function! s:Aligner_init_options() dict
  let self.options = copy(s:Aligner.DEFAULT_OPTIONS)
  call self.apply_options(alignta#get_config_variable('alignta_default_options'))
  call self.apply_options(s:Aligner.extending_options)
endfunction
call s:Aligner.bind(s:SID, 'init_options')

function! s:Aligner_apply_options(options) dict
  let opts = (type(a:options) == type("") ? self._parse_options(a:options) : a:options)
  call extend(self.options, opts, 'force')
endfunction
call s:Aligner.bind(s:SID, 'apply_options')

function! s:get_min_leading_width(lines, ...)
  let ignore_blank = (a:0 ? a:1 : 0)
  let lines = (ignore_blank ? filter(copy(a:lines), 'v:val =~ "\\S"') : copy(a:lines))
  let leadings = map(lines, 'matchstr(v:val, "^\\s*")')
  return min(map(leadings, 'strlen(v:val)'))
endfunction

function! s:Aligner_alignment_method() dict
  return (self.options.M_fld_align ==# 'none' ?  'shifting' : 'padding')
endfunction
call s:Aligner.bind(s:SID, 'alignment_method')

function! s:Aligner_align() dict
  call s:print_debug("region = " . self.region.to_s())
  call s:print_debug("arguments = " . string(self.arguments))
  call s:print_debug("_lines:", self._lines)

  if self.region.type ==# 'block' && self.region.has_tab
    call alignta#print_error("alignta: RegionError: block contains tabs")
    return
  elseif self.region.is_broken
    call alignta#print_error("alignta: RegionError: broken multi-byte character detected")
    return
  endif

  if self.region.has_tab && alignta#get_config_variable('alignta_confirm_for_retab')
    let resp = input("Region contains tabs, alignta will use :retab, OK? [y/n] ")
    if resp !~? '\s*y\%[es]\s*$'
      return
    endif
  endif

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let start_time = reltime()
  endif

  let save_vimenv = alignta#vimenv#new('.', '&ignorecase')
  set noignorecase
  " NOTE: alignta#string#width() for Vim 7.2 or older has a side effect that changes
  " the cursor's position.

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
        \ 'alignta#string#rstrip(v:val.aligned_part . self._lines[v:key])')
  call self.region.update()

  call save_vimenv.restore()

  if exists('g:alignta_profile') && g:alignta_profile && has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    echomsg "alignta: used=" . used_time . "s"
  endif
endfunction
call s:Aligner.bind(s:SID, 'align')

function! s:Aligner__parse_options(value) dict
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
      call s:print_debug("parsed options = " . string(opts))
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
      call s:print_debug("parsed options = " . string(opts))
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
      call s:print_debug("parsed options = " . string(opts))
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
      call s:print_debug("parsed options = " . string(opts))
      continue
    endif
  endfor

  return opts
endfunction
call s:Aligner.bind(s:SID, '_parse_options')
call s:Aligner.export('_parse_options')

function! s:Aligner__parse_pattern(value) dict
  let times_str = matchstr(a:value, '{\zs\(\d\+\|+\)\ze}$')
  let pattern = substitute(a:value, '{\(\d\+\|+\)}$', '', '')
  if !self.use_regexp
    let pattern = alignta#string#escape_regexp(pattern)
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
call s:Aligner.bind(s:SID, '_parse_pattern')

function! s:Aligner__align_at(pattern, times) dict
  call s:print_debug("options = " . string(self.options))
  call s:print_debug("pattern = " . string(a:pattern))

  let flds_list = self._split_to_fields(a:pattern, a:times)
  call self._join_fields(flds_list)

  call s:print_debug("aligned_parts:", map(copy(self._line_data), 'v:val.aligned_part'))
  call s:print_debug("_lines:", self._lines)
endfunction
call s:Aligner.bind(s:SID, '_align_at')

function! s:Aligner__filter_lines() dict
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
call s:Aligner.bind(s:SID, '_filter_lines')

function! s:Aligner__split_to_fields(pattern, times) dict
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
call s:Aligner.bind(s:SID, '_split_to_fields')

function! s:Aligner__join_fields(flds_list) dict
  let flds_list = a:flds_list + [{}, {}]
  call s:print_debug("flds_list = " . string(flds_list))

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
      let leading_width = s:get_min_leading_width(values(L_flds))
      let leading = alignta#string#padding(leading_width)
    endif

    "---------------------------------------
    " Left field

    if method ==# 'padding'
      call map(L_flds, 'alignta#string#strip(v:val)')
    else
      call map(L_flds, 'has_key(Last_flds, v:key)
            \ ? v:val
            \ : alignta#string#strip(v:val)
            \')
    endif

    let L_fld_width = max(values(map(copy(L_flds),
          \ 'self._line_data[v:key].aligned_width + alignta#string#width(v:val)')))

    call map(L_flds, 'has_key(Last_flds, v:key)
          \ ? alignta#string#pad(v:val,
          \     L_fld_width - self._line_data[v:key].aligned_width,
          \     self.options.R_fld_align
          \   )
          \ : alignta#string#pad(v:val,
          \     L_fld_width - self._line_data[v:key].aligned_width,
          \     self.options.L_fld_align
          \   )
          \')

    "---------------------------------------
    " Left padding

    let blank_L_flds = (len(filter(values(L_flds), 'v:val !~ "\\S"')) == len(L_flds))
    " NOTE: If all Left fields are blank, they should be ignored and the Left
    " padding should be set to 0.

    let lpad = (blank_L_flds ? "" : alignta#string#padding(self.options.L_padding))

    "---------------------------------------
    " Matched field

    if method ==# 'padding'
      let M_fld_width = max(map(values(M_flds), 'alignta#string#width(v:val)'))

      call map(M_flds, 'alignta#string#pad(v:val,
            \ M_fld_width,
            \ self.options.M_fld_align
            \ )')
    endif

    "---------------------------------------
    " Right padding

    if method ==# 'padding'
      let rpad = alignta#string#padding(self.options.R_padding)
    else
      let rpad = ""
    endif

    call s:print_debug("L_flds:", L_flds)
    call s:print_debug("M_flds:", M_flds)
    call s:print_debug("R_flds:", R_flds)

    " join fields with paddings
    for idx in keys(L_flds)
      if !has_key(Last_flds, idx)
        let aligned = leading . L_flds[idx] . lpad . M_flds[idx] . rpad
        let line_data = self._line_data[idx]
        let line_data.aligned_part .= aligned
        let line_data.aligned_width += alignta#string#width(aligned)
      else
        " last field
        " the next pattern matching will start from the beginning of it
        let self._lines[idx] = L_flds[idx]
      endif
    endfor
    let flds_idx += 2
  endwhile
endfunction
call s:Aligner.bind(s:SID, '_join_fields')

function! alignta#print_error(msg)
  echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function! s:print_debug(msg, ...)
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

function! s:sort_numbers(list)
  return sort(a:list, 's:compare_numbers')
endfunction

function! s:compare_numbers(n1, n2)
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunction

" vim: filetype=vim
