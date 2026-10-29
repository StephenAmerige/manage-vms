:session:usage()
{
   cat <<EOF
Usage:
   session [<profile>] [OPTIONS]

Profiles:
   xs     1 CPU    2G    02:00:00
   s      2 CPUs   4G    05:00:00   default
   m      4 CPUs   8G    05:00:00
   l      8 CPUs   16G   05:00:00
   xl     16 CPUs  32G   05:00:00
   2xl    32 CPUs  64G   05:00:00

Options:
   -c, --cpus <count>   Override CPUs per task
   -m, --mem <GB>       Override memory in GB
   -t, --time <time>    Override session time
   -h, --help           Show this help

Time:
   5        05:00:00
   5:30     05:30:00
   12:15    12:15:00

Examples:
   session s
   session -m 8
   session l -c 4
   session xl -t 2
   session m -t 5:30
EOF
}


:session:memory()
{
   local Value=$1

   case "$Value" in
   <->)         REPLY="${Value}G";;
   <->G|<->g)   REPLY="${Value[1,-2]}G";;
   *)
      print -u2 -- "Invalid memory value: $Value"
      return 2
      ;;
   esac
}


:session:time()
{
   local Value=$1
   local Hours
   local Minutes

   case "$Value" in
   <->)
      Hours=$Value
      Minutes=0
      ;;

   <->:<->)
      Hours=${Value%%:*}
      Minutes=${Value#*:}
      ;;

   *)
      print -u2 -- "Invalid time value: $Value"
      return 2
      ;;
   esac

   (( Hours = 10#$Hours ))
   (( Minutes = 10#$Minutes ))

   if (( Minutes > 59 )); then
      print -u2 -- "Invalid time value: $Value"
      return 2
   fi

   printf -v REPLY '%02d:%02d:00' $Hours $Minutes
}


:session:validate()
{
   if [[ -z ${_SessionAccount-} ]]; then
      print -u2 -- "session: _SessionAccount is not defined"
      return 2
   fi

   if [[ -z ${_SessionShell-} ]]; then
      print -u2 -- "session: _SessionShell is not defined"
      return 2
   fi

   if [[ ! -x $_SessionShell ]]; then
      print -u2 -- "session: shell is not executable: $_SessionShell"
      return 2
   fi

   if ! whence -p srun >/dev/null 2>&1; then
      print -u2 -- "session: srun is not available"
      return 2
   fi
}


:session()
{
   local Profile=s
   local CPUs
   local Memory
   local Time

   if (( $# == 0 )); then
      :session:usage
      return 0
   fi

   if [[ $1 != -* ]]; then
      Profile=$1
      shift
   fi

   case "$Profile" in
   xs)  CPUs=1;  Memory=2;  Time=2;;
   s)   CPUs=2;  Memory=4;  Time=5;;
   m)   CPUs=4;  Memory=8;  Time=5;;
   l)   CPUs=8;  Memory=16; Time=5;;
   xl)  CPUs=16; Memory=32; Time=5;;
   2xl) CPUs=32; Memory=64; Time=5;;
   *)
      print -u2 -- "Unknown profile: $Profile"
      return 2
      ;;
   esac

   while (( $# > 0 )); do
      case "$1" in
      -c|--cpus) (( $# >= 2 )) || { print -u2 -- "$1 requires an argument"; return 2; }; CPUs=$2; shift 2;;
      -m|--mem)  (( $# >= 2 )) || { print -u2 -- "$1 requires an argument"; return 2; }; Memory=$2; shift 2;;
      -t|--time) (( $# >= 2 )) || { print -u2 -- "$1 requires an argument"; return 2; }; Time=$2; shift 2;;
      -h|--help) :session:usage; return 0;;
      *)         print -u2 -- "Unknown option: $1"; return 2;;
      esac
   done

   :session:validate || return

   [[ $CPUs == <-> ]] && (( CPUs > 0 )) || {
      print -u2 -- "Invalid CPU count: $CPUs"
      return 2
   }

   :session:memory "$Memory" || return
   Memory=$REPLY

   :session:time "$Time" || return
   Time=$REPLY

   srun \
      --pty \
      -A "$_SessionAccount" \
      --nodes=1 \
      --ntasks=1 \
      --cpus-per-task="$CPUs" \
      --mem="$Memory" \
      --time="$Time" \
      env ZSH_TIMER=slurm "$_SessionShell" -di
}


alias session=':session'
