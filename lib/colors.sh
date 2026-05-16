# ANSI escapes used by the dpos installer. red, dim, bold, reset.
# guarded so the file is safe to source twice.

if [[ -n "${_DPOS_COLORS_LOADED:-}" ]]; then return 0; fi
_DPOS_COLORS_LOADED=1

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[38;5;160m'
  C_RED_BRIGHT=$'\033[38;5;196m'
  C_RED_DIM=$'\033[38;5;88m'
  C_GREEN=$'\033[38;5;34m'
  C_AMBER=$'\033[38;5;214m'
  C_WHITE=$'\033[38;5;255m'
  C_GREY=$'\033[38;5;240m'
else
  C_RESET= C_BOLD= C_DIM=
  C_RED= C_RED_BRIGHT= C_RED_DIM=
  C_GREEN= C_AMBER= C_WHITE= C_GREY=
fi

export C_RESET C_BOLD C_DIM C_RED C_RED_BRIGHT C_RED_DIM C_GREEN C_AMBER C_WHITE C_GREY
