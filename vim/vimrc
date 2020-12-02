"""""""""""""""" Vundle settings
" required
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'tablify'
Plugin 'luochen1990/rainbow'
Plugin 'rakr/vim-one'
Plugin 'pboettch/vim-cmake-syntax'

call vundle#end()
filetype plugin indent on " required

"""""""""""""""" plugins settings

set t_Co=256 " 256 color for xshell, same effect with: export TERM=xterm-256color
let g:airline_powerline_fonts = 1 " enable powerline fonts
let g:airline_theme = 'one' " airline theme
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_alt_sep = ''
let g:airline#extensions#tabline#enabled = 1 " airline with tab on head
let g:rainbow_active = 1 " enable rainbow, 0 if you want to enable it later via :RainbowToggle

let g:rainbow_conf = {
\   'separately': {
\       'cmake': 0,
\   }
\}

"""""""""""""""" Other settings

if has("termguicolors")
    " fix bug for vim, ^[ is character of Ctrl-v ESC
    set t_8f=[38;2;%lu;%lu;%lum
    set t_8b=[48;2;%lu;%lu;%lum

    " enable true color
    set termguicolors
endif

set hidden " allow switch buffer if unsaved
set nowrap " no wrap
set nowrapscan " no wrap search
set hlsearch " highlight search
set incsearch " highlight characters on typing when searching
set scrolloff=16 " lines about cursor margin top and margin bottom
syntax on " highlight syntax
set ffs=unix " CR dispaly as ^M
colorscheme one " color scheme
set background=dark
" hi Normal guibg=NONE ctermbg=NONE " background transparent

" inherit indent style
" execute 'set paste' on pasting, and execute 'set nopaste' after pasting
" Or shortcut key for paste mode
set autoindent

" defaut tabs settings
set expandtab tabstop=4 softtabstop=4 shiftwidth=4

"""""""""""""""" file type

" enable filetype detection:
filetype on
filetype plugin on
filetype indent on " file type based indentation

autocmd FileType make set noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType yaml set expandtab shiftwidth=2 softtabstop=2 tabstop=2

"""""""""""""""" key map

set pastetoggle=<C-p> " paste mode

" Esc shortcut
inoremap jk <Esc>

" switch to previous vim buffer
nnoremap th :bp<cr>

" switch to next vim buffer
nnoremap tl :bn<cr>

" close current vim buffer
nnoremap tx :bd<cr>

" convert tab to spaces immediately
nnoremap <Tab><Space> :set expandtab<cr>:retab<cr>

" remove tailing spaces
nnoremap t<Space> :%s/\s\+$//<cr>:let @/=''<cr>

