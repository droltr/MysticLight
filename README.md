# OpenRGB for MSI MAG B850 Tomahawk Max WiFi

This workspace is set up to build and verify current OpenRGB against the
Mystic Light controller on the MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62 v2.0)
motherboard.

## Result

- Motherboard: `MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62)`
- Mystic Light USB device: `0DB0:0076`
- HID path: `/dev/hidraw12` (the number can change across reboots; OpenRGB
  scans for the device by USB Vendor/Product ID `0DB0:0076`, so a renumbered
  node is not a problem — see the [udev rule](#permanent-install-host-system))
- Protocol: OpenRGB `761-byte` MSI motherboard controller
- Support: present in OpenRGB upstream `master`
- Verified zones: `JAF`, `JARGB 1`, `JARGB 2`, `JARGB 3`

The source is kept under `openrgb/` as an upstream Git repository. OpenRGB
sends commands directly to the hardware, so connections and the selected
device must be verified before any color-writing tests.

## Build

Inside the existing `fedora-build` Toolbox container:

```bash
./scripts/build-openrgb.sh
```

Resulting binary: `openrgb/build/openrgb`

## Safe diagnostics

```bash
./scripts/diagnose-msi.sh
```

The command uses `--noautoconnect` to avoid connecting to a running local
OpenRGB server, and writes a detailed device list using a separate temporary
config directory. Device detection performs the upstream MSI HID handshake;
it does not perform any arbitrary SMBus/I2C writes.

## Testing

`game-lighting/` has a unit test suite covering the temperature-to-color
curve, config loading, and game-focus matching logic (the SDK client is
mocked, so no OpenRGB server or hardware is required):

```bash
python3 -m unittest discover -s game-lighting/tests -v
```

## Git workflow

OpenRGB contributions must be sent from a topic branch on our own GitLab
fork; upstream `master` must never be modified directly, and updates should
be rebased rather than merged. Since base support for this board is already
merged upstream, there is currently no new source patch to send. If a
functional LED-writing issue is observed, any change should stay scoped to
the MSI 761-byte controller, with hardware logs and test results attached to
a draft merge request.

See [docs/implementation-plan.md](docs/implementation-plan.md) for detailed
findings and next steps.

## Hardware Sync plugin (builds, runtime still blocked)

`hardware-sync-plugin/` holds OpenRGB's official
[Hardware Sync Plugin](https://gitlab.com/OpenRGBDevelopers/OpenRGBHardwareSyncPlugin.git)
source as a submodule pinned to the `release_1.0` tag (`d999417`) — a plugin
that reflects hardware sensors (CPU temperature, RAM usage, fan speed) onto
RGB zones. Its own `.gitmodules` carries OpenRGB as a nested submodule; after
cloning:

```bash
git submodule update --init --recursive
```

Build:

```bash
./scripts/build-hardware-sync-plugin.sh
```

Resulting file: `hardware-sync-plugin/build/libOpenRGBHardwareSyncPlugin.so`
(the install step copies this into `~/.config/OpenRGB/plugins/`).

**Known issue:** even though it's built in the same `fedora-build` Toolbox as
`openrgb/` against the same Qt (`5.15.18-1.fc42`), OpenRGB rejects the plugin
at runtime with `"uses incompatible Qt library. (5.15.0)"`. Both binaries
link against the identical `libQt5Core.so.5` (verified on both host and
Toolbox, no `LD_LIBRARY_PATH` pollution) — so it is not a real Qt version
difference, but an unresolved mismatch tied to the version stamp Qt embeds in
plugin metadata. The plugin is therefore **currently disabled** (see the
permanent-install section below); the OpenRGB SDK server runs fine without
it. Finding and fixing the root cause is left for a future session.

## Permanent install (host system)

Because the project directory lives on an external drive
(`/run/media/system/4TB_-Data`, not listed in `/etc/fstab`), the running
install **copies the compiled binaries into `$HOME`** and runs from there —
it keeps working even if the project drive isn't mounted:

| Component | Permanent location |
| --- | --- |
| OpenRGB binary | `~/.local/lib/openrgb/openrgb` |
| Host-side launcher | `~/.local/bin/openrgb` (wraps the Toolbox: `toolbox run -c fedora-build ...`) |
| Hardware Sync plugin | `~/.config/OpenRGB/plugins/OpenRGBHardwareSyncPlugin.so` (currently disabled, see above) |
| Autostart | a single systemd `--user` service: `openrgb-server.service` |
| udev rule | `/etc/udev/rules.d/60-openrgb.rules` (requires sudo to install, see below) |

The host is an immutable distro (Bazzite/Kinoite, rpm-ostree), so build and
runtime dependencies (`mbedtls`, `libgtop2`, etc.) are kept in the
`fedora-build` Toolbox container instead of being layered onto the host;
`~/.local/bin/openrgb` wraps this transparently.

**Conflicts resolved:**
- OpenRGB used to start from two paths at once: `openrgb-server.service`
  (AppImage-based, headless) **and** `~/.config/autostart/OpenRGB.desktop`
  (GUI, at login) — both tried to access the same USB/HID device and the
  same SDK port (`6742`), and one of them crashed (core dump). The autostart
  entry was renamed to `OpenRGB.desktop.disabled-by-migration` and disabled;
  `openrgb-server.service` is now the single source.
- The old CPU-temperature-to-RGB solution
  (`~/.local/bin/openrgb-thermal-sync.py` + `openrgb-thermal-sync.service`)
  did the same job as the hardware-sync-plugin; it was stopped, disabled, and
  then removed entirely once superseded by [`game-lighting/`](game-lighting/)
  (see below), which covers the same temperature behavior plus per-game
  keyboard/mouse layouts.
- A stray `libgtop-2.0.so.11` file that had been left in
  `~/.config/OpenRGB/plugins/` (not a real plugin) was removed — OpenRGB
  scans the plugin directory and tries to load every file in it, so this was
  producing a pointless error on every start.

**udev rule (requires sudo):** grants access by device identity
(`0DB0:0076`); it makes OpenRGB's non-root access to the device permanent
even if the `/dev/hidrawN` number changes on every boot. The generated rule
file is staged at `~/.local/share/openrgb/60-openrgb.rules`; to install it:

```bash
sudo install -Dm644 ~/.local/share/openrgb/60-openrgb.rules /etc/udev/rules.d/60-openrgb.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

This has already been installed and verified on this machine (device nodes
under `/dev/hidraw*` now carry the ACL granted by the rule).

## Game-aware lighting

`game-lighting/` is a small Python service that connects to
`openrgb-server.service` as an SDK client: motherboard and RAM always follow
CPU temperature, and the keyboard/mouse do too — except while a mapped game
is the focused window (tracked via the KDE KWin
[FocusNotifier](https://github.com/c-massie/FocusNotifier) script), when the
keyboard switches to a per-key layout for that game. See
[game-lighting/README.md](game-lighting/README.md) for what was evaluated,
what's verified, and the full design.

Installed permanently on this machine as `~/.config/systemd/user/game-lighting.service`
(enabled, running, connects and correctly enumerates all four device types).
No games are mapped in `~/.config/game-lighting/config.yaml` yet — that's
the next step, pending real game names/colors from the user.

## License

The original content of this repository (scripts, docs, and the
game-lighting service) is available under the [MIT License](LICENSE).
`openrgb/` and `hardware-sync-plugin/` are upstream projects included as Git
submodules and remain under their own GPL-2.0 licenses.
