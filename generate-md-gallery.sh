#!/bin/bash

# Author: Twan Goosen <t.goosen@gmail.com>
# Licence: GNU GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FINNA_API='https://api.finna.fi/api/v1'
RECORD_URL="${FINNA_API}/record"

TMP_DIR="${BASE_DIR}/tmp"
mkdir -p "${TMP_DIR}"

IDS_FILE="${BASE_DIR}/ids.txt"
MD_GALLERY="${BASE_DIR}/Gallery.md"
IMAGE_DIR="images"

main() {
	# get_ids
# 	colorize_images
# 	create_metadata
	create_gallery
	
}


create_gallery() {
	echo "Collecting metadata and gallery ${MD_GALLERY}"
	create_gallery_md_content > "${MD_GALLERY}"
}

create_gallery_md_content() {
	echo "# Colorized Livonian Coast"
	echo ""
	echo "[Click here for more information](README.md)"
	echo ""
	while read ITEM_ID; do
		RESULT_TEMP="${TMP_DIR}/result_${ITEM_ID}.json"
		curl -s -G \
			--data-urlencode "id=${ITEM_ID}" \
			--data-urlencode "field[]=title" \
			"${RECORD_URL}" > "${RESULT_TEMP}"
			
		TITLE="$(jq -r '.records|.[]|.title' < "${RESULT_TEMP}")"
		FILE_NAME="${IMAGE_DIR}/${ITEM_ID}.jpg"
		IMAGE_URL="https://www.finna.fi/Cover/Show?id=${ITEM_ID}&index=0&size=large&source=Solr"
		LANDING_PAGE="https://finna.fi/Record/${ITEM_ID}"
		
		echo "----"
		echo ""
		echo "![${TITLE}](${FILE_NAME})"
		echo ""
		echo "\"${TITLE}\""
		echo "| [More information](${LANDING_PAGE}) | [original black-and-white]($IMAGE_URL)"
		echo ""
		echo "Photo by Vilho Setälä"
		echo "| Published under a [CC BY 4.0 license](http://creativecommons.org/licenses/by/4.0/deed.en)"
		echo ""
	done < "${IDS_FILE}"
}


main
