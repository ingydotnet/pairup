#!/usr/bin/env bash

set -e

export PairUp=.PairUp

RUN() {
  if [ -z "$cmd" ]; then
    local cmd="${PAIRUP_ROOT:??}/sbin/${1:?command required}"
    shift
  fi
  [ -z "$title" ] || TITLE "$title"
  [ -z "$sudo" ] || local sudo='sudo -E'
  if [ -n "$log" ]; then
    mkdir -p "$(dirname $log)"
    $sudo "$cmd" "$@" &>> "$log"
  else
    $sudo "$cmd" "$@"
  fi
}

TITLE() {
  (
    set +x
    cat <<...
###############################################################################
# $1
###############################################################################
...
  )
}

tests_ok() {
  local path="$BASH_SOURCE"
  [[ "$path" =~ ^bin/ ]] && path="./$path"
  (
    set +e
    cd "${path%/bin/*}"
    make test &> /dev/null
  ) || return 1
  return 0
}

die() { set +x; echo "$@" >&2; exit 1; }

carp() {
  local rc=$? cmd="${1:-section_command}"
  (
    set +x
    cat <<... >&2
${1:-$section_command} failed (status: $?):
PATH=$PATH
SSH_AUTH_SOCK=$SSH_AUTH_SOCK
user: `whoami`
cwd: `pwd`
...
# ~/.ssh/known_hosts:
# ...
#     cat ~/.ssh/known_hosts >&2
  )
  true
}

continue?() {
  (
    set +x
    echo -n "Error. ctl-c to exit. Enter to continue."
    read
  )
}

export -f RUN
export -f TITLE
export -f tests_ok
export -f die
export -f carp
export -f continue?
