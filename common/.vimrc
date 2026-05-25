" 通用 Vim 配置

" 基础设置
set nocompatible              " 不兼容 vi
set number                    " 显示行号
set relativenumber            " 相对行号
set cursorline                " 高亮当前行
set showcmd                   " 显示命令
set wildmenu                  " 命令行补全

" 缩进设置
set tabstop=4                 " Tab 宽度
set shiftwidth=4              " 缩进宽度
set expandtab                 " 使用空格代替 Tab
set autoindent                " 自动缩进
set smartindent               " 智能缩进

" 搜索设置
set hlsearch                  " 高亮搜索结果
set incsearch                 " 增量搜索
set ignorecase                " 忽略大小写
set smartcase                 " 智能大小写

" 编码设置
set encoding=utf-8
set fileencoding=utf-8

" 外观设置
syntax on                     " 语法高亮
set background=dark           " 深色背景

" 其他设置
set mouse=a                   " 启用鼠标

" Linux 剪贴板支持（检测 xclip/xsel）
if has('clipboard') && has('unix') && !has('gui_running')
  if executable('xclip') || executable('xsel')
    set clipboard=unnamedplus
  endif
endif

set backspace=indent,eol,start " 退格键行为

" === 光标形状（DECSCUSR 标准，现代终端通用） ===
" normal=1(竖线), insert=2(块), replace=3(下划线)
let &t_SI = "\<Esc>[2 q"
let &t_SR = "\<Esc>[3 q"
let &t_EI = "\<Esc>[1 q"

" === 折叠（按缩进自动折叠） ===
set foldmethod=indent
set foldlevel=99

" === 不自动换行 ===
set wrap
set tw=0
set indentexpr=
