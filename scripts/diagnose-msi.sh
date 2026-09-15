#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${project_dir}/openrgb/build/openrgb"
config_dir="$(mktemp -d -p /tmp openrgb-msi-diagnostic.XXXXXX)"

cleanup() {
    rm -rf -- "${config_dir}"
}
trap cleanup EXIT

if [[ ! -x "${binary}" ]]; then
    echo "Built OpenRGB not found; run scripts/build-openrgb.sh first." >&2
    exit 1
fi

toolbox run -c fedora-build "${binary}" \
    --config "${config_dir}" \
    --noautoconnect \
    --list-detailed \
    --very-verbose \
    --print-source 2>&1 \
    | sed -E 's/^([[:space:]]*Serial:[[:space:]]*).*/\1<redacted>/I'
