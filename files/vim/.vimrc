" Vim configuration (Vim 8+/9+)
" Canonical source: files/vim/.vimrc
" Local overrides: ~/.vim/plugin/rc.vim
" Leader is comma; most custom shortcuts work in Normal mode only.
" Note: run :set paste before terminal pastes if bracketed paste is unavailable.

" DO NOT MAKE CHANGES TO THIS FILE =================================
" Instead, place custom changes in $HOME/.vim/plugin/rc.vim

" GLOBAL SETTINGS ==================================================
set nocompatible
syntax on
filetype on

let mapleader=","
" Leader-prefixed shortcuts are Normal-mode-only unless specified otherwise.
set path+=$VIMRUNTIME
set laststatus=2 cmdheight=2 mousehide wrap number nofoldenable
set ai nocindent ignorecase expandtab incsearch hlsearch
set tabstop=4 shiftwidth=4 previewheight=24 formatoptions=l backspace=indent,eol,start
set splitright nosplitbelow noequalalways linebreak showbreak=\ \ \
set sessionoptions+=winpos,resize
set statusline=%<%f%h%w%m%r%=%l\ of\ %L\ col\ %c%V,\ char\ %o\ %P\ x%B
set encoding=utf-8
set cpo-=<
set background=light
set guioptions+=b
set guioptions-=T
set printoptions=header:0
set mps+=<:>
set viminfo='50,n$HOME/.vim/.viminfo
set fileformats=unix,dos,mac
set backup
set writebackup
set backupdir=$HOME/.vim/save//
set directory=$HOME/.vim/swp//
set undodir=$HOME/.vim/undo//
if isdirectory(expand('~/.vim/undo'))
   set undofile
endif
set patchmode=.save
set cursorline
set t_Co=256
set timeout
set timeoutlen=500
" Preserve Vim bracketed paste support; do not disable t_BE.
" Retain original preference: do not switch terminal alternate-screen mode.
set t_ti=
set t_te=
let c_minlines=400
let savevers_dirs=&backupdir
let g:showmarks_hlline_upper=1
let g:showmarks_include="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let g:MultipleSearchColorSequence="#ffff33,#99ff99,#aaffff,#ccccff,#ffcccc"
let g:MultipleSearchTextColorSequence="#000000,#000000,#000000,#000000,#000000"
let g:MultipleSearchMaxColors=5
let g:bufExplorerSortBy='name'
let g:bufExplorerShowRelativePath=1

colorscheme summerfruit256
hi MyGroup ctermfg=0 ctermbg=219 guifg=#000000 guibg=#ffafff
hi ColorColumn ctermbg=255 guibg=#eeeeee

hi DiffAdd     term=bold ctermfg=16  ctermbg=193 guifg=#000000 guibg=#d7ffaf
hi DiffChange  term=bold ctermfg=16  ctermbg=254 guifg=#000000 guibg=#e4e4e4
hi DiffText    term=bold ctermfg=16  ctermbg=222 guifg=#000000 guibg=#ffd787
hi DiffDelete  term=bold ctermfg=225 ctermbg=225 guifg=#ffd7ff guibg=#ffd7ff

" Rebuild only our matchadd() highlights; preserve third-party matches.
fu! RefreshEggHighlighting()
   for l:match in getmatches()
      if get(l:match, 'group', '') =~# '^bashg'
         silent! call matchdelete(l:match.id)
      endif
   endfor
   let P_Name=':[a-zA-Z0-9\.-]\+'
   let P_Dir_Name='\(' . P_Name . '\|' . ':[a-zA-Z0-9\.-]\+/[a-zA-Z0-9\.-]\+' . '\)'
   let P_RE='\(' . '@\?' . '\|' . P_Name . '\|' . '@' . P_Name . '\)'
   let P_Dir_RE='\(' . '@\?' . '\|' . P_Dir_Name . '\|' . '@' . P_Dir_Name . '\)'

   let C_Name=':[%a-zA-Z][%a-zA-Z0-9_\.-]*'
   let C_RE='\(' . '+\?' . '\(' . P_Name . '\)\?' . '\(' . C_Name . '\)\?' . '\)'
   let C_Dir_RE='\(' . '+\?' . '\(' . P_Dir_Name . '\)\?' . '\(' . C_Name . '\)\?' . '\)'

   let U_Name=':[%a-zA-Z][%a-zA-Z0-9_\.-]*'
   let U_RE='\(' . '\(' . U_Name . '\)\?' . '\|' . '\(' . '-' . '\|' . '-\?' . C_Name . '\)' . U_Name . '\)'

   let FunctionRE='\.\{0,2}\([a-zA-Z_:%=-][a-zA-Z0-9_,:%.+-]*\)\?'
   let FunctionAsVarRE='\(_[a-zA-Z0-9_]*\(\[[^]]*\]\)\?\)'

   let P_Variable='(@' . P_RE . ')' . FunctionAsVarRE
   let P_Function_Decl='^@\s\+' . FunctionRE . '\s*(\s*)'
   let P_Function_Ref='(@' . P_RE . ')::\?' . FunctionRE
   let P_Directory='(@' . '\(' . P_Dir_RE .'\)' . ')/'

   let C_Variable='(+' . C_RE . ')' . FunctionAsVarRE
   let C_Function_Decl='^+\s\+' . FunctionRE . '\s*(\s*)'
   let C_Function_Ref='(+' . C_RE . ')::\?' . FunctionRE
   let C_Directory='(+' . '\(' . C_Dir_RE .'\)' . ')/'

   let U_Variable='(-' . U_RE . ')' . FunctionAsVarRE
   let U_Function_Decl='^-\s\+' . FunctionRE . '\s*(\s*)'
   let U_Function_Ref='(-' . U_RE . ')::\?' . FunctionRE
   let U_Directory='(-' . '\(' . U_RE .'\)' . ')/'

   let F_Variable='(\.)' . FunctionAsVarRE

   let E_AndOr='\((||)\|(&&)\)'
   let E_Closure='\(({[^)]*)\|(})\)'
   let E_Token='\((%[^%]\+%)\)'

   " Highlighting for in-use BashG macros
   call matchadd('bashgAndOr', E_AndOr, -1)
   call matchadd('bashgClosure', E_Closure, -1)
   call matchadd('bashgToken', E_Token, -1)

   call matchadd('bashgPackageFunctionDecl', P_Function_Decl, -1)
   call matchadd('bashgPackageFunction', '(@' . P_RE . ')', -1)
   call matchadd('bashgPackageFunction', P_Function_Ref, -1)
   call matchadd('bashgPackageDirectory', P_Directory, -1)
   call matchadd('bashgPackageVariable', P_Variable, -1)

   call matchadd('bashgComponentFunctionDecl', C_Function_Decl, -1)
   call matchadd('bashgComponentFunction', C_Function_Ref, -1)
   call matchadd('bashgComponentDirectory', C_Directory, -1)
   call matchadd('bashgComponentVariable', C_Variable, -1)

   call matchadd('bashgUnitFunctionDecl', U_Function_Decl, -1)
   call matchadd('bashgUnitFunction', U_Function_Ref, -1)
   call matchadd('bashgUnitDirectory', U_Directory, -1)
   call matchadd('bashgUnitVariable', U_Variable, -1)

   call matchadd('bashgFunctionVariable', F_Variable, -1)

   " Escaped highlighting for BashG macros
   call matchadd('bashgEscaped','^\\' . '@\s\+' . FunctionRE . '\s*(\s*)', -1)
   call matchadd('bashgEscaped','\\' . '(@' . P_RE . ')', -1)
   call matchadd('bashgEscaped','\\' . P_Function_Ref, -1)
   call matchadd('bashgEscaped','\\' . P_Directory, -1)
   call matchadd('bashgEscaped','\\' . P_Variable, -1)

   call matchadd('bashgEscaped','^\\' . '+\s\+' . FunctionRE . '\s*(\s*)', -1)
   call matchadd('bashgEscaped','\\' . C_Function_Ref, -1)
   call matchadd('bashgEscaped','\\' . C_Directory, -1)
   call matchadd('bashgEscaped','\\' . C_Variable, -1)

   call matchadd('bashgEscaped','^\\' . '-\s\+' . FunctionRE . '\s*(\s*)', -1)
   call matchadd('bashgEscaped','\\' . U_Function_Ref, -1)
   call matchadd('bashgEscaped','\\' . U_Directory, -1)
   call matchadd('bashgEscaped','\\' . U_Variable, -1)

   call matchadd('bashgEscaped','\\' . F_Variable, -1)

   call matchadd('bashgEscaped','\\' . E_AndOr, -1)
   call matchadd('bashgEscaped','\\' . E_Closure, -1)
   call matchadd('bashgEscaped','\\' . E_Token, -1)

   " Comments
   call matchadd('bashgComment','^\s*\zs#.*$', -1)
   call matchadd('bashgComment','^\s\zs#.*$', -1)

endfunc

" Fonts
fu! FontBigger()
    try
        throw string(g:current_font_size)
    catch /^6/
        se guifont=Lucida\ Console\ Semi-Condensed\ 8
        let g:current_font_size=8
    catch /^8/
        se guifont=Lucida\ Console\ Semi-Condensed\ 9
        let g:current_font_size=9
    catch /^9/
        se guifont=Lucida\ Console\ Semi-Condensed\ 10
        let g:current_font_size=10
    catch /^10/
        se guifont=Lucida\ Console\ Semi-Condensed\ 11
        let g:current_font_size=11
    catch /^11/
        se guifont=Lucida\ Console\ Semi-Condensed\ 12
        let g:current_font_size=12
    catch /^12/
        se guifont=Lucida\ Console\ Semi-Condensed\ 14
        let g:current_font_size=14
    catch /^14/
        se guifont=Lucida\ Console\ Semi-Condensed\ 16
        let g:current_font_size=16
    catch /^16/
        se guifont=Lucida\ Console\ Semi-Condensed\ 18
        let g:current_font_size=18
    catch /^18/
        se guifont=Lucida\ Console\ Semi-Condensed\ 24
        let g:current_font_size=24
    catch /^24/
        se guifont=Lucida\ Console\ Semi-Condensed\ 36
        let g:current_font_size=36
    catch /^36/
        se guifont=Lucida\ Console\ Semi-Condensed\ 48
        let g:current_font_size=48
    catch /^48/
        se guifont=Lucida\ Console\ Semi-Condensed\ 72
        let g:current_font_size=72
    catch /.*/
    endtry
endfunc

fu! FontSmaller()
    try
        throw string(g:current_font_size)
    catch /^72/
        se guifont=Lucida\ Console\ Semi-Condensed\ 48
        let g:current_font_size=48
    catch /^48/
        se guifont=Lucida\ Console\ Semi-Condensed\ 36
        let g:current_font_size=36
    catch /^36/
        se guifont=Lucida\ Console\ Semi-Condensed\ 24
        let g:current_font_size=24
    catch /^24/
        se guifont=Lucida\ Console\ Semi-Condensed\ 18
        let g:current_font_size=18
    catch /^18/
        se guifont=Lucida\ Console\ Semi-Condensed\ 16
        let g:current_font_size=16
    catch /^16/
        se guifont=Lucida\ Console\ Semi-Condensed\ 14
        let g:current_font_size=14
    catch /^14/
        se guifont=Lucida\ Console\ Semi-Condensed\ 12
        let g:current_font_size=12
    catch /^12/
        se guifont=Lucida\ Console\ Semi-Condensed\ 11
        let g:current_font_size=11
    catch /^11/
        se guifont=Lucida\ Console\ Semi-Condensed\ 10
        let g:current_font_size=10
    catch /^10/
        se guifont=Lucida\ Console\ Semi-Condensed\ 9
        let g:current_font_size=9
    catch /^9/
        se guifont=Lucida\ Console\ Semi-Condensed\ 8
        let g:current_font_size=8
    catch /^8/
        se guifont=Lucida\ Console\ Semi-Condensed\ 6
        let g:current_font_size=6
    catch /.*/
    endtry
endfunc

let g:current_font_size=12
" GUI font changes are not meaningful in a terminal Vim session.
if has('gui_running')
   let g:current_font_size=11
   call FontBigger()
endif

" Toggle word wrapping
let g:wrap_state = 1
set wrap
fu! ToggleWrap()
   let g:wrap_state = !g:wrap_state
   execute 'windo set ' . (g:wrap_state ? 'wrap' : 'nowrap')
endfunc
nnoremap <silent> <leader>w :call ToggleWrap()<CR>

" Formatting
let g:format_state=2
fu! SetFormatMapping()
   let l:width = [80, 90, 100][g:format_state]
   execute "nnoremap <silent> <leader>f !'efmt -w" . l:width . '<CR>'
endfunc
fu! ToggleFormat()
   let g:format_state = (g:format_state + 1) % 3
   call SetFormatMapping()
   echo 'Formatting now wraps at ' . [80, 90, 100][g:format_state]
endfunc
nnoremap <silent> <leader>F :call ToggleFormat()<CR>
call SetFormatMapping()

" Toggle Remove Trailing Spaces on Save
let g:remove_trailing_spaces_state=1
fu! ToggleRemoveTrailingSpaces()
   if g:remove_trailing_spaces_state == 0
      let g:remove_trailing_spaces_state=1
      echo "Removing trailing spaces"
   else
      let g:remove_trailing_spaces_state=0
      echo "Not removing trailing spaces"
   endif
endfunc
nnoremap <silent> <leader>s :call ToggleRemoveTrailingSpaces()<CR>

fu! RemoveTrailingSpaces()
   if !g:remove_trailing_spaces_state || &l:filetype ==# 'markdown'
      return
   endif
   let l:view = winsaveview()
   let l:search = @/
   try
      silent! keeppatterns %s/\s\+$//e
   finally
      let @/ = l:search
      call winrestview(l:view)
   endtry
endfunc

" Toggle what happens when you press the ENTER key (selection)
fu! ToggleKeywordIsPropertyState()
    if g:next_keyword_is_property_state == 0
        set iskeyword=@,48-57,_,192-255
        let g:next_keyword_is_property_state=1
        echo "ENTER key selects: Standard characters only"
    elseif g:next_keyword_is_property_state == 1
        set iskeyword=@,47-57,_,192-255,.
        let g:next_keyword_is_property_state=2
        echo "ENTER key now also selects dotted properties"
    else
        set iskeyword=@,47-57,_,192-255,@-@,+,-,.,(,),:
        let g:next_keyword_is_property_state=0
        echo "ENTER key now also selects extended function and variable set"
    endif
endfunc
set iskeyword=@,48-57,_,192-255
let g:next_keyword_is_property_state=1

let g:highlightword = 1
fu! ToggleHighlightWord()
   if g:highlightword == 0
      let g:highlightword = 1
      echo "Full word only highlighting"
   else
      let g:highlightword = 0
      echo "Partial word highlighting"
   endif
endfunc

let g:highlighting = 0
function! Highlighting()
  if g:highlightword == 1
     if g:highlighting == 1 && @/ =~ '^\\<'.expand('<cword>').'\\>$'
       let g:highlighting = 0
       return ":silent nohlsearch\<CR>"
     endif
  else
     if g:highlighting == 1 && @/ =~ '^'.expand('<cword>').'$'
       let g:highlighting = 0
       return ":silent nohlsearch\<CR>"
     endif
  endif

  if g:highlightword == 1
     let @/ = '\<'.expand('<cword>').'\>'
   else
     let @/ = expand('<cword>')
   endif
  let g:highlighting = 1
  return ":silent set hlsearch\<CR>yiw"
endfunction

function! EnableHighlighting()
   nnoremap <silent> <expr> <CR> Highlighting()
endfunction

function! DisableHighlighting()
   silent! nunmap <CR>
endfunction

call EnableHighlighting()
" Cmdwin autocommands are registered in the ManageVimConfig augroup below.

" Toggle line numbering
fu! ToggleNumbering()
    if g:numbering_state == 0
        let g:numbering_state=1
        set nu foldcolumn=4
        ShowMarksToggle
    else
        let g:numbering_state=0
        set nonu foldcolumn=0
        ShowMarksToggle
    endif
endfunc
let g:numbering_state=1

" Toggle fold visibility
fu! ToggleFold()
   if (&foldenable)
      set nofoldenable
      set foldcolumn=0
   else
      set foldenable
      set foldmethod=indent
      set foldnestmax=9
      let javaScript_fold=1         " JavaScript
      let perl_fold=1               " Perl
      let php_folding=1             " PHP
      let r_syntax_folding=1        " R
      let ruby_fold=1               " Ruby
      let sh_fold_enabled=1         " sh
      let vimsyn_folding='af'       " Vim script
      let xml_syntax_folding=1      " XML
      set foldcolumn=4
   endif
endfunc

" Toggle displaying of errors
fu! ToggleDisplayErrors()
    if g:display_error_state
        hi link postscrError Normal
        hi link postscrHexString Normal
        hi link htmlError Normal
        hi link shDerefWordError Normal
        hi! link Error Normal
    else
        hi link postscrError Error
        hi link postscrHexString postscrString
        hi link htmlError Error
        hi link shDerefWordError Error
        hi! link Error NONE
    endif
    let g:display_error_state = ! g:display_error_state
endfunc
let g:display_error_state = 1
call ToggleDisplayErrors()

"###################################################
"# Highlight Column Positions for Comment Aligning #
"###################################################
fu! ToggleColorColumns()
   if !exists('w:display_color_columns')
      let w:display_color_columns = 0
      let w:display_color_column_set = "58,118"
   endif

   if w:display_color_columns
      set colorcolumn=
      let w:display_color_column_set = "58,118"
      let w:display_color_columns = 0
   else
      let w:display_color_column_set = "58,118"
      let &colorcolumn = w:display_color_column_set
      let w:display_color_columns = 1
   endif
endfunc

fu! ToggleColorColumnSet()
   if w:display_color_column_set == "58,118"
      let w:display_color_column_set = "58,67,118"
   elseif w:display_color_column_set == "58,67,118"
      let w:display_color_column_set = "58,76,118"
   elseif w:display_color_column_set == "58,76,118"
      let w:display_color_column_set = "58,85,118"
   elseif w:display_color_column_set == "58,85,118"
      let w:display_color_column_set = "58,94,118"
   elseif w:display_color_column_set == "58,94,118"
      let w:display_color_column_set = "58,103,118"
   else
      let w:display_color_column_set = "58,118"
   endif

   let &colorcolumn = w:display_color_column_set
   let w:display_color_columns = 1
endfunc

nnoremap <silent> <F11> :call ToggleColorColumns()<CR>
nnoremap <silent> <S-F11> :call ToggleColorColumnSet()<CR>

nnoremap <silent> <leader>/ :call <SID>SearchMode()<CR>
function s:SearchMode()
  if !exists('s:searchmode') || s:searchmode == 0
    echo 'Search next: scroll hit to middle if not on same page'
    nnoremap <silent> n n:call <SID>MaybeMiddle()<CR>
    nnoremap <silent> N N:call <SID>MaybeMiddle()<CR>
    let s:searchmode = 1
  elseif s:searchmode == 1
    echo 'Search next: scroll hit to middle'
    nnoremap n nzz
    nnoremap N Nzz
    let s:searchmode = 2
  else
    echo 'Search next: normal'
    nunmap n
    nunmap N
    let s:searchmode = 0
  endif
endfunction

" If cursor is in first or last line of window, scroll to middle line.
function s:MaybeMiddle()
  if winline() == 1 || winline() == winheight(0)
    normal! zz
  endif
endfunction

fu! SetBufWinEnter()
   let w:display_color_column_set = get(w:, 'display_color_column_set', '58,118')
   let l:extensions = ['sh', 'java', 'groovy', 'gradle', 'properties']
   let w:display_color_columns = index(l:extensions, expand('%:e')) >= 0
   let &l:colorcolumn = w:display_color_columns ? w:display_color_column_set : ''
endfunc

" Buffer autocommand is registered in the ManageVimConfig augroup below.

nnoremap <silent> <leader>* yiw:match MyGroup /<c-r>"/<CR>

" Decrease fold level
nnoremap <silent> <leader>< zm
" Increase fold level
nnoremap <silent> <leader>> zr

" Function key mappings
" Highlighting
nnoremap <silent> <f1> :noh<cr>:match<cr>
nnoremap <silent> <leader>eh :noh<CR>:match<CR>:call RefreshEggHighlighting()<CR>
nnoremap <silent> <S-f1> :call ToggleDisplayErrors()<CR>
" Folds: f2=enabled/disabled, f3=open/close
nnoremap <silent> <f2> :call ToggleFold()<CR>
nnoremap <silent> <f3> zA
" Show version differences for a file (left: current, right: history)
" Use numeric + and numeric - to scroll through history
nnoremap <silent> <f4> :call ToggleVersDiff()<cr>
nnoremap <silent> <S-f4> :call EndVersDiff()<cr>
nnoremap <silent> <f6> :call ToggleKeywordIsPropertyState()<CR>
nnoremap <silent> <S-f6> :call ToggleHighlightWord()<CR>
nnoremap <silent> <f7> :cd %:h<CR>
nnoremap <silent> <f8> :call FontBigger()<CR>:echo "Font size: " . g:current_font_size<CR>
nnoremap <silent> <s-f8> :call FontSmaller()<CR>:echo "Font size: " . g:current_font_size<CR>
nnoremap <silent> <f9> :call ZoomWin()<CR>
nnoremap <silent> <f10> :call ToggleNumbering()<CR>
" Save/Restore the session
nnoremap <silent> <f12> :mksession! $HOME/.vim/vimsession.vim<CR>
nnoremap <silent> <s-f12> :so $HOME/.vim/vimsession.vim<CR>

" ===== Miscellaneous =====
" Goto file under cursor
nnoremap <silent> <leader>g <C-W><C-F>

" Search for next log entry
nnoremap <silent> <leader>l /^\[[^]]*\]<CR>

" Search for BashG token
nnoremap <silent> <leader>k /%{[^}]*}%<cr>

" Read a template into the current buffer
nnoremap <silent> <leader>T :.-1r $VIM/template/
nnoremap <silent> <leader>t :r $VIM/template/

" Open Buffer Explorer: easily navigate between buffers
nnoremap <silent> <leader>x :BufExplorer<CR>

" Yank to end of line
nnoremap <silent> Y y$

" Replay macro a (Record a macro: qa ... q, then replay with <C-A>)
nnoremap <silent> <C-A> @a

" Move to the previous/next file
nnoremap <silent> <C-P> :N<cr>
nnoremap <silent> <C-N> :n<cr>

" ===== Copy, Delete, and Paste =====
" Move 'a to top
nnoremap <silent> <leader>a 'az<CR>
" Mark the end of a block
nnoremap <silent> <leader>e me
" Copy to the mark
nnoremap <silent> <leader>c "ay'e
" Copy and Remove content to the mark
nnoremap <silent> <leader>r "ay'ed'e
" Put copied content below cursor line
nnoremap <silent> <leader>p "ap
nnoremap <silent> <leader>v "ap
" Put coopied content above cursor line
nnoremap <silent> <leader>P "aP
nnoremap <silent> <leader>V "aP
" Remove JSON annotations
nnoremap <silent> <leader>J 1G!Gsed '/^ *\(\#\\|$\)/d'<CR>
nnoremap <silent> <leader>j 1G!Gsed '/^ *\(\#\\|$\)/d'\|jq --indent 3 -r .<CR>
nnoremap <silent> <leader>S 1G!Gsed '/^ *\(\#\\|$\)/d'\|jq --indent 3 -rS .<CR>
" Remove trailing spaces on save

" Resizing Windows
nnoremap <silent> <M-Left> <C-W><
nnoremap <silent> <M-Up> <C-W>+
nnoremap <silent> <M-Down> <C-W>-
nnoremap <silent> <M-Right> <C-W>>

" Split the current window, opening a new window in the direction indicated
nnoremap <silent> <C-S-Right> :vnew<CR>
nnoremap <silent> <C-S-Left> :se nosplitright<CR>:vnew<CR>:se splitright<CR>
nnoremap <silent> <C-S-Down> :se splitbelow<CR>:new<CR>
nnoremap <silent> <C-S-Up> :se nosplitbelow<CR>:new<CR>

" Move to a window in the direction indicated
nnoremap <silent> <C-Right> <c-w>l
nnoremap <silent> <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j

" Rotate windows to the right
nnoremap <silent> <C-M-Right> <c-w>r

" Discard buffer changes and reload the current file from disk.
nnoremap <silent> <C-U> :edit!<CR>

" Quit Vim completely, discarding unsaved changes without confirmation.
nnoremap <silent> <C-T> :qall!<CR>

" Terminate vim, but save all files first
nnoremap <silent> <C-M-T> :xa!<cr>

" Show the vim syntax type under the cursor
function! SynStack()
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
endfunc
nnoremap <silent> <s-f10> :call SynStack()<CR>

" Vim diffing
let g:diff_white_state=1
fu! ToggleDiffWhite()
    if g:diff_white_state == 0
        set diffopt-=iwhite
        let g:diff_white_state=1
    else
        set diffopt+=iwhite
        let g:diff_white_state=0
    endif
endfunc

fu! ToggleVersDiff()
   if g:versdiff_state == 0
      let g:versdiff_state=1
      nnoremap <silent> - :VersDiff -<cr>
      nnoremap <silent> + :VersDiff +<cr>
      nnoremap <silent> <kMinus> :VersDiff -<cr>
      nnoremap <silent> <kPlus> :VersDiff +<cr>
      VersDiff -
   else
      let g:versdiff_state=0
      silent! nunmap -
      silent! nunmap +
      silent! nunmap <kMinus>
      silent! nunmap <kPlus>
      VersDiff -c
   endif
endfunc
fu! EndVersDiff()
   Purge 0
   w!
endfunc
let g:versdiff_state=0

fu! DiffSetup()
    syntax off
    auto GUIEnter * simalt ~x

    set diffopt=filler,context:9999
    set cursorbind scrollbind cursorline
    nnoremap <buffer> <silent> <f5> :diffupdate<CR>
    nnoremap <buffer> <silent> <right> :diffget<CR>
    nnoremap <buffer> <silent> <left> :diffput<CR>
    nnoremap <buffer> <silent> <down> ]cz.<c-w><c-w><c-w><c-w>
    nnoremap <buffer> <silent> <up> [cz.<c-w><c-w><c-w><c-w>

    " Pull/push the current diff hunk.
    nnoremap <buffer> <silent> <s-down> do
    nnoremap <buffer> <silent> <s-up> dp

    " Pull/push all changes.
    nnoremap <buffer> <silent> <m-s-down> :%diffget<CR>
    nnoremap <buffer> <silent> <m-s-up> :%diffput<CR>
    nnoremap <buffer> <silent> <m-down> <c-w>wyy<c-w>wPjddk

    nnoremap <buffer> <silent> u :u<cr>:dif<cr>
    nnoremap <buffer> <silent> U :red<cr>:dif<cr>
    let g:current_font_size=8
    call FontBigger()
    hi clear CursorLine
    hi CursorLine cterm=underline
endfunc

fu! DiffThis()
    " Move to the left-most window
    exe "normal \<C-w>t"
    call DiffSetup()
    diffthis
    " Move to the right-most window
    exe "normal \<C-w>b"
    call DiffSetup()
    diffthis
    " Move back to the left-most window
    exe "normal \<C-w>b1G]c"
endfunc
nnoremap <silent> <leader>d :call DiffThis()<CR>
cnoreabbrev D DirDiff
nnoremap <silent> <leader>i :call ToggleDiffWhite()<CR>
nnoremap <silent> <leader>n /\(\[\(\n\s*#.*\)*\n\s*\]\\|null\\|""\)<CR>
nnoremap <silent> <leader>B ^i# <ESC>$a #<ESC>O#<ESC>:se nowrap<CR>125a#<ESC>jhlklDyyjp:se wrap<CR>

let @R='^\(\(\s*\(#.*\|\s*echo.*\)\)\@!..*\)$'
nnoremap <silent> <leader>R /<C-R>R<CR>

fu! FoldBashLib()
   let save_view = winsaveview()
   normal! gg

   if search("^###{BASH_LIBRARY}###", "W")
      let old_errorbells = &errorbells
      set noerrorbells

      let @/ = '###{BASH_LIBRARY}###'
      :silent normal! ggnzfG
      let &errorbells = old_errorbells
   endif

   call winrestview(save_view)
endfunc
nnoremap <silent> <leader>fb :call FoldBashLib()<CR>

" Centralize autocommands to avoid duplicates when this file is re-sourced.
augroup ManageVimConfig
   autocmd!
   autocmd BufWritePre * call RemoveTrailingSpaces()
   autocmd CmdwinEnter * call DisableHighlighting()
   autocmd CmdwinLeave * call EnableHighlighting()
   autocmd BufRead,BufNewFile * call SetBufWinEnter()
   autocmd BufRead,BufNewFile *.conf setfiletype conf
   " Do not label unknown files as shell scripts indiscriminately.
   autocmd BufWinEnter * if !&diff | call RefreshEggHighlighting() | endif
   autocmd BufRead,BufNewFile *.sh silent! call FoldBashLib()
   autocmd BufEnter * let &titlestring = expand('%:t')
   autocmd VimEnter * if &diff | let g:wrap_state=0 | set nowrap | endif
augroup END

if &diff
   call DiffSetup()
endif

" DO NOT MAKE CHANGES TO THIS FILE =================================
" Place local changes in $HOME/.vim/plugin/rc.vim
