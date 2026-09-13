#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${project_dir}/openrgb/build/openrgb"
config_dir="/tmp/openrgb-msi-diagnostic"

if [[ ! -x "${binary}" ]]; then
    echo "Built OpenRGB not found; run scripts/build-openrgb.sh first." >&2
    exit 1
fi

toolbox run -c fedora-build mkdir -p "${config_dir}"
toolbox run -c fedora-build "${binary}" \
    --config "${config_dir}" \
    --noautoconnect \
    --list-detailed \
    --very-verbose \
    --print-source
