#!/bin/bash
# SPDX-License-Identifier: MIT
# Ubuntu host provisioning: run with sudo bash or use as cloud-init Bash user data.
# Change only the marked configuration section; use complete SSH public keys.
# The repository must be anonymously cloneable from the target host.
set -euo pipefail

################################
#   HOST CONFIGURATION BEGIN   #
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
# HOST CONFIGURATION END     #
##############################

# FETCH AND RUN THE REPOSITORY-MANAGED PROVISIONING LOGIC
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git ca-certificates

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

git clone https://github.com/StephenAmerige/ubuntu-host-bootstrap.git "$TMP/ubuntu-host-bootstrap"
source "$TMP/ubuntu-host-bootstrap/provision-vm.sh"
