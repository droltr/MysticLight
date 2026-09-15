#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root; no changes were made." >&2
  exit 2
fi
local_rule=/etc/udev/rules.d/60-openrgb.rules
package_rule=/usr/lib/udev/rules.d/60-openrgb.rules
backup=/var/lib/mysticlight/backup/60-openrgb.rules.before-package-owner
[[ -f "$local_rule" ]] || { echo "local rule already absent"; exit 0; }
[[ -f "$package_rule" ]] || { echo "package rule missing; refusing cleanup" >&2; exit 1; }
install -D -m 0644 "$local_rule" "$backup"
mv "$local_rule" "${local_rule}.disabled-by-mysticlight"
udevadm control --reload-rules
udevadm trigger --subsystem-match=hidraw
echo "disabled local duplicate; backup=$backup"
