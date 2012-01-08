" alignta's test suite

let s:here = expand('<sfile>:p:h')
execute 'source' s:here . '/test_pad_align.vim'
execute 'source' s:here . '/test_pad_align_block.vim'
execute 'source' s:here . '/test_shift_align.vim'
execute 'source' s:here . '/test_options.vim'

execute 'source' s:here . '/test_practice.vim'
