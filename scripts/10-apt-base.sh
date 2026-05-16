#!/usr/bin/env bash
# Base packages — X11, build tooling, networking, utilities.
set -euo pipefail

# shellcheck source=../lib/colors.sh
source "${DPOS_DIR}/lib/colors.sh"
# shellcheck source=../lib/log.sh
source "${DPOS_DIR}/lib/log.sh"

export DEBIAN_FRONTEND=noninteractive

log_info "apt update"
run sudo apt-get update -qq

log_info "apt upgrade (security + point releases)"
run sudo apt-get -y -qq -o Dpkg::Options::='--force-confdef' \
                          -o Dpkg::Options::='--force-confold' \
  upgrade

readonly BASE_PKGS=(
  ca-certificates curl wget git rsync unzip
  build-essential pkg-config
  xserver-xorg xinit x11-xserver-utils x11-utils
  xserver-xorg-input-libinput xserver-xorg-video-fbdev
  dbus-x11 mesa-utils libgl1-mesa-dri
  network-manager iproute2 iputils-ping
  zip tar less file bash-completion man-db
  htop btop tmux
  jq xz-utils
  fonts-dejavu fonts-dejavu-extra
  policykit-1 acl
  imagemagick librsvg2-bin
)

log_info "installing base packages (${#BASE_PKGS[@]})"
run sudo apt-get -y -qq install --no-install-recommends "${BASE_PKGS[@]}"

log_ok "base ready"
