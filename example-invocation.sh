#!/bin/bash
# Paste this entire file into OpenStack > Launch Instance > Configuration.
# Replace the sample SSH public keys below with complete, real public keys.
# The provisioning GitHub repository must be anonymously cloneable.
set -euo pipefail

# THIS INSTANCE'S COLLABORATIVE GROUP AND USERS
Group='reframe'
GroupID=2000

declare -A UserKey=(
   [steve]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY steve'
   [georgine]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY georgine'
)

# FETCH THE REUSABLE PROVISIONING SCRIPTS
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git ca-certificates

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git clone https://github.com/StephenAmerige/manage-vms.git "$TMP/manage-vms"
cd "$TMP/manage-vms"

# BOOTSTRAP THE OS BEFORE CREATING USERS (/etc/skel, zsh, Vim).
bash vm-bootstrap.sh

# CREATE THE NON-LOGIN COLLABORATIVE ACCOUNT.
bash create-shared-group.sh -g "$Group" -i "$GroupID"

# PROVISION EACH USER'S PRIVATE HOME AND SSH PUBLIC KEY.
for UserName in "${!UserKey[@]}"; do
   bash create-user.sh \
      -u "$UserName" \
      -g "$Group" \
      -k "${UserKey[$UserName]}"
done

echo 'OpenStack VM provisioning completed successfully.'
