#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

install -d -o root -g root -m 755 /opt/kevin/bin
install -d -o root -g root -m 750 /var/log/kevin
install -o root -g root -m 755 "${REPO_ROOT}/tools/server-update" /opt/kevin/bin/server-update

echo "Installed /opt/kevin/bin/server-update"
echo "Test with: sudo /opt/kevin/bin/server-update"
