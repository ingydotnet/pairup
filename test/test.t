#!/bin/bash

die() { echo "$1" >&2; exit 42; }

while read -r bash; do
  (
    PairUp=./
    PATH="./bin:$PATH" source "$bash"
  ) || die "Error in '$bash'"
  echo "ok $((++i)) - source $bash"
done <<...
bin/add-pairup-user
bin/del-pairup-user
bin/install-pairup-repos
bin/helper-pairup-functions
bin/install-pairup-cpan
bin/install-pairup-software
bin/pairup
bin/setup-pairup-server
template/admin-setup
template/root-setup
...

echo "1..$i"

# vim: set ft=sh:
