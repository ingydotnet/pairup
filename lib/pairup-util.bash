#!/bin/bash

export PairUp=.PairUp

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

SECTION() {
  section_command="$1"
  (
    set +x
    cat <<...
###############################################################################
# $section_command
###############################################################################
...
  )
}

run-section-cmd() {
  [ -n "$log" ] ||
    die "Missing 'log' running section command '$section_command'"
  $section_command &>> $log || carp &>> $log &
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

export -f carp
export -f continue?
export -f die
export -f SECTION
export -f run-section-cmd
export -f tests_ok
