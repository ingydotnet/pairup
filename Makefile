ifeq (server,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

default:
	@grep -E '^\w+:' Makefile

doc: ReadMe.pod

ReadMe.pod: doc/PairUp.swim
	swim --to=pod --complete --wrap $< > $@

server:
	./bin/pairup-setup-server $(RUN_ARGS)

.PHONY: test
test:
	prove -v test/

clean purge:
	rm -fr .PairUp
