#!/usr/bin/env bash

set -e

export PairUp=.PairUp

RUN() {
  local Cmd="$cmd" Title="$title" Sudo="$sudo" Log="$log"
  cmd= title= sudo= log=
  if [ -z "$Cmd" ]; then
    Cmd="${PAIRUP_ROOT:??}/sbin/${1:?command required}"
    shift
  fi
  [ -z "$Title" ] || TITLE "$Title"
  [ -z "$Sudo" ] || local Sudo='sudo -E'
  if [ -n "$Log" ]; then
    mkdir -p "$(dirname $Log)"
    $Sudo "$Cmd" "$@" &>> "$Log"
  else
    $Sudo "$Cmd" "$@"
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
