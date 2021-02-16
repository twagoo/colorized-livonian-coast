#!/bin/bash

# Uses <https://deepai.org/machine-learning-model/colorizer> to download a colorized
# version of an image. Arguments: <input URL> <output filename>

# Author: Twan Goosen <t.goosen@gmail.com>
# Licence: GNU GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>

curl \
	-s -o tmp.json \
    -F "image=${1}" \
    -H "api-key:${DEEPAI_KEY}" \
    https://api.deepai.org/api/colorizer

URL="$(cat tmp.json|jq -r '.output_url')"

if [ "${URL}" = "null" ] || [ -z "${URL}" ]; then
	echo "Error: ${URL}"
	cat tmp.json
	rm tmp.json
	exit 1
fi

curl -s -o "${2}" "${URL}"
rm tmp.json
