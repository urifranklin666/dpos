#!/usr/bin/env bash
# GTK 3 / GTK 4 dark theme override using deadplug.digital tokens.
# We override at the user level via gtk.css so we don't depend on a third-
# party theme package that may or may not exist for Trixie-arm64.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

# Base on the Adwaita-dark engine but recolor via user gtk.css.
log_info "installing gtk dark base + papirus icons"
run sudo apt-get -y -qq install --no-install-recommends \
  adwaita-icon-theme gnome-themes-extra qt5ct

mkdir -p "${HOME}/.config/gtk-3.0" "${HOME}/.config/gtk-4.0"

write_gtk_settings() {
  local f="$1"
  backup_path "${f}"
  cat > "${f}" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Adwaita
gtk-font-name=Cascadia Code 10
gtk-button-images=1
gtk-menu-images=1
gtk-enable-animations=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
}
write_gtk_settings "${HOME}/.config/gtk-3.0/settings.ini"
write_gtk_settings "${HOME}/.config/gtk-4.0/settings.ini"

write_gtk_css() {
  local f="$1"
  backup_path "${f}"
  cat > "${f}" <<'EOF'
/* deadplug.digital — gtk override
 * tokens mirror /homepage CSS variables.
 */
@define-color dp_red       #cc0000;
@define-color dp_red_bright #ff2222;
@define-color dp_red_dim   #880000;
@define-color dp_red_deep  #3a0000;
@define-color dp_bg        #060606;
@define-color dp_surface   #0a0a0a;
@define-color dp_surface2  #101010;
@define-color dp_border    #1c0000;
@define-color dp_border_mid #2b0000;
@define-color dp_border_hi  #4a0000;
@define-color dp_text       #dedede;
@define-color dp_text_dim   #606060;
@define-color dp_text_mid   #9a9a9a;

window, dialog, popover, menu, .background {
  background-color: @dp_bg;
  color: @dp_text;
}

headerbar, .titlebar {
  background: linear-gradient(180deg, #0a0a0a, #060606);
  border-bottom: 1px solid @dp_border_mid;
  color: @dp_text;
  min-height: 32px;
}

button {
  background: @dp_surface;
  color: @dp_text;
  border: 1px solid @dp_border_mid;
  border-radius: 0;
  padding: 4px 10px;
}
button:hover {
  background: @dp_surface2;
  border-color: @dp_red;
  color: @dp_red_bright;
}
button:active, button:checked {
  background: @dp_red_deep;
  border-color: @dp_red;
}

entry, textview text {
  background: @dp_surface;
  color: @dp_text;
  border: 1px solid @dp_border_mid;
  border-radius: 0;
  caret-color: @dp_red_bright;
}
entry:focus {
  border-color: @dp_red;
}

selection { background-color: @dp_red_deep; color: @dp_text; }

scrollbar slider {
  background: @dp_red_dim;
  min-width: 6px;
  min-height: 6px;
}
scrollbar slider:hover { background: @dp_red; }

tooltip {
  background: @dp_surface2;
  border: 1px solid @dp_red;
  color: @dp_text;
}

label.title-1, label.title-2, label.title-3 {
  color: @dp_red_bright;
  letter-spacing: 0.02em;
}
EOF
}
write_gtk_css "${HOME}/.config/gtk-3.0/gtk.css"
write_gtk_css "${HOME}/.config/gtk-4.0/gtk.css"

log_ok "gtk theming applied"
