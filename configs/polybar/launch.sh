#!/usr/bin/env bash
# polybar launcher — kills any existing instance and launches one bar per
# connected output. Defensive: never aborts on "nothing to kill"; never
# trips on `set -u`; tolerates missing xrandr; logs to /tmp/polybar-dpos.log
# for postmortems.
#
# Called by i3's `exec --no-startup-id`.

LOGFILE="/tmp/polybar-dpos.log"

# Tear down any existing instances. pkill returns non-zero if nothing
# matched; we don't care.
pkill -x polybar 2>/dev/null || true

# Wait briefly for shutdown — up to 1 second
for _ in 1 2 3 4 5 6 7 8 9 10; do
  pgrep -x polybar >/dev/null 2>&1 || break
  sleep 0.1
done

# Detect connected outputs
outputs=()
if command -v xrandr >/dev/null 2>&1; then
  while IFS= read -r line; do
    [[ -n "${line}" ]] && outputs+=("${line}")
  done < <(xrandr --query 2>/dev/null | awk '/ connected/ {print $1}')
fi

# Fall back to a single anonymous bar if xrandr returned nothing
if [[ ${#outputs[@]} -eq 0 ]]; then
  outputs=("")
fi

: > "${LOGFILE}"
for m in "${outputs[@]}"; do
  MONITOR="${m}" polybar --reload dpos >>"${LOGFILE}" 2>&1 &
done

disown -a 2>/dev/null || true
