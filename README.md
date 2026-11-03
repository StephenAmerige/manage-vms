# ubuntu-host-bootstrap

Reproducible Ubuntu system provisioning and ongoing account administration for **virtual machines and physical hosts**. Run the same configuration manually or as a cloud-init user-data script on platforms that support it.

Customize the settings in `example-invocation.sh` and run it as root on an Ubuntu system, or pass it as a Bash user-data script during automated provisioning. The small entrypoint clones this repository and **sources `provision-vm.sh`**, which coordinates OS setup, collaborative groups, user accounts, sudo policy, and the optional reboot. Two administrative helpers remain installed in `/usr/local/bin` for later user and group management.

> **Scope:** This repository initializes an Ubuntu system and provides a limited set of account-management tools. It is **not** a continuous configuration-management service, backup system, user-deletion workflow, or guarantee of bit-for-bit identical systems. It is best suited to fresh installations; see the cautions for already-used hosts below.

> **Trust boundary:** This configuration intentionally grants provisioned users access to the **rootful Docker daemon** through the `docker` group. Such access is effectively **root-equivalent**. Unix primary groups and private home-directory permissions organize collaboration but do **not** provide a security boundary between mutually untrusted Docker users. Use separate VMs or appropriately configured rootless container engines when stronger isolation is required.

**License:** Original project code is offered under the [MIT License](LICENSE).
Bundled third-party Vim components retain their own terms (see
[third-party notices](THIRD_PARTY_NOTICES.md)); one colorscheme still has an
unverified redistribution license as described there.

## Features

- Keep machine-specific settings separate from the repository-managed provisioning logic, whether launched manually or through cloud-init.
- Upgrade Ubuntu packages and install standard utilities, including login-history and file-indexing support.
- Install Docker Engine, Docker CLI, containerd, Buildx, and the Compose plugin from Docker's official Ubuntu APT repository.
- Install zsh and Vim with canonical configuration and Vim runtime files bundled in this repository—without an external BashG clone or zsh ZIP download.
- Configure `/etc/skel`, root, and an existing account named `ubuntu` when present.
- Create named collaborative groups, matching **non-login** accounts, and shared directories with setgid permissions and inheritable access-control lists (ACLs).
- Create individual accounts with private primary groups, private home directories, a common shell/editor environment, a collaborative supplementary group, automatic Docker access, and SSH public-key authentication.
- Allow an host-specific list of users to receive passwordless sudo without modifying the stock `/etc/sudoers` file.
- Install the shared-group and individual-user provisioning helpers into `/usr/local/bin` for later administration.
- Optionally schedule a reboot after successful provisioning, whether launched manually or through cloud-init.

## Repository layout

```text
ubuntu-host-bootstrap/
├── vm-bootstrap.sh             # Ubuntu, Docker, zsh, Vim, initial accounts and helpers
├── provision-vm.sh             # Sourced provisioning orchestration logic
├── create-shared-group.sh      # Collaborative group, non-login account and ACLs
├── create-user.sh              # Private user, collaboration, Docker and SSH key
├── example-invocation.sh       # Machine settings and portable entrypoint
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
| `provision-vm.sh` | Sourced; reads host configuration from calling shell | Apply timezone, run bootstrap and helpers, configure sudo and reboot |
| `create-shared-group.sh` | `-g GROUP` and optional `-i GID` | Collaborative group, non-login account, shared directory, setgid and ACLs |
| `create-user.sh` | `-u USER -g GROUP -k 'PUBLIC_KEY'` | Individual user, private group/home, collaboration, Docker and SSH authorization |
| `example-invocation.sh` | Edit marked configuration section | Run manually as root or as Bash user data; clones the repository and sources `provision-vm.sh` |

Provisioning operations must run as **root**, whether started by an administrator or by a cloud-init service. The example **sources** `provision-vm.sh` in the existing Bash process rather than launching a child shell, so its configuration variables and the `UserKey` and `SudoUsers` arrays remain available without exporting them. Installing administrative helpers with executable permissions in `/usr/local/bin` does not grant unprivileged callers the ability to change users or groups.

## Requirements and assumptions
## Requirements and assumptions

- **Ubuntu 24.04 or 26.04 LTS**, running on a VM or a physical host. `vm-bootstrap.sh` checks `/etc/os-release` and rejects non-Ubuntu systems. The implementation assumes APT, systemd, Bash, and standard GNU/Linux account-management tools.
- **Root privileges** for the initial setup (`sudo bash ...` for manual use). An automated user-data system must run the Bash script as root.
- Network/DNS access to Ubuntu APT mirrors, `download.docker.com`, and the GitHub repository.
- Sufficient disk space and resources for OS upgrades, Docker installation, and subsequent workloads.
- An anonymously cloneable repository at the URL in the example. Private-repository authentication is not implemented.
- Complete **single-line SSH public keys** for accounts being provisioned. Never place SSH private keys, passwords, or API credentials in the configuration script.
- An SSH server and appropriate host firewall/network rules **if remote login is required**. The bootstrap installs `openssh-client` for `ssh-keygen`, **not** `openssh-server`.
- A separate existing administrator/recovery login before the initial setup. An account named `ubuntu` is configured specially if present; other preexisting administrator accounts are not automatically given the canonical zsh and Vim files.

**Cloud-init is optional.** To automate provisioning at first boot, use an Ubuntu image with cloud-init (or another mechanism capable of running a Bash script as root). For manual setup, no cloud-init installation, cloud metadata, or particular virtualization platform is required.

**Caution for existing systems:** The bootstrap upgrades OS packages, installs and enables Docker, changes root's login shell, installs standard editor/shell settings for root and the `ubuntu` account when present, and may schedule a reboot. It is intended primarily for fresh hosts, not as a non-disruptive configuration reconciler for production machines. Back up important configurations and data before running it on an already-used system.

Upstream packages and repositories can change over time, so matching script revisions do not guarantee bit-identical systems.

## Quick start

1. Make a copy of [`example-invocation.sh`](example-invocation.sh) for the host. Keep the opening `#!/bin/bash` line and the clone/`source` commands intact.
2. Edit only the clearly marked **HOST CONFIGURATION** section. Set the initial collaborative `Group` and optional `GroupID` (leave empty to allocate a GID automatically). On shared filesystems, coordinate numeric IDs across hosts.
3. Set the `UserKey` associative array to the desired usernames and their **complete SSH public keys**. The repository's sample keys are intentionally invalid placeholders.
4. Populate `SudoUsers` with the subset that should receive **passwordless sudo**. All its names must appear in `UserKey`; the array may be empty.
5. Set `TimeZone` to an IANA zone such as `America/New_York`, or leave it empty to retain the system default. Set `RebootAfterProvisioning=true` for a delayed restart or `false` to reboot manually.
6. Run the file as root on the target Ubuntu host, or supply its entire contents to a first-boot service that executes Bash user data as root.
7. Verify account creation, SSH authentication, Docker access, collaborative ACLs, and the remaining service configuration.

The editable portion looks like this. **The public keys below are deliberately invalid placeholders:**

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

After the configuration section, the example contains only the minimal setup, clone and source operations:

```bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git ca-certificates

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

git clone https://github.com/StephenAmerige/ubuntu-host-bootstrap.git "$TMP/ubuntu-host-bootstrap"
source "$TMP/manage-vms/provision-vm.sh"
```

Sourcing intentionally shares the same Bash variables and associative/indexed arrays with the orchestrator. `TMP` provides a secure temporary checkout and a place to prepare sudoers rules; the caller's `EXIT` trap removes it afterward. The entrypoint uses `set -euo pipefail` to stop on errors.

### Manual provisioning (any supported Ubuntu host)

Copy your customized script to the machine, then invoke it directly:

```bash
sudo bash ./my-host-config.sh
```

No cloud-init or cloud-provider metadata is involved. Output appears in your terminal; the script must have network access and root privileges. For a local log, run from a Bash shell with `pipefail` enabled:

```bash
set -o pipefail
sudo bash ./my-host-config.sh 2>&1 | tee provisioning.log
```

If rebooting is enabled, it is scheduled approximately one minute after successful provisioning. Be sure the machine can be reached again after restarting.

### Automated provisioning (cloud-init or equivalent)

When the target image has cloud-init, paste the **entire customized Bash script** (starting with `#!/bin/bash`) into the platform's **user-data** or startup-script field. The mechanism must execute it as root. Check its logs and confirm completion; a machine being powered on or marked *running* does not imply provisioning has finished.

For cloud-init, use `sudo cloud-init status --long` and inspect `/var/log/cloud-init-output.log`. Other startup mechanisms may write logs elsewhere.

### Example: OpenStack Horizon

In **Launch Instance > Configuration**, paste the complete customized script into the configuration field. Select an Ubuntu cloud image, suitable network/security-group settings, and an administrative SSH key pair. Cloud-init executes the script during first boot. Horizon may show the VM as **ACTIVE** before provisioning has completed; check the logs and test an actual user login.

The same entrypoint can also be run manually on an Ubuntu VM created outside OpenStack or on a physical Ubuntu host. Neither the coordinator nor the helper scripts require OpenStack services or APIs.

### Repository revision and configuration security

**Deployment dependency:** `provision-vm.sh` must already exist in the repository being cloned. Do not commit machine-specific access lists or actual SSH-key mappings simply to deploy a host. Public keys are not secrets, but cloud user-data may remain retrievable from the guest or its management platform; never place secret material there or in the public repository.

### Execution order

1. The minimal entrypoint installs packages necessary to clone the repository (`git`, `ca-certificates`) and clones it into a temporary directory.
2. It sources `provision-vm.sh`, which checks required variables and arrays, confirms each sudo user appears in `UserKey`, and logs the Git revision.
3. When `TimeZone` is specified, the orchestrator sets it **before** the bootstrap configures nightly indexing.
4. The orchestrator invokes `vm-bootstrap.sh` to install OS packages, Docker, shell/editor defaults, and administrative helpers.
5. It calls the installed `create-shared-group.sh`, passing the explicit `GroupID` when given, and calls `create-user.sh` for each `UserKey` entry. All users join the specified collaborative group and `docker`.
6. It validates and installs `/etc/sudoers.d/90-manage-vms` for the explicitly named `SudoUsers`, leaving `/etc/sudoers` unchanged.
7. It logs completion and, if enabled, schedules a reboot **one minute later** using `shutdown -r +1` so the calling script can exit and its output can be recorded. Cancel a pending reboot with `sudo shutdown -c`.

The temporary clone is removed when the invocation exits. The two installed helpers remain available for future administration. The orchestrator runs during initial setup; it is **not** installed as a long-term administration command.

### Deterministic provisioning revisions

The example currently clones the repository's default branch at execution time. Its `git rev-parse HEAD` log line records the revision used. For repeatable deployments, consider checking out a reviewed **commit SHA or tag** immediately after the clone and before sourcing the orchestrator:

```bash
git -C "$TMP/ubuntu-host-bootstrap" checkout --detach REVIEWED_COMMIT_SHA
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

On many Ubuntu cloud images, the initial `ubuntu` account is created **before** the bootstrap populates `/etc/skel`. When that account exists (cloud image or otherwise), `vm-bootstrap.sh` explicitly installs the canonical zsh and Vim files, configures its login shell as zsh, and adds it to `docker`. On installations whose initial administrative user has another name, that account is left unchanged.

The bootstrap leaves its existing SSH authorization and sudo policy in place. It avoids modifying `~ubuntu/.ssh` and does not replace the account itself.

### Reusable administration helpers

During bootstrap, root-owned copies of these commands are installed with mode `0755`:

```text
/usr/local/bin/create-shared-group.sh
/usr/local/bin/create-user.sh
```

They can be called by root or using `sudo` when users and groups need to be added later. Because the initial Git checkout is temporary, **later GitHub updates do not automatically update these installed copies**. Reinstall them explicitly or reprovision the host when their behavior changes.

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

For a compatible existing user, the helper adds the specified supplementary memberships and sets zsh; it does not remove any previous supplementary groups. **The key supplied with `-k` is authoritative**: every invocation replaces the user's entire `authorized_keys` file rather than appending a key. This is particularly important when updating an existing account.

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

This grants passwordless sudo only to those **explicitly designated administrators**, without editing the default `%sudo` rule in `/etc/sudoers`. An existing `ubuntu` account retains its preexisting sudo arrangement.

If `SudoUsers` is empty during an initial launch, no custom sudoers file is created. On an already configured instance, simply rerunning the orchestration with an empty list would **not** remove an existing sudoers file or revoke prior access; administrative revocation is a separate task.

## Adding users and groups after setup

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

There is currently **no** `delete-user.sh` helper. Account offboarding and group cleanup need a separately reviewed procedure that addresses account termination, SSH access, running processes, home data, shared files, Docker workloads, and any relevant NFS identity mappings. Do not assume deleting a Unix account automatically removes all access paths or preserves everything that should be retained.

## Validation after provisioning

### Monitor execution

For a manual run, the terminal displays command output directly. Capture it to a file using the `tee` example above if desired. When running through cloud-init, inspect its status and logs:

```bash
sudo cloud-init status --wait
sudo cloud-init status --long
sudo tail -n 100 /var/log/cloud-init-output.log
sudo less /var/log/cloud-init.log
```

`/var/log/cloud-init-output.log` contains stdout and stderr for cloud-init runs; `/var/log/cloud-init.log` contains additional cloud-init diagnostics. Follow progress with `sudo tail -f /var/log/cloud-init-output.log`. These paths apply to cloud-init-based deployment, **not** ordinary `sudo bash` execution.

If rebooting is enabled, the host may disconnect one minute after the success message. Reconnect after it is available, then verify the final services and accounts. A failure before the scheduling command normally prevents the reboot because the invocation uses `set -euo pipefail`.

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
| Host is running but users are missing | Verify the invocation finished successfully; for cloud-init, inspect `cloud-init status --long` and `/var/log/cloud-init-output.log`. For a manual run, inspect terminal output or the saved log. |
| Git clone fails | DNS, network egress, repository URL and anonymous clone access. |
| `source` fails because `provision-vm.sh` is absent | Push the orchestrator before using the simplified host script, and confirm the clone uses the intended repository revision. |
| Indexing uses the wrong local hour | Check `TimeZone`, `timedatectl` and `systemctl cat plocate-updatedb.timer`. |
| APT or Docker install fails | Ubuntu release/architecture, repository availability, disk space, DNS, and the relevant execution log. |
| `invalid SSH public key` | Provide exactly one complete public-key line, not a placeholder, private key or wrapped/multiline value. |
| Group creation fails | Inspect `getent group GROUP` and `getent group GID` for name/GID collisions or a conflicting existing account. |
| SSH login fails | Provisioning completion, sshd, firewall/network access, username, matching private key and `authorized_keys` ownership/mode. |
| `docker ps` returns permission denied | Verify `id`, `getent group docker`, socket owner/mode and a **new login session** after membership changes. Do not `chmod a+rw` the socket. |
| Passwordless sudo fails | Verify `SudoUsers`, `sudo -l -U USER`, `/etc/sudoers.d/90-manage-vms` permissions and `sudo visudo -c`. |
| zsh produces locale warnings | `.zshrc` selects `en_US.UTF-8`; check `locale -a` and generate/install the locale if absent. |
| Shared file not group-writable | Inspect `getfacl` of the file and directory, ACL masks and restrictive modes applied by the application. |
| Reboot unexpectedly pending | Check the example's `RebootAfterProvisioning` value and `shutdown` schedule; cancel with `sudo shutdown -c` if appropriate. |
| New GitHub changes do not appear on an existing host | Provisioning is not automatic synchronization; reapply appropriate changes or rebuild the host. |

## Security and reproducibility considerations

- **Protect the provisioning repository.** Its scripts execute as root during setup. Review changes before using a new revision and restrict who can push to the repository.
- **Use public keys only in configuration.** Never include private keys, passwords, API credentials or other secrets in local setup scripts, cloud user data, or the public repository.
- **Docker is a privileged trust decision.** Every account granted rootful Docker access can potentially control the host, regardless of its separate primary group or lack of conventional sudo membership.
- **Preserve administrative recovery access.** Keep an existing administrative account accessible until new SSH logins are verified. The bootstrap deliberately does not modify the `ubuntu` account's existing SSH keys when that account exists.
- **Coordinate numeric identities** across hosts when using NFS or other multi-host shared filesystems. The optional `-i GID` exists for precisely that reason; dynamically assigned individual UIDs may also require attention.
- **Do not assume that an upgraded host has rebooted.** The example schedules a reboot only on successful completion when `RebootAfterProvisioning=true`. Reboots interrupt workloads, so be deliberate when changing that behavior for existing instances.
- **Protect existing data.** Rebuilding a machine or VM does not back up or migrate users' files. Running the bootstrap on an existing host can replace shell/editor settings and update operating-system packages.
- **Retain applicable third-party licenses** for bundled Vim plugins, colorschemes and other redistributed support files.

## License and attribution

The original provisioning scripts, project-specific configuration, and original
documentation are made available under the **MIT License**; see [`LICENSE`](LICENSE).
The license permits personal, research, commercial, and proprietary use with
retention of the copyright and permission notice.

Files bundled from other authors are **not relicensed** by this project. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for the inventory and original
attributions; complete texts of the applicable GNU GPLv2 and Vim License are
included in [`licenses/`](licenses/). The shipped third-party Vim components
include both permissively licensed and GPL-licensed material. The
`summerfruit256.vim` colorscheme's redistribution terms remain unresolved,
so the notices identify this explicitly rather than claiming the entire
repository is uniformly MIT licensed.

### Canonical upstream and organization copies

The canonical development repository is
[`StephenAmerige/ubuntu-host-bootstrap`](https://github.com/StephenAmerige/ubuntu-host-bootstrap).
An organization can maintain a separate copy using its own Git remote,
while retaining attribution and applicable licenses. An independent copy
need not be a GitHub-recognized fork, and changes in that copy do not
synchronize back automatically. Propose general improvements upstream;
keep site-specific configuration in the corresponding downstream repository.

## Maintaining the repository

The canonical configuration lives under `files/zsh/` and `files/vim/`. Make shared changes there and commit them. New hosts using that revision inherit the changes; existing home directories do not receive automatic updates.

The `/usr/local/bin` helpers on a provisioned VM are installed snapshots, not links to GitHub. Updating the repository does not replace those commands until an administrator reinstalls them or reprovisions the VM.

Keep orchestration changes in `provision-vm.sh`, not copied into each machine-specific entrypoint. Review and push the orchestrator and updated example together before provisioning new hosts.

Run Bash syntax checks before committing:

```bash
for script in vm-bootstrap.sh provision-vm.sh create-shared-group.sh create-user.sh example-invocation.sh; do
   bash -n "$script" || exit 1
done
```

This catches Bash syntax errors but does not replace an integration test on a fresh Ubuntu host. Test both manual execution and any unattended deployment mechanism you intend to support. Review `git diff`, commit changes conventionally, and record the Git revision used.

Repository: <https://github.com/StephenAmerige/ubuntu-host-bootstrap>
