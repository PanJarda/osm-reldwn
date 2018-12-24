#!/bin/bash

wget "https://www.openstreetmap.org/api/0.6/relation/$1" \
	-O /tmp/relation.xml  &> /dev/null

rm /tmp/relation.xml
