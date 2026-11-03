# manage-vms

Reproducible first-boot provisioning and lightweight ongoing account administration for Ubuntu virtual machines launched through **OpenStack Horizon**.

The usual workflow is to edit only the instance-specific settings in `example-invocation.sh`, paste it into **Launch Instance > Configuration**, and launch the VM. This minimal user-data script clones the repository and **sources `provision-vm.sh`**, which orchestrates bootstrap, collaborative group creation, user accounts, sudo policy, and the optional reboot. After installation, two administrative helpers remain available in `/usr/local/bin` for adding users and groups without repeating the bootstrap.

> **Scope:** This repository defines a VM's initial configuration and provides a limited set of account-management tools. It is **not** a continuous configuration-management service, backup system, user-deletion workflow, or guarantee of bit-for-bit identical instances.

> **Trust boundary:** This configuration intentionally grants provisioned users access to the **rootful Docker daemon** through the `docker` group. Such access is effectively **root-equivalent**. Unix primary groups and private home-directory permissions organize collaboration but do **not** provide a security boundary between mutually untrusted Docker users. Use separate VMs or appropriately configured rootless container engines when stronger isolation is required.

## Features

- Keep Horizon user data focused on instance configuration while `provision-vm.sh` owns the version-controlled orchestration logic.
- Upgrade Ubuntu packages and install standard utilities, including login-history and file-indexing support.
- Install Docker Engine, Docker CLI, containerd, Buildx, and the Compose plugin from Docker's official Ubuntu APT repository.
- Install zsh and Vim with canonical configuration and Vim runtime files bundled in this repository—without an external BashG clone or zsh ZIP download.
- Configure `/etc/skel`, root, and (when it exists) the pre-created Ubuntu cloud-image account.
- Create named collaborative groups, matching **non-login** accounts, and shared directories with setgid permissions and inheritable access-control lists (ACLs).
- Create individual accounts with private primary groups, private home directories, a common shell/editor environment, a collaborative supplementary group, automatic Docker access, and SSH public-key authentication.
- Allow an instance-specific list of users to receive passwordless sudo without modifying the stock `/etc/sudoers` file.
- Install the shared-group and individual-user provisioning helpers into `/usr/local/bin` for later administration.
- Optionally schedule a reboot after successful cloud-init provisioning.

## Repository layout

```text
manage-vms/
├── vm-bootstrap.sh             # Ubuntu, Docker, zsh, Vim, initial accounts and helpers
├── provision-vm.sh             # Sourced first-boot orchestration logic
├── create-shared-group.sh      # Collaborative group, non-login account and ACLs
├── create-user.sh              # Private user, collaboration, Docker and SSH key
├── example-invocation.sh       # Paste a customized copy into Horizon
├── README.md
└── files/
    ├── vim/
    │   ├── .vimrc              # Canonical Vim configuration
    │   └── runtime/
    │       ├── template/
    │       └── vimfiles/       # Bundled Vim plugins and support files
    └── zsh/
        ├── .zshenv
        ├── .zshrc
        └── .zshrc.d/
            ├── *.zsh          # Shared shell configuration
            └── examples/      # Optional user/site-specific examples
```

### Scripts at a glance

| Script | Arguments | Responsibility |
| --- | --- | --- |
| `vm-bootstrap.sh` | None | OS update, packages, Docker, shell/editor defaults, preexisting `ubuntu` account and helper installation |
| `provision-vm.sh` | Sourced; reads instance configuration from calling shell | Apply timezone, run bootstrap and helpers, configure sudo and reboot |
| `create-shared-group.sh` | `-g GROUP` and optional `-i GID` | Collaborative group, non-login account, shared directory, setgid and ACLs |
| `create-user.sh` | `-u USER -g GROUP -k 'PUBLIC_KEY'` | Individual user, private group/home, collaboration, Docker and SSH authorization |
| `example-invocation.sh` | Edit marked configuration section | Minimal cloud-init entrypoint that clones the repository and sources `provision-vm.sh` |

Provisioning operations must run as **root**, as they do under cloud-init. The example **sources** `provision-vm.sh` in the existing Bash process, rather than launching a child shell, so the instance variables and the `UserKey` and `SudoUsers` arrays remain available without exporting them. Installing administrative helpers with executable permissions in `/usr/local/bin` does not grant unprivileged callers the ability to change users or groups.

## Requirements and assumptions

- An **Ubuntu cloud image** with cloud-init and a usable OpenStack **Configuration** tab. `vm-bootstrap.sh` checks `/etc/os-release` and rejects non-Ubuntu systems. Ubuntu 24.04 and 26.04 LTS are intended targets; verify compatibility on your image and architecture.
- Network/DNS access to Ubuntu APT mirrors, `download.docker.com`, and the GitHub repository.
- Sufficient disk space and resources for the OS upgrades, Docker installation and container workloads.
- An anonymously cloneable repository at the URL configured in the example. Private-repository authentication is not implemented.
- Complete, **single-line public SSH keys** for users being provisioned. Private keys, passwords and access tokens must never be placed in cloud-init user data.
- OpenStack security groups, network addressing and an SSH service on the image that allow the intended access. The bootstrap installs `openssh-client` (used for `ssh-keygen`), **not** `openssh-server`.
- An administrative recovery login, normally the image's initial `ubuntu` account using the OpenStack key pair selected at launch.

Because the installed packages and upstream repositories change over time, identical script revisions do not necessarily produce bit-identical operating systems.

## Quick start: OpenStack Horizon

1. Push the provisioning code revision you intend to deploy and confirm that the VM can clone the repository.
2. Open [`example-invocation.sh`](example-invocation.sh) and make a **per-instance copy** of the entire file, beginning with `#!/bin/bash`. Edit only the marked `INSTANCE CONFIGURATION` section; keep the Git clone and `source` statements unchanged.
3. Set `Group` (the initial collaborative group) and `GroupID` (its numeric GID). You can leave `GroupID` empty for automatic allocation, but NFS or other multi-host shared storage may require consistent numeric IDs.
4. Populate the `UserKey` associative array with each desired username and its **complete SSH public key**. The checked-in values are placeholders and will fail validation if used unchanged.
5. Populate `SudoUsers` with only those users who should receive **passwordless sudo**. Each name must also appear in `UserKey`; the list may be empty.
6. Set `TimeZone` to an IANA zone such as `America/New_York`, or leave it empty to retain the image default. Set `RebootAfterProvisioning=true` for a scheduled post-provisioning reboot or `false` to reboot manually.
7. In Horizon, select **Launch Instance**, choose the Ubuntu image, network, security group and key pair, then paste the customized script into **Configuration** and launch the instance.
8. Monitor cloud-init and verify both account creation and access before considering the VM ready.

The configuration section resembles the following. **The public keys shown are deliberately invalid placeholders:**

```bash
Group='collab'
GroupID=2000
RebootAfterProvisioning=true

declare -A UserKey=(
   [steve]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY steve'
   [georgine]='ssh-ed25519 REPLACE_WITH_COMPLETE_PUBLIC_KEY georgine'
)

declare -a SudoUsers=(
   steve
)

TimeZone=''
```

After the marked configuration section, the example contains only the initial package installation, clone and source operations:

```bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git ca-certificates

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

git clone https://github.com/StephenAmerige/manage-vms.git "$TMP/manage-vms"
source "$TMP/manage-vms/provision-vm.sh"
```

Sourcing is intentional: it shares the same Bash variables and associative/indexed arrays as the user-data entrypoint. The `TMP` variable gives the orchestrator a place to prepare the temporary sudoers file; the caller's `EXIT` trap cleans up the cloned repository afterward. The example uses `set -euo pipefail` to stop on errors.

**Deployment dependency:** `provision-vm.sh` must be pushed to the repository **before** any instance uses this simplified user-data script. The checked-in example is generic; do **not** commit real instance-specific access lists or public-key mappings merely to launch an instance. Public SSH keys are not secrets, but user-data may remain retrievable from the instance or the cloud control plane, and should never be used for secret storage.

**Important:** Horizon's **ACTIVE** status does not mean cloud-init has finished. Package installation and provisioning can continue after the VM is running.

### Execution order

1. The minimal entrypoint installs packages necessary to clone the repository (`git`, `ca-certificates`) and clones it into a temporary directory.
2. It sources `provision-vm.sh`, which checks required variables and arrays, confirms each sudo user appears in `UserKey`, and logs the Git revision.
3. When `TimeZone` is specified, the orchestrator sets it **before** the bootstrap configures nightly indexing.
4. The orchestrator invokes `vm-bootstrap.sh` to install OS packages, Docker, shell/editor defaults, and administrative helpers.
5. It calls the installed `create-shared-group.sh`, passing the explicit `GroupID` when given, and calls `create-user.sh` for each `UserKey` entry. All users join the specified collaborative group and `docker`.
6. It validates and installs `/etc/sudoers.d/90-manage-vms` for the explicitly named `SudoUsers`, leaving `/etc/sudoers` unchanged.
7. It logs completion and, if enabled, schedules a reboot **one minute later** using `shutdown -r +1` so cloud-init can finish. A scheduled reboot can be canceled with `sudo shutdown -c` before it happens.

The temporary clone is removed when the invocation exits. The two installed helpers remain available for future administration. The orchestrator is a first-boot component; it is **not** installed as a long-term administration command.

### Deterministic provisioning revisions

The example currently clones the repository's default branch as it exists at launch time. Its `git rev-parse HEAD` log line records which commit was used. For repeatable deployments, consider checking out a reviewed **commit SHA or tag** immediately after the clone and before running the bootstrap:

```bash
git -C "$TMP/manage-vms" checkout --detach REVIEWED_COMMIT_SHA
```

Replace `REVIEWED_COMMIT_SHA` with a real commit. A pinned Git revision controls the provisioning code but not the changing contents of Ubuntu's and Docker's package repositories.

## What the bootstrap configures

### Ubuntu packages and Docker

`vm-bootstrap.sh` confirms it is running as root on Ubuntu, checks the repository layout, then runs `apt-get update` and `apt-get upgrade -y`. It installs:

```text
acl ca-certificates curl git gnupg lsb-release
openssh-client plocate sudo unzip vim yq zip zsh
```

It installs Docker's signing key in `/etc/apt/keyrings/docker.asc` and its Ubuntu APT source in `/etc/apt/sources.list.d/docker.sources`, then installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, and `docker-compose-plugin`. Docker is enabled and started with systemd.

On Ubuntu 25.10 and later, the bootstrap additionally installs `wtmpdb` and `libpam-wtmpdb` for login-history recording; Ubuntu 24.04 retains the traditional `last`/wtmp implementation.

The `plocate` package initializes its filename database. The bootstrap installs a systemd timer drop-in to run `plocate-updatedb.timer` at **02:00 local time**, with `AccuracySec=1min`, no randomized delay and `Persistent=false` so a missed run is not caught up during the day. The orchestrator sets `TimeZone`, if supplied, before this timer is configured. Inspect the schedule with `systemctl list-timers --all plocate-updatedb.timer`.

**Do not make `/var/run/docker.sock` world-writable.** Docker's standard `root:docker` socket ownership and `0660` permissions are retained; provisioned users gain access through membership in `docker` instead.

### Canonical zsh and Vim configuration

The bootstrap copies `files/zsh/.zsh*` to `/etc/skel/` and `/root/`, including `.zshrc.d/` but excluding common history and cache filenames. Root's login shell changes to `/bin/zsh` after zsh is installed.

For Vim, it:

- Copies `files/vim/runtime/` into `/usr/share/vim/`, preserving the historical runtime layout expected by the custom configuration.
- Installs `files/vim/.vimrc` as `/etc/skel/.vimrc` and `/root/.vimrc`.
- Creates `.gvimrc` symbolic links pointing to `.vimrc`.
- Creates private `.vim/save`, `.vim/swp` and `.vim/undo` directories (mode `0700`) for backups, swap files and undo files.

New users created through `useradd -m` automatically inherit `/etc/skel`. The `.zshrc` sources top-level `~/.zshrc.d/*.zsh` files. Example personal files such as `files/zsh/.zshrc.d/examples/ff-user.zsh` are **not enabled automatically**; users can copy and adapt them into their own `.zshrc.d/`. The `a0`–`ff` naming range is intended for site- or user-specific customizations, such as `TZ`, without imposing personal settings globally.

### Preexisting `ubuntu` account

On standard Ubuntu cloud images, cloud-init has already created `ubuntu` **before** the bootstrap populates `/etc/skel`. When the account exists, `vm-bootstrap.sh` explicitly installs the canonical zsh and Vim files, configures its login shell as zsh, and adds it to `docker`.

The bootstrap leaves its existing SSH authorization and sudo policy in place. It avoids modifying `~ubuntu/.ssh` and does not replace the account itself.

### Reusable administration helpers

During bootstrap, root-owned copies of these commands are installed with mode `0755`:

```text
/usr/local/bin/create-shared-group.sh
/usr/local/bin/create-user.sh
```

They can be called by root or using `sudo` when users and groups need to be added later. Because the initial Git checkout is temporary, **later GitHub updates do not automatically update these installed copies**. Reinstall them explicitly or rebuild the instance when their behavior changes.

## Collaborative groups and ACLs

`create-shared-group.sh -g GROUP [-i GID]` creates a group, a same-named **non-login Unix account**, and `/home/GROUP` for collaborative work. The shared account uses `/usr/sbin/nologin` and is not intended for ordinary direct SSH login.

The shared directory is owned by `GROUP:GROUP`, normally has mode `2770` (setgid), and receives access and default ACL entries granting read/write/execute to owner and group, and no access to others. The setgid bit causes new contents to inherit the shared group; the default ACLs help new files and directories inherit collaborative permissions.

The optional `-i GID` specifies an explicit numeric group ID. **When omitted, the operating system allocates an available GID.** The helper checks for conflicting GIDs and incompatible existing accounts and can process a compatible preexisting group/account again.

An application may explicitly create a restrictive file mode or later change permissions, so default ACLs do not guarantee that every file will always be group-writable.

## Individual users and SSH authorization

`create-user.sh -u USER -g GROUP -k 'PUBLIC_KEY'` validates the supplied key before changing the account and requires the named collaborative group and the `docker` group to exist.

A new user receives:

| Property | Result |
| --- | --- |
| Primary group | Private group named after the user, created by `useradd -U` |
| Supplementary groups | The selected collaborative group **and** `docker` |
| Home directory | `/home/USER`, mode `0700`, initially populated from `/etc/skel` |
| Login shell | `/bin/zsh` |
| SSH authorization | `~/.ssh/authorized_keys`, mode `0600`, in a mode-`0700` `.ssh` directory |

For a compatible existing user, the helper adds the specified supplementary memberships and sets zsh; it does not remove any previous supplementary groups. **The key supplied with `-k` is authoritative**: every invocation replaces the user's entire `authorized_keys` file rather than appending a key. This is particularly important when updating an existing student's account.

After adding a user to a supplementary group, a **new login session** is normally required for the membership to take effect. Verify with `id` and `docker ps` after reconnecting.

Private home-directory mode `0700` is intended to prevent ordinary unprivileged access by other users. It does **not** constrain other users who have effective root privileges through Docker or sudo.

## Administrative privileges

### Standard Docker access

Every provisioned user receives direct access to the rootful Docker daemon through the `docker` supplementary group. This is a deliberate trusted-user policy: **Docker access is root-equivalent**, even without conventional `sudo` membership.

Different collaborative groups can coexist on one VM; users need not share a collaborative group to access Docker. However, mutually exclusive collaborative memberships do **not** prevent one Docker-enabled user from accessing the other group's host files through rootful containers. Use separate VMs or a different container security model for truly untrusted users.

### Selective passwordless sudo

`example-invocation.sh` contains a `SudoUsers` array. Every name in this list must also be in the instance's `UserKey` array. After creating users, the sourced `provision-vm.sh` generates a root-owned file with mode `0440` at:

```text
/etc/sudoers.d/90-manage-vms
```

It validates the proposed rules with `visudo`, installs the file, validates the sudo policy again, and adds listed users to the `sudo` group. A typical rule is:

```text
steve ALL=(ALL:ALL) NOPASSWD: ALL
```

This grants passwordless sudo only to those **explicitly designated administrators**, without editing the default `%sudo` rule in `/etc/sudoers`. `ubuntu` retains whatever sudo arrangement was provided by the cloud image.

If `SudoUsers` is empty during an initial launch, no custom sudoers file is created. On an already configured instance, simply rerunning the orchestration with an empty list would **not** remove an existing sudoers file or revoke prior access; administrative revocation is a separate task.

## Adding users and groups after launch

The installed helper commands simplify requests such as *“Please create user xyz in collaborative group pqr.”* Only a privileged administrator can successfully execute them.

### Create another collaborative group

```bash
sudo create-shared-group.sh -g pqr
```

The system chooses its numeric GID. For shared filesystems or a known identity scheme, specify it explicitly:

```bash
sudo create-shared-group.sh -g pqr -i 2001
```

### Create a user

Given a file containing the new user's **public** SSH key:

```bash
sudo create-user.sh \
   -u xyz \
   -g pqr \
   -k "$(cat /path/to/xyz.pub)"
```

The private primary group, `/etc/skel` files, collaborator membership, Docker access and SSH authorization are handled together. If the user is already present and compatible, the script updates membership and replaces `authorized_keys` with the specified key.

### Verify the new user

```bash
id xyz
getent group xyz
getent group pqr
stat -c '%A %U:%G %n' /home/xyz /home/pqr
sudo -u xyz test -w /home/pqr
```

Test SSH login using the corresponding private key from an authorized client. After the first login, check `docker ps` directly as the user.

### Removing users

There is currently **no** `delete-user.sh` helper. Student offboarding and group cleanup need a separately reviewed procedure that addresses account termination, SSH access, running processes, home data, shared files, Docker workloads, and any relevant NFS identity mappings. Do not assume deleting a Unix account automatically removes all access paths or preserves everything that should be retained.

## Validation after first boot

### Monitor cloud-init

```bash
sudo cloud-init status --wait
sudo cloud-init status --long
sudo tail -n 100 /var/log/cloud-init-output.log
sudo less /var/log/cloud-init.log
```

`/var/log/cloud-init-output.log` contains stdout and stderr from provisioning commands; `/var/log/cloud-init.log` contains more detailed cloud-init diagnostics. You can watch progress with `sudo tail -f /var/log/cloud-init-output.log`. Horizon's instance console **Log** may show some output, but is not a substitute for the files above.

If the invocation schedules a reboot, the VM may disconnect one minute after the success message. Reconnect after it is available, then verify final service and account state. A failure before the final reboot statement normally prevents the script from scheduling that reboot because the invocation uses `set -euo pipefail`.

### Verify accounts and permissions

For the generic example usernames:

```bash
getent passwd collab
getent group collab
id steve
id georgine
stat -c '%A %U:%G %n' /home/collab /home/steve /home/georgine
getfacl /home/collab
```

The collaborative directory should have setgid and inheritable ACL entries; each individual home should have its own primary group and mode `0700`.

Cross-user ACL smoke test (using the example users, after provisioning):

```bash
sudo -u steve sh -c 'umask 077; touch /home/collab/.acl-smoke-test'
sudo -u georgine test -w /home/collab/.acl-smoke-test
getfacl /home/collab/.acl-smoke-test
sudo rm -f /home/collab/.acl-smoke-test
```

This tests whether one collaborator can modify a file another created even when the creator's umask is restrictive. Substitute your actual group and usernames as appropriate.

### Verify timezone, indexing, Docker, sudo, zsh and Vim

```bash
timedatectl
systemctl list-timers --all plocate-updatedb.timer
sudo systemctl is-active docker
sudo docker version
getent group docker
id steve
sudo -l -U steve
sudo visudo -c
```

Log in as a provisioned user and check `docker ps` (without sudo). For a user in `SudoUsers`, run `sudo -n true` to verify passwordless sudo. Verify an interactive zsh shell and open Vim to confirm the expected configuration. Check the initial `ubuntu` account independently if it is present.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Horizon says ACTIVE but users are missing | `cloud-init status --long`, `/var/log/cloud-init-output.log`; ACTIVE is not a provisioning-complete signal. |
| Git clone fails | DNS, network egress, repository URL and anonymous clone access. |
| `source` fails because `provision-vm.sh` is absent | Push the orchestrator before using the simplified instance script, and confirm the clone uses the intended repository revision. |
| Indexing uses the wrong local hour | Check `TimeZone`, `timedatectl` and `systemctl cat plocate-updatedb.timer`. |
| APT or Docker install fails | Ubuntu release/architecture, package repository availability, disk space, DNS and the cloud-init output log. |
| `invalid SSH public key` | Provide exactly one complete public-key line, not a placeholder, private key or wrapped/multiline value. |
| Group creation fails | Inspect `getent group GROUP` and `getent group GID` for name/GID collisions or a conflicting existing account. |
| SSH login fails | Cloud-init status, sshd, OpenStack security groups, host reachability, username, matching private key and `authorized_keys` ownership/mode. |
| `docker ps` returns permission denied | Verify `id`, `getent group docker`, socket owner/mode and a **new login session** after membership changes. Do not `chmod a+rw` the socket. |
| Passwordless sudo fails | Verify `SudoUsers`, `sudo -l -U USER`, `/etc/sudoers.d/90-manage-vms` permissions and `sudo visudo -c`. |
| zsh produces locale warnings | `.zshrc` selects `en_US.UTF-8`; check `locale -a` and generate/install the locale if absent. |
| Shared file not group-writable | Inspect `getfacl` of the file and directory, ACL masks and restrictive modes applied by the application. |
| Reboot unexpectedly pending | Check the example's `RebootAfterProvisioning` value and `shutdown` schedule; cancel with `sudo shutdown -c` if appropriate. |
| New GitHub changes do not appear on an existing VM | First-boot provisioning is not automatic synchronization; reapply appropriate changes or rebuild. |

## Security and reproducibility considerations

- **Protect the provisioning repository.** Its scripts execute as root during first boot. Review changes before using a new revision and restrict who can push to the repository.
- **Use public keys only in user data.** Never include private keys, passwords, API credentials or other secrets in Horizon's Configuration tab.
- **Docker is a privileged trust decision.** Every account granted rootful Docker access can potentially control the host, regardless of its separate primary group or lack of conventional sudo membership.
- **Preserve SSH recovery access.** Keep the cloud image's initial administrative account accessible until newly provisioned SSH logins are verified. The bootstrap deliberately does not modify that account's existing SSH keys.
- **Coordinate numeric identities** across hosts when using NFS or other multi-host shared filesystems. The optional `-i GID` exists for precisely that reason; dynamically assigned individual UIDs may also require attention.
- **Do not assume that an upgraded VM has rebooted.** The example schedules a reboot only on successful completion when `RebootAfterProvisioning=true`. Reboots interrupt workloads, so be deliberate when changing that behavior for existing instances.
- **Treat instance destruction as data loss unless storage is protected.** Rebuilding an OpenStack instance does not back up or migrate user data.
- **Retain applicable third-party licenses** for bundled Vim plugins, colorschemes and other redistributed support files.

## Maintaining the repository

The canonical configuration lives under `files/zsh/` and `files/vim/`. Make shared changes there and commit them. New VMs using that revision inherit the changes; existing home directories do not receive automatic updates.

The `/usr/local/bin` helpers on a provisioned VM are installed snapshots, not links to GitHub. Updating the repository does not replace those commands until an administrator reinstalls them or reprovisions the VM.

Keep orchestration changes in `provision-vm.sh`, not copied into each instance-specific user-data script. Review and push the orchestrator and updated example together before launching new instances.

Run Bash syntax checks before committing:

```bash
for script in vm-bootstrap.sh provision-vm.sh create-shared-group.sh create-user.sh example-invocation.sh; do
   bash -n "$script" || exit 1
done
```

This catches syntax errors but cannot replace a fresh-VM cloud-init integration test. Review `git diff`, commit changes conventionally, and record the revision tested in OpenStack.

Repository: <https://github.com/StephenAmerige/manage-vms>
