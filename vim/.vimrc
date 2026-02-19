" Syntax and display
syntax on
set number
set relativenumber
set cursorline
set showmatch
set signcolumn=yes

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap <Esc><Esc> :nohlsearch<CR>

" Indentation
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smartindent
set autoindent

" 2-space indent for web languages
autocmd FileType javascript,typescript,typescriptreact,javascriptreact,html,css,scss,json,yaml,vue setlocal tabstop=2 shiftwidth=2 softtabstop=2

" Persistent undo
set undofile
set undodir=~/.vim/undodir
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif

" No swap/backup
set noswapfile
set nobackup
set nowritebackup

" Split navigation with C-hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Splits open below/right
set splitbelow
set splitright

" Mouse
set mouse=a

" Clipboard
set clipboard=unnamedplus

" Scrolling
set scrolloff=8

" Backspace
set backspace=indent,eol,start

" File handling
set encoding=utf-8
set hidden
set autoread

" Status line
set laststatus=2
set statusline=\ %f\ %m%r%h%w\ %=%y\ [%l:%c]\ %p%%\
