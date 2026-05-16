#!/usr/bin/env bash
# dpos / motd — login banner.
# Prints: ANSI logo (if present), one-line system status, one rotating burn.

set -u

LOGO="/usr/local/share/dpos/logo.ans"
BURNS="/usr/local/share/dpos/burns.txt"

RED=$'\033[38;5;160m'
RED_BR=$'\033[38;5;196m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
GREY=$'\033[38;5;240m'
RESET=$'\033[0m'

if [[ -r "${LOGO}" ]]; then
  printf '%s' "${RED}"
  cat "${LOGO}"
  printf '%s' "${RESET}"
fi

hn="$(hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || echo pi)"
ker="$(uname -r 2>/dev/null)"
arch="$(uname -m 2>/dev/null)"
upt="$(uptime -p 2>/dev/null | sed 's/^up //')"
load="$(awk '{print $1, $2, $3}' /proc/loadavg 2>/dev/null)"
mem_used=$(awk '/MemAvailable:/ {avail=$2} /MemTotal:/ {tot=$2} END {printf "%d/%dMB", (tot-avail)/1024, tot/1024}' /proc/meminfo 2>/dev/null)
disk_used=$(df -h --output=used,size / 2>/dev/null | awk 'NR==2 {print $1"/"$2}')
ip_addr=$(hostname -I 2>/dev/null | awk '{print $1}')
[[ -z "${ip_addr}" ]] && ip_addr="(offline)"

if command -v vcgencmd >/dev/null 2>&1; then
  temp="$(vcgencmd measure_temp 2>/dev/null | sed 's/temp=//;s/.C.*//')"
else
  temp="$(awk '{printf "%.1f", $1/1000}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null)"
fi
[[ -z "${temp}" ]] && temp="n/a"

printf '\n%s%s// %sdpos%s @ %s  %s%s%s\n' \
  "${RED}" "${BOLD}" "${RED_BR}" "${RED}${BOLD}" "${hn}" "${DIM}" "${ker} ${arch}" "${RESET}"

printf '%s──────────────────────────────────────────────%s\n' "${RED}" "${RESET}"
printf '  %sup%s    %s\n'      "${RED}" "${RESET}" "${upt:-?}"
printf '  %sload%s  %s\n'      "${RED}" "${RESET}" "${load:-?}"
printf '  %smem%s   %s\n'      "${RED}" "${RESET}" "${mem_used:-?}"
printf '  %sdisk%s  %s\n'      "${RED}" "${RESET}" "${disk_used:-?}"
printf '  %sip%s    %s\n'      "${RED}" "${RESET}" "${ip_addr}"
printf '  %stemp%s  %sC\n'     "${RED}" "${RESET}" "${temp}"
printf '%s──────────────────────────────────────────────%s\n' "${RED}" "${RESET}"

if [[ -r "${BURNS}" ]]; then
  total=$(wc -l <"${BURNS}")
  if [[ "${total}" -gt 0 ]]; then
    seed=$(($(date +%s) / 60))   # rotate roughly every minute
    pick=$(( (seed % total) + 1 ))
    line="$(sed -n "${pick}p" "${BURNS}")"
    if [[ -n "${line}" ]]; then
      printf '  %s%s// %s%s\n' "${GREY}" "${DIM}" "${line}" "${RESET}"
    fi
  fi
fi

printf '\n'
