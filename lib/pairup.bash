#!/usr/bin/env bash

set -e

export LocalPairUp=.PairUp
export RemotePairUp=/usr/local/share/PairUp
export TempPairUp=/tmp/PairUp

RUN() {
  local cmd="${1:? RUN <command> required}"; shift
  local Title="$title" Sudo="$sudo" Log="$log"
  title= sudo= log=
  local check= PATH="$RemotePairUp/sbin:$PATH"
  if [[ "$cmd" =~ ^check:(.*) ]]; then
    cmd="${BASH_REMATCH[1]}"
    check="check-$cmd"
  fi
  if [ -n "$Title" ] && [ -z "$check" ]; then
    TITLE "$Title"
  fi
  local SUDO=
  if [ -n "$Sudo" ]; then
    SUDO="sudo -E"
    if [[ ! "$cmd" =~ / ]] && [ -e "$RemotePairUp/sbin/$cmd" ]; then
      cmd="$RemotePairUp/sbin/$cmd"
    fi
  fi
  if [ -n "$check" ]; then
    while ! "$check" "$@"; do
      sleep 10
    done
    title="$Title" sudo="$Sudo" log="$Log" RUN "$cmd" "$@"
    return
  fi
  if [ -n "$Log" ]; then
    $SUDO "$cmd" "$@" 2>&1 >> "$(LOG $Log $cmd)"
  else
    $SUDO "$cmd" "$@"
  fi
}

LOG() {
  local log="${1:??}" default="$2"
  if [ "$log" == true ]; then
    log="${default##*/}"
  fi
  if [[ ! "$log" =~ / ]]; then
    log="$RemotePairUp/log/$log.log"
  fi
  mkdir -p "$(dirname $log)"
  echo "$log"
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

prompt_continue() {
  (
    set +x
    echo -n "Error. ctl-c to exit. Enter to continue."
    read
  )
}

export -f RUN
export -f LOG
export -f TITLE
export -f tests_ok
export -f die
export -f carp
export -f prompt_continue
