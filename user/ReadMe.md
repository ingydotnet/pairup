# User Settings

This directory contains folders for all the pairup programmers. Directory name
should be your typical unix login (not your github account (unless its the
same)).

Typical contents are:

* `id_rsa.pub`          - Your public ssh key for joining the PairUp VPS
* `meta`                - Any contact info you want to share
* `conf...              - Your `...` conf. See http://github.com/sharpsaw/.../
* `pre-install`         - Bash script to apt-get install, etc.
* `post-install`        - Bash script run after initial setup.
* `known_hosts`         - Preset ssh knownhosts, to avoid prompting

Most of those files are snippets that are concatenated with your pair
programmers snippets and the default PairUp snippets found in the ../conf/
directory.

If you have private stuff to not publish on github, put it under the ./private/
directory using the same names. Thhe private directory gets merged in if it
exists.
