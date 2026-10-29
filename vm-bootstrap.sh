#!/bin/bash
# Initialize a new Ubuntu VM with Docker, zsh and Vim.
# Custom shell and editor configuration is bundled with this repository.
set -euo pipefail

main()
{
   if (( EUID != 0 )); then
      echo 'Error: vm-bootstrap.sh must run as root.' >&2
      return 1
   fi

   # Locate the configuration files relative to this script, not the caller's CWD.
   local ScriptDir ZshDir VimDir
   ScriptDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
   ZshDir="$ScriptDir/files/zsh"
   VimDir="$ScriptDir/files/vim"

   # Check the repository layout before making changes to the VM.
   [[ -f "$ZshDir/.zshrc" ]] || {
      echo "Error: missing $ZshDir/.zshrc" >&2
      return 1
   }
   [[ -f "$VimDir/.vimrc" && -d "$VimDir/runtime" ]] || {
      echo "Error: expected $VimDir/.vimrc and $VimDir/runtime/" >&2
      return 1
   }

   # Confirm that we are running on Ubuntu.
   # shellcheck source=/dev/null
   . /etc/os-release
   if [[ ${ID:-} != ubuntu ]]; then
      echo 'Error: vm-bootstrap.sh supports Ubuntu only.' >&2
      return 1
   fi

   export DEBIAN_FRONTEND=noninteractive

   # BASE OPERATING SYSTEM AND UTILITIES
   apt-get update
   apt-get upgrade -y
   apt-get install -y \
      acl ca-certificates curl git gnupg lsb-release \
      openssh-client unzip vim yq zip zsh

   # DOCKER: configure the official APT repository.
   install -d -m 0755 /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc
   chmod 0644 /etc/apt/keyrings/docker.asc

   cat > /etc/apt/sources.list.d/docker.sources <<DOCKER_SOURCES
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
DOCKER_SOURCES

   apt-get update
   apt-get install -y \
      docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin
   systemctl enable --now docker

   # ZSH: copy repository-managed dotfiles to the new-user template and root.
   # This includes .zshrc.d/ but excludes generated shell history/cache files.
   local Item Count=0
   shopt -s nullglob
   for Item in "$ZshDir"/.zsh*; do
      case ${Item##*/} in
         .zsh_history|.zcompdump*|.zsh_sessions) continue ;;
      esac
      cp -a -- "$Item" /etc/skel/
      cp -a -- "$Item" /root/
      (( Count += 1 ))
   done

   if (( Count == 0 )); then
      echo "Error: no zsh configuration files found in $ZshDir" >&2
      return 1
   fi

   # VIM: install the bundled runtime, including templates and plugins.
   # Keep the historical /usr/share/vim layout used by the Vim configuration.
   cp -a -- "$VimDir/runtime/." /usr/share/vim/

   # Set up directories used by backupdir, directory and undodir.
   install -d -m 0700 \
      /etc/skel/.vim/save \
      /etc/skel/.vim/swp \
      /etc/skel/.vim/undo
   chmod 0700 /etc/skel/.vim

   install -m 0644 "$VimDir/.vimrc" /etc/skel/.vimrc
   ln -sfn .vimrc /etc/skel/.gvimrc

   # ROOT: replicate the Vim defaults without nesting .vim directories.
   install -d -m 0700 /root/.vim
   cp -a -- /etc/skel/.vim/. /root/.vim/
   install -m 0644 /etc/skel/.vimrc /root/.vimrc
   ln -sfn .vimrc /root/.gvimrc

   # Change root's login shell only after zsh and its configuration are installed.
   usermod -s /bin/zsh root

   echo 'VM bootstrap completed successfully.'
}

main "$@"
