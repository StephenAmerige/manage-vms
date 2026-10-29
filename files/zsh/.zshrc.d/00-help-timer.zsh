########################################################################
#
# 00-help-timer.zsh
#
# Explain the extensible prompt timer service.
#
########################################################################


########################################################################
# :help:timer
#
# Explain timer selection, behavior, and extension.
########################################################################

function :help:timer
{
   local timer_bg=${PROMPT_TIMER_BG:-220}
   local timer_fg=${PROMPT_TIMER_FG:-0}

   print -P -- "%BPrompt Timers%b"
   print

   :help-wrap-indent 3 \
      "The %Btimer%b command selects an optional timer service whose value may" \
      "be displayed as the first item in the dynamic prompt."
   print

   print -P -- \
      "   %K{${timer_bg}}%F{${timer_fg}}[03:42:17]%f%k [venv:repo:branch] Sep 15 14:32:01 !3372 [~project]"
   print

   :help-wrap-indent 3 \
      "The timer is independent of the prompt implementation. Timer providers" \
      "are functions named %B:timer:<name>%b. The prompt displays the selected" \
      "timer only when that provider reports a value."
   print

   print -P -- "%BUsage%b"
   print

   :help-command "timer <name>"
   :help-wrap-indent 6 \
      "Select the named timer provider."
   print

   :help-command "timer off"
   :help-wrap-indent 6 \
      "Disable timer display."
   print

   :help-command "timer status"
   :help-wrap-indent 6 \
      "Display the currently selected timer, or report that timers are off."
   print

   :help-command "timer"
   :help-wrap-indent 6 \
      "Display timer-command usage."
   print

   print -P -- "%BSlurm timer%b"
   print

   :help-command "timer slurm"
   :help-wrap-indent 6 \
      "Select the Slurm timer. When running inside a Slurm job, the prompt" \
      "displays the allocation time remaining as reported by %Bsqueue%b."
   print

   :help-wrap-indent 3 \
      "Outside a Slurm allocation, the Slurm timer produces no prompt field." \
      "It may therefore remain selected while moving between login shells and" \
      "interactive Slurm jobs."
   print

   :help-wrap-indent 3 \
      "The %Bsession%b command automatically selects the Slurm timer for the" \
      "interactive child shell that it starts. The timer selection of the" \
      "parent login shell is not changed."
   print

   print -P -- "%BTimer providers%b"
   print

   :help-wrap-indent 3 \
      "A timer provider is a function whose name begins with %B:timer:%b followed" \
      "by a lowercase timer name."
   print

   :help-example "function :timer:example"
   :help-example "{"
   :help-example "   REPLY=..."
   :help-example "}"
   print

   :help-wrap-indent 3 \
      "A provider places the text to be displayed in %BREPLY%b and returns zero" \
      "when the timer should appear. Returning nonzero suppresses the timer for" \
      "that prompt."
   print

   :help-wrap-indent 3 \
      "This allows timer implementations to represent different kinds of" \
      "remaining time without requiring changes to the prompt itself."
   print

   print -P -- "%BPrompt behavior%b"
   print

   :help-wrap-indent 3 \
      "When a timer is active, it is displayed first with a yellow background" \
      "and black text by default. Its width participates in the prompt's" \
      "adaptive layout calculation, so pathname shortening and one-line versus" \
      "two-line selection continue to account for the complete visible prompt."
   print

   :help-wrap-indent 3 \
      "Timer colors may be customized with %BPROMPT_TIMER_BG%b and" \
      "%BPROMPT_TIMER_FG%b."
   print

   print -P -- "%BExamples%b"
   print

   :help-example "timer slurm"
   :help-wrap-indent 6 \
      "Select the Slurm allocation-time-remaining timer."
   print

   :help-example "timer status"
   :help-wrap-indent 6 \
      "Show the currently selected timer."
   print

   :help-example "timer off"
   :help-wrap-indent 6 \
      "Disable timer display."
}

