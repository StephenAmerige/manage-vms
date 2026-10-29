########################################################################
#
# 00-help-session.zsh
#
# Explain the Slurm interactive session helper.
#
########################################################################


########################################################################
# :help:session
#
# Explain how to start and customize interactive Slurm sessions.
########################################################################

function :help:session
{
   print -P -- "%BSlurm Sessions%b"
   print

   :help-wrap-indent 3 \
      "The %Bsession%b command starts an interactive Slurm job using" \
      "%Bsrun --pty%b and launches the configured shell on the allocated" \
      "compute node."
   print

   :help-wrap-indent 3 \
      "A small set of predefined resource profiles provides convenient" \
      "defaults for CPU count, memory, and session duration. Individual" \
      "values may be overridden on the command line."
   print

   print -P -- "%BUsage%b"
   print

   :help-command "session [<profile>] [OPTIONS]"
   print

   :help-wrap-indent 3 \
      "With no arguments, %Bsession%b displays its built-in usage information." \
      "If options are supplied without an explicit profile, the %Bs%b profile" \
      "is used as the default."
   print

   print -P -- "%BProfiles%b"
   print

   print -rl -- \
      "   xs     1 CPU    2G    02:00:00" \
      "   s      2 CPUs   4G    05:00:00   default" \
      "   m      4 CPUs   8G    05:00:00" \
      "   l      8 CPUs   16G   05:00:00" \
      "   xl     16 CPUs  32G   05:00:00" \
      "   2xl    32 CPUs  64G   05:00:00"
   print

   :help-wrap-indent 3 \
      "Profiles are intended as convenient starting points. Resource values" \
      "may be adjusted independently with command-line options."
   print

   print -P -- "%BOptions%b"
   print

   :help-command "-c, --cpus <count>"
   :help-wrap-indent 6 \
      "Override the number of CPUs requested for the task."
   print

   :help-command "-m, --mem <GB>"
   :help-wrap-indent 6 \
      "Override the memory request. A bare number is interpreted as gigabytes." \
      "For example, %B-m 8%b becomes %B--mem=8G%b."
   print

   :help-command "-t, --time <time>"
   :help-wrap-indent 6 \
      "Override the session duration. A single number specifies whole hours." \
      "A value containing a colon specifies hours and minutes."
   print

   :help-command "-h, --help"
   :help-wrap-indent 6 \
      "Display the built-in session usage information."
   print

   print -P -- "%BTime input%b"
   print

   :help-wrap-indent 3 \
      "Session time is normalized to the form required by Slurm:"
   print

   print -rl -- \
      "   5        -> 05:00:00" \
      "   5:30     -> 05:30:00" \
      "   12:15    -> 12:15:00"
   print

   print -P -- "%BMemory input%b"
   print

   :help-wrap-indent 3 \
      "Memory may be entered as a bare number of gigabytes. The %BG%b suffix" \
      "is added automatically before invoking Slurm."
   print

   print -rl -- \
      "   4        -> 4G" \
      "   8        -> 8G" \
      "   32       -> 32G"
   print

   print -P -- "%BConfiguration%b"
   print

   :help-wrap-indent 3 \
      "The session service requires two user-defined global variables." \
      "They are intentionally not defined by the distributed shell" \
      "configuration because both values are installation- and user-specific." \
      "They should normally be placed in a user configuration file such as" \
      "%B\$HOME/.zshrc.d/ff-user.zsh%b."
   print

   :help-example "typeset -g _SessionAccount=my_project"
   :help-example "typeset -g _SessionShell=/path/to/zsh"
   print

   :help-wrap-indent 3 \
      "%B_SessionAccount%b specifies the Slurm account or project passed to" \
      "%Bsrun -A%b when requesting the interactive allocation."
    print

   :help-wrap-indent 3 \
      "%B_SessionShell%b specifies the executable shell started on the allocated" \
      "compute node. This is useful on systems where the preferred zsh is not" \
       "the user's login shell or is installed at a site-specific pathname."
   print

   print -P -- "%BSlurm timer integration%b"
   print

   :help-wrap-indent 3 \
      "Interactive sessions automatically select the %Bslurm%b timer for the" \
      "child shell. When timer and prompt support are installed, the prompt" \
      "therefore displays the remaining Slurm allocation time."
   print

   :help-wrap-indent 3 \
      "The timer is applied to the compute-node shell without changing the" \
      "timer selection in the parent login shell."
   print

   print -P -- "%BExamples%b"
   print

   :help-example "session s"
   :help-wrap-indent 6 \
      "Start the small profile using 2 CPUs, 4G of memory, and a 5-hour limit."
   print

   :help-example "session -m 8"
   :help-wrap-indent 6 \
      "Use the default small profile but request 8G of memory."
   print

   :help-example "session l -c 4"
   :help-wrap-indent 6 \
      "Use the large profile but override its CPU count to 4."
   print

   :help-example "session xl -t 2"
   :help-wrap-indent 6 \
      "Use the extra-large profile with a 2-hour time limit."
   print

   :help-example "session m -t 5:30"
   :help-wrap-indent 6 \
      "Use the medium profile with a 5-hour, 30-minute time limit."
}

