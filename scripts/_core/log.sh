#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2
}

_export_colors() {
  if ! ${DOT_COLORS_EXPORTED:-false}; then
    if [[ -z "${TERM:-}" || "${TERM:-}" == "dumb" ]]; then
      bold=""
      underline=""
      freset=""
      purple=""
      red=""
      green=""
      tan=""
      blue=""
    else
      bold=$(tput bold)
      underline=$(tput sgr 0 1)
      freset=$(tput sgr0)
      purple=$(tput setaf 171)
      red=$(tput setaf 1)
      green=$(tput setaf 76)
      tan=$(tput setaf 3)
      blue=$(tput setaf 38)
    fi

    readonly DOT_COLORS_EXPORTED=true
  fi
}

if [ -z ${LOG_FILE+x} ]; then
  readonly LOG_FILE="/tmp/$(basename "$0").log"
fi

_log() {
  local template=$1
  shift
  if ${log_to_file:-false}; then
    echoerr -e "$(printf "$template" "$@")" | tee -a "$LOG_FILE" >&2
  else
    echoerr -e "$(printf "$template" "$@")"
  fi
}

_header() {
  local TOTAL_CHARS=60
  local total=$(( TOTAL_CHARS - 2 ))
  local size=${#1}
  local left=$((($total - $size) / 2))
  local right=$(($total - $size - $left))
  printf "%${left}s" '' | tr ' ' =
  printf " %s " "$1"
  printf "%${right}s" '' | tr ' ' =
}

log::header() { _export_colors && _log "\n${bold}${purple}%s${freset}\n" "$(_header "$1")"; }
log::success() { _export_colors && _log "${green}✔ %s${freset}\n" "$@"; }
log::error() { _export_colors && _log "${red}✖ %s${freset}\n" "$@"; }
log::warning() { _export_colors && _log "${tan}➜ %s${freset}\n" "$@"; }
log::note() { _export_colors && _log "${blue}%s${freset}\n" "$@"; }