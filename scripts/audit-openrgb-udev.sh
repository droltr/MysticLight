#!/usr/bin/env bash
set -euo pipefail

system_rule=/usr/lib/udev/rules.d/60-openrgb.rules
local_rule=/etc/udev/rules.d/60-openrgb.rules

if [[ -f "$system_rule" && -f "$local_rule" ]]; then
  echo "duplicate OpenRGB rule owners detected: $system_rule and $local_rule"
  echo "package rule: $system_rule"
  echo "local rule:   $local_rule"
  exit 1
fi

if [[ -f "$system_rule" ]]; then
  echo "OpenRGB udev owner: $system_rule"
elif [[ -f "$local_rule" ]]; then
  echo "OpenRGB udev owner: $local_rule"
else
  echo "OpenRGB udev rule not found" >&2
  exit 1
fi
