# Kevin Repo Instructions

This repository manages a restricted VPS operations agent called Kevin.

## Core Rules

- Never grant unrestricted sudo to `kevin`.
- Never edit `/etc/sudoers.d/kevin` in ad hoc places. Deploy it only through `bootstrap/90-install-sudoers.sh`.
- Runtime tools live in `/opt/kevin/bin`. Source files live in this repository.
- Keep runtime scripts independent from the git checkout path unless the installer explicitly copies required assets into `/opt/kevin`.
- Prefer idempotent shell code and safe reruns.
- Use Bash for scripts with `#!/usr/bin/env bash` and `set -euo pipefail`.

## Infrastructure Conventions

- Domain base is `alexlupu.dev`.
- New projects use `<project>.alexlupu.dev`.
- Project web roots use `/var/www/<project>/public`.
- Project staging roots use `/opt/kevin/staging/<project>`.
- Project ownership in v1 is `www-data:www-data`.
- PHP-FPM socket is `/run/php/php8.3-fpm.sock`.
- Wildcard certificate paths are:
  - `/etc/letsencrypt/live/alexlupu.dev/fullchain.pem`
  - `/etc/letsencrypt/live/alexlupu.dev/privkey.pem`
- Kevin runtime logs live under `/var/log/kevin`.

## Safety Rules

- Validate every Nginx change with `nginx -t` before reload.
- Validate every SSH daemon config change with `sshd -t` before reload.
- Do not add destructive project deletion tooling in v1.
- Do not add raw root shells or arbitrary command runners for Kevin.
- Ask for explicit approval before adding tools that reboot the server, delete data, rotate keys, or change firewall defaults.

## Deployment Rules

- Installed tools under `/opt/kevin/bin` must be owned by `root:root` and mode `0755`.
- Installed templates under `/opt/kevin/templates` must be owned by `root:root`.
- `/etc/sudoers.d/kevin` must be mode `0440` and pass `visudo -c`.
- `00-kevin-birth.sh` creates the account and directories only. It must not install tools or sudoers.
- Deployments must flow from `/opt/kevin/staging/<project>/` to `/var/www/<project>/public/` via `project-deploy`.
- Direct `rsync` into `/var/www/<project>/public` is not supported.

## v1 Scope

Allowed tools:

- `server-check`
- `server-update`
- `project-create`
- `project-deploy`
- `project-setup`
- `project-disable`
- `project-enable`
- `project-delete`
- `server-vuln-scan`

Not in scope for v1:

- Telegram or chat controllers
- DNS automation
- Database provisioning
- MCP or Codex SDK runtime integration
