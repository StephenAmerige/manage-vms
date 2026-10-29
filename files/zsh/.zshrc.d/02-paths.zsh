########################################################################
# path [options] [command ...]
#
# Display or search the directories comprising PATH.
#
# With no arguments:
#
#    Display the directories in PATH, one per line.
#
# With one or more command names:
#
#    Display the first executable pathname found for each command.
#
# Options:
#
#    -a    Display all executable pathnames found rather than only the
#          first.
#
#    -d    Display only the directory containing each executable.
#
# Options may be combined:
#
#    path -ad command
#
########################################################################

function path
{
   local opt
   local dir
   local name
   local candidate
   local OPTARG
   local -i OPTIND=1
   local -i allpaths=0
   local -i dir_only=0
   local -i rc=1

   #
   # With no arguments, display PATH one directory per line.
   #
   # Zsh maintains $path as an array tied directly to $PATH, so no
   # parsing of the colon-separated scalar is necessary.
   #
   if (( $# == 0 )); then
      for dir in "${path[@]}"; do
         #
         # An empty PATH component means the current directory.
         #
         if [[ -n $dir ]]; then
            print -r -- "$dir"
         else
            print -r -- "."
         fi
      done

      return 0
   fi

   #
   # Process options.
   #
   while getopts ':ad' opt; do
      case $opt in
      a)
         allpaths=1
         ;;

      d)
         dir_only=1
         ;;

      *)
         print -u2 -- "usage: path [ -a -d ] file ..."
         return 1
         ;;
      esac
   done

   shift $(( OPTIND - 1 ))

   if (( $# == 0 )); then
      print -u2 -- "usage: path [ -a -d ] file ..."
      return 1
   fi

   #
   # Search PATH for each specified command.
   #
   for name in "$@"; do
      for dir in "${path[@]}"; do
         #
         # In PATH, an empty element represents the current directory.
         #
         [[ -n $dir ]] || dir=.

         candidate="$dir/$name"

         if [[ -f $candidate && -x $candidate ]]; then
            rc=0

            if (( dir_only )); then
               print -r -- "$dir"
            else
               print -r -- "$candidate"
            fi

            (( allpaths )) || break
         fi
      done
   done

   return $rc
}

addpath after /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
addpath before "$HOME/bin"
addmanpath before /usr/local/share/man /usr/share/locale/man /usr/share/man

cdpath=(.. $HOME)
