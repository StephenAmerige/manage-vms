########################################################################
#
# ff-user.zsh
#
# User-specific shell configuration loaded late in the startup sequence.
#
# Files in the a0-ff range are intended for site-specific or personal
# customization.  This file is sourced near the end of ~/.zshrc.d so it
# is a convenient place to override defaults or add local settings.
#
########################################################################

########################################################################
# Prompt spacing.
#
# Insert a blank line before each prompt.
#
# See:
#
#    help prompt
#
########################################################################

pgap on &>/dev/null

########################################################################
# Interactive Slurm session configuration.
#
# The "session" command starts an interactive Slurm allocation using
# predefined resource profiles.
#
# _SessionAccount specifies the Slurm account/project used for the
# allocation.
#
# _SessionShell specifies the shell executable started on the allocated
# compute node.
#
# See:
#
#    help session
#
# Examples:
#
#    typeset -g _SessionAccount=my_project
#    typeset -g _SessionShell=/usr/bin/zsh
#
########################################################################

#typeset -g _SessionAccount=my_project
#typeset -g _SessionShell=/usr/bin/zsh

########################################################################
# PATH customization.
#
# addpath modifies PATH without introducing duplicate entries.
#
# Syntax:
#
#    addpath before <directory>
#    addpath after  <directory>
#
# "before" gives commands in the directory higher precedence.
# "after" gives existing PATH entries higher precedence.
#
# Examples:
#
#    addpath before "$HOME/bin"
#    addpath before /opt/local/bin
#    addpath after  /opt/vendor/bin
#
########################################################################
