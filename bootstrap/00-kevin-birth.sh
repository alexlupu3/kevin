#!/usr/bin/env bash
set -euo pipefail

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Run this script as root: sudo bash bootstrap/00-kevin-birth.sh" >&2
        exit 1
    fi
}

should_install_cli() {
    case "${KEVIN_INSTALL_CLI:-n}" in
        y|Y)
            return 0
            ;;
        n|N|"")
            return 1
            ;;
        *)
            echo "KEVIN_INSTALL_CLI must be 'y' or 'n'." >&2
            exit 1
            ;;
    esac
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

install_cli_wrapper() {
    install -d -o root -g root -m 755 /usr/local/bin

    cat >/usr/local/bin/kevin <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: kevin <command> [other-options]

Allowed commands:
  server-check
  server-update
  project-create
  project-disable
  project-enable
  project-delete
  server-vuln-scan
USAGE
}

require_command() {
    if [[ $# -eq 0 ]]; then
        usage >&2
        exit 1
    fi
}

command_path() {
    case "$1" in
        server-check|server-update|project-create|project-disable|project-enable|project-delete|server-vuln-scan)
            printf '/opt/kevin/bin/%s\n' "$1"
            ;;
        help|-h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown Kevin command: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
}

main() {
    require_command "$@"

    local subcommand="$1"
    shift

    local target
    target="$(command_path "${subcommand}")"

    if [[ ! -x "${target}" ]]; then
        echo "Kevin runtime tool not installed: ${target}" >&2
        exit 1
    fi

    if [[ "${EUID}" -eq 0 ]]; then
        exec "${target}" "$@"
    fi

    if [[ "${USER:-}" == "kevin" ]]; then
        exec sudo "${target}" "$@"
    fi

    exec sudo -u kevin sudo "${target}" "$@"
}

main "$@"
EOF

    chown root:root /usr/local/bin/kevin
    chmod 0755 /usr/local/bin/kevin
    echo "Installed Kevin CLI wrapper at /usr/local/bin/kevin."
}

main() {
    require_root
    KEY_CONTENT=""
    read_pubkey
    create_user
    setup_ssh
    create_runtime_dirs

    if should_install_cli; then
        install_cli_wrapper
        CLI_STATUS="enabled (/usr/local/bin/kevin)"
    else
        CLI_STATUS="disabled (set KEVIN_INSTALL_CLI=y to install /usr/local/bin/kevin)"
    fi

    cat <<EOF
Kevin birth complete.
- user: kevin
- shell: /bin/bash
- password: locked
- runtime bin: /opt/kevin/bin
- runtime templates: /opt/kevin/templates
- logs: /var/log/kevin
- cli wrapper: ${CLI_STATUS}
EOF
}

main "$@"
