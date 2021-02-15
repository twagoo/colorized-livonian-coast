#!/bin/bash

# Author: Twan Goosen <t.goosen@gmail.com>
# Licence: GNU GPLv3

set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

( cd "${BASE_DIR}/docker/gallery" && 
	docker build --tag twagoo/thumbsup .)

( cd "${BASE_DIR}" &&
	docker run --rm -it -v $(pwd):/pwd --workdir /pwd  twagoo/thumbsup thumbsup --input images --output .
)
