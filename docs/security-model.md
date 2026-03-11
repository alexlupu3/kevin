# Security Model

Kevin is a restricted operator account. It is not a human admin account and not a root replacement.

Key decisions:

- `kevin` uses SSH keys only.
- Kevin's password is locked.
- Kevin receives `NOPASSWD` sudo only for approved runtime tools in `/opt/kevin/bin`.
- Runtime tools are owned by `root:root` so Kevin cannot tamper with them.
- Sudoers is generated from a single source-of-truth file.

This model is intentionally narrower than giving Kevin a shell with broad root powers. Audited scripts are easier to review, safer to rerun, and less likely to create accidental damage.

Kevin's approved root actions stay narrow and script-bound. Even destructive operations should require explicit confirmation, validate surrounding config before reload, and target only project-specific paths rather than broad system state.
