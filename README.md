# Kevin

Kevin is a restricted VPS operations agent for an Ubuntu 24.04 server. This repository is the source of truth for Kevin's scripts, templates, docs, and sudo policy. The deployed runtime tools live under `/opt/kevin`, while this checkout stays editable and version-controlled.

## What Kevin can do in v1

- Create and maintain the `kevin` operator account
- Install root-owned runtime tools into `/opt/kevin/bin`
- Run a server health check
- Show the full Kevin command list
- Run safe package maintenance
- Provision a new PHP/Nginx project site
- Deploy staged project files from `/opt/kevin/staging/<project>/` into the live web root
- Run setup profiles for Laravel or staged Node API services
- List existing PHP/Nginx project sites and whether they are enabled
- Re-enable a previously disabled project site
- Disable an existing project site without deleting files
- Delete an existing project site, config, and files with explicit confirmation
- Run a practical vulnerability and hardening audit
- Install a tightly scoped sudoers policy for Kevin

Kevin is intentionally restricted. It does not get unrestricted sudo, raw root shell access, arbitrary project script execution as root, or DNS automation in v1.

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
sudo KEVIN_PUBKEY_FILE=/path/to/kevin.pub KEVIN_INSTALL_CLI=y bash bootstrap/99-bootstrap-all.sh
```

Or provide the public key directly:

```bash
sudo KEVIN_PUBKEY="ssh-ed25519 AAAA..." KEVIN_INSTALL_CLI=y bash bootstrap/99-bootstrap-all.sh
```

`KEVIN_INSTALL_CLI=y` is optional. When set, Kevin also installs a wrapper at `/usr/local/bin/kevin` so you can run:

```bash
kevin help
kevin server-check
sudo kevin server-check
sudo kevin project-create testapp
```

If you want to install pieces one at a time:

```bash
sudo KEVIN_INSTALL_CLI=y bash bootstrap/00-kevin-birth.sh
sudo bash bootstrap/10-install-server-check.sh
sudo bash bootstrap/15-install-help.sh
sudo bash bootstrap/20-install-server-update.sh
sudo bash bootstrap/30-install-project-create.sh
sudo bash bootstrap/32-install-project-list.sh
sudo bash bootstrap/34-install-project-deploy.sh
sudo bash bootstrap/35-install-project-disable.sh
sudo bash bootstrap/36-install-project-enable.sh
sudo bash bootstrap/37-install-project-delete.sh
sudo bash bootstrap/38-install-project-setup.sh
sudo bash bootstrap/40-install-server-vuln-scan.sh
sudo bash bootstrap/90-install-sudoers.sh
```

## Rerun Individual Installers

Each installer is designed to be safe to rerun. Reinstalling a tool simply recopies the source script into `/opt/kevin/bin` with the expected ownership and permissions.

Examples:

```bash
sudo bash bootstrap/15-install-help.sh
sudo bash bootstrap/10-install-server-check.sh
sudo bash bootstrap/30-install-project-create.sh
sudo bash bootstrap/32-install-project-list.sh
sudo bash bootstrap/34-install-project-deploy.sh
sudo bash bootstrap/35-install-project-disable.sh
sudo bash bootstrap/36-install-project-enable.sh
sudo bash bootstrap/37-install-project-delete.sh
sudo bash bootstrap/38-install-project-setup.sh
sudo bash bootstrap/90-install-sudoers.sh
```

## Verify Installation

Run these checks after bootstrap:

```bash
id kevin
sudo -l -U kevin
sudo -u kevin kevin help
sudo -u kevin kevin server-check
sudo kevin help
kevin project-list
sudo kevin server-check
sudo kevin server-update
sudo kevin server-vuln-scan
```

To test project provisioning:

```bash
sudo kevin project-create testapp
```

Then confirm:

```bash
ls -la /var/www/testapp/public
ls -la /opt/kevin/staging/testapp
sudo nginx -t
curl -I https://testapp.alexlupu.dev
```

Deployments must go through Kevin staging. Direct `rsync` into `/var/www/<project>/public` is not supported.

```bash
rsync -av ./build/ /opt/kevin/staging/testapp/
sudo kevin project-deploy testapp
```

Then confirm:

```bash
sudo tail -n 20 /var/log/kevin/project-deploy.log
find /var/www/testapp -maxdepth 2 -printf '%M %u:%g %p\n' | head
```

For a Laravel app, run the post-deploy setup after `project-deploy`:

```bash
sudo kevin project-setup testapp
```

Then confirm:

```bash
sudo tail -n 20 /var/log/kevin/project-setup.log
test -f /var/www/testapp/public/bootstrap/cache/config.php
test -L /var/www/testapp/public/public/storage
```

For a staged Node API, use the explicit `node-api` profile instead of trying to run a staged shell script as root:

```bash
sudo kevin project-setup testapp node-api
```

Or override the bounded parameters for a different layout:

```bash
sudo kevin project-setup testapp node-api \
  --app-subdir api \
  --service-name testapp-api \
  --api-user testapp-api \
  --db-name testapp \
  --db-user testapp_api \
  --port 3100 \
  --entrypoint dist/server.js \
  --api-location /api/ \
  --client-max-body-size 5M \
  --proxy-read-timeout 120s \
  --proxy-send-timeout 120s
```

If the API uses Node from an NVM install instead of a system-wide binary, pass the absolute `node` path and let `project-setup` restart the service:

```bash
sudo kevin project-setup info-bisericabetel node-api \
  --node-bin /home/kevin/.nvm/versions/node/v24.14.0/bin/node \
  --start-service
```

To list all configured projects and whether each site is enabled:

```bash
kevin project-list
```

To disable the site later while keeping its files and Nginx config in place:

```bash
sudo kevin project-disable testapp
```

To re-enable a previously disabled site:

```bash
sudo kevin project-enable testapp
```

To delete the site, config, and project files entirely:

```bash
sudo kevin project-delete testapp --force
```

## Notes

- Runtime tools are copied into `/opt/kevin/bin` and owned by `root:root`.
- The optional `kevin` CLI wrapper is installed at `/usr/local/bin/kevin` by `bootstrap/00-kevin-birth.sh` when `KEVIN_INSTALL_CLI=y`.
- `help` prints the current Kevin command list and is safe to run without root.
- Sudoers is managed only through `bootstrap/90-install-sudoers.sh`.
- The bootstrap can be rerun. It should converge to the same deployed state rather than drift.
- `project-enable` restores the `sites-enabled` symlink, then validates and reloads Nginx.
- `project-disable` removes only the `sites-enabled` symlink, then validates and reloads Nginx.
- `project-list` reads Kevin-managed Nginx site configs and reports `enabled` or `disabled`.
- `project-deploy` syncs only from `/opt/kevin/staging/<project>/` into `/var/www/<project>/public/`, then reapplies `www-data:www-data`, `755` directories, and `644` files.
- `project-delete` removes the site config and project files and requires `--force`.
- `project-setup` supports bounded setup profiles. The default `laravel` profile runs framework bootstrap tasks as `www-data` inside `/var/www/<project>/public`. The `node-api` profile provisions PostgreSQL, uploads storage, Nginx, a systemd unit, and a staged `.env` file using root-owned templates and validated arguments. It can also pin the service to a validated absolute Node binary path with `--node-bin`, restart the service with `--start-service`, and tune `client_max_body_size`, `proxy_read_timeout`, and `proxy_send_timeout` with bounded Nginx arguments.
