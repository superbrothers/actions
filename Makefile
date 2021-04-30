SHELLCHECK ?= docker run --rm -v "$${PWD}:/mnt" -w /mnt docker.io/koalaman/shellcheck:stable

.PHONY: lint
lint:
	$(SHELLCHECK) -x *.sh **/*.sh
