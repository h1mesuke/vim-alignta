" alignta.vim test suite

let tc = unittest#testcase#new('test_region')
let tc.context_file = expand('<sfile>:p:h') . '/test_region.dat'

"-----------------------------------------------------------------------------

function! tc.test_region_normal()
  let range = s:data_range('region')
  call self._test_region_update(range[0], range[1])
endfunction

function! tc.test_region_op_char_in_line()
  execute s:data_range('region')[0]
  normal! 0f|m[f|m]
  call self._test_region_update('char')
endfunction

function! tc.test_region_op_char_across_line()
  execute s:data_range('region')[0]
  normal! 0f|m[2jf|m]
  call self._test_region_update('char')
endfunction

function! tc.test_region_op_line()
  let range = s:data_range('region')
  execute range[0]
  execute 'normal! 0m[' . (range[1] - range[0]) . 'j$m]'
  call self._test_region_update('line')
endfunction

function! tc.test_region_op_block()
  let range = s:data_range('region_block')
  execute range[0]
  execute 'normal! 04lm[' . (range[1] - range[0]) . 'jf*2hm]'
  call self._test_region_update('block')
endfunction

function! tc.test_region_visual_char_in_line()
  execute s:data_range('region')[0]
  execute "normal! 0f|vf|\<Esc>"
  call self._test_region_update(visualmode())
endfunction

function! tc.test_region_visual_char_across_lines()
  execute s:data_range('region')[0]
  execute "normal! 0f|v2jf|\<Esc>"
  call self._test_region_update(visualmode())
endfunction

function! tc.test_region_visual_line()
  let range = s:data_range('region')
  execute range[0]
  execute 'normal! V' . (range[1] - range[0]) . "j\<Esc>"
  call self._test_region_update(visualmode())
endfunction

function! tc.test_region_visual_block()
  let range = s:data_range('region_block')
  execute range[0]
  execute "normal! 04l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  call self._test_region_update(visualmode())
endfunction

"---------------------------------------
" has_tab

function! tc.setup_region_visual_line_has_tab()
  let self.save_expandtab = &l:expandtab
  set noexpandtab
endfunction
function! tc.test_region_visual_line_has_tab()
  let range = s:data_range('region_has_tab')
  execute range[0]
  execute 'normal! V' . (range[1] - range[0]) . "j\<Esc>"
  call self._test_region_update('!', visualmode())
endfunction
function! tc.teardown_region_visual_line_has_tab()
  let &l:expandtab = self.save_expandtab
endfunction

function! tc.test_region_visual_block_has_tab()
  let range = s:data_range('region_block_has_tab')
  execute range[0]
  execute "normal! 04l\<C-v>" . (range[1] - range[0]) . "jf*2h\<Esc>"
  let region = alignta#region#new(visualmode())
  call self.puts()
  call self.puts(string(region))
  call assert#true(region.has_tab)
  " can't align blocks contain tabs
endfunction

"---------------------------------------
" is_broken

function! tc.test_region_visual_block_is_broken()
  let range = s:data_range('region_block')
  execute range[1]
  execute "normal! 04l\<C-v>" . (range[1] - range[0]) . "kf|\<Esc>"
  let region = alignta#region#new(visualmode())
  call self.puts()
  call self.puts(string(region))
  call assert#true(region.is_broken)
endfunction

"-----------------------------------------------------------------------------
" Utils

function! tc._test_region_update(...)
  let args = a:000
  if args[0] == '!'
    let has_tab = 1
    let args = args[1:]
  else
    let has_tab = 0
  endif

  let region = call('alignta#region#new', args)
  let range = region.line_range
  call self.puts()
  call self.puts(string(region))

  let expected = getline(range[0], range[1])
  call region.update()
  let value = getline(range[0], range[1])
  silent undo

  call assert#false(region.is_broken, 'is_broken')

  if has_tab
    call assert#true(region.has_tab, 'has_tab')
    call assert#not_equal_C(expected, value)
  else
    call assert#false(region.has_tab, 'has_tab')
    call assert#equal_C(expected, value)
  endif
  call self.print_lines(expected)
  call self.puts(['', '----'])
  call self.print_lines(value)
endfunction

function! s:tag_range(tag)
  call search('^# ' . a:tag . '_begin', 'w')
  let from = line('.') + 1
  call search('^# ' . a:tag . '_end', 'w')
  let to = line('.') - 1
  return [from, to]
endfunction

function! s:data_range(tag)
  return s:tag_range('test_' . a:tag . '_data')
endfunction

function! tc.print_lines(lines)
  call self.puts()
  for line in a:lines
    call self.puts(string(line))
  endfor
endfunction

unlet tc

" vim: filetype=vim
