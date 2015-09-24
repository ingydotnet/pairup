#!/usr/bin/env bash

set -e

export LocalPairUp=.PairUp
export RemotePairUp=/usr/local/share/PairUp
export TempPairUp=/tmp/PairUp

# Use the rsa public key under ./user/$unix_user/authorized_keys or attempt to
# get one from GitHub, or error out:
assert-public-key() {
  if [ -e "$LocalPairUp" ]; then
    local PairUp="$LocalPairUp"
  elif [ -e "$TempPairUp" ]; then
    local PairUp="$TempPairUp"
  elif [ -e "$RemotePairUp" ]; then
    local PairUp="$RemotePairUp"
  else
    die "Can't find $LocalPairUp or $TempPairUp or $RemotePairUp"
  fi

  local unix_user= github_user=
  if [[ "$user" =~ : ]]; then
    unix_user="${user%:*}"
    github_user="${user#*:}"
  else
    unix_user="$user"
  fi
  if [ -z "$github_user" ]; then
    github_user="$(
      grep -Esh "^$unix_user:" $PairUp/conf/github-users* |
      head -n1 | cut -d: -f2
    )"
    github_user="${github_user:-$unix_user}"
  fi
  local keys=$(
    curl --silent "https://api.github.com/users/$github_user/keys"
  )
  local rsa_keys=$(
    echo "$keys" |
    grep -E '^    "key": "ssh-rsa' |
    cut -d'"' -f4
  )
  local dsa_keys=$(
    echo "$keys" |
    grep -E '^    "key": "ssh-dss' |
    cut -d'"' -f4
  )
  if [ -n "$rsa_keys" ]; then
    echo "$rsa_keys" > "$PairUp/keys/$unix_user/authorized_keys"
  fi
  if [ -n "$dsa_keys" ]; then
    echo "$dsa_keys" > "$PairUp/keys/$unix_user/authorized_keys2"
  fi
  if [ -e "$PairUp/user/$unix_user/authorized_keys" ]; then
    cat "$PairUp/user/$unix_user/authorized_keys" >> \
      "$PairUp/keys/$unix_user/authorized_keys"
  fi
  if [ -e "$PairUp/user/$unix_user/authorized_keys2" ]; then
    cat "$PairUp/user/$unix_user/authorized_keys2" >> \
      "$PairUp/keys/$unix_user/authorized_keys2"
  fi
  [ -s "$PairUp/keys/$unix_user/authorized_keys" ] ||
  [ -s "$PairUp/keys/$unix_user/authorized_keys2" ] ||
    die "Can't find a public key for user '$unix_user:$github_user'"
  :
}

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
