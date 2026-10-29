# manage-vms

Reproducible first-boot provisioning for Ubuntu virtual machines launched through **OpenStack Horizon**. A small Bash user-data script clones this repository, prepares the operating system, creates one collaborative Unix group, and provisions its individual users with SSH public keys.

The intended workflow is simple: define the group and users in Horizon's **Launch Instance > Configuration** tab, launch the VM, and let cloud-init run the provisioning scripts as root.

> **Scope:** This repository establishes the *initial state* of a VM. It does not continuously manage existing instances, synchronize configuration changes to old VMs, or back up data.

## Features

- Upgrade Ubuntu packages and install essential command-line utilities.
- Install Docker Engine, the Docker CLI, containerd, Buildx, and the Docker Compose plugin from Docker's official Ubuntu APT repository; enable the Docker service.
- Install zsh and Vim with configuration maintained directly in this repository (no separate BashG clone or zsh ZIP download).
- Configure `/etc/skel` so subsequently created users receive the standard shell and editor environment; configure root as well.
- Create one shared Unix group and a matching **non-login** account, with a setgid shared directory and inheritable access-control lists (ACLs).
- Create individual accounts with private primary groups and home directories, membership in the collaborative group, zsh as the login shell, and an assigned SSH public key.
- Stop on most provisioning failures and support rerunning the account-creation scripts for the same intended configuration.

## Repository layout

```text
manage-vms/
├── vm-bootstrap.sh             # Ubuntu, packages, Docker, zsh, Vim
├── create-shared-group.sh      # Collaborative group, account and ACLs
├── create-user.sh              # Individual account and authorized_keys
├── example-invocation.sh      # Copy into Horizon's Configuration tab
└── files/
    ├── vim/
    │   ├── .vimrc
    │   └── runtime/
    │       ├── template/
    │       └── vimfiles/       # Bundled Vim plugins and support files
    └── zsh/
        ├── .zshenv
        ├── .zshrc
        └── .zshrc.d/
            ├── *.zsh          # Shared shell customizations
            └── examples/      # Optional sample user configurations
```

### Scripts at a glance

| Script | Arguments | Responsibility |
| --- | --- | --- |
| `vm-bootstrap.sh` | None | OS upgrade, packages, Docker, zsh and Vim configuration |
| `create-shared-group.sh` | `-g GROUP` and optional `-i GID` | Shared group, non-login account, directory and ACLs |
| `create-user.sh` | `-u USER -g GROUP -k 'PUBLIC_KEY'` | Private user account, shared membership and SSH authorization |
| `example-invocation.sh` | Edit its variables before use | Complete cloud-init shell user-data example |

All three provisioning scripts must run as **root**. The example invocation runs them in the necessary order and is also intended to run as root through cloud-init.

## Requirements

- An Ubuntu cloud image with **cloud-init** and an accessible OpenStack Horizon **Configuration** tab. The bootstrap explicitly rejects non-Ubuntu systems. Ubuntu 24.04 LTS and 26.04 LTS are the intended targets; confirm compatibility on the actual image and architecture you deploy.
- Outbound access to Ubuntu package mirrors, `download.docker.com`, and GitHub.
- A VM flavor with enough resources and disk space for package upgrades and Docker installation.
- A public or otherwise **anonymously cloneable** copy of this repository, as used by the current example. Private-repository authentication is not implemented.
- Real, complete SSH public keys for each intended user (typically a single `ssh-ed25519 ...` line per user).
- An OpenStack network, security-group rules, and an SSH server on the image that permit access as intended. The bootstrap installs `openssh-client` (for `ssh-keygen`), **not** `openssh-server`.

Initial access to the stock cloud-image account may use the OpenStack key pair selected when launching the instance. The accounts created by `create-user.sh` use the keys provided separately in user data.

## Quick start: OpenStack Horizon

1. Make sure the changes you want to use have been pushed to this repository.
2. Open [`example-invocation.sh`](example-invocation.sh) and copy its **entire contents**, including the first `#!/bin/bash` line.
3. In your local copy of the script, set the common group and GID, then list every user and their **complete public key** in the `UserKey` associative array. The checked-in key strings are placeholders and **will fail validation** if left unchanged.
4. In Horizon, select **Launch Instance**, choose your Ubuntu image and other instance settings, and paste the edited script into **Configuration**.
5. Launch the instance. Cloud-init executes the shell script during its first-boot processing, ordinarily as root.
6. Check completion and test a newly provisioned user's SSH login before relying on the VM.

The configuration portion of the example looks like this (keys are deliberately incomplete):

```bash
Group='collab'
GroupID=2000

declare -A UserKey=(
   [steve]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY steve'
   [georgine]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY georgine'
)
```

Everyone in `UserKey` joins the same collaborative group, but retains a private primary group. To provision a different set of users, modify that associative array in the **Horizon copy**; you do not need to commit per-instance user data to GitHub.

The example clones:

```bash
git clone https://github.com/StephenAmerige/manage-vms.git "$TMP/manage-vms"
```

The bootstrap then runs before the group and user scripts so `/etc/skel`, `/bin/zsh`, and the bundled editor configuration are ready when individual home directories are created. A temporary checkout is deleted at the end of a successful run, or on script exit.

**Important:** Merely seeing the instance marked **ACTIVE** in Horizon does not mean cloud-init has finished. Large package upgrades and Docker installation can continue after the VM begins running.

## What provisioning changes

### Operating system and Docker

`vm-bootstrap.sh`:

1. Checks for root, verifies Ubuntu using `/etc/os-release`, and validates the bundled configuration layout.
2. Runs `apt-get update` and `apt-get upgrade -y`.
3. Installs `acl`, `ca-certificates`, `curl`, `git`, `gnupg`, `lsb-release`, `openssh-client`, `unzip`, `vim`, `yq`, `zip`, and `zsh`.
4. Installs Docker's signing key and defines `/etc/apt/sources.list.d/docker.sources` for the Ubuntu release and CPU architecture.
5. Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, and `docker-compose-plugin`; enables and starts Docker.

A package upgrade can leave a **reboot required** even when the provisioning script finishes successfully. Reboot deliberately after confirming you can regain administrative access.

### zsh and Vim

The bootstrap copies `files/zsh/.zsh*` to both `/etc/skel/` and `/root/`, excluding common generated history and cache filenames. This includes the shared `.zshrc.d` directory. It changes root's login shell to `/bin/zsh` **after** zsh and its files are installed.

For Vim it:

- Copies `files/vim/runtime/` into `/usr/share/vim/`, preserving the historical runtime layout expected by the bundled configuration.
- Installs `files/vim/.vimrc` as `/etc/skel/.vimrc` and `/root/.vimrc`.
- Creates `.gvimrc` symlinks pointing to `.vimrc`.
- Creates private `.vim/save`, `.vim/swp`, and `.vim/undo` directories for backups, swap files, and undo files.

The zsh startup file sources top-level `~/.zshrc.d/*.zsh` scripts. The `files/zsh/.zshrc.d/examples/` directory contains **examples**, not automatically activated personal settings. For example, a user can adapt `examples/ff-user.zsh` into `~/.zshrc.d/ff-user.zsh`; the `a0` through `ff` naming range is intended for personal or site-specific overrides. Set personal preferences such as `TZ` there rather than imposing them on every account.

`useradd -m` copies `/etc/skel` automatically when a new individual user is created; no subsequent dotfile copy or recursive ownership repair is needed.

### Shared group and home

For the default configuration:

- Group: `collab`, GID `2000` (override with `-i`).
- Shared account: `collab`, with home `/home/collab` and shell `/usr/sbin/nologin`.
- Shared directory: `/home/collab`, owned by `collab:collab` with setgid and mode `2770`.
- Access and default ACLs: owner and group receive `rwx`; others receive no access. Default ACLs establish inherited collaboration permissions for new contents.

This arrangement is meant for users to collaborate inside the shared directory **without** making their private home directories group-accessible. Default ACLs are not a guarantee that every application-created file will be writable by the group: applications can explicitly create or change restrictive file modes.

The group script checks for conflicting numeric GIDs and rejects an existing shared account whose configured home, primary GID, or login shell do not match its expectations.

### Individual users and SSH

`create-user.sh` creates, or updates an existing compatible account, as follows:

- Primary group: the user's own private group (created with `useradd -U`).
- Supplementary group: the common collaborative group.
- Home: `/home/USERNAME`, mode `0700`.
- Shell: `/bin/zsh`.
- SSH key: validated with `ssh-keygen` before account changes; installed into `~/.ssh/authorized_keys` with correct ownership and permissions. The `.ssh` directory uses `0700` and `authorized_keys` uses `0600`.

**Rerun behavior:** For an existing compatible user, the script ensures collaborative membership and sets zsh as the shell. The supplied public key is **authoritative**: rerunning replaces `authorized_keys` rather than appending to it. Do not run it expecting preexisting additional keys to survive.

Neither user script grants `sudo` access or adds users to the `docker` group. Docker group membership can provide root-equivalent privileges and should be granted only as a separate deliberate administrative decision.

## Manual use outside cloud-init

On a new Ubuntu VM, after obtaining this repository and becoming root (or using `sudo` for each command), the scripts can also be run individually:

```bash
sudo bash vm-bootstrap.sh
sudo bash create-shared-group.sh -g collab -i 2000
sudo bash create-user.sh \
   -u exampleuser \
   -g collab \
   -k "$(cat /path/to/exampleuser.pub)"
```

The file at `/path/to/exampleuser.pub` must contain that user's complete **public** SSH key, not their private key. For additional users, repeat only the last command with the appropriate username and public key.

The scripts generally stop on errors and try to handle preexisting compatible accounts, but `vm-bootstrap.sh` is **not** a full configuration reconciler: it upgrades packages, writes the Docker source definition, installs files, and changes root's shell. Rerun it only intentionally.

## Validate a new VM

Wait for cloud-init to finish, then inspect its logs:

```bash
sudo cloud-init status --wait
sudo cloud-init status --long
sudo tail -n 100 /var/log/cloud-init-output.log
```

For the default group and the two **sample** usernames, check:

```bash
getent group collab
getent passwd collab
id steve
id georgine
stat -c '%A %U:%G %n' /home/collab /home/steve /home/georgine
getfacl /home/collab
sudo systemctl is-active docker
sudo docker version
```

You should find a non-login `collab` account; both individual users should belong to `collab`, while each has their own primary group. `/home/collab` should retain setgid and inheritable ACLs. Docker should be active.

A small cross-user ACL smoke test, **after both sample accounts have been created**:

```bash
sudo -u steve sh -c 'umask 077; touch /home/collab/.acl-smoke-test'
sudo -u georgine test -w /home/collab/.acl-smoke-test
getfacl /home/collab/.acl-smoke-test
sudo rm -f /home/collab/.acl-smoke-test
```

The second command should exit successfully: it checks that one collaborator can write to a file created by another, despite the deliberately restrictive umask. Substitute your actual usernames if you changed the example.

Finally, from a client machine, use each user's **private** SSH key to authenticate to the VM (the corresponding *public* key is the one supplied in Horizon). Verify an interactive zsh shell and launch Vim to confirm the expected settings. Also check access controls and network restrictions rather than relying solely on successful SSH login.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Instance running but setup seems incomplete | `cloud-init status --long` and `/var/log/cloud-init-output.log`; Horizon's ACTIVE state is not a completion signal. |
| Clone fails | Outbound GitHub access and the exact repository URL; the current example requires anonymous clone access. |
| Docker install fails | Ubuntu release/architecture, Docker repository availability, network/DNS, and APT errors in the cloud-init log. |
| `invalid SSH public key` | Replace the example placeholder with an actual complete single-line `.pub` key; check for line breaks and pasted private-key material. |
| Group creation fails with GID conflict | Determine which group owns the requested number using `getent group 2000`; change `GroupID` only if that is appropriate for every collaborating host. |
| SSH login fails | Cloud-init completion, SSH service, OpenStack security groups, reachable IP, correct username, matching private key, and `~/.ssh/authorized_keys` permissions. |
| zsh reports locale warnings | `files/zsh/.zshrc` sets `LANG` and `LC_ALL` to `en_US.UTF-8`; check `locale -a` and install/generate the locale if it is absent. |
| Shared file is not group-writable | Inspect `getfacl` on the directory and file, the ACL mask, and the file mode requested or subsequently changed by the creating application. |
| Changed repository configuration not visible on an existing VM | First-boot provisioning is not ongoing synchronization; reapply a change explicitly or rebuild a VM as appropriate. |

The scripts do not perform a reboot, configure the host firewall, add Docker users, mount shared storage, or set a machine-wide timezone. Those remain deliberate per-instance administration decisions.

## Security and reproducibility

- **Public SSH keys are not passwords**, but OpenStack user data should still be treated as instance configuration, **not secret storage**. Do not place private keys, credentials, or access tokens in Horizon's Configuration tab or in this repository.
- The GitHub repository is executable provisioning code fetched during boot. Review changes before using them on privileged hosts; restrict who can modify the repository.
- The example currently clones the **latest default branch**, so two launches at different times can pick up different commits. For repeatable provisioning, optionally add a `git -C "$TMP/manage-vms" checkout <reviewed-tag-or-commit>` after cloning and before running the scripts.
- Even with a pinned Git revision, Ubuntu and Docker package repository contents can change over time; this is repeatable **configuration**, not a bit-for-bit immutable image.
- If shared directories are placed on NFS or another multi-host filesystem, keep numeric UIDs and GIDs consistent across participating systems or use an appropriate centralized identity service.
- Recreating or deleting an OpenStack instance may destroy data held only on that instance. Provisioning scripts are **not** a backup or migration system.
- Bundled Vim support files and plugins may have third-party licenses; retain and review their applicable copyright and license notices when redistributing them.

## Maintaining the repository

Make changes to canonical zsh configuration under `files/zsh/` and Vim configuration under `files/vim/`. Changes committed here will apply to **newly provisioned** instances that use that revision; existing users' dotfiles are not automatically updated.

For a lightweight check before committing changes:

```bash
for script in vm-bootstrap.sh create-shared-group.sh create-user.sh example-invocation.sh; do
   bash -n "$script" || exit 1
done
```

This validates Bash parsing only. A real cloud-init launch on a fresh Ubuntu image is the meaningful end-to-end integration test.

Repository: <https://github.com/StephenAmerige/manage-vms>

