#!/bin/bash
LOCATION_FILE="$HOME/.location"

coords=$(curl -s https://ipinfo.io/loc)
if [ -n "$coords" ]; then
    echo "$coords" > "$LOCATION_FILE"
else
	echo "45.4642,9.1900" > "$LOCATION_FILE"
fi

