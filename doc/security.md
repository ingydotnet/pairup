## Security

To do PairUp effectively, you will want the config files with the private info
need to run the software you like. You will almost certainly want to forward
SSH. The point is that if your pair is malicious they can probably get some of
your credentials. Pair with people you know and trust and that you would have
no problem letting them use your laptop while you went to the bathroom.

A few possible known threats/leaks:

    - SSH_AUTH_SOCK             - Pair can SSH anywhere you can
    - ~/.git-hub/config         - GitHub auth token
    - ~/.pause                  - CPAN password
