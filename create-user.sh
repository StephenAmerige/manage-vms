#!/bin/bash
# SPDX-License-Identifier: MIT
# Provision a private user in one collaborative group and the docker group.
# Docker access on this VM is a trusted-user policy and is root-equivalent.
set -euo pipefail

usage()
{
   echo "Usage: $0 -u USER -g GROUP -k 'SSH_PUBLIC_KEY'" >&2
}

main()
{
   if (( EUID != 0 )); then
      echo 'Error: create-user.sh must run as root.' >&2
      return 1
   fi

   local Options UserName='' GroupName='' SSHKey=''
   Options=$(getopt -o 'u:g:k:' -l 'user:,group:,key:' -n "$0" -- "$@") || {
      usage
      return 1
   }
   eval set -- "$Options"

   while true; do
      case "$1" in
         -u|--user)  UserName=$2; shift 2 ;;
         -g|--group) GroupName=$2; shift 2 ;;
         -k|--key)   SSHKey=$2; shift 2 ;;
         --)         shift; break ;;
      esac
   done
   if (( $# != 0 )); then usage; return 1; fi
   if [[ ! $UserName =~ ^[a-z_][a-z0-9_-]*$ ]]; then
      echo 'Error: supply a valid lowercase username with -u.' >&2
      return 1
   fi
   if [[ ! $GroupName =~ ^[a-z_][a-z0-9_-]*$ ]]; then
      echo 'Error: supply a valid lowercase group name with -g.' >&2
      return 1
   fi
   if [[ -z $SSHKey || $SSHKey == *$'\n'* || $SSHKey == *$'\r'* ]]; then
      echo 'Error: -k must contain one complete SSH public key.' >&2
      return 1
   fi
   if ! getent group "$GroupName" >/dev/null; then
      echo "Error: create shared group $GroupName first." >&2
      return 1
   fi
   if ! getent group docker >/dev/null; then
      echo 'Error: Docker group does not exist; run vm-bootstrap.sh first.' >&2
      return 1
   fi
   if ! command -v ssh-keygen >/dev/null; then
      echo 'Error: ssh-keygen is required to validate the public key.' >&2
      return 1
   fi

   # Validate the key before changing the account.
   # EXIT traps run after main() returns, so keep the pathname global.
   USER_KEYFILE=$(mktemp)
   trap 'rm -f -- "$USER_KEYFILE"' EXIT
   printf '%s\n' "$SSHKey" > "$USER_KEYFILE"
   chmod 0600 "$USER_KEYFILE"
   if ! ssh-keygen -lf "$USER_KEYFILE" >/dev/null 2>&1; then
      echo "Error: invalid SSH public key for $UserName." >&2
      return 1
   fi

   local Home=/home/$UserName
   if getent passwd "$UserName" >/dev/null; then
      local Entry AccountHome PrimaryGroup
      Entry=$(getent passwd "$UserName")
      IFS=: read -r _ _ _ _ _ AccountHome _ <<< "$Entry"
      PrimaryGroup=$(id -gn "$UserName")
      if [[ $AccountHome != "$Home" || $PrimaryGroup != "$UserName" ]]; then
         echo "Error: existing account $UserName has an unexpected home or primary group." >&2
         return 1
      fi
      usermod -aG "$GroupName,docker" -s /bin/zsh "$UserName"
   else
      # -U creates the private primary group named after the user.
      useradd -m -U -G "$GroupName,docker" -s /bin/zsh "$UserName"
   fi

   chmod 0700 "$Home"
   install -d -o "$UserName" -g "$UserName" -m 0700 "$Home/.ssh"
   # Explicitly supplied key is authoritative; reruns replace authorized_keys.
   install -o "$UserName" -g "$UserName" -m 0600 \
      "$USER_KEYFILE" "$Home/.ssh/authorized_keys"

   id "$UserName"
   echo "User $UserName provisioned successfully."
}

main "$@"
