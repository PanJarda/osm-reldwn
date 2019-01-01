#!/bin/sh
#
# reldwn.sh
# =========	
# 
# Downloads relations from openstreetmap.org api.
#
# usage:   reldwn.sh <rel_id>
# example: reldwn.sh 442084
#
# options:
#  -v    version
#  -d    debug mode: print every statement

# shell options:
set -e  # exit when unguarded statement evaluates to a false value
set -u  # exit when undefined variable is referenced

# constants
version='20190101'
sleep=0       # delay between api calls

# global variables
apiurl='https://www.openstreetmap.org/api/0.6'

dwn() {
	curl "$apiurl/$1/$2" -s
}

dwnnode() {
	dwn 'node' "$1"
}

dwnway() {
	dwn 'way' "$1"
}

dwnrelation() {
	dwn 'relation' "$1"
}

parsenode() {
	awk 'BEGIN {
		RS = "<"
		FS = "\""
	}
	/lon="/ {
		lonp = match($0,/lon="/)
		lon = substr($0, lonp + 5, 10)
		latp = match($0, /lat="/)
		lat = substr($0, latp + 5, 10)
		print lat" "lon
	}'
}

parseway() {
	awk 'BEGIN {
		RS = "<"
		FS = "\""
	}
	/^nd ref="/ {
		print $2
	}'
}

parserelation() {
	awk 'BEGIN {
		RS = "<"
		FS = " "
	}
	/type="way"/ {
		match($0, /"[0-9]+"/)
		ref = substr($0, RSTART+1, RLENGTH-2)
		match($0, /inner|outer/)
		inout = substr($0, RSTART, RLENGTH)
		print ref, inout
	}'
}

processnodelist() {
	while read -r node; do
		dwnnode "$node" \
		| parsenode
		sleep "$sleep"
	done
}

processwaylist() {
	while IFS=' ' read -r id inout; do
		printf "#%s %s\n" "$id" "$inout"
		dwnway "$id" \
		| parseway \
		| processnodelist
		sleep "$sleep"
	done
}

processrelation() {
	dwnrelation "$1" \
	| parserelation \
	| processwaylist
}

version() {
	printf '%s\n' "$version"
}

main() {
	processrelation "$1"
}

while getopts 'dv' opt; do
	case $opt in
		d) set -x;; # debug mode: print every statement to console
		v) version; exit;;
		\?) exit;;
	esac
done

# Check wheter is beeing sourced for testing
if [ "$_" != './test.sh' ]; then
	shift "$((OPTIND -1))"
	main "$1"
fi
