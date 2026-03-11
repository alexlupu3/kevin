#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

"${SCRIPT_DIR}/00-kevin-birth.sh"
"${SCRIPT_DIR}/10-install-server-check.sh"
"${SCRIPT_DIR}/20-install-server-update.sh"
"${SCRIPT_DIR}/30-install-project-create.sh"
"${SCRIPT_DIR}/35-install-project-disable.sh"
"${SCRIPT_DIR}/36-install-project-enable.sh"
"${SCRIPT_DIR}/37-install-project-delete.sh"
"${SCRIPT_DIR}/40-install-server-vuln-scan.sh"
"${SCRIPT_DIR}/90-install-sudoers.sh"

cat <<'EOF'
Bootstrap complete.

Suggested verification:
  id kevin
  sudo -l -U kevin
  sudo -u kevin sudo /opt/kevin/bin/server-check
  sudo -u kevin sudo /opt/kevin/bin/server-update
  sudo -u kevin sudo /opt/kevin/bin/server-vuln-scan
  sudo -u kevin sudo /opt/kevin/bin/project-create testapp
  sudo -u kevin sudo /opt/kevin/bin/project-disable testapp
  sudo -u kevin sudo /opt/kevin/bin/project-enable testapp
  sudo -u kevin sudo /opt/kevin/bin/project-delete testapp --force
EOF
