call plug#begin('~/.config/nvim/plugged')
"# ranger的nvim插件，文件浏览
Plug 'kevinhwang91/rnvimr', {'do': 'make sysc'}
Plug 'majutsushi/tagbar', { 'on': 'TagbarOpenAutoClose' }
nmap <silent> <F4> :TagbarToggle<CR>  
let g:tagbar_ctags_bin = 'ctags'  
let g:tagbar_width = 25

"# 代码智能补全
"# 如果使用python，最好选择mpls，若选择jedi，会导致一个变量后的方法名无法补全
" Python
Plug 'tmhedberg/SimpylFold', { 'for' :['python', 'vim-plug'] }
Plug 'Vimjas/vim-python-pep8-indent', { 'for' :['python', 'vim-plug'] }
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
Plug 'vim-scripts/indentpython.vim', { 'for' :['python', 'vim-plug'] }
Plug 'plytophogy/vim-virtualenv', { 'for' :['python', 'vim-plug'] }
Plug 'tweekmonster/braceless.vim', { 'for' :['python', 'vim-plug'] }
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-jedi'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-match-highlight'

let g:python3_host_prog='/usr/bin/python3'

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" 指定 Python 版本
let g:ncm2_jedi#python_version = 3

let g:ncm2#match_highlight = 'sans-serif'

"# 自己的代码片段
Plug 'SirVer/ultisnips'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'itchyny/vim-cursorword'
Plug 'vim-scripts/indentpython.vim'

"# markdown预览
"Plug 'iamcco/markdown-preview.nvim', {'do': 'cd app & yarn install'}

"# 彩虹括号
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

"文件树
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" 文件树设置 {{{
" 自动打开 nerdtree
" autocmd vimenter * NERDTree
" 关闭NERDTree快捷键
map <C-t> :NERDTreeToggle<CR>
""当NERDTree为剩下的唯一窗口时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

""修改树的显示图标
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeAutoCenter=1
" 显示行号
let NERDTreeShowLineNumbers=1
" 是否显示隐藏文件
let NERDTreeShowHidden=1
" 设置宽度
let NERDTreeWinSize=25
" 在终端启动vim时，共享NERDTree
let g:nerdtree_tabs_open_on_console_startup=1
" 忽略一下文件的显示
let NERDTreeIgnore=['\.pyc','\~$','\.swp']
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }
" }}}

" 注释
Plug 'scrooloose/nerdcommenter'
map <C-/> NERDCommenterToggle
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

call plug#end()

"============================================================================
set number
syntax on
" set mouse=a
set encoding=utf-8
set t_Co=256
filetype indent on
set autoindent
set tabstop=4
set ts=4
set expandtab
set softtabstop=4
set cursorline
set linebreak
set showmatch
set hlsearch
set helplang=cn
set wildmenu
set foldenable

" ======================================== 设置状态栏格式(begin) ========================================
set statusline=%1*\%<%.50F\                                     "显示文件名和文件路径
set statusline+=%=%2*\%y%m%r%h%w\ %*                            "显示文件类型及文件状态
set statusline+=%3*\%{&ff}\[%{&fenc}]\ %*                       "显示文件编码类型
set statusline+=%4*\ row:%l/%L,col:%c\ %*                       "显示光标所在行和列
set statusline+=%5*\%3p%%\%*                                    "显示光标前文本所占总文本的比例
hi User1 cterm=none ctermfg=25 ctermbg=0
hi User2 cterm=none ctermfg=208 ctermbg=0
hi User3 cterm=none ctermfg=169 ctermbg=0
hi User4 cterm=none ctermfg=100 ctermbg=0
hi User5 cterm=none ctermfg=green ctermbg=0
" ======================================== 设置状态栏格式(end) ========================================
