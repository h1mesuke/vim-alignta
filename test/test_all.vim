" alignta's test suite

let here = expand('<sfile>:p:h')
execute 'source' here . '/test_pad_align.vim'
execute 'source' here . '/test_pad_align_mb.vim'
execute 'source' here . '/test_shift_align.vim'
execute 'source' here . '/test_misc.vim'

" vim: filetype=vim
