#!/usr/bin/env bash
set -euo pipefail

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Run this script as root: sudo bash bootstrap/00-kevin-birth.sh" >&2
        exit 1
    fi
}

read_pubkey() {
    if [[ -n "${KEVIN_PUBKEY:-}" && -n "${KEVIN_PUBKEY_FILE:-}" ]]; then
        echo "Provide only one of KEVIN_PUBKEY or KEVIN_PUBKEY_FILE." >&2
        exit 1
    fi

    if [[ -n "${KEVIN_PUBKEY_FILE:-}" ]]; then
        if [[ ! -f "${KEVIN_PUBKEY_FILE}" ]]; then
            echo "Public key file not found: ${KEVIN_PUBKEY_FILE}" >&2
            exit 1
        fi
        KEY_CONTENT="$(<"${KEVIN_PUBKEY_FILE}")"
    else
        KEY_CONTENT="${KEVIN_PUBKEY:-}"
    fi

    if [[ -n "${KEY_CONTENT}" && "${KEY_CONTENT}" != ssh-* ]]; then
        echo "KEVIN_PUBKEY does not look like a valid SSH public key." >&2
        exit 1
    fi
}

create_user() {
    if id -u kevin >/dev/null 2>&1; then
        echo "User kevin already exists."
    else
        useradd --create-home --home-dir /home/kevin --shell /bin/bash kevin
        echo "Created user kevin."
    fi

    usermod --shell /bin/bash kevin
    passwd -l kevin >/dev/null
}

setup_ssh() {
    install -d -o kevin -g kevin -m 700 /home/kevin/.ssh

    if [[ -n "${KEY_CONTENT}" ]]; then
        printf '%s\n' "${KEY_CONTENT}" > /home/kevin/.ssh/authorized_keys
        chown kevin:kevin /home/kevin/.ssh/authorized_keys
        chmod 600 /home/kevin/.ssh/authorized_keys
        echo "Installed Kevin SSH public key."
    else
        echo "No public key provided. authorized_keys unchanged."
    fi
}

create_runtime_dirs() {
    install -d -o root -g root -m 755 /opt/kevin/bin
    install -d -o root -g root -m 755 /opt/kevin/templates
    install -d -o root -g root -m 750 /var/log/kevin
}

main() {
    require_root
    KEY_CONTENT=""
    read_pubkey
    create_user
    setup_ssh
    create_runtime_dirs

    cat <<EOF
Kevin birth complete.
- user: kevin
- shell: /bin/bash
- password: locked
- runtime bin: /opt/kevin/bin
- runtime templates: /opt/kevin/templates
- logs: /var/log/kevin
EOF
}

main "$@"
