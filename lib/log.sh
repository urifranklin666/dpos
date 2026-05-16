# Logging helpers for the dpos installer. No timestamps. No padding.
# Stage banners are mono red.

if [[ -n "${_DPOS_LOG_LOADED:-}" ]]; then return 0; fi
_DPOS_LOG_LOADED=1

log_stage() {
  printf '\n%b' "${C_RED}// ${C_BOLD}${1}${C_RESET}\n"
}

log_info() {
  printf '%b' "${C_DIM}  ${1}${C_RESET}\n"
}

log_ok() {
  printf '%b' "${C_GREEN}  ok${C_RESET} ${C_DIM}${1}${C_RESET}\n"
}

log_warn() {
  printf '%b' "${C_AMBER}  warn${C_RESET} ${1}\n" >&2
}

log_err() {
  printf '%b' "${C_RED_BRIGHT}  err${C_RESET}  ${1}\n" >&2
}

log_skip() {
  printf '%b' "${C_GREY}  skip${C_RESET} ${C_DIM}${1}${C_RESET}\n"
}

# Wrap a command so its output gets indented under the stage banner.
run() {
  if [[ "${DPOS_DRY_RUN:-0}" -eq 1 ]]; then
    printf '%b' "${C_DIM}  $ ${*}${C_RESET}\n"
    return 0
  fi
  "$@"
}

# back up a path before we replace it; no-op if it doesn't exist
backup_path() {
  local src="$1"
  [[ -e "${src}" || -L "${src}" ]] || return 0
  local rel="${src#${HOME}/}"
  local dest="${DPOS_BACKUP_DIR}/${rel}"
  mkdir -p "$(dirname "${dest}")"
  mv -- "${src}" "${dest}"
  log_info "backed up ${src} -> ${dest}"
}
