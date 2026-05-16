#!/usr/bin/env bash
# Replace the system MOTD with a deadplug banner + live status + a small
# burn from a rotating pool.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

# Disable stock motd snippets
for f in /etc/update-motd.d/*; do
  [[ -e "${f}" ]] || continue
  case "$(basename "${f}")" in
    10-uname|10-help-text|10-sysinfo|50-motd-news|80-livepatch|99-bento|*pi-bullseye*|*pi-bookworm*|*pi-trixie*)
      [[ ! -x "${f}" ]] && continue
      run sudo chmod -x "${f}" || true
      log_info "disabled $(basename "${f}")"
      ;;
  esac
done

# Make sure /etc/motd is empty (handled by update-motd.d on Debian)
run sudo bash -c ':> /etc/motd'

# Install our motd script
run sudo install -m 0755 "${DPOS_DIR}/configs/motd/motd.sh" \
  /etc/update-motd.d/00-dpos

# Install the ANSI logo where motd can read it
run sudo mkdir -p /usr/local/share/dpos
run sudo install -m 0644 "${DPOS_DIR}/assets/ansi/deadplug-logo.txt" \
  /usr/local/share/dpos/logo.ans
run sudo install -m 0644 "${DPOS_DIR}/configs/motd/burns.txt" \
  /usr/local/share/dpos/burns.txt

# Make sure PAM is set to actually show motd. On Trixie/Bookworm SSH and login
# already source pam_motd so usually this is already on, but be explicit.
if [[ -f /etc/pam.d/login ]] && ! grep -q 'pam_motd.so' /etc/pam.d/login; then
  log_warn "pam_motd not in /etc/pam.d/login — motd may not show on console login"
fi

log_ok "motd replaced"
