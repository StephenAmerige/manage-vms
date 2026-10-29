########################################################################
#
# 00-help-prompt.zsh
#
# Explain the dynamic zsh prompt and its visual conventions.
#
########################################################################


########################################################################
# :help:prompt
#
# Explain the information represented by the shell prompt.
########################################################################

function :help:prompt
{
   local available_bg=${PROMPT_VENV_AVAILABLE_BG:-94}
   local venv_bg=${PROMPT_VENV_BG:-33}
   local conda_bg=${PROMPT_CONDA_BG:-208}
   local git_bg=${PROMPT_GIT_BG:-28}
   local submodule_bg=${PROMPT_SUBMODULE_BG:-93}
   local separator_bg=${PROMPT_GIT_SEPARATOR_BG:-15}
   local context_fg=${PROMPT_CONTEXT_FG:-15}
   local timer_bg=${PROMPT_TIMER_BG:-220}
   local timer_fg=${PROMPT_TIMER_FG:-0}

   print -P -- "%BZsh Prompt%b"
   print

   :help-wrap-indent 3 \
      "The prompt continuously displays useful development context without" \
      "requiring separate commands to determine an active timer, the current" \
      "Python environment, Git repository, Git branch, or working directory."
   print

   :help-wrap-indent 3 \
      "Prompt information occupies one or two lines. The command being entered" \
      "always begins in column 1 on the line following the prompt."
   print

   print -P -- "%BPrompt layout%b"
   print

   :help-wrap-indent 3 \
      "The prompt normally uses a single information line containing an optional" \
      "timer, development context, date and time, shell history number, and the" \
      "current directory."
   print

   print -r -- \
      "   [2:59:54] [venv:repo:branch] Sep 15 10:26:22 !3504 [.../project/src]"
   print

   :help-wrap-indent 3 \
      "The layout adapts automatically to the width of the terminal. If the" \
      "current directory cannot be shortened while retaining sufficiently useful" \
      "pathname information, the directory is moved to a second information line."
   print

   print -r -- \
      "   [2:59:54] [venv:repo:long-feature-branch] Sep 15 10:26:22 !3505" \
      "   [.../project/ondemand/project/template]"
   print

   :help-wrap-indent 3 \
      "When shortening is required, the one-line form is preferred as long as" \
      "at least two pathname components can be retained. Otherwise the pathname" \
      "receives its own line, where substantially more of it can be displayed."
   print

   :help-wrap-indent 3 \
      "Resizing the terminal therefore may cause subsequent prompts to change" \
      "automatically between the one-line and two-line forms."
   print

   print -P -- "%BPrompt spacing%b"
   print

   :help-wrap-indent 3 \
      "A blank line can optionally be inserted before each prompt. This visually" \
      "separates the output of one command from the prompt for the next command."
   print

   :help-command "pgap"
   :help-wrap-indent 6 \
      "Toggle the prompt gap on or off."
   print

   :help-command "pgap on"
   :help-wrap-indent 6 \
      "Enable a blank line before each prompt."
   print

   :help-command "pgap off"
   :help-wrap-indent 6 \
      "Disable the blank line before each prompt."
   print

   :help-command "pgap status"
   :help-wrap-indent 6 \
      "Display whether the prompt gap is presently enabled or disabled."
   print

   :help-wrap-indent 3 \
      "The distributed default is off. A user who prefers the gap may make the" \
      "choice persistent by placing the following in a user configuration file" \
      "such as %B\$HOME/.zshrc.d/ff-user.zsh%b:"
   print

   :help-example "pgap on &>/dev/null"
   print

   print -P -- "%BPrompt timers%b"
   print

   :help-wrap-indent 3 \
      "A selected timer may appear as the first prompt element. Timers are" \
      "optional and are displayed only when the selected timer has a value to" \
      "show."
   print

   print -P -- \
      "   %K{${timer_bg}}%F{${timer_fg}}[2:59:54]%f%k [venv:repo:branch] Sep 15 10:26:22 !3504 [~project]"
   print

   :help-wrap-indent 3 \
      "The distributed timer color is yellow with black text. The timer is" \
      "included in prompt-width calculations, so displaying a timer may cause" \
      "a long pathname to move to the second information line."
   print

   :help-command "timer name"
   :help-wrap-indent 6 \
      "Select the timer implemented by %B:timer:name%b."
   print

   :help-command "timer off"
   :help-wrap-indent 6 \
      "Disable timer display."
   print

   :help-command "timer status"
   :help-wrap-indent 6 \
      "Display the currently selected timer, or indicate that timers are off."
   print

   :help-command "timer slurm"
   :help-wrap-indent 6 \
      "Select the distributed Slurm timer. Inside a Slurm allocation it displays" \
      "the scheduler's current time remaining. Outside a Slurm allocation it" \
      "quietly contributes nothing to the prompt."
   print

   :help-wrap-indent 3 \
      "Additional timers can be provided by defining functions named" \
      "%B:timer:name%b. A timer returns success and places its display text in" \
      "%BREPLY%b when it has something to show; otherwise it returns nonzero."
   print

   print -P -- "%BDevelopment context%b"
   print

   :help-wrap-indent 3 \
      "The colored development-context portion describes the current Python" \
      "environment and Git context. It follows an active timer when one is" \
      "displayed. Text identifies the environment, repository, or branch while" \
      "background color communicates its type or state."
   print

   print -P -- "%BPython virtual environments%b"
   print

   print -P -- \
      "   %K{${available_bg}}%F{${context_fg}}[venv"\
"%K{${separator_bg}}%F{${available_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}repo"\
"%K{${separator_bg}}%F{${git_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}branch]%f%k"

   :help-wrap-indent 6 \
      "A venv matching the current Git repository is available, but is not" \
      "active. Brown indicates availability without activation."
   print

   print -P -- \
      "   %K{${venv_bg}}%F{${context_fg}}[venv"\
"%K{${separator_bg}}%F{${venv_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}repo"\
"%K{${separator_bg}}%F{${git_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}branch]%f%k"

   :help-wrap-indent 6 \
      "The venv matching the current Git repository is active. Blue indicates" \
      "an active Python venv."
   print

   print -P -- \
      "   %K{${venv_bg}}%F{${context_fg}}[plantmap3d"\
"%K{${separator_bg}}%F{${venv_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}repo"\
"%K{${separator_bg}}%F{${git_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}branch]%f%k"

   :help-wrap-indent 6 \
      "A different explicitly selected venv named %Bplantmap3d%b is active." \
      "Its actual name is displayed because it does not match the current Git" \
      "repository."
   print

   print -P -- "%BManaging Python virtual environments%b"
   print

   :help-command "vstart"
   :help-wrap-indent 6 \
      "Activate the venv associated with the current Git repository. If the" \
      "prompt shows %Bvenv%b with a brown background, successful activation" \
      "changes the same indication to blue."
   print

   :help-command "vstart name"
   :help-wrap-indent 6 \
      "Activate the named venv by searching the directories configured in" \
      "%BVENV_DIRS%b. If the selected venv does not match the current Git" \
      "repository, its actual name appears in the blue prompt section."
   print

   :help-command "vstop"
   :help-wrap-indent 6 \
      "Deactivate the current Python venv or Conda environment. If a matching" \
      "venv remains available for the current Git repository, the brown" \
      "%Bvenv%b indication reappears automatically."
   print

   print -P -- "%BVirtual environment configuration%b"
   print

   :help-wrap-indent 3 \
      "Directories containing named Python venv environments are specified in" \
      "%B\$HOME/.zshrc.d/e0-python-env.zsh%b using the %BVENV_DIRS%b array." \
      "The directories are searched in the order in which they are listed."
   print

   :help-wrap-indent 3 \
      "For example, if the current Git repository is named %Bproject%b and one" \
      "of the configured directories contains %Bproject/bin/activate%b, the" \
      "prompt automatically indicates that a matching venv is available."
   print

   print -P -- "%BConda environments%b"
   print

   print -P -- \
      "   %K{${conda_bg}}%F{${context_fg}}[analysis"\
"%K{${separator_bg}}%F{${conda_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}repo"\
"%K{${separator_bg}}%F{${git_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}branch]%f%k"

   :help-wrap-indent 6 \
      "The Conda environment named %Banalysis%b is active. Orange identifies" \
      "an active Conda environment."
   print

   print -P -- "%BGit repositories%b"
   print

   print -P -- \
      "   %K{${git_bg}}%F{${context_fg}}[repo"\
"%K{${separator_bg}}%F{${git_bg}}:"\
"%K{${git_bg}}%F{${context_fg}}branch]%f%k"

   :help-wrap-indent 6 \
      "The current directory is within the Git repository %Brepo%b on branch" \
      "%Bbranch%b. Green identifies an ordinary Git repository."
   print

   :help-wrap-indent 3 \
      "Git information is refreshed automatically. Commands such as" \
      "%Bgit switch%b that change the current branch are reflected in the next" \
      "prompt even though the working directory did not change."
   print

   print -P -- "%BGit submodules%b"
   print

   print -P -- \
      "   %K{${submodule_bg}}%F{${context_fg}}[repo-submodule"\
"%K{${separator_bg}}%F{${submodule_bg}}:"\
"%K{${submodule_bg}}%F{${context_fg}}branch]%f%k"

   :help-wrap-indent 6 \
      "The current directory is within the Git submodule %Brepo-submodule%b" \
      "on branch %Bbranch%b. Purple distinguishes a Git submodule from an" \
      "ordinary repository."
   print

   print -P -- "%BColors%b"
   print

   print -P -- \
      "   %K{${timer_bg}}%F{${timer_fg}} yellow %f%k  active timer"

   print -P -- \
      "   %K{${available_bg}}%F{${context_fg}} brown  %f%k  venv available but inactive"

   print -P -- \
      "   %K{${venv_bg}}%F{${context_fg}} blue   %f%k  active Python venv"

   print -P -- \
      "   %K{${conda_bg}}%F{${context_fg}} orange %f%k  active Conda environment"

   print -P -- \
      "   %K{${git_bg}}%F{${context_fg}} green  %f%k  Git repository"

   print -P -- \
      "   %K{${submodule_bg}}%F{${context_fg}} purple %f%k  Git submodule"

   print

   :help-wrap-indent 3 \
      "A colon on a white background separates adjacent pieces of development" \
      "context. The colon itself has the color of the section immediately" \
      "before it."
   print

   print -P -- "%BDate, history, and directory%b"
   print

   :help-wrap-indent 3 \
      "Following any active timer and the colored development context, the" \
      "prompt shows the current date and time, the shell history number, and the" \
      "current working directory."
   print

   print -r -- \
      "   Sep 11 07:15:32 !3001 [~project/src]"
   print

   :help-wrap-indent 3 \
      "The history number can be used with normal Zsh history facilities and" \
      "also provides a convenient visual sequence number for commands issued" \
      "during the session."
   print

   print -P -- "%BDirectory display%b"
   print

   :help-wrap-indent 3 \
      "The directory is first rendered using %Bzsh named-directory expansion%b." \
      "A configured directory tag may therefore appear as %B~name%b rather than" \
      "as its complete filesystem pathname."
   print

   :help-wrap-indent 3 \
      "When the pathname is too long for the available terminal width, it is" \
      "shortened at a directory boundary when possible. An ellipsis at the" \
      "beginning indicates that leading pathname components have been omitted."
   print

   print -r -- \
      "   [.../orgname/projname/template]"
   print

   :help-wrap-indent 3 \
      "The prompt prefers the one-line layout whenever the complete pathname" \
      "fits or the shortened pathname can retain at least two useful directory" \
      "components. Otherwise the pathname is placed on its own information line."
   print

   print -P -- "%BTerminal resizing%b"
   print

   :help-wrap-indent 3 \
      "The prompt uses the current terminal width when deciding its layout." \
      "Widening the terminal may cause the next prompt to return to a one-line" \
      "form, while narrowing it may move the pathname to a second line."
   print

   :help-wrap-indent 3 \
      "%BPROMPT_MARGIN%b reserves a small amount of unused space at the right" \
      "edge of the terminal. Its distributed default is 2 columns."
   print

   print -P -- "%BExamples%b"
   print

   :help-example "cd ~project"
   :help-wrap-indent 6 \
      "Enter a tagged directory. Git and matching-venv information appear" \
      "automatically when applicable."
   print

   :help-example "git switch feature/new-work"
   :help-wrap-indent 6 \
      "Change branches. The next prompt immediately displays the new branch."
   print

   :help-example "vstart"
   :help-wrap-indent 6 \
      "Activate the venv matching the current repository. Brown %Bvenv%b changes" \
      "to blue."
   print

   :help-example "vstop"
   :help-wrap-indent 6 \
      "Deactivate the environment. Brown %Bvenv%b reappears if the matching" \
      "environment remains available."
   print

   :help-example "timer slurm"
   :help-wrap-indent 6 \
      "Display Slurm time remaining when the shell is running inside a Slurm" \
      "allocation."
   print

   :help-example "timer off"
   :help-wrap-indent 6 \
      "Disable the prompt timer."
   print

   :help-example "pgap"
   :help-wrap-indent 6 \
      "Toggle visual separation between command output and subsequent prompts."
}

