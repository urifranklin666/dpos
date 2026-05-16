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

drop_dir i3        "${HOME}/.config/i3"
drop_dir polybar   "${HOME}/.config/polybar"
drop_dir picom     "${HOME}/.config/picom"
drop_dir rofi      "${HOME}/.config/rofi"
drop_dir alacritty "${HOME}/.config/alacritty"
drop_dir conky     "${HOME}/.config/conky"
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

log_ok "configs deployed"
