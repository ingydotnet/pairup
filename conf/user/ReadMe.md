# User Settings

This directory contains folders for all the pairup programmers. Directory name
should be your typical unix login (not your github account (unless its the
same)).

Typical contents are:

* `conf...              - Your `...` conf. See http://github.com/sharpsaw/.../
* `cpan`                - List of CPAN modules to cpanm install
* `debian`              - List of debian pkgs to apt-get install
* `install`             - Bash script to do any custom installation
* `github`              - List of GitHub repos to clone
* `known_hosts`         - Preset ssh knownhosts, to avoid prompting
* `authorized_keys`     - Your public ssh key(s) for joining the PairUp VPS.
                          Typically this can be retrieved from GitHub, at
                          https://api.github.com/users/<your-github-id>/keys
                          but you can override that here.

Most of those files are snippets that are concatenated with your pair
programmers snippets and the default PairUp snippets found in the ../conf/
directory.

If you have private stuff to not publish on github, put it under the ./private/
directory using the same names. Thhe private directory gets merged in if it
exists.
