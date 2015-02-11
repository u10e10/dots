"Make the make file
command! Makemf  call system("makemf " . expand("%:r"))
command! Makemf2 call system("makemf2 " . expand("%"))

command! MakefileCP call system("cp .Makefile_" . expand("%:r") . " makefile")

command! Make  !make --no-print-directory
command! SaveMake write|Make

autocmd FileType c,cpp,ruby Makemf2

autocmd FileType c,cpp,ruby inoremap <F5> <C-O>:SaveMake<CR>
autocmd FileType c,cpp,ruby  noremap <F5> :SaveMake<CR>

autocmd FileType c,cpp,ruby autocmd VimEnter * MakefileCP
autocmd FileType c,cpp,ruby autocmd VimLeavePre * call system("rm makefile")

autocmd FileType ruby set tabstop=2
autocmd FileType ruby set softtabstop=2
autocmd FileType ruby set shiftwidth=2

autocmd FileType c,cpp set cindent
autocmd FileType c,cpp inoremap {<CR> {<CR>}<C-O>O
"autocmd FileType c,cpp inoremap { {}<LEFT>
"autocmd FileType c,cpp inoremap " ""<LEFT>
"autocmd FileType c,cpp inoremap ( ()<LEFT>
