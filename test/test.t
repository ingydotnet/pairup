#!/bin/bash

die() { echo "$1" >&2; exit 42; }

ok=0
while read -r bash; do
  (
    PairUp=./
    PATH="./bin:$PATH" source "$bash"
  ) && rc=true || rc=false
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
done <<...
bin/add-pairup-user
bin/del-pairup-user
bin/install-pairup-repos
bin/helper-pairup-functions
bin/install-pairup-cpan
bin/install-pairup-software
bin/invite-pairup-user
bin/pairup
bin/pairup-info
bin/setup-pairup-server
template/admin-setup
template/root-setup
...

echo "1..$i"

exit $ok

# vim: set ft=sh:
