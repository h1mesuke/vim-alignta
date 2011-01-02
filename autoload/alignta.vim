"=============================================================================
" Align Them All!
"
" File    : autoload/alignta.vim
" Author  : h1mesuke <himesuke@gmail.com>
" Updated : 2011-01-02
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

function! alignta#align(region_args, align_args, ...)
  let use_regexp = (a:0 ? a:1 : 0)
  let aligner = s:Aligner.new(a:region_args, a:align_args, use_regexp)
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

let s:Aligner = alignta#object#extend()

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

function! s:Aligner.initialize(region_args, align_args, use_regexp)
  let self.region = call('alignta#region#new', a:region_args)
  let self.arguments = a:align_args
  let self.use_regexp = a:use_regexp
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

  if self.region.type ==# 'block' && self.region.has_tab
    call s:print_error("alignta: RegionError: block contains tabs")
    return
  elseif self.region.is_broken
    call s:print_error("alignta: RegionError: broken multi-byte character detected")
    return
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

    call s:debug_echo("L_flds:", L_flds)
    call s:debug_echo("M_flds:", M_flds)
    call s:debug_echo("R_flds:", R_flds)

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

function! s:print_error(msg)
  echohl ErrorMsg
  echomsg a:msg
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

" vim: filetype=vim
