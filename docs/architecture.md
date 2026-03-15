# Architecture

Kevin uses a split design:

- This repository is the editable source of truth.
- Runtime tools are deployed into `/opt/kevin/bin`.
- Runtime templates are deployed into `/opt/kevin/templates`.
- Staging content is prepared under `/opt/kevin/staging/<project>`.
- Runtime logs are written into `/var/log/kevin`.

This separation keeps production execution stable even if the git checkout moves or is temporarily absent. It also makes updates explicit: edit source here, then rerun the relevant installer.

Sudoers is centralized through one source file and one installer. That avoids permission drift and keeps Kevin's approved root actions auditable.

Project creation uses a template so every site starts from the same Nginx conventions. This reduces one-off config edits and makes future hardening easier to apply consistently.

Deployments are intentionally narrowed to one approved path: staged content under `/opt/kevin/staging/<project>` is promoted into `/var/www/<project>/public` by `project-deploy`. This keeps Kevin away from arbitrary source and destination inputs and makes live content changes auditable through one tool and one log.

For Laravel apps, `project-setup` is a distinct post-deploy step that runs in the already-approved live web root as `www-data`. Keeping that bootstrap separate from `project-deploy` preserves a narrow deployment primitive while still allowing framework-specific setup to be rerun and audited through its own log.

For non-PHP services that still need bounded root setup, `project-setup` can expose explicit profiles backed by root-owned templates and parameter validation. That keeps Kevin on audited rails for actions like database provisioning, Nginx updates, and systemd unit installation without allowing arbitrary staged scripts to execute as root.

The layout also leaves room for future Codex or controller-driven automation because the operational surface is already narrow, documented, and script-based.
