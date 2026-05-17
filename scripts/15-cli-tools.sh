#!/usr/bin/env bash
# Hacker CLI suite — the tools that make the shell pop and the operator
# console feel useful. All in Trixie main.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

export DEBIAN_FRONTEND=noninteractive

readonly CLI_PKGS=(
  fzf            # fuzzy finder — engine for the dpos launcher
  bat            # syntax-highlighted cat (binary is /usr/bin/batcat)
  eza            # modern ls replacement, brand-friendly colors
  fd-find        # fast find (binary is /usr/bin/fdfind)
  ripgrep        # fast grep (binary is /usr/bin/rg)
  ncdu           # interactive du
)

log_info "installing CLI suite (${#CLI_PKGS[@]} pkgs)"
run sudo apt-get -y -qq install --no-install-recommends "${CLI_PKGS[@]}"

# ---- optional extras ------------------------------------------------------
# These are nice-to-have; install one if available, skip silently if not.
# Each install is attempted in isolation so one failure doesn't break the
# stage.

install_optional() {
  local pkg="$1" label="$2"
  if apt-cache show "${pkg}" >/dev/null 2>&1; then
    log_info "installing ${label} (${pkg})"
    if run sudo apt-get -y -qq install --no-install-recommends "${pkg}"; then
      return 0
    else
      log_warn "${pkg} install failed; continuing"
    fi
  fi
  return 1
}

# tldr — try tealdeer (Rust, actively maintained) first, then the old name
if ! install_optional tealdeer "tldr quick-reference (tealdeer)"; then
  install_optional tldr "tldr quick-reference (legacy)" \
    || log_skip "no tldr package available in apt repos"
fi

# lazygit — git TUI, in main on some point releases
install_optional lazygit "git TUI (lazygit)" \
  || log_skip "no lazygit package available in apt repos"

# Prime the tldr cache if a tldr binary ended up on PATH
if command -v tldr >/dev/null 2>&1; then
  log_info "priming tldr cache"
  run tldr --update 2>/dev/null || log_skip "tldr cache update skipped"
fi

log_ok "CLI suite ready"
