# HARDWARE.md — Raspberry Pi 4B with dpos

This is the deliberate per-component picks for the Pi 4B, and why.

## Target hardware

- **Raspberry Pi 4 Model B, 8GB** — the 4GB will run this fine too, the
  2GB will be tight if you open Firefox.
- **64-bit Raspberry Pi OS Lite (Trixie)** — Debian 13, the current
  Pi OS as of late 2025. Kernel must be aarch64 to use the full 8GB.
  The preflight refuses to proceed on armv7l. Bookworm (Debian 12)
  also passes preflight; no other changes needed.
- **Storage:** USB-3 SATA SSD via the blue ports. Strongly recommended.
  SD cards work, but a desktop with random reads on an SD card is a
  punishment.
- **Cooling:** anything that keeps the SoC below 75 °C. The plain plastic
  case will throttle under sustained load. Heatsink + fan, or one of the
  metal cases, or the official active cooler.
- **PSU:** the official USB-C 3A. Underpower causes throttling that looks
  exactly like a kernel bug.

## What's already true on Trixie Lite (and we don't fight)

- `vc4-kms-v3d` is the default video driver (KMS, full DRM).
- `gpu_mem` is no longer fixed at 64 with KMS; memory is allocated
  dynamically. We still set `gpu_mem=128` to give the firmware-side
  pool room. Setting higher buys nothing for our workload.
- `cpufreq` is in `ondemand` mode by default. We leave it. `performance`
  is a small win for compile times and a much larger thermal cost.
- `dtoverlay=vc4-kms-v3d` and `max_framebuffers=2` are written into
  `/boot/firmware/config.txt` by us if they're not already there.
- Trixie (like Bookworm) uses `pipewire` + `pipewire-pulse` +
  `wireplumber` as the default audio stack. We install the pulseaudio
  client tools (`pactl`) — they speak to pipewire's pulse shim.

## What we explicitly tune

| What                              | Where                               | Why |
|-----------------------------------|-------------------------------------|-----|
| `gpu_mem=128`                     | `/boot/firmware/config.txt`         | Headroom for the KMS firmware pool. |
| `dtoverlay=vc4-kms-v3d`           | same                                | Default in Trixie/Bookworm, but pin it. |
| `max_framebuffers=2`              | same                                | Lets us drive two HDMIs without surprises. |
| `disable_splash=1`                | same                                | Firmware rainbow fights plymouth. |
| `quiet splash plymouth.ignore-serial-consoles` | `/boot/firmware/cmdline.txt` | Hands the boot screen to plymouth. |
| zram (50% RAM, zstd)              | `/etc/default/zramswap`             | Faster than disk swap, easier on the SSD. |
| `triggerhappy.service` disabled   | systemd                             | Console gpio button daemon — we don't use it. |
| `ModemManager.service` disabled   | systemd                             | No cellular modem here. |

## Picom on VideoCore VI — the picks

- **Backend:** `glx`. The KMS driver gives us real OpenGL. `xrender`
  would be a CPU regression for no gain.
- **Vsync:** `true`. The VC6 honors it.
- **`use-damage = true`** — only redraws damaged regions. Big win on a
  tiling layout where most of the screen is static.
- **Blur:** off. The VC6 will technically do blur, but it costs ~6× the
  GPU budget of a shadow. Not worth it for chrome you barely look at.
- **Shadows:** on, soft, ~8px radius. Cheap, and the design needs them.
- **Fade:** on, fast (50ms). Hides workspace-switch pop.
- **`glx-no-stencil = true`** — Pi GLES doesn't have a stencil buffer
  worth using.

## i3 — gaps without the fork

Since i3 4.22, the `gaps`, `smart_gaps`, `smart_borders` commands are in
mainline i3. Trixie ships **i3 4.23**, Bookworm ships **4.22** — both
fine. We don't pull `i3-gaps` as a separate package; we don't need to.

If you ever land on a system with i3 <4.22, the install script warns and
the gaps lines in `~/.config/i3/config` get parsed as no-ops (i3 logs
warnings but doesn't refuse to start).

## Plymouth on the Pi — known quirks

- The plymouth splash only renders during the gap between firmware
  handoff and getty. On the Pi 4 that gap is *small*. Expect to see the
  splash for ~2 seconds. Not a bug.
- `update-initramfs -u` must be run after registering the theme. The
  script does this. If you skip it, you get the default theme back.
- The firmware rainbow is what makes the splash flicker if you forget
  `disable_splash=1`.

## Display server choice

X11. i3 is X11-only. If you want Wayland, you want sway, and that's a
different (very reasonable) project. Wayland on the Pi 4 is good now,
but the dpos tooling is X11-native (xrandr, xset, xrdb, feh, Xresources).

## Networking

- **NetworkManager** for the desktop story. `nmtui` from terminal,
  `nm-applet` from the tray-less polybar (it stays accessible via D-Bus).
- Polybar's `[module/net]` defaults to `eth0`. If you're on wifi, edit
  it to `wlan0` in `~/.config/polybar/config.ini`.

## Power and thermal

- The preflight reads `vcgencmd measure_temp` and warns above 70 °C.
- Under load on a passive case, expect ~75 °C. Throttling kicks in
  around 80 °C — at that point the SoC drops to 1.0 GHz from 1.5.
- `vcgencmd get_throttled` returns a bitfield; any non-zero value
  means the firmware has throttled. `alias throttle` lets you check fast.

## The "what if I have a Pi 5" question

Probably works. Trixie on Pi 5 has the same i3, picom, polybar story.
The preflight allows-list is limited to "Pi 4" right now; pass `--force`
on a Pi 5 to bypass. Tuning specifics (gpu_mem on Pi 5 is a no-op, KMS
overlay name differs — Pi 5 uses `vc4-kms-v3d-pi5`) need a small update
to `99-tighten.sh` before this is a clean run. Treat Pi 5 as out-of-scope
for now.

## The "what if I have a Pi 3" question

Don't. The 1GB / 4-core A53 will run i3 — it will not run i3 with
picom + polybar + conky + cmatrix without flinching. The dpos
`70-eyecandy.sh` is built for the 4B's headroom.
