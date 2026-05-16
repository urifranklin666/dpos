#!/usr/bin/env bash
# i3 window manager and visible-stack companions.
# i3 4.22+ has gaps in mainline. Trixie ships i3 4.23, Bookworm ships 4.22.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

export DEBIAN_FRONTEND=noninteractive

readonly I3_PKGS=(
  i3 i3status i3lock
  picom
  polybar
  rofi
  alacritty
  dunst libnotify-bin
  feh maim xclip xdotool
  brightnessctl
  pipewire pipewire-pulse pipewire-alsa wireplumber
  pulseaudio-utils pavucontrol
  network-manager-gnome
  arandr autorandr
  ranger
  scrot
  papirus-icon-theme
)

# polybar in Trixie is 3.7, rofi 1.7+. Both fine for our config.

log_info "installing i3 stack (${#I3_PKGS[@]} pkgs)"
run sudo apt-get -y -qq install --no-install-recommends "${I3_PKGS[@]}"

# i3lock-color is an optional drop-in upgrade for the basic i3lock. We try
# it after the mandatory install so the stage doesn't fail if it's missing.
if apt-cache show i3lock-color >/dev/null 2>&1; then
  log_info "installing i3lock-color (better lock screen typography)"
  run sudo apt-get -y -qq install --no-install-recommends i3lock-color \
    || log_warn "i3lock-color failed to install; keeping basic i3lock"
else
  log_skip "i3lock-color not in apt repos; keeping basic i3lock"
fi

# Verify i3 has gaps support (mainline ≥ 4.22)
if command -v i3 >/dev/null 2>&1; then
  ver="$(i3 --version 2>/dev/null | awk '{print $3}' | head -n1)"
  log_info "i3 version: ${ver}"
  major="${ver%%.*}"; rest="${ver#*.}"; minor="${rest%%.*}"
  if [[ -n "${major}" && -n "${minor}" ]]; then
    if (( major < 4 )) || (( major == 4 && minor < 22 )); then
      log_warn "i3 < 4.22 detected; 'gaps' commands may fail"
    fi
  fi
fi

log_ok "i3 stack installed"
