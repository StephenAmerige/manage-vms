########################################################################
#
# 20-files.zsh
#
# File-related utility functions.
#
########################################################################

zmodload zsh/datetime
zmodload -F zsh/stat b:zstat


########################################################################
# :timestamp:mtime <file>
#
# Return the modification time of <file>, expressed as seconds since
# the Unix epoch, in REPLY.
########################################################################

function :timestamp:mtime
{
   local file=$1
   local -A info

   if ! zstat -H info +mtime "$file" 2>/dev/null; then
      print -u2 -- "Could not stat: $file"
      return 1
   fi

   REPLY=${info[mtime]}
}


########################################################################
# timestamp [file [file]]
#
# With no arguments:
#
#    Print the current time as seconds since the Unix epoch.
#
# With one argument:
#
#    Print the modification time of the specified file as seconds
#    since the Unix epoch.
#
# With two arguments:
#
#    Return 0 if the files have identical modification times and
#    return 1 otherwise.  No output is produced.
########################################################################

function timestamp
{
   local mtime1
   local mtime2

   case $# in
   0)
      print -r -- "$EPOCHSECONDS"
      ;;

   1)
      :timestamp:mtime "$1" || return 1
      print -r -- "$REPLY"
      ;;

   2)
      :timestamp:mtime "$1" || return 1
      mtime1=$REPLY

      :timestamp:mtime "$2" || return 1
      mtime2=$REPLY

      [[ $mtime1 == $mtime2 ]]
      ;;

   *)
      print -u2 -- "Usage: timestamp [file [file]]"
      return 2
      ;;
   esac
}
