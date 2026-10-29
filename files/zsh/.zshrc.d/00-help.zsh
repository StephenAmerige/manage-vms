########################################################################
#
# 00-help.zsh
#
# Provide self-documenting help for services installed in the shell
# environment.
#
# Help topics are implemented as functions named:
#
#    :help:<topic>
#
# For example:
#
#    :help:prompt
#    :help:session
#    :help:tags
#    :help:timer
#    :help:zsh
#
# Available topics are discovered dynamically from the functions that
# have been defined.
#
########################################################################


########################################################################
# :help-wrap-indent <indent> <text> [...]
#
# Display prose wrapped at word boundaries and indented by the specified
# number of columns.
#
# Multiple text arguments are joined with spaces, allowing source text
# to be split across lines for readability.
#
# %B and %b may be used within the text to enable and disable bold.
# These prompt escapes do not count toward the displayed line width.
########################################################################

function :help-wrap-indent
{
   local indent=$1
   shift

   local width=${HELP_WIDTH:-96}
   local prefix=${(l:$indent:: :)}
   local text="$*"
   local word plain
   local line=
   local line_length=0
   local word_length
   local content_width
   local -a words

   if (( ${COLUMNS:-0} > 0 && COLUMNS < width )); then
      width=$COLUMNS
   fi

   (( content_width = width - indent ))

   words=( ${(s: :)text} )

   for word in "${words[@]}"; do
      plain=${word//\%B/}
      plain=${plain//\%b/}
      word_length=${#plain}

      if (( line_length == 0 )); then
         line=$word
         line_length=$word_length
      elif (( line_length + 1 + word_length <= content_width )); then
         line+=" $word"
         (( line_length += 1 + word_length ))
      else
         print -P -r -- "$prefix$line"
         line=$word
         line_length=$word_length
      fi
   done

   [[ -z $line ]] || print -P -r -- "$prefix$line"
}


########################################################################
# :help-wrap <text> [...]
#
# Display prose wrapped at word boundaries without indentation.
########################################################################

function :help-wrap
{
   :help-wrap-indent 0 "$@"
}


########################################################################
# :help-command <text> [...]
#
# Display command syntax using bold, dark-blue text.
########################################################################

function :help-command
{
   local color=${HELP_CODE_FG:-25}

   print -P -r -- "   %F{${color}}%B$*%b%f"
}


########################################################################
# :help-example <text> [...]
#
# Display a literal command or code example using dark-blue text.
########################################################################

function :help-example
{
   local color=${HELP_CODE_FG:-25}

   print -P -r -- "   %F{${color}}$*%f"
}


########################################################################
# :help-topics
#
# Return the available help topics in the reply array.
########################################################################

function :help-topics
{
   local -a help_functions

   reply=()

   help_functions=(
      ${(f)"$(whence -m ':help:*' 2>/dev/null)"}
   )

   reply=(
      ${(o)${help_functions#:help:}}
   )
}


########################################################################
# :help-list
#
# List the available help topics.
########################################################################

function :help-list
{
   local topic

   :help-topics

   if (( ${#reply} == 0 )); then
      print -r -- "No help topics are presently available."
      return 0
   fi

   print -r -- "Available help topics:"
   print

   for topic in "${reply[@]}"; do
      print -r -- "   $topic"
   done

   print
   print -r -- 'Use "help <topic>" for more information.'
}


########################################################################
# :help-usage
#
# Show help-command usage.
########################################################################

function :help-usage
{
   print -rl -- \
      "Help" \
      "" \
      "Usage:" \
      "   help <topic>     Show help for <topic>" \
      "   help -l          List available help topics" \
      "" \
      "Examples:" \
      "   help zsh" \
      "   help prompt" \
      "   help session" \
      "   help timer" \
      "   help tags" \
      "" \
      'Use "help -l" to list the available help topics.'
}


########################################################################
# :help-page <function>
#
# Display the output from a help function through a pager when stdout
# is attached to a terminal.
#
# Prefer less, then more. If neither is available, display the help
# directly.
#
# less options:
#
#    -F    Exit automatically if the text fits on one screen
#    -R    Preserve ANSI color sequences
#    -X    Leave the displayed text on the screen after exiting
#
# Do not invoke a pager when help output has been redirected or piped.
########################################################################

function :help-page
{
   local help_function=$1

   #
   # PIPE_FAIL can cause an otherwise successful help command to report
   # failure if a user quits a pager before all input has been consumed.
   # Make the pipeline status depend upon the pager instead.
   #
   setopt localoptions
   unsetopt pipefail

   if [[ -t 1 ]] && whence -p less >/dev/null 2>&1; then
      "$help_function" | command less -FRX
   elif [[ -t 1 ]] && whence -p more >/dev/null 2>&1; then
      "$help_function" | command more
   else
      "$help_function"
   fi
}


########################################################################
# help [option | topic]
#
# Show help for a configured shell service.
#
# Interactive output is automatically displayed through less when
# available, otherwise more. Redirected or piped output is written
# directly.
########################################################################

function help
{
   local topic
   local help_function

   if (( $# == 0 )); then
      :help-page :help-usage
      return $?
   fi

   if (( $# != 1 )); then
      print -u2 -r -- "Usage: help <topic> | help -l"
      return 2
   fi

   if [[ $1 == -l ]]; then
      :help-page :help-list
      return $?
   fi

   if [[ $1 == -* ]]; then
      print -u2 -r -- "Unknown help option: $1"
      print -u2 -r -- "Usage: help <topic> | help -l"
      return 2
   fi

   topic=$1
   help_function=":help:$topic"

   if whence "$help_function" >/dev/null 2>&1; then
      :help-page "$help_function"
      return $?
   fi

   print -u2 -r -- "No help is available for: $topic"
   print -u2 -r -- 'Use "help -l" to list the available help topics.'
   return 1
}

