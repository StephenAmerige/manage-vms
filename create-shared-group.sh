#!/bin/bash
# Provision a non-login collaborative account and an ACL-enabled shared home.
# Assign a GID automatically unless -i/--gid is provided.
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

   local Options GroupName='' GroupID=''
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
   if [[ -n $GroupID ]]; then
      if [[ ! $GroupID =~ ^[0-9]+$ ]] || (( 10#$GroupID < 1 )); then
         echo 'Error: GID must be a positive integer.' >&2
         return 1
      fi
      GroupID=$(( 10#$GroupID ))
   fi

   # Reject conflicting GIDs, but allow a compatible existing group.
   local ExistingGroup ExistingGID
   if getent group "$GroupName" >/dev/null; then
      ExistingGID=$(getent group "$GroupName" | cut -d: -f3)
      if [[ -n $GroupID && $ExistingGID != "$GroupID" ]]; then
         echo "Error: $GroupName has GID $ExistingGID, not $GroupID." >&2
         return 1
      fi
   else
      if [[ -n $GroupID ]]; then
         ExistingGroup=$(getent group "$GroupID" | cut -d: -f1 || true)
         if [[ -n $ExistingGroup ]]; then
            echo "Error: GID $GroupID is already owned by $ExistingGroup." >&2
            return 1
         fi
         groupadd -g "$GroupID" "$GroupName"
      else
         groupadd "$GroupName"
      fi
   fi
   GroupID=$(getent group "$GroupName" | cut -d: -f3)

   local Home=/home/$GroupName
   if getent passwd "$GroupName" >/dev/null; then
      local Entry AccountHome PrimaryGID AccountShell
      Entry=$(getent passwd "$GroupName")
      IFS=: read -r _ _ _ PrimaryGID _ AccountHome AccountShell <<< "$Entry"
      if [[ $AccountHome != "$Home" || $PrimaryGID != "$GroupID" || $AccountShell != /usr/sbin/nologin ]]; then
         echo "Error: existing account $GroupName does not match the shared-account configuration." >&2
         return 1
      fi
   else
      useradd -M -d "$Home" -g "$GroupName" \
         -s /usr/sbin/nologin "$GroupName"
   fi

   install -d -o "$GroupName" -g "$GroupName" -m 2770 "$Home"
   setfacl -m 'u::rwx,g::rwx,m::rwx,o::---' "$Home"
   setfacl -d -m 'u::rwx,g::rwx,m::rwx,o::---' "$Home"
   chmod g+s "$Home"

   getfacl "$Home"
   echo "Collaborative account $GroupName (GID $GroupID) ready."
}

main "$@"
