#!/usr/bin/env bash
# Boot splash via Plymouth — brand-compliant.
#
# Renders every SVG in assets/plymouth/ to a PNG in the theme directory.
# bg.png is sized to the host's display resolution so we don't get
# bilinear-stretch fuzz; everything else is rendered at fixed size.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"
# shellcheck source=../lib/check.sh
source "${DPOS_DIR}/lib/check.sh"

log_info "installing plymouth"
run sudo apt-get -y -qq install --no-install-recommends \
  plymouth plymouth-themes plymouth-label

if ! command -v rsvg-convert >/dev/null 2>&1; then
  log_warn "rsvg-convert missing; installing librsvg2-bin"
  run sudo apt-get -y -qq install --no-install-recommends librsvg2-bin
fi

theme_dir="/usr/share/plymouth/themes/deadplug"
src_dir="${DPOS_DIR}/assets/plymouth"

run sudo mkdir -p "${theme_dir}"
run sudo install -m 0644 "${DPOS_DIR}/configs/plymouth/deadplug.plymouth" \
  "${theme_dir}/deadplug.plymouth"
run sudo install -m 0644 "${DPOS_DIR}/configs/plymouth/deadplug.script" \
  "${theme_dir}/deadplug.script"

# ---- detect display resolution for bg.png ---------------------------------
# We don't have X here; ask the Pi firmware. Fall back to 1920×1080.
bg_w=1920; bg_h=1080
if command -v tvservice >/dev/null 2>&1; then
  # legacy firmware; some older Pi images still ship it
  r=$(tvservice -s 2>/dev/null | grep -oP '[0-9]+x[0-9]+' | head -n1)
  [[ -n "${r}" ]] && { bg_w="${r%x*}"; bg_h="${r#*x}"; }
elif [[ -r /sys/class/graphics/fb0/virtual_size ]]; then
  r="$(cat /sys/class/graphics/fb0/virtual_size 2>/dev/null)"   # "1920,1080"
  if [[ -n "${r}" ]]; then
    bg_w="${r%,*}"
    bg_h="${r#*,}"
  fi
fi
# sanity clamp
[[ "${bg_w}" -lt 640  ]] && bg_w=1920
[[ "${bg_h}" -lt 480  ]] && bg_h=1080
log_info "rendering bg.png at ${bg_w}x${bg_h}"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

# render() <svg-basename> <w> <h>
render() {
  local base="$1" w="$2" h="$3"
  local svg="${src_dir}/${base}.svg"
  local png="${tmp}/${base}.png"
  if [[ ! -f "${svg}" ]]; then
    log_warn "missing source: ${svg}"
    return 1
  fi
  if ! run rsvg-convert -w "${w}" -h "${h}" -o "${png}" "${svg}" 2>/dev/null; then
    log_warn "rsvg-convert failed on ${base}.svg"
    return 1
  fi
  run sudo install -m 0644 "${png}" "${theme_dir}/${base}.png"
}

render bg              "${bg_w}" "${bg_h}"
render logo            256       256
render wordmark        720       70
render wordmark-glitch-r 720     70
render wordmark-glitch-c 720     70
render eyebrow         880       28
render bar-track       360       2
render bar-fill        1         2
render ember           24        24

# legacy filename used by some tools
run sudo cp "${theme_dir}/logo.png" "${theme_dir}/box.png" 2>/dev/null || true

# ---- register theme via update-alternatives -------------------------------
log_info "registering deadplug plymouth theme"
run sudo update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth default.plymouth \
  "${theme_dir}/deadplug.plymouth" 200

run sudo update-alternatives --set default.plymouth \
  "${theme_dir}/deadplug.plymouth"

# ---- kernel cmdline: quiet splash, suppress serial-console plymouth -------
cmdline="/boot/firmware/cmdline.txt"
[[ -r "${cmdline}" ]] || cmdline="/boot/cmdline.txt"
if [[ -w "${cmdline}" ]] || sudo test -w "${cmdline}"; then
  if ! grep -q 'splash' "${cmdline}"; then
    log_info "patching ${cmdline}: + quiet splash plymouth.ignore-serial-consoles"
    run sudo cp "${cmdline}" "${cmdline}.dpos-bak"
    run sudo sed -i 's|$| quiet splash plymouth.ignore-serial-consoles|' "${cmdline}"
  else
    log_skip "cmdline already has splash"
  fi
fi

# ---- initramfs ------------------------------------------------------------
if command -v update-initramfs >/dev/null 2>&1; then
  log_info "rebuilding initramfs (Pi takes ~10s)"
  run sudo update-initramfs -u || log_warn "update-initramfs returned non-zero"
fi

# ---- preview test (optional) ----------------------------------------------
log_info "you can preview without rebooting with:  sudo plymouthd; sudo plymouth --show-splash; sleep 5; sudo plymouth --quit"

log_ok "plymouth theme installed"
