try
  source $LOCAL_ADMIN_SCRIPTS/master.vimrc
catch
endtry

let mapleader="\<space>"

set colorcolumn=80
syntax on

map Y y$

set expandtab
set nobackup
set noswapfile
set hidden
set history=200
set spelllang=en_us

set incsearch
set hlsearch
noremap <BS> :noh<CR>

set wildmode=longest,list,full
set wildmenu
set wildignore+=*.pyc,*.so,*.swp,.git

set noerrorbells 
set novisualbell

colors desert

