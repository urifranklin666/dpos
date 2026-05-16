#!/usr/bin/env bash
# Fonts: mono stack (Fira Code, Cascadia Code) + serif (DejaVu, already in
# base) + Nerd Font icons (Symbols-Only Nerd Font, light footprint).
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

readonly FONT_PKGS=(
  fonts-firacode
  fonts-cascadia-code
  fonts-jetbrains-mono
  fonts-noto-core
  fonts-noto-color-emoji
  fonts-font-awesome
)

log_info "installing font packages"
run sudo apt-get -y -qq install --no-install-recommends "${FONT_PKGS[@]}"

# Symbols Nerd Font for polybar / status glyphs without dragging in a
# full Nerd-patched font set.
nf_dir="${HOME}/.local/share/fonts/NerdFonts"
nf_marker="${nf_dir}/.dpos-installed"
if [[ ! -f "${nf_marker}" ]]; then
  log_info "fetching Symbols-Only Nerd Font"
  mkdir -p "${nf_dir}"
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' RETURN
  url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip"
  if run curl -fsSL --max-time 60 -o "${tmp}/symbols.zip" "${url}" \
       && run unzip -q -o "${tmp}/symbols.zip" -d "${nf_dir}"; then
    touch "${nf_marker}"
    log_ok "Symbols Nerd Font installed"
  else
    log_warn "could not fetch Symbols Nerd Font; polybar glyphs may show as boxes"
  fi
fi

run fc-cache -f >/dev/null 2>&1 || true
log_ok "font cache rebuilt"
