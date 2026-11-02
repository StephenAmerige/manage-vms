#!/bin/bash
# Initialize an Ubuntu VM with Docker, zsh, Vim, and administration helpers.
# Custom shell and editor configuration is bundled with this repository.
set -euo pipefail

main()
{
   if (( EUID != 0 )); then
      echo 'Error: vm-bootstrap.sh must run as root.' >&2
      return 1
   fi

   local ScriptDir ZshDir VimDir
   ScriptDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
   ZshDir="$ScriptDir/files/zsh"
   VimDir="$ScriptDir/files/vim"

   # Validate the checkout before modifying the operating system.
   [[ -f "$ZshDir/.zshrc" ]] || {
      echo "Error: missing $ZshDir/.zshrc" >&2
      return 1
   }
   [[ -f "$VimDir/.vimrc" && -d "$VimDir/runtime" ]] || {
      echo "Error: expected $VimDir/.vimrc and $VimDir/runtime/" >&2
      return 1
   }
   local Helper
   for Helper in create-shared-group.sh create-user.sh; do
      [[ -f "$ScriptDir/$Helper" ]] || {
         echo "Error: missing $ScriptDir/$Helper" >&2
         return 1
      }
   done

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
      openssh-client plocate sudo unzip vim yq zip zsh

   # LOGIN HISTORY: wtmpdb is available on Ubuntu 25.10 and later;
   # Ubuntu 24.04 retains the traditional last/wtmp implementation.
   if dpkg --compare-versions "$VERSION_ID" ge 25.10; then
      apt-get install -y wtmpdb libpam-wtmpdb
   fi

   # PLOCATE: its package initializes the database and enables the timer.
   # Override the packaged daily schedule to run at 02:00 local time.
   # Disable catch-up runs to avoid indexing during the day after downtime.
   install -d -o root -g root -m 0755 \
      /etc/systemd/system/plocate-updatedb.timer.d
   cat > /etc/systemd/system/plocate-updatedb.timer.d/override.conf <<'PLOCATE_TIMER'
[Timer]
OnCalendar=
OnCalendar=*-*-* 02:00:00
RandomizedDelaySec=0
AccuracySec=1min
Persistent=false
PLOCATE_TIMER
   systemctl daemon-reload
   systemctl enable plocate-updatedb.timer
   systemctl restart plocate-updatedb.timer

   # DOCKER: configure the official Ubuntu APT repository.
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

   # ZSH: repository-managed dotfiles for future users and root.
   # Include .zshrc.d/; exclude histories and generated cache files.
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
      echo "Error: no zsh configuration found in $ZshDir" >&2
      return 1
   fi

   # VIM: maintain the historical runtime layout used by the configuration.
   cp -a -- "$VimDir/runtime/." /usr/share/vim/
   install -d -m 0700 \
      /etc/skel/.vim/save \
      /etc/skel/.vim/swp \
      /etc/skel/.vim/undo
   chmod 0700 /etc/skel/.vim
   install -m 0644 "$VimDir/.vimrc" /etc/skel/.vimrc
   ln -sfn .vimrc /etc/skel/.gvimrc

   # ROOT: configure Vim and zsh without interfering with .ssh.
   install -d -m 0700 /root/.vim
   cp -a -- /etc/skel/.vim/. /root/.vim/
   install -m 0644 /etc/skel/.vimrc /root/.vimrc
   ln -sfn .vimrc /root/.gvimrc
   usermod -s /bin/zsh root

   # INITIAL CLOUD ACCOUNT: cloud-init created 'ubuntu' before /etc/skel
   # was populated. Configure it explicitly, preserving its SSH keys.
   local InitialUser=ubuntu InitialHome InitialGroup
   if getent passwd "$InitialUser" >/dev/null; then
      InitialHome=$(getent passwd "$InitialUser" | cut -d: -f6)
      InitialGroup=$(id -gn "$InitialUser")
      if [[ ! -d $InitialHome || $InitialHome == / ]]; then
         echo "Error: unsafe or missing home for $InitialUser: $InitialHome" >&2
         return 1
      fi

      for Item in /etc/skel/.zsh*; do
         [[ -e $Item || -L $Item ]] || continue
         cp -a -- "$Item" "$InitialHome/"
         chown -R -- "$InitialUser:$InitialGroup" \
            "$InitialHome/${Item##*/}"
      done

      install -d -o "$InitialUser" -g "$InitialGroup" -m 0700 \
         "$InitialHome/.vim" \
         "$InitialHome/.vim/save" \
         "$InitialHome/.vim/swp" \
         "$InitialHome/.vim/undo"
      install -o "$InitialUser" -g "$InitialGroup" -m 0644 \
         /etc/skel/.vimrc "$InitialHome/.vimrc"
      ln -sfn .vimrc "$InitialHome/.gvimrc"
      chown -h "$InitialUser:$InitialGroup" "$InitialHome/.gvimrc"

      usermod -s /bin/zsh "$InitialUser"
      usermod -aG docker "$InitialUser"
      echo "Initial account $InitialUser configured for zsh, Vim, and Docker."
   fi

   # Install reusable administration helpers for later additions of users
   # and collaborative groups. Only root/sudo can successfully invoke them.
   install -d -o root -g root -m 0755 /usr/local/bin
   install -o root -g root -m 0755 \
      "$ScriptDir/create-shared-group.sh" \
      /usr/local/bin/create-shared-group.sh
   install -o root -g root -m 0755 \
      "$ScriptDir/create-user.sh" \
      /usr/local/bin/create-user.sh

   echo 'VM bootstrap completed successfully.'
}

main "$@"
