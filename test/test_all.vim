" alignta.vim test suite

let here = expand('<sfile>:p:h')
execute 'source' here . '/test_region.vim'
execute 'source' here . '/test_align.vim'

" vim: filetype=vim
