########################################################################
#
# 80-python-env.zsh
#
# Python environment activation helpers.
#
# VENV_DIRS and CONDA_DIRS are the authoritative lists of directories
# beneath which named Python environments may be found.
#
# They are user configuration and are normally defined in:
#
#    ~/.zshrc.d/e0-python-env.zsh
#
# Python venv environments are expected to contain:
#
#    <directory>/<environment-name>/bin/activate
#
# Conda environments are expected to contain:
#
#    <directory>/<environment-name>/conda-meta
#
# Each list is searched in the order specified.  If the same name is
# found as both a venv and a Conda environment, vstart reports the name
# as ambiguous rather than choosing one silently.
#
# When vstart is invoked without an environment name, the basename of
# the current Git worktree is used as the environment name.  A Git
# submodule is its own worktree and is therefore handled naturally.
#
# Only one Python environment is managed as active at a time.  vstart
# deactivates any active venv or Conda environment before activating the
# selected environment.
#
# Prompt presentation is handled independently by 90-prompt.zsh.
#
########################################################################


########################################################################
# Prevent Python venv activation scripts from modifying PS1.
#
# Prompt construction is owned entirely by 90-prompt.zsh.
########################################################################

export VIRTUAL_ENV_DISABLE_PROMPT=1

########################################################################
# Initialize Conda shell integration.
#
# The Conda executable may already be available through the system
# environment, but "conda activate" requires Conda's zsh shell function
# so that activation can modify the current shell.
#
# Disable Conda's own prompt modification because prompt construction is
# owned entirely by 90-prompt.zsh.
########################################################################

########################################################################
# :conda:init
#
# Initialize Conda shell integration when a Conda executable is
# available.
#
# Conda activation requires a shell function because activation must
# modify the current shell environment.  This helper contains no
# installation-specific knowledge; locating or loading Conda is the
# responsibility of user configuration.
########################################################################

function :conda:init
{
   (( ${+functions[conda]} )) && return 0

   if ! command -v conda >/dev/null 2>&1; then
      if [[ -n ${CONDA_MODULE-} ]] &&
         (( ${+functions[module]} ))
      then
         module load "$CONDA_MODULE" || return $?
      fi
   fi

   command -v conda >/dev/null 2>&1 || return 1

   eval "$(command conda shell.zsh hook)"
}


########################################################################
# :conda:deactivate
#
# Completely deactivate Conda in the current shell.
#
# Conda can maintain an activation stack.  Unwind the complete stack so
# that activating a Python venv never leaves an underlying Conda
# environment active.
########################################################################

function :conda:deactivate
{
   local -i level

   if [[ -z ${CONDA_PREFIX-} && -z ${CONDA_DEFAULT_ENV-} ]]; then
      return 0
   fi

   whence conda >/dev/null 2>&1 || {
      print -u2 -- "Cannot deactivate Conda: conda is not available"
      return 1
   }

   if [[ ${CONDA_SHLVL-0} == <-> ]] && (( CONDA_SHLVL > 0 )); then
      while (( CONDA_SHLVL > 0 )); do
         level=$CONDA_SHLVL
         conda deactivate || return $?

         # Protect against a broken Conda shell integration that reports
         # success without reducing the activation level.
         (( CONDA_SHLVL < level )) || {
            print -u2 -- "Cannot deactivate Conda: activation level did not change"
            return 1
         }
      done
   else
      conda deactivate
   fi
}


########################################################################
# :python-env:deactivate
#
# Deactivate every Python environment represented in the current shell.
#
# venv and Conda environments are managed as mutually exclusive.  If
# they have somehow been nested manually, deactivate the venv first and
# then completely unwind Conda.
########################################################################

function :python-env:deactivate
{
   if [[ -n ${VIRTUAL_ENV-} ]]; then
      whence deactivate >/dev/null 2>&1 || {
         print -u2 -- "Cannot deactivate Python venv: deactivate is not available"
         return 1
      }

      deactivate || return $?
   fi

   :conda:deactivate
}


########################################################################
# :venv:activate <activate-script>
#
# Switch from any currently active Python environment to the specified
# Python venv.
########################################################################

function :venv:activate
{
   local activate=$1

   [[ -f $activate ]] || return 1

   :python-env:deactivate || return $?

   source "$activate"
}


########################################################################
# :conda:activate <environment-directory>
#
# Switch from any currently active Python environment to the specified
# Conda environment.
#
# Conda must already be initialized in the current shell so that its
# activation function can modify the shell environment.
########################################################################

function :conda:activate
{
   local environment=$1

   [[ -d $environment/conda-meta ]] || return 1

   :conda:init || {
      print -u2 -- "Cannot activate Conda: conda is not available"
      return 1
   }

   :python-env:deactivate || return $?

   conda activate "$environment"
}


########################################################################
# :venv:find <name>
#
# Search VENV_DIRS, in order, for a Python venv named <name>.
#
# Return the pathname of bin/activate in REPLY.
#
# If VENV_DIRS is undefined or empty, no directories are searched.
########################################################################

function :venv:find
{
   local name=$1
   local dir
   local activate

   REPLY=

   (( ${+VENV_DIRS} )) || return 1

   for dir in "${VENV_DIRS[@]}"; do
      [[ -n $dir ]] || continue

      activate="$dir/$name/bin/activate"

      if [[ -f $activate ]]; then
         REPLY=$activate
         return 0
      fi
   done

   return 1
}


########################################################################
# :conda:find <name>
#
# Search CONDA_DIRS, in order, for a Conda environment named <name>.
#
# Return the environment directory in REPLY.
#
# If CONDA_DIRS is undefined or empty, no directories are searched.
########################################################################

function :conda:find
{
   local name=$1
   local dir
   local environment

   REPLY=

   (( ${+CONDA_DIRS} )) || return 1

   for dir in "${CONDA_DIRS[@]}"; do
      [[ -n $dir ]] || continue

      environment="$dir/$name"

      if [[ -d $environment/conda-meta ]]; then
         REPLY=$environment
         return 0
      fi
   done

   return 1
}


########################################################################
# :python-env:find <name>
#
# Search the configured venv and Conda locations for <name>.
#
# On success:
#
#    REPLY             pathname used to activate the environment
#    __PythonEnvType   venv or conda
#
# Return status:
#
#    0   exactly one environment was found
#    1   no environment was found
#    2   both a venv and a Conda environment were found
########################################################################

typeset -g __PythonEnvType=

function :python-env:find
{
   local name=$1
   local venv=
   local conda=

   REPLY=
   __PythonEnvType=

   if :venv:find "$name"; then
      venv=$REPLY
   fi

   if :conda:find "$name"; then
      conda=$REPLY
   fi

   if [[ -n $venv && -n $conda ]]; then
      __PythonEnvType=ambiguous
      return 2
   fi

   if [[ -n $venv ]]; then
      REPLY=$venv
      __PythonEnvType=venv
      return 0
   fi

   if [[ -n $conda ]]; then
      REPLY=$conda
      __PythonEnvType=conda
      return 0
   fi

   return 1
}


########################################################################
# :python-env:git-name
#
# Return the basename of the current Git worktree in REPLY.
#
# A Git submodule is treated as its own worktree and therefore produces
# its own environment name naturally.
########################################################################

function :python-env:git-name
{
   local top

   REPLY=

   whence -p git >/dev/null 2>&1 || return 1

   if ! top=$(command git -C "$PWD" rev-parse --show-toplevel 2>/dev/null); then
      return 1
   fi

   [[ -d $top ]] || return 1

   top=${top:A}
   REPLY=${top:t}
}


########################################################################
# :python-env:activate <type> <pathname>
#
# Activate an environment previously returned by :python-env:find.
########################################################################

function :python-env:activate
{
   local type=$1
   local environment=$2

   case $type in
   venv)
      :venv:activate "$environment"
      ;;

   conda)
      :conda:activate "$environment"
      ;;

   *)
      print -u2 -- "Unknown Python environment type: $type"
      return 1
      ;;
   esac
}


########################################################################
# vstart [-c|--conda|-v|--venv] [name]
#
# Without an argument:
#
#    Determine the current Git worktree basename and activate the
#    matching environment found in VENV_DIRS or CONDA_DIRS.
#
# With one argument:
#
#    Search VENV_DIRS and CONDA_DIRS for the explicitly named
#    environment.
#
# Examples:
#
#    vstart
#    vstart example-project
#
# If both a venv and Conda environment have the selected name, no
# environment is activated and the ambiguity is reported.
########################################################################

function vstart
{
   local type=
   local name
   local -i return_status

   case ${1-} in
   -c|--conda)
      type=conda
      shift
      ;;

   -v|--venv)
      type=venv
      shift
      ;;
   esac

   if (( $# == 0 )); then
      if ! :python-env:git-name; then
         print -u2 -- "Could not determine a Python environment to activate"
         return 1
      fi

      name=$REPLY

   elif (( $# == 1 )); then
      name=$1

   else
      print -u2 -- "Usage: vstart [-c|--conda|-v|--venv] [environment]"
      return 2
   fi

   case $type in
   conda)
      if :conda:find "$name"; then
         :python-env:activate conda "$REPLY"
      else
         print -u2 -- "Conda environment not found: $name"
         return 1
      fi
      ;;

   venv)
      if :venv:find "$name"; then
         :python-env:activate venv "$REPLY"
      else
         print -u2 -- "Python venv not found: $name"
         return 1
      fi
      ;;

   '')
      :python-env:find "$name"
      return_status=$?

      case $return_status in
      0)
         :python-env:activate "$__PythonEnvType" "$REPLY"
         ;;

      1)
         print -u2 -- "Python environment not found: $name"
         return 1
         ;;

      2)
         print -u2 -- \
            "Python environment is ambiguous: $name exists as both venv and Conda"
         print -u2 -- \
            "Use vstart --venv or vstart --conda to select one"
         return 1
         ;;
      esac
      ;;
   esac
}


########################################################################
# vstop
#
# Deactivate the currently active Python venv or Conda environment.
#
# No prompt manipulation is performed here.  On the next prompt,
# 90-prompt.zsh examines the resulting environment state and any Python
# environment associated with the current Git worktree.
########################################################################

function vstop
{
   :python-env:deactivate
}
