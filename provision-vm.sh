#!/bin/bash
# Orchestrate an OpenStack VM's first-boot provisioning.
# Source this script from example-invocation.sh so its configuration
# variables and Bash arrays are available without exporting them.

provision_vm()
{
   if (( EUID != 0 )); then
      echo 'Error: provision-vm.sh must run as root.' >&2
      return 1
   fi

   # Fail on invalid instance configuration before modifying the VM.
   if [[ -z ${Group:-} ]]; then
      echo 'Error: Group must be configured.' >&2
      return 1
   fi
   case ${RebootAfterProvisioning:-false} in
      true|false) ;;
      *)
         echo 'Error: RebootAfterProvisioning must be true or false.' >&2
         return 1
         ;;
   esac
   if [[ $(declare -p UserKey 2>/dev/null) != 'declare -A '* ]]; then
      echo 'Error: UserKey must be a Bash associative array.' >&2
      return 1
   fi
   if [[ $(declare -p SudoUsers 2>/dev/null) != 'declare -a '* ]]; then
      echo 'Error: SudoUsers must be an indexed Bash array.' >&2
      return 1
   fi

   local UserName
   for UserName in "${SudoUsers[@]}"; do
      if [[ -z ${UserKey[$UserName]+x} ]]; then
         echo "Error: sudo user $UserName is not in UserKey." >&2
         return 1
      fi
   done

   local RepoDir
   RepoDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
   echo "Provisioning from revision $(git -C "$RepoDir" rev-parse HEAD)"

   # CONFIGURE SYSTEM TIMEZONE
   if [[ -n ${TimeZone:-} ]]; then
      echo "=== Setting system timezone: $TimeZone ==="
      timedatectl set-timezone "$TimeZone"
   fi

   # BOOTSTRAP: installs reusable helpers into /usr/local/bin.
   echo '=== Bootstrapping VM ==='
   bash "$RepoDir/vm-bootstrap.sh"

   # CREATE THE INITIAL COLLABORATIVE GROUP.
   echo "=== Creating collaborative group: $Group ==="
   local -a GroupArgs=(-g "$Group")
   if [[ -n ${GroupID:-} ]]; then
      GroupArgs+=(-i "$GroupID")
   fi
   /usr/local/bin/create-shared-group.sh "${GroupArgs[@]}"

   # CREATE USERS WITH PRIVATE HOMES, COLLABORATION, AND DOCKER ACCESS.
   echo '=== Creating individual users ==='
   for UserName in "${!UserKey[@]}"; do
      echo "Creating or updating user: $UserName"
      /usr/local/bin/create-user.sh \
         -u "$UserName" \
         -g "$Group" \
         -k "${UserKey[$UserName]}"
   done

   # PASSWORDLESS SUDO FOR DESIGNATED ADMINISTRATORS.
   # Leave the stock /etc/sudoers and initial ubuntu account untouched.
   if (( ${#SudoUsers[@]} > 0 )); then
      local SudoersTemp="$TMP/90-manage-vms"
      : > "$SudoersTemp"

      for UserName in "${SudoUsers[@]}"; do
         printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' \
            "$UserName" >> "$SudoersTemp"
      done

      chmod 0440 "$SudoersTemp"
      visudo -cf "$SudoersTemp"
      install -o root -g root -m 0440 \
         "$SudoersTemp" /etc/sudoers.d/90-manage-vms
      visudo -c

      for UserName in "${SudoUsers[@]}"; do
         usermod -aG sudo "$UserName"
         echo "Passwordless sudo granted to: $UserName"
      done
   fi

   echo '=== OpenStack VM provisioning completed successfully ==='

   # Defer reboot so cloud-init can exit and flush its logs.
   # Cancel before it occurs with: sudo shutdown -c
   if [[ ${RebootAfterProvisioning:-false} == true ]]; then
      echo 'Scheduling reboot in one minute.'
      shutdown -r +1 'OpenStack VM provisioning completed'
   fi
}

provision_vm
