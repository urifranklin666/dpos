#!/usr/bin/env bash
# Preflight: refuse to mutate the system unless we're on a Pi 4 / 64-bit
# Trixie or Bookworm / sane network / enough disk. --force overrides.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"
# shellcheck source=../lib/check.sh
source "${DPOS_DIR}/lib/check.sh"

fail=0
warn=0

if is_pi4; then
  log_ok "Raspberry Pi 4 detected"
else
  log_warn "this does not look like a Raspberry Pi 4"
  if [[ -r /proc/device-tree/model ]]; then
    log_info "  model: $(tr -d '\0' </proc/device-tree/model)"
  fi
  fail=1
fi

arch="$(uname -m)"
if is_arm64; then
  log_ok "64-bit aarch64 kernel"
elif [[ "${arch}" == armv7l || "${arch}" == armv6l ]]; then
  log_warn "kernel is ${arch}; 32-bit ARM caps RAM at 4GB and is unsupported here"
  log_info "  reflash 64-bit Raspberry Pi OS Lite (Trixie) and run again"
  fail=1
else
  log_warn "kernel is ${arch}; this kit targets aarch64 Pi 4B"
  log_info "  pass --force if you know what you're doing"
  fail=1
fi

if is_supported_os; then
  log_ok "Debian/Raspbian (supported codename)"
else
  log_warn "OS is not Debian/Raspbian Bookworm/Trixie/sid — packages may not resolve"
  if [[ -r /etc/os-release ]]; then
    log_info "  $(grep -E '^(PRETTY_NAME|VERSION_CODENAME)=' /etc/os-release | tr '\n' ' ')"
  fi
  fail=1
fi

if have_internet; then
  log_ok "internet reachable"
else
  log_warn "cannot reach deb.debian.org or archive.raspberrypi.org"
  fail=1
fi

ram=$(total_ram_mb)
if [[ ${ram} -ge 3500 ]]; then
  log_ok "RAM: ${ram}MB"
elif [[ ${ram} -ge 1500 ]]; then
  log_warn "RAM: ${ram}MB — this targets the 8GB model but will work on smaller"
  warn=1
else
  log_warn "RAM: ${ram}MB — too small for this stack"
  fail=1
fi

disk=$(free_disk_mb)
if [[ ${disk} -ge 4000 ]]; then
  log_ok "free disk: ${disk}MB"
else
  log_warn "free disk: ${disk}MB — install needs ~3GB"
  fail=1
fi

if command -v apt-get >/dev/null 2>&1; then
  log_ok "apt-get present"
else
  log_warn "no apt-get; this script is Debian-only"
  fail=1
fi

if [[ ${fail} -ne 0 ]]; then
  if [[ "${DPOS_FORCE:-0}" -eq 1 ]]; then
    log_warn "--force set; continuing in spite of preflight failures"
  else
    log_err "preflight failed. fix the above, or re-run with --force."
    exit 1
  fi
fi

if [[ ${warn} -ne 0 ]]; then
  log_info "preflight passed with warnings."
fi

log_ok "preflight clear"
