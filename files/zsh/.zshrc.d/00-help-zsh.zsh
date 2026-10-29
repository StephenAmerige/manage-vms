########################################################################
#
# 00-help-zsh.zsh
#
# Provide an overview of the developer-productivity enhancements
# supplied by this zsh configuration.
#
########################################################################


########################################################################
# :help:zsh
#
# Explain the major interactive features provided by the installed zsh
# configuration and point to more detailed help topics where available.
########################################################################

function :help:zsh
{
   print -P -- "%BZsh Developer Productivity Environment%b"
   print

   :help-wrap-indent 3 \
      "This configuration extends the Zsh shell with features intended to" \
      "make interactive command-line work faster and more informative for" \
      "software developers. It provides dynamic development context, prompt" \
      "timers, interactive Slurm sessions, directory tags, Python environment" \
      "management, directory-stack navigation, command and pathname utilities," \
      "persistent history, completion, and other shell productivity enhancements."
   print

   :help-wrap-indent 3 \
      "These files configure Zsh; they do not install Zsh itself. The %Bzsh%b" \
      "command must already be available on the system."
   print

   print -P -- "%BGetting help%b"
   print

   :help-command "help"
   :help-wrap-indent 6 \
      "Show basic help-system usage."
   print

   :help-command "help -l"
   :help-wrap-indent 6 \
      "List all currently installed help topics."
   print

   :help-command "help zsh"
   :help-wrap-indent 6 \
      "Show this overview."
   print

   :help-command "help prompt"
   :help-wrap-indent 6 \
      "Explain the dynamic developer prompt, timers, Git information, Python" \
      "environments, prompt colors, adaptive layout, and prompt spacing."
   print

   :help-command "help session"
   :help-wrap-indent 6 \
      "Explain interactive Slurm sessions, resource profiles, overrides, and" \
      "required user configuration."
   print

   :help-command "help timer"
   :help-wrap-indent 6 \
      "Explain prompt timers, timer selection, the Slurm timer, and how timer" \
      "providers may be extended."
   print

   :help-command "help tags"
   :help-wrap-indent 6 \
      "Explain persistent named-directory tags and how they are created," \
      "listed, used, changed, and removed."
   print

   print -P -- "%BConfiguration layout%b"
   print

   :help-wrap-indent 3 \
      "The primary startup file is %B\$HOME/.zshrc%b. Additional services are" \
      "kept in %B\$HOME/.zshrc.d%b so that individual features can be maintained" \
      "independently rather than accumulating in one large startup file."
   print

   :help-wrap-indent 3 \
      "Files numbered %B00%b through %B99%b are intended for packaged or" \
      "persistent system configuration. Files numbered %Ba0%b through %Bff%b" \
      "are available for user-specific configuration and persistent data."
   print

   :help-example '$HOME/.zshrc.d/a0-tags.zsh'
   :help-example '$HOME/.zshrc.d/e0-python-env.zsh'
   :help-example '$HOME/.zshrc.d/ff-timer.zsh'
   :help-example '$HOME/.zshrc.d/ff-user.zsh'
   print

   print -P -- "%BDynamic developer prompt%b"
   print

   :help-wrap-indent 3 \
      "The prompt continuously reflects development context such as Python" \
      "environments, Git repositories, branches, Git submodules, date and time," \
      "shell history number, and the current working directory. An optional" \
      "leading timer can display time-sensitive context such as remaining Slurm" \
      "allocation time."
   print

   :help-wrap-indent 3 \
      "Commands always begin in column 1 on the line following the prompt." \
      "The prompt itself automatically chooses between one and two information" \
      "lines according to the current terminal width and the amount of useful" \
      "pathname information that can be retained."
   print

   :help-wrap-indent 3 \
      "When sufficient space is available, the prompt remains on one information" \
      "line. If shortening the pathname would leave too little useful directory" \
      "context, the pathname is moved to a second information line."
   print

   :help-wrap-indent 3 \
      "Resizing the terminal can therefore cause subsequent prompts to change" \
      "automatically between the one-line and two-line forms."
   print

   :help-wrap-indent 3 \
      "Prompt state is refreshed automatically. Changing Git branches," \
      "activating or deactivating a Python environment, or entering another" \
      "repository does not require a separate prompt-refresh command."
   print

   :help-command "pgap"
   :help-wrap-indent 6 \
      "Toggle insertion of a blank line before each prompt. The blank line can" \
      "make command output and subsequent prompts easier to distinguish."
   print

   :help-command "pgap on"
   :help-command "pgap off"
   :help-wrap-indent 6 \
      "Explicitly enable or disable prompt spacing."
   print

   :help-command "pgap status"
   :help-wrap-indent 6 \
      "Show whether prompt spacing is currently enabled."
   print

   :help-wrap-indent 3 \
      "Prompt spacing is disabled by default. A user who prefers it may enable" \
      "it persistently from a user configuration file such as" \
      "%B\$HOME/.zshrc.d/ff-user.zsh%b."
   print

   :help-example "pgap on &>/dev/null"
   print

   :help-command "help prompt"
   :help-wrap-indent 6 \
      "Show the complete explanation of prompt colors, timers, layout, pathname" \
      "shortening, Python environments, and Git behavior."
   print

   print -P -- "%BPrompt timers%b"
   print

   :help-wrap-indent 3 \
      "The prompt can display an optional timer as its first information field." \
      "Timer providers are selected by name and are independent of the prompt" \
      "implementation."
   print

   :help-command "timer slurm"
   :help-wrap-indent 6 \
      "Select the Slurm timer. Inside a Slurm job, it displays the allocation" \
      "time remaining as reported by Slurm."
   print

   :help-command "timer status"
   :help-wrap-indent 6 \
      "Display the currently selected timer."
   print

   :help-command "timer off"
   :help-wrap-indent 6 \
      "Disable timer display."
   print

   :help-command "help timer"
   :help-wrap-indent 6 \
      "Explain timer selection, Slurm timer behavior, colors, and the" \
      "%B:timer:<name>%b extension convention."
   print

   print -P -- "%BInteractive Slurm sessions%b"
   print

   :help-wrap-indent 3 \
      "The %Bsession%b command starts an interactive Slurm allocation using" \
      "%Bsrun --pty%b and launches the configured shell on the allocated compute" \
      "node. Predefined profiles provide convenient CPU, memory, and time values."
   print

   :help-command "session s"
   :help-wrap-indent 6 \
      "Start the default small profile."
   print

   :help-command "session l -c 4"
   :help-wrap-indent 6 \
      "Start the large profile while overriding the requested CPU count."
   print

   :help-command "session -m 8"
   :help-wrap-indent 6 \
      "Use the default profile while overriding memory to 8G."
   print

   :help-command "session m -t 5:30"
   :help-wrap-indent 6 \
      "Start the medium profile with a 5-hour, 30-minute time limit."
   print

   :help-wrap-indent 3 \
      "The service requires user-defined %B_SessionAccount%b and" \
      "%B_SessionShell%b variables, normally configured in" \
      "%B\$HOME/.zshrc.d/ff-user.zsh%b. Interactive sessions automatically" \
      "select the Slurm timer for the child shell."
   print

   :help-command "help session"
   :help-wrap-indent 6 \
      "Show complete session profiles, options, input conversions, and" \
      "configuration requirements."
   print

   print -P -- "%BDirectory tags%b"
   print

   :help-wrap-indent 3 \
      "Directory tags use Zsh named-directory expansion to give frequently used" \
      "directories short persistent names. A tag may be used anywhere a normal" \
      "pathname can be used."
   print

   :help-example "tag project /path/to/project"
   :help-example "cd ~project"
   :help-example "vim ~project/README.md"
   print

   :help-command "tag"
   :help-wrap-indent 6 \
      "List the currently defined persistent directory tags."
   print

   :help-command "tag name"
   :help-wrap-indent 6 \
      "Associate a tag with the current working directory."
   print

   :help-command "tag name directory"
   :help-wrap-indent 6 \
      "Associate a tag with the specified directory."
   print

   :help-command "rmtag name"
   :help-wrap-indent 6 \
      "Remove a persistent directory tag."
   print

   :help-command "help tags"
   :help-wrap-indent 6 \
      "Show complete directory-tag help."
   print

   print -P -- "%BPython virtual environments%b"
   print

   :help-wrap-indent 3 \
      "The prompt can detect a Python venv whose name matches the current Git" \
      "repository. An available but inactive matching environment is displayed" \
      "in brown. An active Python venv is displayed in blue. An active Conda" \
      "environment is displayed in orange."
   print

   :help-command "vstart"
   :help-wrap-indent 6 \
      "Activate the venv whose name matches the current Git repository."
   print

   :help-command "vstart name"
   :help-wrap-indent 6 \
      "Activate the named venv by searching the directories in %BVENV_DIRS%b."
   print

   :help-command "vstop"
   :help-wrap-indent 6 \
      "Deactivate the current Python venv or Conda environment."
   print

   :help-wrap-indent 3 \
      "The ordered list of directories containing Python venv environments is" \
      "configured using %BVENV_DIRS%b in" \
      "%B\$HOME/.zshrc.d/e0-python-env.zsh%b."
   print

   print -P -- "%BDirectory navigation and stack%b"
   print

   :help-wrap-indent 3 \
      "The directory stack provides fast movement among directories that are" \
      "being used during a development session."
   print

   :help-command "d"
   :help-wrap-indent 6 \
      "Display the directory stack with numbered entries."
   print

   :help-command "push directory"
   :help-wrap-indent 6 \
      "Push the current location onto the directory stack and move to the" \
      "specified directory."
   print

   :help-command "push -r directory"
   :help-wrap-indent 6 \
      "Resolve the specified pathname before pushing it."
   print

   :help-command "pop"
   :help-wrap-indent 6 \
      "Pop the current directory-stack entry and display the resulting stack."
   print

   :help-command "r"
   :help-wrap-indent 6 \
      "Rotate to the next directory in the directory stack."
   print

   :help-command "r number"
   :help-wrap-indent 6 \
      "Rotate to the specified numbered directory-stack entry."
   print

   :help-wrap-indent 3 \
      "Duplicate pushd entries are suppressed and normal pushd/popd stack" \
      "output is kept quiet; the %Bd%b display provides the numbered view."
   print

   print -P -- "%BCommand-path utilities%b"
   print

   :help-command "path"
   :help-wrap-indent 6 \
      "Display the directories in PATH, one per line."
   print

   :help-command "path command ..."
   :help-wrap-indent 6 \
      "Display the first executable pathname found in PATH for each specified" \
      "command."
   print

   :help-command "path -a command ..."
   :help-wrap-indent 6 \
      "Display all executable pathname matches."
   print

   :help-command "path -d command ..."
   :help-wrap-indent 6 \
      "Display only the directory containing each matching executable."
   print

   :help-command "is name ..."
   :help-wrap-indent 6 \
      "Show how each specified name is resolved, including aliases, shell" \
      "functions, executables in PATH, and other command types."
   print

   print -P -- "%BFile display utilities%b"
   print

   :help-command "ls"
   :help-wrap-indent 6 \
      "Display files using color and file-type indicators."
   print

   :help-command "la"
   :help-wrap-indent 6 \
      "Display non-dot and dot entries except . and .. using the compact" \
      "listing format."
   print

   :help-command "ll"
   :help-wrap-indent 6 \
      "Display a long file listing."
   print

   :help-command "lla"
   :help-wrap-indent 6 \
      "Display a long listing including dot files."
   print

   :help-command "lL"
   :help-wrap-indent 6 \
      "Display a long listing while following symbolic links."
   print

   :help-command "lf [directory ...]"
   :help-wrap-indent 6 \
      "Recursively find regular files. With no argument, search from the" \
      "current directory."
   print

   print -P -- "%BFile timestamps%b"
   print

   :help-command "timestamp"
   :help-wrap-indent 6 \
      "Print the current time as seconds since the Unix epoch."
   print

   :help-command "timestamp file"
   :help-wrap-indent 6 \
      "Print the file modification time as seconds since the Unix epoch."
   print

   :help-command "timestamp file1 file2"
   :help-wrap-indent 6 \
      "Return success if the two files have identical modification times." \
      "This form produces no output."
   print

   print -P -- "%BPathname shortening%b"
   print

   :help-wrap-indent 3 \
      "The prompt determines pathname width dynamically from the current terminal" \
      "width. It does not use %BPATH_LIMIT%b when deciding how much of the current" \
      "directory to display."
   print

   :help-wrap-indent 3 \
      "When a displayed pathname must be shortened, leading components are" \
      "removed at a directory boundary when possible and an ellipsis is added." \
      "Named-directory expansion is performed first, allowing tags such as" \
      "%B~project%b to preserve useful context while consuming little space."
   print

   :help-example ".../orgname/projname/template"
   print

   :help-wrap-indent 3 \
      "The %Bpfrag%b utility may also be used independently to shorten a pathname." \
      "When called without an explicit length, it uses %BPATH_LIMIT%b as its" \
      "default maximum pathname length."
   print

   :help-command "plimit"
   :help-wrap-indent 6 \
      "Display the current PATH_LIMIT value used by pfrag when no explicit" \
      "length is supplied."
   print

   :help-command "plimit number"
   :help-wrap-indent 6 \
      "Set PATH_LIMIT for direct uses of pfrag. Changing this value does not" \
      "change the adaptive pathname width used by the prompt."
   print

   print -P -- "%BHistory and command-line editing%b"
   print

   :help-wrap-indent 3 \
      "A large persistent command history is maintained and shared among active" \
      "Zsh sessions. Adjacent duplicate commands are not saved, and a command" \
      "whose first character is a space is omitted from the saved history."
   print

   :help-command "h"
   :help-wrap-indent 6 \
      "Display command history with event numbers and timestamps."
   print

   :help-wrap-indent 3 \
      "Zsh's line editor is configured for %Bvi-style editing%b. Completion" \
      "menus and interactive comments are enabled, and numeric portions of" \
      "filenames are sorted numerically."
   print

   print -P -- "%BUseful aliases and commands%b"
   print

   :help-command ".."
   :help-wrap-indent 6 \
      "Re-source %B\$HOME/.zshrc%b. In this configuration, %B..%b reloads the" \
      "shell configuration; it does not mean \"cd ..\"."
   print

   :help-command "more"
   :help-wrap-indent 6 \
      "Use %Bless%b for commands that invoke %Bmore%b."
   print

   :help-command "D"
   :help-wrap-indent 6 \
      "Shorthand for %Bdocker%b."
   print

   print -P -- "%BPATH configuration helpers%b"
   print

   :help-command "addpath before directory ..."
   :help-command "addpath after directory ..."
   :help-wrap-indent 6 \
      "Add one or more directories to PATH in the requested position while" \
      "avoiding duplicate entries."
   print

   :help-command "addmanpath before directory ..."
   :help-command "addmanpath after directory ..."
   :help-wrap-indent 6 \
      "Add one or more directories to MANPATH."
   print

   print -P -- "%BTerminal behavior%b"
   print

   :help-wrap-indent 3 \
      "Prompt context uses terminal colors to communicate state compactly." \
      "The prompt uses the current %BCOLUMNS%b value when choosing between its" \
      "one-line and two-line layouts, and %BPROMPT_MARGIN%b reserves a small" \
      "amount of space at the right edge of the terminal."
   print

   :help-wrap-indent 3 \
      "Terminal-title management is independent of the prompt and can display" \
      "nothing, a fixed string, or the current hostname. Hostname mode is useful" \
      "when moving between login and compute nodes because the title is refreshed" \
      "before each prompt."
   print

   print -P -- "%BOptional development context%b"
   print

   :help-wrap-indent 3 \
      "Git-aware prompt information and automatic repository-to-venv matching" \
      "require the %Bgit%b command. Conda prompt state and %Bvstop%b support are" \
      "available when Conda has been installed and initialized. Slurm session" \
      "support requires %Bsrun%b, while the Slurm timer uses %Bsqueue%b."
   print

   print -P -- "%BWhere to go next%b"
   print

   :help-command "help prompt"
   :help-wrap-indent 6 \
      "Learn the prompt colors, timers, adaptive layout, prompt spacing, and" \
      "Python/Git development workflow."
   print

   :help-command "help session"
   :help-wrap-indent 6 \
      "Learn how to start and customize interactive Slurm sessions."
   print

   :help-command "help timer"
   :help-wrap-indent 6 \
      "Learn how prompt timers are selected and extended."
   print

   :help-command "help tags"
   :help-wrap-indent 6 \
      "Learn how to create persistent short names for filesystem locations."
   print

   :help-command "help -l"
   :help-wrap-indent 6 \
      "Discover additional help topics as more services are added."
}

