# Directory
push()
{
   local Options
   Options=$(getopt -o 'r' -l 'resolve' -n "$FUNCNAME" -- "$@") || return
   eval set -- "$Options"

   local Resolve=false

   while true ; do
      case "$1" in
      -r|--resolve)  Resolve=true; shift;;
      --)            shift; break;;
      *)             break;;
      esac
   done
   $Resolve && pushd "$(readlink -fm "$1" )" || pushd "$1"
   d
}

pop()
{
   if [[ $1 = = ]]; then
      shift
      COUNT="$1"
      while (( $COUNT > 0 )); do
         popd
         COUNT=$(($COUNT - 1))
      done
   else
      popd $*
   fi
   d
}

r()
{
    if (( $# == 0 )); then
       push +1
    else
       push +$1
    fi
}
