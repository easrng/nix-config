.PHONY: rebuild fmt all
all: fmt rebuild
rebuild:
	./scripts/rebuild
fmt:
	find -name '*.nix' -exec nixfmt {} \;
	jq sort packages.json | sponge packages.json
