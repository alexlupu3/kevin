# Security Model

Kevin is a restricted operator account. It is not a human admin account and not a root replacement.

Key decisions:

- `kevin` uses SSH keys only.
- Kevin's password is locked.
- Kevin receives `NOPASSWD` sudo only for approved runtime tools in `/opt/kevin/bin`.
- Runtime tools are owned by `root:root` so Kevin cannot tamper with them.
- Sudoers is generated from a single source-of-truth file.

This model is intentionally narrower than giving Kevin a shell with broad root powers. Audited scripts are easier to review, safer to rerun, and less likely to create accidental damage.

Destructive tooling is excluded from v1. That includes project deletion, firewall resets, arbitrary service changes, and anything that would make rollback harder during early adoption.
