#!/usr/bin/env bash

# die() { echo "$1" >&2; exit 1; }

PAIRUP_ROOT="$PWD"
PAIRUP_TEST_RUN=1

ok=0
for bash in bin/* lib/* share/script/*; do
  [ -f "$bash" ] || continue
  (source "$bash") && rc=true || rc=false
  if $rc; then
    echo "ok $((++i)) - source $bash"
  else
    echo "not ok $((++i)) - source $bash"
    ok=1
  fi

  if [[ "$bash" =~ ^bin ]]; then
    if [ -x $bash ]; then
      echo "ok $((++i)) - $bash is executable"
    else
      echo "not ok $((++i)) - $bash is executable"
      ok=1
    fi
  fi
done

echo "1..$i"

exit $ok

# vim: set ft=sh:
