#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="${project_dir}/openrgb"

if [[ ! -f "${source_dir}/OpenRGB.pro" ]]; then
    echo "OpenRGB kaynağı bulunamadı: ${source_dir}" >&2
    exit 1
fi

toolbox run -c fedora-build bash -lc \
    "cd '${source_dir}' && mkdir -p build && cd build && qmake-qt5 ../OpenRGB.pro && make -j\"\$(nproc)\""
