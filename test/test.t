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
bin/pairup
bin/pairup-add-user
bin/pairup-create-hp
bin/pairup-del-user
bin/pairup-info
bin/pairup-install-cpan
bin/pairup-install-repos
bin/pairup-install-software
bin/pairup-invite-user
bin/pairup-server-setup
lib/bashmore.bash
lib/pairup-util.bash
share/bin/admin-setup
share/bin/root-setup
...

echo "1..$i"

exit $ok

# vim: set ft=sh:
