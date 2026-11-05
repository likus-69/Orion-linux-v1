# Orion OS — Security Policy

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report vulnerabilities by email to:
**`likus-69+security@users.noreply.github.com`** (replace with the project's actual contact
address listed in the project page). Please:

1. Use a clear, descriptive subject line beginning with `[SEC]`.
2. Describe the affected component and version (run `orion-about` or inspect
   `os-release`).
3. Include steps to reproduce, expected behavior, and actual behavior.
4. If possible, include a proof-of-concept and a suggested fix.
5. PGP-encrypt the report if you can; the project's public key fingerprint is
   published in [`docs/security.md`](docs/security.md) under "Disclosure PGP
   key". If no key is published, plain email is acceptable.

## Disclosure timeline

- **Acknowledgement within 72 hours** of receiving the report.
- **Initial assessment within 7 days.**
- **Coordinated disclosure** after a fix is available, or after **90 days**
  from the initial report, whichever comes first. Critical issues may be
  disclosed sooner with the reporter's cooperation.
- Credit will be given to the reporter unless they prefer to remain anonymous.

## What qualifies as a security issue

- Privilege escalation (any unprivileged user → root, or one user → another).
- Bypass of polkit / sudo authorization.
- Arbitrary code execution from a desktop file, thumbnailer, archive, or
  network request.
- Insecure defaults that expose services, files, or input to untrusted parties
  without explicit user opt-in.
- Secret leakage (private keys, tokens, passwords) in shipped artifacts.
- Weak package-signing verification, broken repository metadata checks.
- Boot chain issues that allow a local attacker to bypass disk encryption or
  Secure Boot.

## What does NOT qualify

- Bugs that require prior root access to exploit.
- Bugs in upstream components already fixed upstream (report to upstream).
- Social-engineering or phishing scenarios.
- "The default wallpaper is ugly." Use a regular issue for that.

## Security architecture

The full security model is documented in [`docs/security.md`](docs/security.md).
Highlights:

- **Unprivileged daily-user accounts.** No desktop component runs as root by
  default. Privileged operations go through **polkit** with narrowly scoped
  policies.
- **PackageKit, not raw pacman, for graphical package management.** The
  Software Center cannot execute arbitrary privileged commands.
- **Signed repositories.** Orion repository metadata is signed; `pacman`
  enforces signature verification. The signing key is **not** stored in this
  repository.
- **No secrets in source.** CI uses repository-scoped secrets; signing keys
  live in a secure host, not in git.
- **No network services enabled by default.** `sshd` is **off** unless the
  user explicitly enables it during installation.
- **Optional disk encryption** at install time (LUKS). The installer offers but
  does not force encryption.
- **Secure Boot** is documented; pre-signed bootloader binaries are a future
  release-engineering goal, not a current default.

## Hardening checklist (per release)

Before any release artifact is published, the release engineer verifies:

- [ ] No private keys, tokens, or passwords are present in the ISO or git
  history (`scripts/security-scan.sh` must pass).
- [ ] `pacman-key` initialization runs at first boot and verifies the Orion
  signing key against a published fingerprint.
- [ ] No unprivileged network listeners exist by default
  (`ss -tlnp` should be empty or limited to local sockets).
- [ ] polkit policies in `distro/defaults/polkit/` are reviewed.
- [ ] `mkinitcpio.conf` does **not** load unnecessary modules.
- [ ] Default user is in the `wheel` group with `sudo` requiring a password.
- [ ] The kernel command line does **not** contain `module.sig_unenforce`.
- [ ] No AUR helper is preinstalled.
- [ ] The ISO's `archlinux-keyring` and `orion-keyring` are current at build
  time.
