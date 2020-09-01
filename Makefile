MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Define make commands that wrap npm scripts to ensure a more consistent workflow across repos
.PHONY: test
test:
	./main.sh
