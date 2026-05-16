# Hardware / OS / network preflight helpers.

if [[ -n "${_DPOS_CHECK_LOADED:-}" ]]; then return 0; fi
_DPOS_CHECK_LOADED=1

# Returns 0 if we are on a Raspberry Pi 4 (any RAM variant), 1 otherwise.
is_pi4() {
  local model=""
  if [[ -r /proc/device-tree/model ]]; then
    model="$(tr -d '\0' </proc/device-tree/model)"
  fi
  [[ "${model}" == *"Raspberry Pi 4"* ]]
}

# Returns 0 if we are running a 64-bit OS.
is_arm64() {
  [[ "$(uname -m)" == "aarch64" ]]
}

# Returns 0 if OS is Debian/Raspbian Bookworm or later (Trixie is current).
is_supported_os() {
  local id="" codename=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-}${ID_LIKE:+:${ID_LIKE}}"
    codename="${VERSION_CODENAME:-}"
  fi
  [[ "${id}" == *debian* || "${id}" == *raspbian* ]] || return 1
  case "${codename}" in
    bookworm|trixie|sid) return 0 ;;
    *) return 1 ;;
  esac
}

have_internet() {
  curl -fsS --max-time 5 https://deb.debian.org/ >/dev/null 2>&1 \
    || curl -fsS --max-time 5 https://archive.raspberrypi.org/ >/dev/null 2>&1
}

# Minimum free disk space on / for the install, in MB.
free_disk_mb() {
  df -Pm / | awk 'NR==2 {print $4}'
}

total_ram_mb() {
  awk '/^MemTotal:/ {printf "%d", $2/1024}' /proc/meminfo
}

# Returns the GPU memory line from config.txt if set, else empty.
current_gpu_mem() {
  local f="/boot/firmware/config.txt"
  [[ -r "${f}" ]] || f="/boot/config.txt"
  [[ -r "${f}" ]] || return 0
  awk -F= '/^[[:space:]]*gpu_mem[[:space:]]*=/ {print $2; exit}' "${f}"
}

config_txt_path() {
  if [[ -w /boot/firmware/config.txt ]]; then
    printf '%s' "/boot/firmware/config.txt"
  elif [[ -w /boot/config.txt ]]; then
    printf '%s' "/boot/config.txt"
  else
    printf '%s' ""
  fi
}
