# dpos

A deadplug.digital flavored desktop for the Raspberry Pi 4B (8GB).
Debian-based, i3 tiling, picom-glassed, with all the red/black eyecandy and
none of the agency-speak.

This is not an ISO. It is a post-install kit. You flash a clean 64-bit
**Raspberry Pi OS Lite (Trixie)** — Debian 13, the current Pi OS as of
late 2025 — boot the Pi, clone this folder on it, run `./install.sh`.
By the time it finishes, your Pi looks like the homepage. Bookworm
(Debian 12) also works; the preflight accepts both.

## What you get

```
i3 (gaps mainline)   ──  the WM, configured, sane keybinds, deadplug colors
polybar              ──  top bar: workspaces, window, cpu, mem, temp, net, clock
picom                ──  compositor, light shadows + fade, no blur (the Pi GPU
                         doesn't owe you blur)
rofi                 ──  launcher, deadplug.rasi theme
alacritty            ──  terminal, mono, transparent, red prompt
zsh                  ──  default shell, custom prompt, dry aliases
dunst                ──  notifications, black with a red gutter
plymouth             ──  boot splash with the plug-skull-bolt
fortune              ──  custom fortune file (deadplug canon, no rainbows)
fastfetch            ──  ASCII art + sysinfo on every shell open
motd                 ──  login banner, system status, a small burn
```

Hardware preflight refuses to run if it can't see a Pi 4. Override with
`--force` if you're testing in a VM.

## Install

On a freshly-flashed Pi running 64-bit Raspberry Pi OS Lite (Trixie),
logged in as a normal user with sudo:

```bash
sudo apt-get update && sudo apt-get install -y git
git clone https://git.deadplug.digital/urifranklin666/skynet.git
cd skynet/dpos
./install.sh
```

Reboot when it tells you to. Log in to tty1 — `startx` autoruns and drops
you into i3. From there, `Mod+Return` is a terminal, `Mod+d` is rofi.

To run only part of it:

```bash
./install.sh --only 20-i3,50-configs,70-eyecandy
./install.sh --skip 80-plymouth
./install.sh --dry-run
```

## Components

| Script              | What it does                                              |
|---------------------|-----------------------------------------------------------|
| `00-preflight.sh`   | Verify Pi 4, 64-bit, Trixie/Bookworm, sudo, network, disk |
| `10-apt-base.sh`    | apt update/upgrade, install X11 + base tools              |
| `15-cli-tools.sh`   | Hacker CLI suite: fzf, bat, eza, fd, ripgrep, ncdu, tldr  |
| `20-i3.sh`          | Install i3, polybar, picom, rofi, alacritty, dunst, feh   |
| `30-theme.sh`       | GTK 3/4 dark theme override with brand tokens             |
| `40-fonts.sh`       | Mono (Fira Code, Cascadia), serif (DejaVu)                |
| `50-configs.sh`     | Drop configs from `configs/` into `$HOME/.config/`        |
| `60-shell.sh`       | zsh + custom prompt + brand aliases                       |
| `70-eyecandy.sh`    | picom, fortunes, fastfetch, autostart of `startx`         |
| `80-plymouth.sh`    | Boot splash theme + initramfs update                      |
| `90-motd.sh`        | Login banner replacement                                  |
| `99-tighten.sh`     | gpu_mem, zram, disable cruft, KMS check, governor         |

## The `dpos` command

A central operator-console command lands at `~/.local/bin/dpos`. Bare
invocation pops a brand-themed fzf launcher; `dpos <sub>` dispatches
directly. See `dpos help` for the full subcommand list (status, ssh,
services, sigil, confess, numbers, boot, rite, onair, lock, colors,
banner, home, ops).

Each script is idempotent. Re-running won't double-install or wreck configs
that already exist (those are backed up to `~/.dpos-backup/`).

## Hardware notes

See `docs/HARDWARE.md`. Short version: 64-bit OS, USB-3 SSD strongly
recommended, `gpu_mem=128`, KMS driver, picom on glx with vsync, no blur.
The Pi 4B is more than enough for this whole stack. It is not enough for
Chromium with twelve tabs. Use a real machine for that.

## Pi-gen path (optional)

`pi-gen/` has a stage stub for when you want to bake all of this into a
flashable `.img` so you can hand out cards to friends. Not wired yet —
that's a P2 once the script path is verified.

## Voice

This thing is part of deadplug.digital. The MOTD, fortunes, aliases,
prompt, and shutdown messages are dry, terse, and a little hostile to
the discourse. No emojis. If you want sunshine, install GNOME.
