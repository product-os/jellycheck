#!/bin/bash

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
