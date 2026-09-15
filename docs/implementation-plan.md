# Investigation and implementation plan

## Findings

The system's DMI string matches exactly what OpenRGB expects:
`MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62)`. The USB HID controller reports
the `0DB0:0076` identifier and the product name `MYSTIC LIGHT`.

Current OpenRGB `master` uses the common `0DB0:0076` detector. If the first
feature-report attempt doesn't match one of the older 112/162/185-byte
families, it sends a read-enable request and falls back to the 761-byte
controller. The board's DMI name is registered in the 761-byte board
configuration table with zone-based direct mode.

Board support was added by upstream commit
`93830c12eee0e678ebf449b9e4ae80b379db0646`. A locally built OpenRGB 1.0
successfully registered the board and reported four zones. Adding a new PID
to an older release, or enabling `ENABLE_UNTESTED_MYSTIC_LIGHT`, is therefore
neither necessary nor correct.

## Implementation stages

1. Use current upstream `master` and record the pinned commit in test notes.
2. Repeat the isolated Toolbox build with official Fedora dependencies.
3. Verify direct detection with `--noautoconnect --list-detailed
   --very-verbose`; do not accept test results from a build that connects to
   the local SDK server.
4. Before touching the UI, try a single static low-brightness color on one
   JARGB zone; verify the physical result by user observation.
5. If color writing doesn't work, don't duplicate the existing detection
   support. Capture MSI Center or SignalRGB USB traffic, compare the
   761-byte packets, and apply only the proven board-specific zone/packet
   difference.
6. If a change is needed, open a topic branch such as
   `fix/msi-7e62-761-output`, keep the upstream style, make a single-purpose
   commit, and send a draft GitLab MR first.

## Acceptance criteria

- The board registers as an MSI 761-byte controller on every clean start.
- JAF and all three JARGB zones are listed.
- Static red, green, and blue are physically verified on the selected zone.
- The controller is redetected after OpenRGB is closed and reopened.
- Detection and color writing work again after suspend/resume.
- Firmware version and a redacted verbose log are attached to the MR record
  during testing. Unique hardware identifiers, usernames, hostnames, local
  paths, and network addresses are removed before publication.

## Risks

OpenRGB's MSI driver has previously carried a risk of corrupting firmware.
For this reason, only the current upstream flow should be used; experimental
writes via I2C Tools, `ENABLE_UNTESTED_MYSTIC_LIGHT`, or unverified raw HID
packets must not be attempted.
