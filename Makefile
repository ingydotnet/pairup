.PHONY: test clean purge
test:
	prove -v test/

clean purge:
	rm -fr PairUp
