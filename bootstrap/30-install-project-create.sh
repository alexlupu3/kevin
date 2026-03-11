#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

install -d -o root -g root -m 755 /opt/kevin/bin
install -d -o root -g root -m 755 /opt/kevin/templates
install -o root -g root -m 755 "${REPO_ROOT}/tools/project-create" /opt/kevin/bin/project-create
install -o root -g root -m 644 "${REPO_ROOT}/templates/nginx-php-site.conf.tpl" /opt/kevin/templates/nginx-php-site.conf.tpl

echo "Installed /opt/kevin/bin/project-create"
echo "Installed /opt/kevin/templates/nginx-php-site.conf.tpl"
echo "Test with: sudo /opt/kevin/bin/project-create testapp"
