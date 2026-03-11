#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

install -d -o root -g root -m 755 /opt/kevin/bin
install -o root -g root -m 755 "${REPO_ROOT}/tools/project-delete" /opt/kevin/bin/project-delete

echo "Installed /opt/kevin/bin/project-delete"
echo "Test with: sudo /opt/kevin/bin/project-delete testapp --force"
