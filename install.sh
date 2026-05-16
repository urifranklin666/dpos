#!/usr/bin/env bash
# dpos installer — deadplug.digital desktop for Raspberry Pi 4B
#
# Usage:
#   ./install.sh                  full install
#   ./install.sh --dry-run        print what would happen, do nothing
#   ./install.sh --only 20,50,70  run only specific stages (prefix-match)
#   ./install.sh --skip 80        skip stages by prefix
#   ./install.sh --force          ignore preflight failures
#   ./install.sh --yes            assume yes to confirms
#
# Idempotent. Re-running is safe. Existing dotfiles get backed up to
# ~/.dpos-backup/<timestamp>/.

set -euo pipefail

readonly DPOS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export DPOS_DIR

# shellcheck source=lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=lib/log.sh
source "${DPOS_DIR}/lib/log.sh"
# shellcheck source=lib/check.sh
source "${DPOS_DIR}/lib/check.sh"

DPOS_DRY_RUN=0
DPOS_FORCE=0
DPOS_YES=0
DPOS_ONLY=""
DPOS_SKIP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DPOS_DRY_RUN=1 ;;
    --force)     DPOS_FORCE=1 ;;
    --yes|-y)    DPOS_YES=1 ;;
    --only)      shift; DPOS_ONLY="${1:-}" ;;
    --skip)      shift; DPOS_SKIP="${1:-}" ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      log_err "unknown flag: $1"
      exit 2
      ;;
  esac
  shift
done

export DPOS_DRY_RUN DPOS_FORCE DPOS_YES

readonly DPOS_BACKUP_DIR="${HOME}/.dpos-backup/$(date +%Y%m%d-%H%M%S)"
export DPOS_BACKUP_DIR

print_banner() {
  cat <<'EOF'

      d e a d p l u g . d i g i t a l   //   d p o s
      ──────────────────────────────────────────────
      Raspberry Pi 4B desktop kit.  Red, black, dry.

EOF
}

print_banner

if [[ ${EUID} -eq 0 ]]; then
  log_err "do not run this as root. it uses sudo where it needs to."
  exit 2
fi

if ! sudo -n true 2>/dev/null; then
  log_info "sudo will prompt for your password (cached for the run)."
  sudo -v
fi
# keep sudo alive in the background while the installer runs
(
  while true; do
    sudo -n true 2>/dev/null || exit
    sleep 50
  done
) &
readonly SUDO_KEEPALIVE_PID=$!
trap 'kill ${SUDO_KEEPALIVE_PID} 2>/dev/null || true' EXIT

# Confirm before doing anything if not --yes
if [[ ${DPOS_YES} -ne 1 && ${DPOS_DRY_RUN} -ne 1 ]]; then
  printf '%b' "${C_DIM}This will install i3, polybar, picom, rofi, alacritty, zsh, plymouth,\n"
  printf '%b' "and a deadplug-branded set of configs into your home directory.\n"
  printf '%b' "Existing dotfiles are backed up to ~/.dpos-backup/.\n${C_RESET}"
  read -r -p "$(printf '%b' "${C_RED}proceed?${C_RESET} [y/N] ")" reply
  case "${reply}" in
    y|Y|yes|YES) : ;;
    *) log_warn "aborted by user."; exit 1 ;;
  esac
fi

mkdir -p "${DPOS_BACKUP_DIR}"
log_info "backup dir: ${DPOS_BACKUP_DIR}"

# Collect scripts in order
mapfile -t ALL_SCRIPTS < <(find "${DPOS_DIR}/scripts" -maxdepth 1 -type f -name '*.sh' | sort)

should_run() {
  local name; name="$(basename "$1")"
  local prefix; prefix="${name%%-*}"

  if [[ -n "${DPOS_ONLY}" ]]; then
    IFS=',' read -r -a only_arr <<<"${DPOS_ONLY}"
    local match=0
    for o in "${only_arr[@]}"; do
      [[ "${prefix}" == "${o}" || "${name}" == "${o}"* ]] && match=1
    done
    [[ ${match} -eq 1 ]] || return 1
  fi
  if [[ -n "${DPOS_SKIP}" ]]; then
    IFS=',' read -r -a skip_arr <<<"${DPOS_SKIP}"
    for s in "${skip_arr[@]}"; do
      [[ "${prefix}" == "${s}" || "${name}" == "${s}"* ]] && return 1
    done
  fi
  return 0
}

for script in "${ALL_SCRIPTS[@]}"; do
  if ! should_run "${script}"; then
    log_skip "$(basename "${script}")"
    continue
  fi
  log_stage "$(basename "${script}")"
  if [[ ${DPOS_DRY_RUN} -eq 1 ]]; then
    log_info "  (dry-run, not executing)"
    continue
  fi
  # shellcheck source=/dev/null
  bash "${script}"
done

cat <<EOF

──────────────────────────────────────────────
$(printf '%b' "${C_RED}")INSTALL COMPLETE$(printf '%b' "${C_RESET}")

  next steps:
    1. ${C_BOLD}sudo reboot${C_RESET}
    2. log in on tty1 as your normal user
    3. ${C_BOLD}startx${C_RESET}  (or it'll autorun if you enabled autologin)
    4. Mod+Return for terminal, Mod+d for rofi, Mod+Shift+e to exit

  if anything looks off, check ${DPOS_BACKUP_DIR}
  for whatever we replaced.
──────────────────────────────────────────────

EOF
