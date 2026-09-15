# Mystic Light on MSI MAG B850 Tomahawk Max WiFi

This repository documents a tested OpenRGB setup for the Mystic Light
controller on the MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62 v2.0). It also
provides reproducible build and diagnostic scripts and pins related projects
as Git submodules.

> [!CAUTION]
> RGB controller firmware can be damaged by unsupported low-level writes.
> Use the current upstream OpenRGB implementation. Do not enable untested
> Mystic Light support or send experimental SMBus, I2C, or raw HID commands.

## Verified status

| Item | Result |
| --- | --- |
| USB device ID | `0DB0:0076` |
| OpenRGB protocol | MSI `761-byte` motherboard controller |
| Upstream support | Available on OpenRGB `master` |
| Verified zones | `JAF`, `JARGB 1`, `JARGB 2`, `JARGB 3` |
| Game-aware lighting | CS2 and Factorio profiles verified |
| Hardware Sync plugin | Builds successfully; runtime loading is blocked by a Qt metadata mismatch |

Device paths such as `/dev/hidrawN` are intentionally not treated as stable.
OpenRGB discovers the controller by its USB vendor and product IDs. Unique
hardware identifiers and unredacted diagnostic logs must not be committed.

## Repository layout

| Path | Purpose |
| --- | --- |
| `openrgb/` | Pinned upstream OpenRGB source |
| `hardware-sync-plugin/` | Pinned upstream Hardware Sync plugin source |
| `game-lighting/` | Standalone game-aware lighting service |
| `scripts/` | Local build and redacted diagnostic helpers |
| `systemd/` | Example user service for the single OpenRGB startup owner |
| `docs/` | Investigation notes and acceptance criteria |

## Getting started

Clone the repository and initialize the submodules:

```bash
git clone --recurse-submodules https://github.com/droltr/MysticLight.git
cd MysticLight
```

For an existing clone:

```bash
git submodule update --init --recursive
```

The build scripts expect a Fedora Toolbox container named `fedora-build`
with the OpenRGB build dependencies installed.

```bash
./scripts/build-openrgb.sh
./scripts/build-hardware-sync-plugin.sh
```

Build outputs are written below the relevant submodule's `build/` directory
and are excluded from version control.

## Safe diagnostics

Build OpenRGB first, then run:

```bash
./scripts/diagnose-msi.sh
```

The diagnostic helper uses an isolated temporary configuration directory,
disables SDK autoconnection, and redacts serial-number fields from its output.
Review the complete output for hostnames, usernames, paths, network addresses,
and other identifiers before attaching it to a public issue.

Detection still performs the upstream MSI HID handshake. It does not perform
arbitrary SMBus or I2C writes.

## Testing

The game-aware lighting service has unit tests for configuration loading,
temperature-to-color conversion, and focused-game matching. The OpenRGB SDK
client is mocked, so tests do not write to hardware.

```bash
python3 -m unittest discover -s game-lighting/tests -v
```

Shell helpers can be syntax-checked with:

```bash
bash -n scripts/*.sh
```

## Login startup

OpenRGB must have exactly one login-time owner. This project uses
`openrgb-server.service`; OpenRGB's own desktop autostart must be disabled.
The service starts the verified build as both the GUI and SDK server, then
uses `wmctrl` to minimize the OpenRGB window after it is created. One process
therefore provides the tray interface and the SDK endpoint on
`127.0.0.1:6742`. The explicit minimize step is used because this Qt/KDE setup
exits cleanly when OpenRGB is launched directly with `--startminimized`.

Audit the current session without changing it:

```bash
./scripts/audit-openrgb-startup.sh
```

Install the example service only after the launcher and binary described above
exist. The service also requires `wmctrl` on the host:

```bash
install -Dm644 systemd/openrgb-server.service \
  ~/.config/systemd/user/openrgb-server.service
~/.local/bin/openrgb --autostart-disable
systemctl --user daemon-reload
systemctl --user disable openrgb-server.service
systemctl --user enable --now openrgb-server.service
```

Also turn off **Start at Login** in OpenRGB settings. This prevents OpenRGB
from recreating its desktop autostart entry on a later GUI start. Do not run a
headless OpenRGB service and a second GUI instance against the same devices.

## Game-aware lighting

[`game-lighting`](https://github.com/droltr/game-lighting) runs as an OpenRGB
SDK client. Motherboard and RAM lighting follow CPU temperature. Keyboard and
mouse lighting can switch to per-game profiles when KDE's
[FocusNotifier](https://github.com/c-massie/FocusNotifier) reports a matching
focused window.

The service is maintained as a separate MIT-licensed project and included
here as a pinned submodule. Its configuration and deployment instructions are
in [game-lighting/README.md](game-lighting/README.md).

## CoolerControl and Zalman LCD ownership

CoolerControl owns fan/pump PWM and RPM control. The CoolerDash plugin and its
external LCD writer own the Zalman cooler display and its telemetry rendering.
OpenRGB owns only RGB LEDs, while `game-lighting` owns temperature-to-RGB and
context profiles. These components must not write each other's interfaces.

On the reference machine the expected service chain is:

```text
coolercontrold.service → cc-plugin-coolerdash.service → Zalman LCD writer
openrgb-server.service → game-lighting.service → RGB devices
```

The LCD integration is an external dependency and must be documented with its
installation source and rollback procedure; secrets, tokens, serials, and raw
host-specific identifiers must never be committed.

## Known limitation

The Hardware Sync plugin currently fails OpenRGB's runtime compatibility
check because its Qt plugin metadata reports `5.15.0`, despite both binaries
linking against the same Qt runtime. The plugin should remain disabled until
the root cause is understood and a tested fix is reviewed.

## Development workflow

The default branch records reviewed, working states. All changes should start
on a short-lived topic branch and reach `main` through a pull request with
passing checks. Hardware experiments must include a rollback plan and should
begin as draft pull requests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branch, issue, and review
process. Report vulnerabilities privately as described in
[SECURITY.md](SECURITY.md).

## Ordered implementation roadmap

- [x] Single minimized OpenRGB startup owner.
- [x] SDK recovery, Direct temperature mode, and desktop/game profiles.
- [x] Smooth blue → yellow → orange → red CPU temperature mapping.
- [x] Unified startup health check and udev ownership audit.
- [ ] Validate required device inventory and modes in the health check.
- [ ] Add resource safeguards: deduplicated writes, bounded rates, and systemd limits.
- [ ] Complete reboot and suspend/resume end-to-end validation.
- [ ] Investigate this machine's GPU LED exposure through OpenRGB.
- [ ] Integrate GPU LED conditionally after reversible live validation.

Each unchecked item is developed on a topic branch and merged only through a
passing pull request. GPU work remains last and is never a required device.

OpenRGB contributions belong in a topic branch on an appropriate OpenRGB fork
and should follow that project's upstream contribution process. This
repository does not modify the pinned upstream submodule directly.

## License

Original scripts and documentation in this repository are available under the
[MIT License](LICENSE). The `openrgb/` and `hardware-sync-plugin/` submodules
remain under their upstream GPL-2.0 licenses. `game-lighting/` is a separate
MIT-licensed project.
