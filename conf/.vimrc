set nocompatible "去掉讨厌的有关vim一致性模式,避免以前版本的一些bug和局限.
set number "显示行号.
set background=dark "背景颜色暗色.(我觉得不错,保护眼睛.)
syntax on "语法高亮显示.(这个肯定是要的.)
filetype on "检测文件类型
set history=1024 "设置命令历史记录为50条.
set autoindent "使用自动对起，也就是把当前行的对起格式应用到下一行.
set smartindent "依据上面的对齐格式，智能的选择对起方式，对于类似C语言编写上很有用
set tabstop=4 "设置tab键为4个空格.
set shiftwidth=4 "设置当行之间交错时使用4个空格
set showmatch "设置匹配模式，类似当输入一个左括号时会匹配相应的那个右括号
set incsearch "搜索选项.(比如,键入"/bo",光标自动找到第一个"bo"所在的位置.)
set guioptions-=T  "去除vim的GUI版本中的toolbar
set ruler "在编辑过程中，在右下角显示光标位置的状态行
set whichwrap+=<,>,h,l "允许backspace和光标键跨越行边界

hi Comment ctermfg=DarkCyan "修改默认注释颜色

set backspace=2 "允许退格键删除
set mouse=a "启用鼠标
set selection=exclusive
set selectmode=mouse,key

"侦测文件类型
filetype on
"载入文件类型插件
filetype plugin on
"为特定文件类型载入相关缩进文件
filetype indent on

"设置编码自动识别, 中文引号显示
"set fileencodings=utf-8,gbk
"set encoding=euc-cn "这句会导致乱码。。。
set ambiwidth=double

"设置高亮搜索
set hlsearch

"按C语言格式缩进
set cindent
"显示括号匹配
set showmatch
"括号匹配显示时间为1(单位是十分之一秒)
set matchtime=1

"增强模式中的命令行自动完成操作
set wildmenu
"不要生成swap文件，当buffer被丢弃的时候隐藏它
setlocal noswapfile
set bufhidden=hide

"set nohls "默认情况下，寻找匹配是高亮度显示的，该设置关闭高亮显示

"是否生成一个备份文件.(备份的文件名为原文件名加“~“后缀.)
"(我不喜欢这个备份设置,一般注释掉.)
"if has(“vms”)
" set nobackup
"else
" set backup
"endif

