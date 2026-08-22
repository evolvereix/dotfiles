" Ghostty 终端中的日常 Vim 基础配置。
set nocompatible               " 使用现代 Vim 行为，关闭旧版 vi 兼容模式。
syntax on                      " 为代码和配置文件启用语法高亮。
filetype plugin indent on      " 检测文件类型，并加载对应插件和缩进规则。

set number                     " 显示绝对行号，便于快速跳转和定位错误。
set relativenumber             " 显示相对行号，方便使用 5j、3k 等移动命令。
set cursorline                 " 高亮当前行，便于追踪光标位置。
set guicursor=n-v-c:ver25,i-ci-ve:ver25,r-cr:hor20,o:hor50 " 普通和插入模式都使用类似 VS Code 的竖线光标。
set ruler                      " 在命令区域显示当前光标位置。
set showcmd                    " 显示尚未输入完成的普通模式命令。
set wildmenu                   " 为命令和路径补全显示简洁的候选菜单。

set expandtab                  " 按下 Tab 时插入空格。
set tabstop=2                  " 将制表符显示为 2 列宽度。
set shiftwidth=2               " 自动缩进及 >>、<< 操作使用 2 个空格。
set softtabstop=2              " 让 Tab 和退格键按照 2 个空格的缩进宽度操作。
set smartindent                " 为常见代码块应用基础智能缩进。

set ignorecase                 " 默认搜索时忽略大小写。
set smartcase                  " 搜索内容包含大写字母时自动区分大小写。
set incsearch                  " 输入搜索内容时即时显示匹配结果。
set hlsearch                   " 搜索后高亮所有匹配结果。

set hidden                     " 允许在不保存当前修改的情况下切换缓冲区。
set backspace=indent,eol,start " 允许退格键自然跨越缩进、行尾和插入起点。
set mouse=a                    " 在 Ghostty 中为所有模式启用鼠标支持。

if has('clipboard')            " 仅在当前 Vim 支持剪贴板时配置系统剪贴板集成。
  set clipboard=unnamed        " 让复制、删除、修改和粘贴操作默认使用系统剪贴板。
endif                          " 结束剪贴板功能检查。

set undofile                   " 关闭并重新打开文件后仍保留撤销历史。
set undodir=~/.vim/undo        " 将持久化撤销文件存放到独立的 Vim 目录。

if has('termguicolors')        " 仅在当前 Vim 支持真彩色时启用该功能。
  set termguicolors            " 使用 Ghostty 的 24 位色彩能力改善主题和高亮效果。
endif                          " 结束真彩色功能检查。

set background=dark            " 告知 Vim 当前使用暗色终端背景。

" 加载官方 Nord 配色方案
colorscheme nord

" 让主要编辑区域使用终端背景，切换 Ghostty 暗色主题时自然融合。
highlight Normal      guibg=NONE ctermbg=NONE
highlight LineNr      guibg=NONE ctermbg=NONE
highlight SignColumn  guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" 使用类似 VS Code 的中性灰色背景标记当前行。
highlight clear CursorLine
highlight CursorLine guibg=#363A43 gui=NONE cterm=NONE
highlight clear CursorLineNr
highlight CursorLineNr guifg=#ECEFF4 guibg=#363A43 gui=bold cterm=bold

" 隐藏文件内容结束后空白行左侧显示的波浪号。
set fillchars+=eob:\ 
