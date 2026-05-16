# PACKAGES.md — what we install and why it's arm64-clean

Every apt package dpos installs is either in **Debian Trixie main**
(Pi OS Lite is on Trixie as of late 2025) with arm64 binaries, or
`Architecture: all` (architecture-independent — shell scripts, fonts,
config files). Nothing in here is x86-only.

This is the audited list grouped by install stage. Each entry is the
binary package name as it appears in `apt-cache show <name>`.

The Raspberry Pi OS Trixie repos are a strict subset of Debian Trixie
with a small overlay for Pi firmware/kernel — every userspace package
below resolves against `deb.debian.org/debian trixie main` unchanged.
Bookworm is also supported; every package below was already in Bookworm
main, so the kit works on either codename.

## Stage 10 — base (`scripts/10-apt-base.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| ca-certificates                  | all      | |
| curl, wget                       | arm64    | |
| git                              | arm64    | |
| rsync, unzip, zip, tar, xz-utils | arm64    | |
| build-essential, pkg-config      | arm64    | meta + gcc + make |
| xserver-xorg, xinit              | all/arm64 | core X11 |
| x11-xserver-utils, x11-utils     | arm64    | xrandr, xrdb, xset, xdpyinfo |
| xserver-xorg-input-libinput      | arm64    | |
| xserver-xorg-video-fbdev         | arm64    | KMS auto-selects; this is fallback |
| dbus-x11                         | arm64    | |
| mesa-utils                       | arm64    | `glxinfo` |
| libgl1-mesa-dri                  | arm64    | VC6 ships its own driver inside this package family |
| network-manager                  | arm64    | |
| iproute2, iputils-ping           | arm64    | |
| less, file, bash-completion, man-db | arm64 | |
| htop, btop                       | arm64    | |
| tmux                             | arm64    | |
| jq                               | arm64    | |
| fonts-dejavu, fonts-dejavu-extra | all      | |
| polkitd                          | arm64    | renamed from `policykit-1` in Trixie (transitional pkg dropped). |
| acl                              | arm64    | |
| imagemagick                      | arm64    | for asset rasterization fallbacks |
| librsvg2-bin                     | arm64    | `rsvg-convert`, used by 80-plymouth.sh |

## Stage 15 — CLI suite (`scripts/15-cli-tools.sh`)

| Package    | Arch  | Notes |
|------------|-------|-------|
| fzf        | arm64 | fuzzy finder — engine for the `dpos` launcher and zsh Ctrl-R/T/Alt-C |
| bat        | arm64 | Debian binary is `batcat`; used by fzf preview and `cat` alias |
| eza        | arm64 | Modern `ls` replacement; `ls`/`l`/`la`/`ll`/`lt` aliases |
| fd-find    | arm64 | Fast `find`; binary is `fdfind`; used by FZF_DEFAULT_COMMAND |
| ripgrep    | arm64 | Fast `grep`; binary is `rg` |
| ncdu       | arm64 | Interactive disk usage |
| tldr       | all   | Quick man-page summaries |
| lazygit    | arm64 | Git TUI — installed if available, otherwise skipped |

## Stage 20 — i3 stack (`scripts/20-i3.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| i3                               | arm64    | **4.23 in Trixie, 4.22 in Bookworm — gaps are in mainline, no separate i3-gaps needed.** |
| i3status, i3lock                 | arm64    | |
| picom                            | arm64    | compositor. We use the glx backend. |
| polybar                          | arm64    | 3.7 in Trixie, 3.6 in Bookworm. |
| rofi                             | arm64    | 1.7+. |
| alacritty                        | arm64    | 0.13+ in Trixie. TOML config. |
| dunst, libnotify-bin             | arm64    | notification daemon + `notify-send`. |
| feh, maim, xclip, xdotool        | arm64    | wallpaper + screenshot + clipboard. |
| brightnessctl                    | arm64    | works on Pi for backlight if present; no-op otherwise. |
| pipewire, pipewire-pulse         | arm64    | **Trixie/Bookworm's default audio stack.** |
| pipewire-alsa                    | arm64    | ALSA → PipeWire bridge. |
| wireplumber                      | arm64    | session manager for PipeWire. |
| pulseaudio-utils                 | arm64    | `pactl`, speaks to pipewire-pulse — no conflict. |
| pavucontrol                      | arm64    | GTK control. |
| network-manager-gnome            | arm64    | `nm-applet` (used for connection dialogs). |
| arandr, autorandr                | all      | display layout. |
| ranger                           | all      | TUI file manager. |
| scrot                            | arm64    | screenshots. |
| papirus-icon-theme               | all      | |

**Note: no `pulseaudio`.** Trixie (and Bookworm) use PipeWire with a
pulse-protocol shim (`pipewire-pulse`). Installing the legacy
`pulseaudio` daemon would fight the shim. The `pulseaudio-utils`
package provides the client tools (`pactl`, `paplay`) and is the
supported combo.

## Stage 30 — theme (`scripts/30-theme.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| adwaita-icon-theme               | all      | |
| gnome-themes-extra               | all      | base GTK engine. |
| qt5ct                            | arm64    | Qt theming (in case any Qt app shows up). |

Theming itself is done via `~/.config/gtk-{3,4}.0/gtk.css` — no
third-party theme package needed.

## Stage 40 — fonts (`scripts/40-fonts.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| fonts-firacode                   | all      | |
| fonts-cascadia-code              | all      | in Debian main since Bookworm; current in Trixie. |
| fonts-jetbrains-mono             | all      | |
| fonts-noto-core                  | all      | |
| fonts-noto-color-emoji           | all      | rendered as emoji even though we don't write them |
| fonts-font-awesome               | all      | |

Plus a **Symbols-Only Nerd Font** zip pulled from GitHub at install time
into `~/.local/share/fonts/`. The font file is a TTF — architecture-
independent. If GitHub is unreachable during install, the script logs
a warning and continues; polybar status glyphs render as boxes until
you re-run `./install.sh --only 40`.

## Stage 60 — shell (`scripts/60-shell.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| zsh                              | arm64    | |

No frameworks, no plugins. The prompt is hand-rolled in `~/.zshrc`.

## Stage 70 — eye candy (`scripts/70-eyecandy.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| cmatrix                          | arm64    | |
| pipes.sh                         | all      | bash script — runs anywhere. |
| fortune-mod                      | arm64    | |
| fortunes-min                     | all      | |
| figlet, toilet                   | arm64    | ASCII banner generators. |
| fastfetch                        | arm64    | actively-maintained neofetch successor; in Trixie main. |
| cowsay                           | all      | perl script — runs anywhere. |
| bsdmainutils                     | arm64    | provides `strfile`, used to index our fortune file. |

## Stage 80 — plymouth (`scripts/80-plymouth.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| plymouth                         | arm64    | |
| plymouth-themes                  | all      | |
| plymouth-label                   | arm64    | required by the `script` plugin to render text. |

## Stage 99 — tightening (`scripts/99-tighten.sh`)

| Package                          | Arch     | Notes |
|----------------------------------|----------|-------|
| zram-tools                       | all      | shell scripts; sets up `/dev/zram*` swap. |

No kernel module install — the `zram` driver is in the Pi's stock
kernel (Bookworm and Trixie) by default.

## Things we explicitly do **not** install

- `pulseaudio` (legacy daemon, conflicts with pipewire-pulse)
- `i3-gaps` (rolled into mainline `i3` ≥4.22; Trixie ships 4.23)
- `neofetch` (upstream archived in 2024 — replaced by `fastfetch`)
- `lxpolkit` / `policykit-gnome` (policykit-1 is enough for our needs)
- A separate display manager (lightdm/gdm/sddm). dpos uses tty1 autologin
  + `startx`. One less moving part.
- `lolcat` (rainbow output is off-brand)
- A Nerd-patched font replacement for everything. We install a single
  symbols-only file and let Cascadia/Fira/JetBrains carry the rest.

## Sanity check this list against your Pi

After flashing 64-bit Raspberry Pi OS Lite Trixie, before running the
installer:

```bash
sudo apt-get update
apt-cache madison i3 picom polybar rofi alacritty plymouth pipewire \
                  fonts-cascadia-code fastfetch librsvg2-bin
```

Every line should show a Trixie version and `arm64` (or `all`) as the
arch. If anything resolves to `i386` or `amd64`, you're on the wrong
kernel — go back to the preflight section in `HARDWARE.md`.
