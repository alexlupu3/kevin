#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

bash "${SCRIPT_DIR}/00-kevin-birth.sh"
bash "${SCRIPT_DIR}/10-install-server-check.sh"
bash "${SCRIPT_DIR}/15-install-help.sh"
bash "${SCRIPT_DIR}/20-install-server-update.sh"
bash "${SCRIPT_DIR}/30-install-project-create.sh"
bash "${SCRIPT_DIR}/32-install-project-list.sh"
bash "${SCRIPT_DIR}/34-install-project-deploy.sh"
bash "${SCRIPT_DIR}/35-install-project-disable.sh"
bash "${SCRIPT_DIR}/36-install-project-enable.sh"
bash "${SCRIPT_DIR}/37-install-project-delete.sh"
bash "${SCRIPT_DIR}/38-install-project-setup.sh"
bash "${SCRIPT_DIR}/40-install-server-vuln-scan.sh"
bash "${SCRIPT_DIR}/90-install-sudoers.sh"

cat <<'EOF'
Bootstrap complete.

Suggested verification:
  id kevin
  sudo -l -U kevin
  sudo kevin help
  sudo kevin server-check
  sudo kevin server-update
  sudo kevin server-vuln-scan
  sudo kevin project-create testapp
  sudo kevin project-deploy testapp
  sudo kevin project-setup testapp
  sudo kevin project-list
  sudo kevin project-disable testapp
  sudo kevin project-enable testapp
  sudo kevin project-delete testapp --force
EOF
