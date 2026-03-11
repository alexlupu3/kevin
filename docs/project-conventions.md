# Project Conventions

Kevin assumes these conventions:

- Domain format: `<project>.alexlupu.dev`
- Web root: `/var/www/<project>/public`
- Staging root: `/opt/kevin/staging/<project>`
- Project ownership: `www-data:www-data`
- PHP socket: `/run/php/php8.3-fpm.sock`
- TLS certificate:
  - `/etc/letsencrypt/live/alexlupu.dev/fullchain.pem`
  - `/etc/letsencrypt/live/alexlupu.dev/privkey.pem`

Nginx sites are rendered from the provided template into `/etc/nginx/sites-available/<domain>` and then symlinked into `/etc/nginx/sites-enabled/<domain>`.

Application content is staged in `/opt/kevin/staging/<project>` and then deployed into `/var/www/<project>/public` only through `project-deploy`. Direct `rsync` into `/var/www/<project>/public` is not supported.

`project-deploy` treats the staging directory as the source of truth for the live web root. After sync, Kevin reapplies `www-data:www-data`, `755` on directories, and `644` on files so reruns converge cleanly.

Disabling a project removes only the `sites-enabled` symlink. The rendered config in `sites-available` and the project files under `/var/www/<project>` remain in place for manual review or future re-enablement.

Re-enabling a project restores the `sites-enabled` symlink to the existing config in `sites-available`.

Deleting a project removes both Nginx config paths and the full project directory under `/var/www/<project>`. Kevin requires an explicit force flag for that operation.

The first version does not overwrite existing sites. If a project directory, site config, or enabled symlink already exists, provisioning stops and asks for operator review.
