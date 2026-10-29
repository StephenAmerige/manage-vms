# Prompt
plimit()
{
    if [[ $1 = = ]] ; then
       if (( $# == 1 )) ; then
          export PATH_LIMIT=70
       else
          export PATH_LIMIT="$2"
       fi
    else
       if (( $# == 1 )) ; then
          export PATH_LIMIT="$1"
       fi
       echo "Path limit: $PATH_LIMIT"
    fi
}

########################################################################
# pfrag [pathname [limit]]
#
# Shorten a pathname to fit within a specified number of characters.
#
# If no pathname is specified, use the current working directory.
#
# If no limit is specified, use PATH_LIMIT, defaulting to 80.
#
# If the pathname fits within the limit, return it unchanged.
#
# Otherwise:
#
#    Prefer a pathname component boundary and prefix the shortened
#    pathname with "...".
#
#    If no pathname component boundary exists within the usable tail,
#    retain the end of the pathname and prefix it with "*".
########################################################################

function pfrag
{
   local pathname
   local plimit
   local length
   local start
   local suffix

   if (( $# == 0 )); then
      pathname=${PWD:A}
   else
      pathname=$1
   fi

   if (( $# >= 2 )); then
      plimit=$2
   elif [[ -n ${PATH_LIMIT-} && $PATH_LIMIT == <-> && $PATH_LIMIT -ge 4 ]]; then
      plimit=$PATH_LIMIT
   else
      plimit=80
   fi

   if [[ $plimit != <-> ]] || (( plimit < 4 )); then
      plimit=80
   fi

   length=${#pathname}

   if (( length <= plimit )); then
      print -r -- "$pathname"
      return 0
   fi

   start=$(( length - plimit + 4 ))
   suffix=${pathname[$start,-1]}

   if [[ $suffix == */* ]]; then
      print -r -- ".../${suffix#*/}"
   else
      start=$(( length - plimit + 2 ))
      print -r -- "*${pathname[$start,-1]}"
   fi
}
