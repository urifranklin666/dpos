#!/usr/bin/env bash
# zsh with a small native prompt and brand-flavored aliases.
# No oh-my-zsh. We don't need a framework to render a prompt.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

log_info "installing zsh"
run sudo apt-get -y -qq install --no-install-recommends zsh

backup_path "${HOME}/.zshrc"
cp "${DPOS_DIR}/configs/zsh/zshrc" "${HOME}/.zshrc"
log_ok "deployed ~/.zshrc"

# Aliases live in their own file so it's easy to override
backup_path "${HOME}/.zsh_aliases"
cp "${DPOS_DIR}/configs/zsh/aliases" "${HOME}/.zsh_aliases"
log_ok "deployed ~/.zsh_aliases"

# Bash gets the same aliases so non-zsh shells still feel branded
if [[ -f "${HOME}/.bashrc" ]] && ! grep -q "dpos/configs/bash" "${HOME}/.bashrc"; then
  cat >> "${HOME}/.bashrc" <<'EOF'

# dpos: load brand aliases in bash too
[ -f "$HOME/.zsh_aliases" ] && . "$HOME/.zsh_aliases"
EOF
  log_ok "appended alias loader to ~/.bashrc"
fi

# Change default shell only if currently bash
current_shell="$(getent passwd "$USER" | cut -d: -f7 || echo "")"
zsh_path="$(command -v zsh)"
if [[ -n "${zsh_path}" && "${current_shell}" != "${zsh_path}" ]]; then
  log_info "default shell is ${current_shell}, switching to ${zsh_path}"
  if run sudo chsh -s "${zsh_path}" "$USER"; then
    log_ok "default shell is now zsh (takes effect at next login)"
  else
    log_warn "could not change default shell; run: chsh -s ${zsh_path}"
  fi
else
  log_ok "default shell already zsh"
fi
