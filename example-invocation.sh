#!/bin/bash
# Paste the entire file into OpenStack > Launch Instance > Configuration.
# Replace sample SSH public keys with complete, real public keys before use.
# The repository must be anonymously cloneable from the VM.
set -euo pipefail

# INSTANCE CONFIGURATION
Group='collab'
GroupID=2000
RebootAfterProvisioning=true

declare -A UserKey=(
   [steve]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY steve'
   [georgine]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY georgine'
)

# Passwordless administrative access. Users must also be in UserKey.
declare -a SudoUsers=(
   steve
)

# FETCH THE REUSABLE PROVISIONING SCRIPTS
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git ca-certificates

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git clone https://github.com/StephenAmerige/manage-vms.git "$TMP/manage-vms"
cd "$TMP/manage-vms"
echo "Provisioning from revision $(git rev-parse HEAD)"

# BOOTSTRAP: installs helpers in /usr/local/bin.
echo '=== Bootstrapping VM ==='
bash vm-bootstrap.sh

# COLLABORATIVE GROUP
# Omit -i for additional groups when automatic GID allocation is desired.
echo "=== Creating collaborative group: $Group ==="
/usr/local/bin/create-shared-group.sh -g "$Group" -i "$GroupID"

# PRIVATE USERS + COLLABORATIVE MEMBERSHIP + DOCKER ACCESS
echo '=== Creating individual users ==='
for UserName in "${!UserKey[@]}"; do
   echo "Creating or updating user: $UserName"
   /usr/local/bin/create-user.sh \
      -u "$UserName" \
      -g "$Group" \
      -k "${UserKey[$UserName]}"
done

# PASSWORDLESS SUDO FOR DESIGNATED ADMINISTRATORS
# Leave the stock /etc/sudoers and existing ubuntu admin account intact.
if (( ${#SudoUsers[@]} > 0 )); then
   SudoersTemp="$TMP/90-manage-vms"
   : > "$SudoersTemp"

   for UserName in "${SudoUsers[@]}"; do
      if [[ -z ${UserKey[$UserName]+x} ]]; then
         echo "Error: sudo user $UserName is not in UserKey." >&2
         exit 1
      fi
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

# Defer the restart so this cloud-init script can exit and flush its logs.
# To cancel while waiting: sudo shutdown -c
if [[ $RebootAfterProvisioning == true ]]; then
   echo 'Scheduling reboot in one minute.'
   shutdown -r +1 'OpenStack VM provisioning completed'
fi
