#!/usr/bin/env bash
# Eye candy: cmatrix, pipes.sh, fastfetch with deadplug ASCII,
# fortune-mod with our cookie file, plus wiring for startx-on-tty1
# autologin.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

readonly EYE_PKGS=(
  cmatrix
  pipes.sh
  fortune-mod fortunes-min
  figlet toilet
  fastfetch
  cowsay
  bsdmainutils
)

log_info "installing eye-candy CLI tools"
run sudo apt-get -y -qq install --no-install-recommends "${EYE_PKGS[@]}" || \
  log_warn "some optional eye-candy packages may not be available; continuing"

# ---- custom fortune file ---------------------------------------------------
fortunes_src="${DPOS_DIR}/assets/fortunes/deadplug"
fortunes_dst="/usr/local/share/games/fortunes"
if [[ -f "${fortunes_src}" ]] && command -v strfile >/dev/null 2>&1; then
  log_info "installing deadplug fortune file"
  run sudo mkdir -p "${fortunes_dst}"
  run sudo install -m 0644 "${fortunes_src}" "${fortunes_dst}/deadplug"
  run sudo strfile -r -s "${fortunes_dst}/deadplug" "${fortunes_dst}/deadplug.dat"
  log_ok "fortune cookies indexed"
fi

# ---- fastfetch config ----------------------------------------------------
# fastfetch is the actively-maintained neofetch successor; ships in Trixie.
# Config is JSONC (JSON with comments).
mkdir -p "${HOME}/.config/fastfetch"
backup_path "${HOME}/.config/fastfetch/config.jsonc"
cp "${DPOS_DIR}/configs/fastfetch/config.jsonc" "${HOME}/.config/fastfetch/config.jsonc"
log_ok "fastfetch configured"

# ---- xinitrc: start i3 ----------------------------------------------------
backup_path "${HOME}/.xinitrc"
cat > "${HOME}/.xinitrc" <<'EOF'
#!/bin/sh
# dpos: launch i3 from `startx`
xrdb -merge ~/.Xresources 2>/dev/null || true
xset s off -dpms       # don't blank/sleep — your call to flip back
xset r rate 250 35     # faster key repeat
exec i3
EOF
chmod +x "${HOME}/.xinitrc"
log_ok "deployed ~/.xinitrc"

# ---- Xresources (Alacritty already reads alacritty.toml, but X apps care) -
backup_path "${HOME}/.Xresources"
cat > "${HOME}/.Xresources" <<'EOF'
! dpos — minimal Xresources
Xft.dpi:        96
Xft.antialias:  1
Xft.hinting:    1
Xft.hintstyle:  hintslight
Xft.rgba:       rgb
Xft.lcdfilter:  lcddefault
Xcursor.theme:  Adwaita
Xcursor.size:   16
EOF
log_ok "deployed ~/.Xresources"

# ---- zlogin / .bash_profile: auto-startx on tty1 ---------------------------
profile_block='
# dpos: auto-startx on tty1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && command -v startx >/dev/null 2>&1; then
  exec startx
fi
'
for rcfile in "${HOME}/.zlogin" "${HOME}/.bash_profile"; do
  touch "${rcfile}"
  # Self-heal: prior installs may have included `-- -nocursor` which makes
  # the mouse cursor invisible in i3. Strip it if present.
  if grep -q 'exec startx -- -nocursor' "${rcfile}"; then
    sed -i 's|exec startx -- -nocursor|exec startx|' "${rcfile}"
    log_ok "removed stale -nocursor from $(basename "${rcfile}")"
  fi
  if ! grep -q "dpos: auto-startx" "${rcfile}"; then
    printf '%s\n' "${profile_block}" >> "${rcfile}"
    log_ok "wired startx into $(basename "${rcfile}")"
  else
    log_skip "startx already wired in $(basename "${rcfile}")"
  fi
done

# ---- autologin tty1 (optional, asks first) --------------------------------
override_dir="/etc/systemd/system/getty@tty1.service.d"
override_file="${override_dir}/dpos-autologin.conf"
if [[ ! -f "${override_file}" ]]; then
  if [[ "${DPOS_YES:-0}" -eq 1 ]] || \
     { read -r -p "$(printf '%b' "${C_DIM}  enable autologin on tty1 (drops you straight into i3 on boot)? [y/N] ${C_RESET}")" reply && \
       [[ "${reply}" =~ ^[Yy] ]]; }; then
    run sudo mkdir -p "${override_dir}"
    sudo tee "${override_file}" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${USER} --noclear %I \$TERM
EOF
    run sudo systemctl daemon-reload
    log_ok "autologin enabled for ${USER} on tty1"
  else
    log_skip "autologin tty1 (you can run this script with --only 70 later)"
  fi
fi

log_ok "eye candy wired"
