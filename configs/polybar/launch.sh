#!/usr/bin/env bash
# dpos / polybar — launch on every i3 start. Kills any running instance
# first so reloads are clean.

set -eu

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# Launch one bar per output. Defaults to primary if no outputs listed.
if command -v xrandr >/dev/null 2>&1; then
  mapfile -t outputs < <(xrandr --query | awk '/ connected/ {print $1}')
fi

if [[ ${#outputs[@]:-0} -eq 0 ]]; then
  outputs=("")
fi

for m in "${outputs[@]}"; do
  MONITOR="${m}" polybar --reload dpos >/tmp/polybar-dpos.log 2>&1 &
done
