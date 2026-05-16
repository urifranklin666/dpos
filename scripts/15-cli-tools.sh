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
  fzf            # fuzzy finder — the engine for the dpos launcher
  bat            # syntax-highlighted cat (binary is /usr/bin/batcat)
  eza            # modern ls replacement, brand-friendly colors
  fd-find        # fast find (binary is /usr/bin/fdfind)
  ripgrep        # fast grep (binary is /usr/bin/rg)
  ncdu           # interactive du
  tldr           # quick man-page summaries
)

log_info "installing CLI suite (${#CLI_PKGS[@]} pkgs)"
run sudo apt-get -y -qq install --no-install-recommends "${CLI_PKGS[@]}"

# lazygit is optional — not always in main, varies by point release
if apt-cache show lazygit >/dev/null 2>&1; then
  log_info "installing lazygit (git TUI)"
  run sudo apt-get -y -qq install --no-install-recommends lazygit \
    || log_warn "lazygit install failed; continuing"
else
  log_skip "lazygit not available in apt repos"
fi

# Prime the tldr cache so the first invocation isn't a download
if command -v tldr >/dev/null 2>&1; then
  log_info "priming tldr cache (background)"
  run sudo -u "${USER}" tldr --update 2>/dev/null \
    || tldr --update 2>/dev/null \
    || log_skip "tldr cache update skipped"
fi

log_ok "CLI suite ready"
