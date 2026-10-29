########################################################################
#
# e0-python-env.zsh
#
# User-specific Python environment configuration.
#
# VENV_DIRS and CONDA_DIRS are ordered lists of directories beneath
# which named Python environments may be located.
#
# Python venv environments are expected to have the form:
#
#    <VENV_DIR>/<environment-name>/bin/activate
#
# Conda environments are expected to have the form:
#
#    <CONDA_DIR>/<environment-name>/conda-meta
#
# The directories in each list are searched in the order specified.
#
# For example:
#
#    VENV_DIRS=(
#       "$HOME/.venv"
#       /opt/venv
#    )
#
#    CONDA_DIRS=(
#       "$HOME/.conda-envs"
#       /opt/conda-envs
#    )
#
# If the current Git worktree is named "myproject", vstart searches for:
#
#    <VENV_DIR>/myproject/bin/activate
#    <CONDA_DIR>/myproject/conda-meta
#
# The same environment name may exist as both a venv and a Conda
# environment.  In that case vstart reports the ambiguity unless the
# environment type is selected explicitly:
#
#    vstart --venv
#    vstart --conda
#
# An explicit environment name may also be supplied:
#
#    vstart myproject
#    vstart --venv myproject
#    vstart --conda myproject
#
# When no Python environment is active, 90-prompt.zsh uses these
# mappings to indicate whether an environment associated with the
# current Git worktree is available.
#
# No directories are searched unless they are explicitly listed here.
#
########################################################################

typeset -ga VENV_DIRS CONDA_DIRS

VENV_DIRS=(
)

CONDA_DIRS=(
)

########################################################################
# Optional Conda module.
#
# Some systems provide Conda through an environment-module system rather
# than placing the conda executable on PATH at shell startup.
#
# If CONDA_MODULE is defined and conda is not already available,
# :conda:init may load this module before initializing Conda shell
# integration.
#
# Example:
#
#    CONDA_MODULE=miniconda3/25.11.1
#
# Leave CONDA_MODULE undefined or empty when:
#
#    - conda is already available on PATH;
#    - Conda is not used on this system; or
#    - environment modules are not used.
#
# This file contains only site/user-specific configuration.  Generic
# Conda initialization behavior belongs in 80-python-env.zsh.
#
########################################################################

typeset -g CONDA_MODULE=

########################################################################
# Conda user configuration.
#
# Conda settings such as the following are normally configured once
# with "conda config" and stored by Conda, typically in ~/.condarc:
#
#    conda config --set auto_activate_base false
#    conda config --set changeps1 false
#
# They should not be executed each time zsh starts.
########################################################################
