" Custom filetype detection.
if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
    au! BufRead,BufNewFile .latexmkrc setfiletype perl
augroup END
