#!/bin/bash
# Provision one non-login collaborative account and an ACL-enabled shared home.
set -euo pipefail

usage()
{
   echo "Usage: $0 -g GROUP [-i GID]" >&2
}

main()
{
   if (( EUID != 0 )); then
      echo 'Error: create-shared-group.sh must run as root.' >&2
      return 1
   fi

   local Options GroupName='' GroupID=2000
   Options=$(getopt -o 'g:i:' -l 'group:,gid:' -n "$0" -- "$@") || {
      usage
      return 1
   }
   eval set -- "$Options"

   while true; do
      case "$1" in
         -g|--group) GroupName=$2; shift 2 ;;
         -i|--gid)   GroupID=$2; shift 2 ;;
         --)         shift; break ;;
      esac
   done
   if (( $# != 0 )); then usage; return 1; fi
   if [[ ! $GroupName =~ ^[a-z_][a-z0-9_-]*$ ]]; then
      echo 'Error: supply a valid lowercase group name with -g.' >&2
      return 1
   fi
   if [[ ! $GroupID =~ ^[0-9]+$ ]] || (( 10#$GroupID < 1 )); then
      echo 'Error: GID must be a positive integer.' >&2
      return 1
   fi

   # Don't silently reuse an existing GID assigned to another group.
   local existing_group existing_gid
   if getent group "$GroupName" >/dev/null; then
      existing_gid=$(getent group "$GroupName" | cut -d: -f3)
      if [[ $existing_gid != "$GroupID" ]]; then
         echo "Error: group $GroupName already has GID $existing_gid (expected $GroupID)." >&2
         return 1
      fi
   else
      existing_group=$(getent group "$GroupID" | cut -d: -f1 || true)
      if [[ -n $existing_group ]]; then
         echo "Error: GID $GroupID already belongs to group $existing_group." >&2
         return 1
      fi
      groupadd -g "$GroupID" "$GroupName"
   fi

   local home=/home/$GroupName
   if getent passwd "$GroupName" >/dev/null; then
      local entry account_home primary_gid account_shell
      entry=$(getent passwd "$GroupName")
      IFS=: read -r _ _ _ primary_gid _ account_home account_shell <<< "$entry"
      if [[ $account_home != "$home" || $primary_gid != "$GroupID" || $account_shell != /usr/sbin/nologin ]]; then
         echo "Error: existing account $GroupName does not match the shared-account configuration." >&2
         return 1
      fi
   else
      useradd -M -d "$home" -g "$GroupName" \
         -s /usr/sbin/nologin "$GroupName"
   fi

   install -d -o "$GroupName" -g "$GroupName" -m 2770 "$home"
   setfacl -m 'u::rwx,g::rwx,m::rwx,o::---' "$home"
   setfacl -d -m 'u::rwx,g::rwx,m::rwx,o::---' "$home"
   chmod g+s "$home"

   getfacl "$home"
   echo "Collaborative account $GroupName (GID $GroupID) ready."
}

main "$@"
