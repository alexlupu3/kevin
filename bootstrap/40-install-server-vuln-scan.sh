#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

if ! command -v lynis >/dev/null 2>&1; then
    echo "Installing lynis..."
    apt-get update
    apt-get install -y lynis
fi

install -d -o root -g root -m 755 /opt/kevin/bin
install -d -o root -g root -m 750 /var/log/kevin
install -o root -g root -m 755 "${REPO_ROOT}/tools/server-vuln-scan" /opt/kevin/bin/server-vuln-scan

echo "Installed /opt/kevin/bin/server-vuln-scan"
echo "Test with: sudo /opt/kevin/bin/server-vuln-scan"
