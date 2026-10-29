########################################################################
#
# 91-title.zsh
#
# Manage the terminal window or tab title.
#
# The title is independent of the shell prompt.  When hostname mode is
# selected, the title is refreshed before each prompt so that a change
# of host is reflected automatically.
#
########################################################################


########################################################################
# Configuration
########################################################################

typeset -g _TitleMode=${_TitleMode:-host}
typeset -g _TitleText=${_TitleText:-}


########################################################################
# :title:emit <text>
#
# Set the terminal window title using the OSC 2 escape sequence.
########################################################################

function :title:emit
{
   [[ -o interactive && -t 1 ]] || return 0

   printf '\033]2;%s\007' "$1"
}


########################################################################
# :title:precmd
#
# Refresh the terminal title immediately before displaying each prompt.
########################################################################

function :title:precmd
{
   setopt localoptions noxtrace

   local Hostname

   case $_TitleMode in
   none)
      ;;

   fixed)
      :title:emit "$_TitleText"
      ;;

   host)
      Hostname=$(hostname)
      :title:emit "$Hostname"
      ;;

   *)
      _TitleMode=host
      Hostname=$(hostname)
      :title:emit "$Hostname"
      ;;
   esac
}


########################################################################
# title
#
# Display the current title mode.
#
# title none
#    Stop managing the title and clear the existing shell-managed title.
#
# title host
#    Display the current hostname and update it before each prompt.
#
# title fixed <text>
#    Display the specified fixed title.
########################################################################

function title
{
   local Mode=${1-}

   if (( $# == 0 )); then
      print -r -- "Title mode: $_TitleMode"

      if [[ $_TitleMode == fixed ]]; then
         print -r -- "Title text: $_TitleText"
      fi

      return 0
   fi

   case $Mode in
   none)
      (( $# == 1 )) || {
         print -u2 -r -- "Usage: title none"
         return 2
      }

      _TitleMode=none
      _TitleText=
      :title:emit ""
      ;;

   host)
      (( $# == 1 )) || {
         print -u2 -r -- "Usage: title host"
         return 2
      }

      _TitleMode=host
      _TitleText=
      :title:precmd
      ;;

   fixed)
      (( $# >= 2 )) || {
         print -u2 -r -- "Usage: title fixed <text>"
         return 2
      }

      shift
      _TitleMode=fixed
      _TitleText="$*"
      :title:emit "$_TitleText"
      ;;

   *)
      print -u2 -r -- "Usage: title [none|host|fixed <text>]"
      return 2
      ;;
   esac
}


########################################################################
# Install the precmd hook.
########################################################################

typeset -ga precmd_functions

precmd_functions=(
   ${precmd_functions:#:title:precmd}
   :title:precmd
)
