########################################################################
#
# 90-prompt.zsh
#
# Construct the interactive zsh prompt dynamically.
#
# Timer colors:
#
#    Yellow  Active timer
#
# Environment colors:
#
#    Brown   Matching Git-associated Python environment is available
#            but inactive
#    Blue    Python venv is active
#    Orange  Conda environment is active
#
# Git colors:
#
#    Green   Ordinary Git worktree
#    Purple  Git submodule
#
# Adjacent context sections are separated by a colon having a white
# background and a foreground matching the preceding section.
#
# The prompt normally uses one information line followed by the command
# line.  If pathname shortening cannot preserve at least two pathname
# components, the pathname moves to a second information line.
#
########################################################################


########################################################################
# Prompt behavior
#
# PROMPT_MARGIN reserves a small number of columns at the right side of
# the terminal rather than allowing a prompt-information line to occupy
# the terminal's entire width.
#
# PROMPT_GAP inserts a blank line before each prompt when enabled.
########################################################################

typeset -g PROMPT_MARGIN=${PROMPT_MARGIN:-2}
typeset -g PROMPT_GAP=${PROMPT_GAP:-0}


########################################################################
# Configurable colors
########################################################################

typeset -g PROMPT_TIMER_BG=${PROMPT_TIMER_BG:-220}
typeset -g PROMPT_TIMER_FG=${PROMPT_TIMER_FG:-0}

typeset -g PROMPT_VENV_AVAILABLE_BG=${PROMPT_VENV_AVAILABLE_BG:-94}
typeset -g PROMPT_VENV_AVAILABLE_FG=${PROMPT_VENV_AVAILABLE_FG:-15}

typeset -g PROMPT_VENV_BG=${PROMPT_VENV_BG:-33}
typeset -g PROMPT_CONDA_BG=${PROMPT_CONDA_BG:-208}

typeset -g PROMPT_GIT_BG=${PROMPT_GIT_BG:-28}
typeset -g PROMPT_SUBMODULE_BG=${PROMPT_SUBMODULE_BG:-93}
typeset -g PROMPT_GIT_SEPARATOR_BG=${PROMPT_GIT_SEPARATOR_BG:-15}

typeset -g PROMPT_CONTEXT_FG=${PROMPT_CONTEXT_FG:-15}


########################################################################
# Git topology cache
########################################################################

typeset -gA __PromptGitTop
typeset -gA __PromptGitDir
typeset -gA __PromptGitName
typeset -gA __PromptGitKind

typeset -g __PromptGitCurrentName=
typeset -g __PromptGitCurrentBranch=
typeset -g __PromptGitCurrentKind=

typeset -g __PromptEscaped=


########################################################################
# :prompt:escape <string>
#
# Escape literal percent signs before inserting arbitrary text into
# PROMPT.
########################################################################

function :prompt:escape
{
   __PromptEscaped=${1//\%/\%\%}
}


########################################################################
# :prompt:path-useful <fragment>
#
# Determine whether a shortened pathname retains useful context.
#
# A pfrag result beginning with ".../" is considered useful when at
# least two pathname components remain after the ellipsis:
#
#    .../directory/directory
#
# A "*tail" result is not considered sufficiently useful for the
# one-line prompt layout.
########################################################################

function :prompt:path-useful
{
   local fragment=$1
   local remainder

   [[ $fragment == '...'/* ]] || return 1

   remainder=${fragment#.../}

   [[ $remainder == */* ]]
}


########################################################################
# :prompt:git-marker
#
# Find the nearest ancestor containing .git.
#
# Return the directory in REPLY.
########################################################################

function :prompt:git-marker
{
   local dir=$PWD

   REPLY=

   while :; do
      if [[ -e $dir/.git ]]; then
         REPLY=$dir
         return 0
      fi

      [[ $dir == / ]] && break
      dir=${dir:h}
   done

   return 1
}


########################################################################
# :prompt:git-probe <marker-directory>
#
# Discover the comparatively stable topology of a Git worktree.
########################################################################

function :prompt:git-probe
{
   local marker=$1
   local top
   local gitdir
   local superproject
   local kind

   whence -p git >/dev/null 2>&1 || return 1

   if ! top=$(command git -C "$marker" rev-parse --show-toplevel 2>/dev/null); then
      return 1
   fi

   if ! gitdir=$(command git -C "$marker" rev-parse --absolute-git-dir 2>/dev/null); then
      return 1
   fi

   superproject=$(
      command git -C "$marker" \
         rev-parse --show-superproject-working-tree 2>/dev/null
   )

   if [[ -n $superproject ]]; then
      kind=submodule
   else
      kind=repository
   fi

   __PromptGitTop[$marker]=$top
   __PromptGitDir[$marker]=$gitdir
   __PromptGitName[$marker]=${top:t}
   __PromptGitKind[$marker]=$kind
}


########################################################################
# :prompt:git-head <git-directory>
#
# Determine the current branch directly from HEAD without invoking git.
#
# In detached-HEAD state, display the first eight hexadecimal digits.
#
# Return the result in REPLY.
########################################################################

function :prompt:git-head
{
   local gitdir=$1
   local head
   local ref

   REPLY=

   [[ -r $gitdir/HEAD ]] || return 1

   IFS= read -r head < "$gitdir/HEAD" || return 1

   if [[ $head == 'ref: '* ]]; then
      ref=${head#ref: }

      if [[ $ref == refs/heads/* ]]; then
         REPLY=${ref#refs/heads/}
      else
         REPLY=${ref:t}
      fi
   else
      REPLY=${head[1,8]}
   fi

   return 0
}


########################################################################
# :prompt:git-current
#
# Determine the Git information applicable to the current directory.
########################################################################

function :prompt:git-current
{
   local marker
   local kind
   local gitdir

   __PromptGitCurrentName=
   __PromptGitCurrentBranch=
   __PromptGitCurrentKind=

   whence -p git >/dev/null 2>&1 || return 1

   :prompt:git-marker || return 1
   marker=$REPLY

   kind=${__PromptGitKind[$marker]-}
   gitdir=${__PromptGitDir[$marker]-}

   if [[ -z $kind || -z $gitdir || ! -r $gitdir/HEAD ]]; then
      :prompt:git-probe "$marker" || return 1

      kind=${__PromptGitKind[$marker]-}
      gitdir=${__PromptGitDir[$marker]-}
   fi

   :prompt:git-head "$gitdir" || return 1

   __PromptGitCurrentName=${__PromptGitName[$marker]-}
   __PromptGitCurrentBranch=$REPLY
   __PromptGitCurrentKind=$kind

   return 0
}


########################################################################
# :prompt:cache-clear
########################################################################

function :prompt:cache-clear
{
   __PromptGitTop=()
   __PromptGitDir=()
   __PromptGitName=()
   __PromptGitKind=()
}


########################################################################
# pgap [on|off|status]
#
# Toggle or explicitly control insertion of a blank line before each
# prompt.
########################################################################

function pgap
{
   case ${1-} in
   '')
      if [[ ${PROMPT_GAP-0} == 1 ]]; then
         PROMPT_GAP=0
      else
         PROMPT_GAP=1
      fi
      ;;

   on)
      PROMPT_GAP=1
      ;;

   off)
      PROMPT_GAP=0
      ;;

   status)
      ;;

   *)
      print -u2 -- "Usage: pgap [on|off|status]"
      return 2
      ;;
   esac

   if [[ $PROMPT_GAP == 1 ]]; then
      print -- "Prompt gap enabled"
   else
      print -- "Prompt gap disabled"
   fi
}


########################################################################
# :prompt:precmd
#
# Reconstruct PROMPT immediately before zsh displays each prompt.
#
# Layout policy:
#
#    1. Prefer one information line.
#
#    2. If the complete pathname fits, always retain the one-line
#       layout.
#
#    3. If shortening is necessary, retain one line only when pfrag
#       can preserve at least two pathname components.
#
#    4. Otherwise move the pathname to its own information line.
#
# An optional timer, when active, appears as the first item on the first
# information line and participates in pathname-width calculations.
#
# Terminal width is taken from COLUMNS, less PROMPT_MARGIN.
########################################################################

function :prompt:precmd
{
   setopt localoptions noxtrace

   local timer_text=
   local timer_prompt=

   local env_name=
   local env_prompt=
   local env_bg=
   local env_fg=

   local git_bg=
   local git_name=
   local git_name_prompt=
   local git_branch=
   local git_branch_prompt=

   local context=
   local context_text=

   local status_text
   local status_prompt

   local shown_pwd
   local shown_pwd_prompt
   local one_line_pwd

   local prompt_end=']'
   local prompt_gap=

   local -i terminal_width
   local -i prompt_margin
   local -i usable_width
   local -i timer_width=0
   local -i env_status=0
   local -i one_line_path_limit
   local -i two_line_path_limit
   local -i two_lines=0

   #
   # Determine the usable terminal width.
   #
   if [[ ${COLUMNS-} == <-> ]] && (( COLUMNS > 0 )); then
      terminal_width=$COLUMNS
   else
      terminal_width=100
   fi

   if [[ ${PROMPT_MARGIN-} == <-> ]]; then
      prompt_margin=$PROMPT_MARGIN
   else
      prompt_margin=2
   fi

   usable_width=$(( terminal_width - prompt_margin ))
   (( usable_width >= 20 )) || usable_width=20

   #
   # Determine timer state.
   #
   if whence :timer:current >/dev/null 2>&1 && :timer:current; then
      timer_text=$REPLY

      if [[ -n $timer_text ]]; then
         :prompt:escape "$timer_text"
         timer_prompt=$__PromptEscaped
         timer_prompt="%K{${PROMPT_TIMER_BG}}%F{${PROMPT_TIMER_FG}}[${timer_prompt}]%f%k "
         timer_width=$(( ${#timer_text} + 3 ))
      fi
   fi

   #
   # Determine Git state first.
   #
   :prompt:git-current

   #
   # Determine environment state.
   #
   # venv and Conda environments are managed as mutually exclusive.
   # If both are somehow active because they were nested manually, the
   # venv is displayed because it is normally the innermost environment.
   #
   if [[ -n ${VIRTUAL_ENV-} ]]; then
      if
         [[ -n $__PromptGitCurrentName ]] &&
         [[ ${VIRTUAL_ENV:t} == $__PromptGitCurrentName ]]
      then
         env_name=venv
      else
         env_name=${VIRTUAL_ENV:t}
      fi

      env_bg=$PROMPT_VENV_BG
      env_fg=$PROMPT_CONTEXT_FG

    elif [[ -n ${CONDA_PREFIX-} || -n ${CONDA_DEFAULT_ENV-} ]]; then
       if [[ -n ${CONDA_DEFAULT_ENV-} ]]; then
          env_name=${CONDA_DEFAULT_ENV:t}
       else
          env_name=${CONDA_PREFIX:t}
       fi

       if
          [[ -n $__PromptGitCurrentName ]] &&
          [[ $env_name == $__PromptGitCurrentName ]]
       then
          env_name=conda
       fi

       env_bg=$PROMPT_CONDA_BG
       env_fg=$PROMPT_CONTEXT_FG
   elif
      [[ -n $__PromptGitCurrentName ]] &&
      whence :python-env:find >/dev/null 2>&1
   then
      :python-env:find "$__PromptGitCurrentName"
      env_status=$?

      case $env_status in
      0)
         env_name=$__PythonEnvType
         env_bg=$PROMPT_VENV_AVAILABLE_BG
         env_fg=$PROMPT_VENV_AVAILABLE_FG
         ;;

      2)
         env_name='venv+conda'
         env_bg=$PROMPT_VENV_AVAILABLE_BG
         env_fg=$PROMPT_VENV_AVAILABLE_FG
         ;;
      esac
   fi

   #
   # Construct environment context.
   #
   if [[ -n $env_name ]]; then
      :prompt:escape "$env_name"
      env_prompt=$__PromptEscaped

      context="%K{${env_bg}}%F{${env_fg}}[${env_prompt}"
      context_text="[${env_name}"
   fi

   #
   # Construct Git context.
   #
   if [[ -n $__PromptGitCurrentName ]]; then
      git_name=$__PromptGitCurrentName
      git_branch=$__PromptGitCurrentBranch

      :prompt:escape "$git_name"
      git_name_prompt=$__PromptEscaped

      :prompt:escape "$git_branch"
      git_branch_prompt=$__PromptEscaped

      if [[ $__PromptGitCurrentKind == submodule ]]; then
         git_bg=$PROMPT_SUBMODULE_BG
      else
         git_bg=$PROMPT_GIT_BG
      fi

      if [[ -n $context ]]; then
         context+="%K{${PROMPT_GIT_SEPARATOR_BG}}%F{${env_bg}}:"
         context+="%K{${git_bg}}%F{${PROMPT_CONTEXT_FG}}${git_name_prompt}"

         context_text+=":${git_name}"
      else
         context="%K{${git_bg}}%F{${PROMPT_CONTEXT_FG}}[${git_name_prompt}"
         context_text="[${git_name}"
      fi

      context+="%K{${PROMPT_GIT_SEPARATOR_BG}}%F{${git_bg}}:"
      context+="%K{${git_bg}}%F{${PROMPT_CONTEXT_FG}}${git_branch_prompt}"

      context_text+=":${git_branch}"
   fi

   if [[ -n $context ]]; then
      context+=']%f%k '
      context_text+='] '
   fi

   #
   # Generate date/time/history text now so the value measured is the
   # same value displayed.
   #
   status_text=$(print -rP -- '%D{%b %e %T} !%!')

   :prompt:escape "$status_text"
   status_prompt=$__PromptEscaped

   #
   # Obtain zsh's named-directory representation of PWD.
   #
   shown_pwd=$(print -rP -- '%~')

   if [[ -n ${PROMPT_END-} ]]; then
      prompt_end=$PROMPT_END
   fi

   #
   # Calculate pathname capacity for the one-line layout:
   #
   #    <context><status> [<pathname>]
   #
   one_line_path_limit=$(( usable_width - timer_width - ${#context_text} - ${#status_text} - 2 - ${#prompt_end} ))

   #
   # A pathname on its own information line has nearly the complete
   # terminal width available.
   #
   two_line_path_limit=$(( usable_width - 1 - ${#prompt_end} ))
   (( two_line_path_limit >= 4 )) || two_line_path_limit=4

   #
   # Prefer one line if the complete pathname fits.
   #
   if (( one_line_path_limit >= ${#shown_pwd} )); then
      one_line_pwd=$shown_pwd

   #
   # Otherwise see whether pfrag can retain at least two pathname
   # components within the available first-line space.
   #
   elif (( one_line_path_limit >= 4 )); then
      one_line_pwd=$(pfrag "$shown_pwd" "$one_line_path_limit")

      if ! :prompt:path-useful "$one_line_pwd"; then
         two_lines=1
      fi

   else
      two_lines=1
   fi

   #
   # If one line does not provide sufficiently useful pathname context,
   # give the pathname its own information line.
   #
   if (( two_lines )); then
      shown_pwd=$(pfrag "$shown_pwd" "$two_line_path_limit")
   else
      shown_pwd=$one_line_pwd
   fi

   :prompt:escape "$shown_pwd"
   shown_pwd_prompt=$__PromptEscaped

   #
   # Optional visual separation from the preceding command output.
   #
   if [[ ${PROMPT_GAP-0} == 1 ]]; then
      prompt_gap=$'\n'
   fi

   #
   # Construct either:
   #
   #    <timer><context><status> [<pathname>]
   #    <command begins in column 1>
   #
   # or:
   #
   #    <timer><context><status>
   #    [<pathname>]
   #    <command begins in column 1>
   #
   if (( two_lines )); then
      PROMPT="${prompt_gap}${timer_prompt}${context}%S${status_prompt}%s"$'\n'
      PROMPT+="%S[${shown_pwd_prompt}${prompt_end}%s"$'\n'
   else
      PROMPT="${prompt_gap}${timer_prompt}${context}%S${status_prompt} [${shown_pwd_prompt}${prompt_end}%s"$'\n'
   fi
}


########################################################################
# Install the precmd hook.
########################################################################

typeset -ga precmd_functions

precmd_functions=(
   ${precmd_functions:#:prompt:precmd}
   :prompt:precmd
)

