.PHONY: server test clean purge

ifeq (server,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

server:
	./bin/pairup-setup-server $(RUN_ARGS)

test:
	prove -v test/

clean purge:
	rm -fr PairUp
