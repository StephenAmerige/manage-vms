########################################################################
#
# 89-timer.zsh
#
# Provide extensible prompt timers.
#
# Timer implementations are functions named:
#
#    :timer:<name>
#
# A timer function places its display text in REPLY and returns zero when
# the timer should be displayed.  A nonzero return suppresses the timer.
#
########################################################################

typeset -g _TimerName=${ZSH_TIMER-}


########################################################################
# timer [<name>|off|status]
########################################################################

function timer
{
   local Name=${1-}

   case "$Name" in
   '')
      print -r -- "Usage: timer <name>|off|status"
      return 0
      ;;

   off)
      _TimerName=
      ;;

   status)
      if [[ -n $_TimerName ]]; then
         print -r -- "Timer: $_TimerName"
      else
         print -r -- "Timer: off"
      fi
      ;;

   *)
      if whence ":timer:${Name}" >/dev/null 2>&1; then
         _TimerName=$Name
      else
         print -u2 -r -- "Unknown timer: $Name"
         return 2
      fi
      ;;
   esac
}


########################################################################
# :timer:current
#
# Invoke the currently selected timer.
########################################################################

function :timer:current
{
   REPLY=

   [[ -n $_TimerName ]] || return 1
   whence ":timer:${_TimerName}" >/dev/null 2>&1 || return 1

   ":timer:${_TimerName}"
}
