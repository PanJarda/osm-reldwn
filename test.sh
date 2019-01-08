#!/bin/sh
#
# Test for reldwn.sh
# ==================
#

# does not work when executing this script via symlink
dir=$(cd -- "$(dirname -- "$0")" && pwd)

. "$dir/reldwn.sh"

apiurl="file://$dir/test/apimock"

_testdwn() {
	if ! "dwn$1" "$2" > /dev/null; then
		printf 'Failed to download %s %s\n' "$1" "$2"
		return 1
	fi
	return 0
}

_test() {
	exitcode=0

	# Download relation
	if ! _testdwn 'relation' '434744'; then
		exitcode=3
	fi

	# Download way
	if ! _testdwn 'way' '181859936'; then
		exitcode=3
	fi

	# Download node
	if ! _testdwn 'node' '1922271902'; then
		exitcode=3
	fi

	# Parse relation and waylist
	if ! parserelation < "$dir/test/relation.xml" \
	   | diff "$dir/test/waylist.txt" -; then
		printf 'Failed to parse relation to waylist\n'
		exitcode=3
	fi

	# Parse way to nodelist
	if ! parseway < "$dir/test/way.xml" \
	   | diff "$dir/test/nodelist.txt" -; then
		printf 'Failed to parse way to nodelist\n'
		exitcode=3
	fi

	# Parse node to coordinate
	if ! parsenode < "$dir/test/node.xml" \
	   | diff "$dir/test/coordinate.txt" -; then
		printf 'Failed to parse node to coordinate\n'
		exitcode=3
	fi

	# Process nodelist to list of coordinates
	if ! processnodelist < "$dir/test/nodelist.txt" \
	   | diff "$dir/test/coordlist.txt" -; then
		printf "Failed to process nodelist \
to list of coordinates\n"
		exitcode=3
	fi

	# Process waylist to list of coordinates
	if ! processwaylist < "$dir/test/waylist.txt" \
	   | diff "$dir/test/out.txt" -; then
		printf "Failed to process waylist \
to list of coordinates\n"
		exitcode=3
	fi

	return "$exitcode"
}

while getopts 'd' opt; do
	case $opt in
		d) set -x;; # debug mode: print every statement to console
		\?) exit;;
	esac
done

_test
