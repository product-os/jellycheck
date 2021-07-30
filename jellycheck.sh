#!/bin/bash

###
# Copyright (C) Balena.io - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
###

set -e

# Check for files in lib/ that shouldn't be there
if [ -d "lib" ]; then
	HTML="$(find lib -name '*.html')"

	if [ -n "$HTML" ]; then
		echo "There can not be HTML files in lib/" 1>&2
		echo "All deployable components should live in apps" 1>&2
		echo "" 1>&2
		echo "$HTML" 1>&2
		exit 1
	fi

	WEBPACK="$(find lib -name '*webpack*.js*')"

	if [ -n "$WEBPACK" ]; then
		echo "There can not be webpack configuration files in lib/" 1>&2
		echo "All deployable components should live in apps" 1>&2
		echo "" 1>&2
		echo "$WEBPACK" 1>&2
		exit 1
	fi

	DOCKERFILE="$(find lib -name '*Dockerfile*')"

	if [ -n "$DOCKERFILE" ]; then
		echo "There can not be Dockefiles in lib/" 1>&2
		echo "All deployable components should live in apps" 1>&2
		echo "" 1>&2
		echo "$DOCKERFILE" 1>&2
		exit 1
	fi
fi

# Check filenames
DIRECTORIES=("lib" "scripts" "test")
for directory in "${DIRECTORIES[@]}"; do
	if [[ "$1" == "--ui-lib" && ("$directory" == "lib" || "$directory" == "test") ]]; then
		continue
	fi
	if [ -d "$directory" ]; then
		for file in $(find "$directory" -type f | grep -v -E node_modules); do
			BASENAME="$(basename "$file")"

			# Known exceptions
			if [ "$directory" == "test" ] && [ "$BASENAME" = "Dockerfile" ]; then
				continue
			fi
			if [ "$BASENAME" = "LICENSE" ] || [ "$BASENAME" = "README.md" ]; then
				continue
			fi

			# Everything that is all lowercase is fine
			if ! [[ $file =~ [A-Z] ]]; then
				continue
			fi

			echo "This file should not have capital letters:" 1>&2
			echo "" 1>&2
			echo "$file" 1>&2
			exit 1
		done
	fi
done

# Check license header
LICENSE_JS="/*
 * Copyright (C) Balena.io - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 */"

LICENSE_SHEBANG_JS="#!/usr/bin/env node

/*
 * Copyright (C) Balena.io - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 */"

LICENSE_SH="###
# Copyright (C) Balena.io - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
###"

JAVASCRIPT_FILES="$(find . \( -name '*.js' \) \
	-and -not -path './*node_modules/*' \
	-and -not -path './build/*' \
	-and -not -path './.out/*' \
	-and -not -path './docs/*' \
	-and -not -path './.tmp/*')"

SHELL_FILES="$(find . -name '*.sh' \
	-and -not -path './*node_modules/*' \
	-and -not -path './build/*' \
	-and -not -path './.out/*' \
	-and -not -path '**/dist/*' \
	-and -not -path '**/.libs/*' \
	-and -not -path './.git/*' \
	-and -not -path './.husky/*' \
	-and -not -path './.tmp/*')"

for file in $JAVASCRIPT_FILES; do
	if [ "$(head -n 5 "$file")" != "$LICENSE_JS" ] && \
		[ "$(head -n 7 "$file")" != "$LICENSE_SHEBANG_JS" ]; then
		echo "Invalid license header: $file" 1>&2
		echo "Should be:" 1>&2
		echo "" 1>&2
		echo "$LICENSE_JS" 1>&2
		echo "" 1>&2
		echo "Or:" 1>&2
		echo "" 1>&2
		echo "$LICENSE_SHEBANG_JS" 1>&2
		exit 1
	fi
done

for file in $SHELL_FILES; do
	if [ "$(head -n 7 "$file" | tail -n 5)" != "$LICENSE_SH" ]; then
		echo "Invalid license header: $file" 1>&2
		echo "Should be:" 1>&2
		echo "" 1>&2
		echo "$LICENSE_SH" 1>&2
		exit 1
	fi
done
