# Kevin

Kevin is a restricted VPS operations agent for an Ubuntu 24.04 server. This repository is the source of truth for Kevin's scripts, templates, docs, and sudo policy. The deployed runtime tools live under `/opt/kevin`, while this checkout stays editable and version-controlled.

## What Kevin can do in v1

- Create and maintain the `kevin` operator account
- Install root-owned runtime tools into `/opt/kevin/bin`
- Run a server health check
- Run safe package maintenance
- Provision a new PHP/Nginx project site
- Re-enable a previously disabled project site
- Disable an existing project site without deleting files
- Delete an existing project site, config, and files with explicit confirmation
- Run a practical vulnerability and hardening audit
- Install a tightly scoped sudoers policy for Kevin

Kevin is intentionally restricted. It does not get unrestricted sudo, raw root shell access, database provisioning, or DNS automation in v1.

## Repo Layout

```text
bootstrap/  Installer and bootstrap scripts
tools/      Source versions of Kevin runtime tools
sudoers/    Source-of-truth sudoers policy
templates/  Runtime templates copied into /opt/kevin/templates
docs/       Architecture, security, conventions, and operations notes
```

## Prerequisites

- Ubuntu 24.04
- A non-root user with `sudo`
- Nginx and PHP-FPM installed
- PHP-FPM socket at `/run/php/php8.3-fpm.sock`
- Wildcard certificate already present at:
  - `/etc/letsencrypt/live/alexlupu.dev/fullchain.pem`
  - `/etc/letsencrypt/live/alexlupu.dev/privkey.pem`
- Existing server convention of `/var/www/<project>/public`

## Fresh VPS Install

From inside this repository:

```bash
sudo KEVIN_PUBKEY_FILE=/path/to/kevin.pub bash bootstrap/99-bootstrap-all.sh
```

Or provide the public key directly:

```bash
sudo KEVIN_PUBKEY="ssh-ed25519 AAAA..." bash bootstrap/99-bootstrap-all.sh
```

If you want to install pieces one at a time:

```bash
sudo bash bootstrap/00-kevin-birth.sh
sudo bash bootstrap/10-install-server-check.sh
sudo bash bootstrap/20-install-server-update.sh
sudo bash bootstrap/30-install-project-create.sh
sudo bash bootstrap/35-install-project-disable.sh
sudo bash bootstrap/36-install-project-enable.sh
sudo bash bootstrap/37-install-project-delete.sh
sudo bash bootstrap/40-install-server-vuln-scan.sh
sudo bash bootstrap/90-install-sudoers.sh
```

## Rerun Individual Installers

Each installer is designed to be safe to rerun. Reinstalling a tool simply recopies the source script into `/opt/kevin/bin` with the expected ownership and permissions.

Examples:

```bash
sudo bash bootstrap/10-install-server-check.sh
sudo bash bootstrap/30-install-project-create.sh
sudo bash bootstrap/35-install-project-disable.sh
sudo bash bootstrap/36-install-project-enable.sh
sudo bash bootstrap/37-install-project-delete.sh
sudo bash bootstrap/90-install-sudoers.sh
```

## Verify Installation

Run these checks after bootstrap:

```bash
id kevin
sudo -l -U kevin
sudo -u kevin sudo /opt/kevin/bin/server-check
sudo -u kevin sudo /opt/kevin/bin/server-update
sudo -u kevin sudo /opt/kevin/bin/server-vuln-scan
```

To test project provisioning:

```bash
sudo -u kevin sudo /opt/kevin/bin/project-create testapp
```

Then confirm:

```bash
ls -la /var/www/testapp/public
sudo nginx -t
curl -I https://testapp.alexlupu.dev
```

To disable the site later while keeping its files and Nginx config in place:

```bash
sudo -u kevin sudo /opt/kevin/bin/project-disable testapp
```

To re-enable a previously disabled site:

```bash
sudo -u kevin sudo /opt/kevin/bin/project-enable testapp
```

To delete the site, config, and project files entirely:

```bash
sudo -u kevin sudo /opt/kevin/bin/project-delete testapp --force
```

## Notes

- Runtime tools are copied into `/opt/kevin/bin` and owned by `root:root`.
- Sudoers is managed only through `bootstrap/90-install-sudoers.sh`.
- The bootstrap can be rerun. It should converge to the same deployed state rather than drift.
- `project-enable` restores the `sites-enabled` symlink, then validates and reloads Nginx.
- `project-disable` removes only the `sites-enabled` symlink, then validates and reloads Nginx.
- `project-delete` removes the site config and project files and requires `--force`.
