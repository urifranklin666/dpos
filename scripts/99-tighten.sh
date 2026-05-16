#!/usr/bin/env bash
# Pi 4B specific tuning. Each block is conservative and idempotent.
#
#  - gpu_mem=128 in config.txt (KMS likes the room; default 64 is too tight)
#  - dtoverlay=vc4-kms-v3d enabled (default in Trixie/Bookworm; verify)
#  - zram-swap-enabled instead of disk-backed swap
#  - disable services that the Pi rarely needs (triggerhappy, ModemManager)
#  - CPU governor: 'ondemand' (default; verify)
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"
# shellcheck source=../lib/check.sh
source "${DPOS_DIR}/lib/check.sh"

cfg="$(config_txt_path)"
if [[ -z "${cfg}" ]]; then
  log_warn "no writable config.txt found — skipping Pi-firmware tuning"
else
  # gpu_mem
  cur="$(current_gpu_mem)"
  if [[ -z "${cur}" || "${cur}" -lt 128 ]]; then
    log_info "setting gpu_mem=128 in ${cfg}"
    run sudo cp "${cfg}" "${cfg}.dpos-bak.$(date +%s)"
    if grep -q '^[[:space:]]*gpu_mem' "${cfg}"; then
      run sudo sed -i 's/^[[:space:]]*gpu_mem.*/gpu_mem=128/' "${cfg}"
    else
      printf '\n# dpos\ngpu_mem=128\n' | run sudo tee -a "${cfg}" >/dev/null
    fi
  else
    log_skip "gpu_mem already ≥128 (${cur})"
  fi

  # KMS overlay
  if ! grep -qE '^[[:space:]]*dtoverlay=vc4-kms-v3d' "${cfg}"; then
    log_info "enabling vc4-kms-v3d in ${cfg}"
    printf '\n# dpos\ndtoverlay=vc4-kms-v3d\nmax_framebuffers=2\n' \
      | run sudo tee -a "${cfg}" >/dev/null
  else
    log_skip "vc4-kms-v3d already enabled"
  fi

  # Disable rainbow boot splash (it fights with plymouth)
  if ! grep -qE '^[[:space:]]*disable_splash' "${cfg}"; then
    printf 'disable_splash=1\n' | run sudo tee -a "${cfg}" >/dev/null
    log_ok "disabled firmware rainbow"
  fi
fi

# zram. There's a debian 'zram-tools' package; safe to install.
if dpkg-query -W -f='${Status}' zram-tools 2>/dev/null | grep -q 'install ok installed'; then
  log_skip "zram-tools already installed"
else
  log_info "installing zram-tools"
  run sudo apt-get -y -qq install --no-install-recommends zram-tools
fi
if [[ -w /etc/default/zramswap ]] || sudo test -w /etc/default/zramswap; then
  # Set conservative defaults: 50% of RAM, zstd
  run sudo bash -c 'sed -i "s/^#\?PERCENTAGE=.*/PERCENTAGE=50/;s/^#\?ALGO=.*/ALGO=zstd/;s/^#\?PRIORITY=.*/PRIORITY=100/" /etc/default/zramswap || true'
  run sudo systemctl enable --now zramswap.service 2>/dev/null || true
  log_ok "zram-swap configured (50% / zstd)"
fi

# Disable services we don't need on a desktop Pi
for svc in triggerhappy.service ModemManager.service; do
  if systemctl list-unit-files 2>/dev/null | grep -q "^${svc}"; then
    if systemctl is-enabled --quiet "${svc}" 2>/dev/null; then
      run sudo systemctl disable --now "${svc}" || true
      log_ok "disabled ${svc}"
    else
      log_skip "${svc} already disabled"
    fi
  fi
done

# CPU governor — keep ondemand (default). Print current for transparency.
if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
  gov="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
  log_info "cpu governor: ${gov}"
fi

# Temperature sanity readout
if command -v vcgencmd >/dev/null 2>&1; then
  t="$(vcgencmd measure_temp 2>/dev/null | sed 's/temp=//;s/.C.*//')"
  if [[ -n "${t}" ]]; then
    log_info "current SoC temp: ${t}C"
    awk -v t="${t}" 'BEGIN { if (t+0 > 70) exit 1 }' \
      && log_ok "thermal headroom looks fine" \
      || log_warn "running hot — verify your case has airflow / heatsink"
  fi
fi

log_ok "tuning applied"
echo
log_info "you should now: sudo reboot"
