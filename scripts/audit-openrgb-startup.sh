#!/usr/bin/env bash

set -euo pipefail

found=0

report_file() {
    local label="$1"
    local path="$2"

    if [[ -e "${path}" || -L "${path}" ]]; then
        if grep -Eiq '^Hidden=true[[:space:]]*$' "${path}"; then
            printf '%s-disabled\t%s\n' "${label}" "${path}"
        else
            printf '%s\t%s\n' "${label}" "${path}"
            found=$((found + 1))
        fi
    fi
}

printf 'OpenRGB startup owners:\n'

if systemctl --user is-enabled openrgb-server.service >/dev/null 2>&1; then
    printf 'systemd-enabled\topenrgb-server.service\n'
    found=$((found + 1))
fi

report_file "desktop-entry" "${HOME}/.config/autostart/OpenRGB.desktop"
report_file "desktop-entry" "${HOME}/.config/autostart/openrgb.desktop"

printf '\nRunning OpenRGB processes:\n'
pgrep -a -x openrgb || true

printf '\nSDK listeners:\n'
ss -ltnp 2>/dev/null | awk '$4 ~ /127\.0\.0\.1:6742$/ {print}' || true

if (( found > 1 )); then
    printf '\nConflict: %d startup owners are enabled. Keep exactly one.\n' "${found}" >&2
    exit 1
fi

printf '\nStartup owner count: %d\n' "${found}"
