#!/bin/zsh

#***********************************************************************#
#* ENVIRONMENT                                                         *#
#***********************************************************************#

export ENV_HOME="$HOME"
export EDITOR=vi
export PAGER=less
export LESS='-X -F -R'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export DIRSTACKSIZE=20
export HISTSIZE=999999
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME"/.history
export HOST="$(/bin/hostname)"
export MAILCHECK=999999999
export LESSBINFMT='*u%x'
export READNULLCMD=less
export SHELL=/bin/zsh
export TAB=$'\011'
export TERM=xterm-256color
export QUOTING_STYLE=literal
export KEYTIMEOUT=20
export LS_COLORS='no=00:fi=00:di=01;34:ln=01:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=01:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.flac=01;35:*.mp3=01;35:*.mpc=01;35:*.ogg=01;35:*.wav=01;35:';

typeset -a zsh_OPTIONS=(
   AUTOMENU                                              # Show completion menu after ambiguous completion
   EXTENDED_GLOB                                         # Enable advanced glob patterns
   EXTENDED_HISTORY                                      # Store timestamps and durations in history
   SHARE_HISTORY                                         # Share command history across active shells
   HIST_IGNORE_DUPS                                      # Do not store duplicate adjacent commands
   HIST_IGNORE_SPACE                                     # Do not store commands that begin with space
   IGNOREEOF                                             # Prevent Ctrl-D from exiting the shell
   INTERACTIVE_COMMENTS                                  # Allow comments in interactive commands
   LIST_TYPES                                            # Show file type markers in completion lists
   NO_NOMATCH                                            # Leave unmatched globs unchanged
   NOTIFY                                                # Report background job status immediately
   NULL_GLOB                                             # Remove unmatched globs instead of erroring
   NUMERICGLOBSORT                                       # Sort numeric filename parts numerically
   PATH_DIRS                                             # Search path for commands containing slashes
   PUSHD_IGNORE_DUPS                                     # Avoid duplicate entries in directory stack
   PUSHD_SILENT                                          # Suppress pushd/popd directory stack output
   RM_STAR_SILENT                                        # Do not prompt specially for rm *
   TYPESET_SILENT                                        # Suppress output from bare typeset commands
   ZLE                                                   # Enable Zsh line editor
)

setopt "${zsh_OPTIONS[@]}"
unset zsh_OPTIONS

unset zle_bracketed_paste
zle_highlight=('paste:none')
zstyle ':completion:*:*:cd:*' tag-order local-directories

setopt -m
bindkey -v
compctl -c man
compctl -v export printenv
fignore=(.o \~)

#***********************************************************************#
#* ALIASES                                                             *#
#***********************************************************************#

alias more=less
alias ..='. "$HOME"/.zshrc'
alias d='dirs -v'
alias h='fc -li'
alias D='docker'

#***********************************************************************#
#* FUNCTIONS                                                           *#
#***********************************************************************#

is()
{
   for FILE
   do
      alias "$FILE" || functions "$FILE" || path "$FILE" || type "$FILE"
   done
}

# Fix for <ESC>/ being interpreted as <esc-/>
# See: https://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode
vi-search-fix()
{
   zle vi-cmd-mode
   zle .vi-history-search-backward
}
autoload vi-search-fix
zle -N vi-search-fix
bindkey -M viins '\e/' vi-search-fix

# FILES
for Cmd in ls la ll lla lL; do
   unalias $Cmd &>/dev/null
   unfunction $Cmd &>/dev/null
done
ls()  { LC_ALL=C /bin/ls -FC --color=tty $@ }
la()  { LC_ALL=C /bin/ls -A --color=tty $@ }
ll()  { LC_ALL=C /bin/ls -l --color=tty $@ }
lla() { LC_ALL=C /bin/ls -lA --color=tty $@ }
lL()  { LC_ALL=C /bin/ls -LFl --color=tty $@ }
lf()  { if [[ $# -gt 0 ]]; then find "$@" -type f; else find . -type f; fi }

#***********************************************************************#
#* LOAD Additional Requirements                                        *#
#***********************************************************************#

for ZshrcFile in "$HOME"/.zshrc.d/*.zsh; do
   . "$ZshrcFile"
done
