#!/bin/bash
# Paste the entire file into OpenStack > Launch Instance > Configuration.
# Replace the sample SSH public keys with complete, real public keys.
# The repository must be anonymously cloneable from the VM.
set -euo pipefail

################################
# INSTANCE CONFIGURATION BEGIN #
#    EDIT THIS SECTION ONLY    #
################################
Group='collab'
GroupID=2000
RebootAfterProvisioning=true

# Each user receives a private home, collaborative access, and Docker access.
declare -A UserKey=(
   [steve]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY steve'
   [georgine]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY georgine'
)

# Passwordless sudo users must also be present in UserKey.
declare -a SudoUsers=(
   steve
)

# Empty means retain the cloud image's default timezone.
TimeZone=''
##############################
# INSTANCE CONFIGURATION END #
##############################

# FETCH AND RUN THE REPOSITORY-MANAGED PROVISIONING LOGIC
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git ca-certificates

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

git clone https://github.com/StephenAmerige/manage-vms.git "$TMP/manage-vms"
source "$TMP/manage-vms/provision-vm.sh"
