#!/bin/bash

curl \
	-s -o tmp.json \
    -F "image=${1}" \
    -H 'api-key:16132985-db29-43b2-a923-cca36be36215' \
    https://api.deepai.org/api/colorizer

URL="$(cat tmp.json|jq -r '.output_url')"

if [ "${URL}" = "null" ] || ! [ -n "${URL}" ]; then
	echo "Error: ${URL}"
	cat tmp.json
	rm tmp.json
	exit 1
fi

curl -s -o "${2}" "${URL}"
rm tmp.json
