#!/usr/bin/env bash
# Copy configs/ into ~/.config (and a few other places). Anything we'd
# clobber gets backed up to $DPOS_BACKUP_DIR first.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

drop_dir() {
  # drop_dir <src-relative-to-configs/> <dest-absolute>
  local src="${DPOS_DIR}/configs/$1"
  local dest="$2"
  if [[ ! -d "${src}" ]]; then
    log_warn "no source dir: ${src}"
    return 1
  fi
  if [[ -e "${dest}" ]]; then
    backup_path "${dest}"
  fi
  mkdir -p "$(dirname "${dest}")"
  cp -r "${src}" "${dest}"
  log_ok "deployed $(basename "${dest}")"
}

# Migration: conky was dropped in the visual pass (didn't suit a tiling
# WM). Kill any running instance and back up the old config so future
# reinstalls don't resurrect it.
if pgrep -x conky >/dev/null 2>&1; then
  pkill -x conky 2>/dev/null || true
  log_info "stopped running conky daemon"
fi
if [[ -d "${HOME}/.config/conky" ]]; then
  backup_path "${HOME}/.config/conky"
  log_info "backed up old conky config"
fi

drop_dir i3        "${HOME}/.config/i3"
drop_dir polybar   "${HOME}/.config/polybar"
drop_dir picom     "${HOME}/.config/picom"
drop_dir rofi      "${HOME}/.config/rofi"
drop_dir alacritty "${HOME}/.config/alacritty"
drop_dir dunst     "${HOME}/.config/dunst"

# polybar launcher must be executable
chmod +x "${HOME}/.config/polybar/launch.sh"

# Wallpaper. Render the SVG to PNG at the host's native resolution if we
# can detect it; otherwise 1920x1080.
mkdir -p "${HOME}/.local/share/dpos/wallpapers"
src_svg="${DPOS_DIR}/assets/wallpapers/deadplug.svg"
dest_png="${HOME}/.local/share/dpos/wallpapers/deadplug.png"
if [[ -f "${src_svg}" ]]; then
  res="1920x1080"
  if command -v xdpyinfo >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
    r=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ {print $2; exit}')
    [[ -n "${r}" && "${r}" == *x* ]] && res="${r}"
  fi
  w="${res%x*}"; h="${res#*x}"
  if command -v rsvg-convert >/dev/null 2>&1; then
    run rsvg-convert -w "${w}" -h "${h}" -o "${dest_png}" "${src_svg}" || true
  elif command -v convert >/dev/null 2>&1; then
    run convert -background black -resize "${res}" "${src_svg}" "${dest_png}" || true
  fi
  [[ -f "${dest_png}" ]] && log_ok "wallpaper rendered: ${dest_png} (${res})"
fi

# Drop the ANSI logo so MOTD + fastfetch can find it
mkdir -p "${HOME}/.local/share/dpos"
cp "${DPOS_DIR}/assets/ansi/deadplug-logo.txt" "${HOME}/.local/share/dpos/logo.ans"
log_ok "deployed ANSI logo"

# Deploy the rites corpus — daily rotation by dpos-rite
mkdir -p "${HOME}/.local/share/dpos"
cp "${DPOS_DIR}/assets/rites/dpos-rites.txt" "${HOME}/.local/share/dpos/rites.txt"
log_ok "deployed rites corpus ($(wc -l <"${HOME}/.local/share/dpos/rites.txt") lines)"

# Deploy helper scripts into ~/.local/bin/ so they're on PATH and tab-complete
mkdir -p "${HOME}/.local/bin"
for script in "${DPOS_DIR}/configs/bin/"*; do
  name="$(basename "${script}")"
  dest="${HOME}/.local/bin/${name}"
  if [[ -e "${dest}" ]]; then
    backup_path "${dest}"
  fi
  install -m 0755 "${script}" "${dest}"
done
log_ok "deployed helpers to ~/.local/bin ($(ls "${HOME}/.local/bin/dpos-"* 2>/dev/null | wc -l) scripts)"

log_ok "configs deployed"
