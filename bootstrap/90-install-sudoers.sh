#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

visudo -cf "${REPO_ROOT}/sudoers/kevin"
install -o root -g root -m 440 "${REPO_ROOT}/sudoers/kevin" /etc/sudoers.d/kevin
visudo -c

echo "Installed /etc/sudoers.d/kevin"
