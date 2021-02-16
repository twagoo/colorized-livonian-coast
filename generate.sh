#!/bin/bash

# Author: Twan Goosen <t.goosen@gmail.com>
# Licence: GNU GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>

set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FINNA_API='https://api.finna.fi/api/v1'
SEARCH_URL="${FINNA_API}/search"
RECORD_URL="${FINNA_API}/record"

TMP_DIR="${BASE_DIR}/tmp"
mkdir -p "${TMP_DIR}"

IDS_FILE="${BASE_DIR}/ids.txt"
METADATA_TSV="${BASE_DIR}/metadata.tsv"
MD_GALLERY="${BASE_DIR}/Gallery.md"
IMAGE_DIR="images"

main() {
	get_ids
	colorize_images
	create_metadata
	create_gallery
}

colorize_images() {
	mkdir -p "${IMAGE_DIR}"
	while read -r ITEM_ID; do
		IMAGE_URL="https://www.finna.fi/Cover/Show?id=${ITEM_ID}&index=0&size=large&source=Solr"

		OUT="${BASE_DIR}/${IMAGE_DIR}/${ITEM_ID}.jpg"
		echo "Colorizing and saving ${IMAGE_URL}"
		bash "${BASE_DIR}/colorize.sh" "${IMAGE_URL}" "${OUT}"
	done < "${IDS_FILE}"
}

create_metadata() {
	echo "Collecting and writing metadata to ${METADATA_TSV}"

	echo -e "id\ttitle\tfilename\toriginal_image_url\tlanding_page" > "${METADATA_TSV}"
	while read -r ITEM_ID; do
		echo "${ITEM_ID}"
	
		RESULT_TEMP="${TMP_DIR}/result_${ITEM_ID}.json"
		curl -s -G \
			--data-urlencode "id=${ITEM_ID}" \
			--data-urlencode "field[]=title" \
			"${RECORD_URL}" > "${RESULT_TEMP}"
			
		TITLE="$(jq -r '.records|.[]|.title' < "${RESULT_TEMP}")"
		FILE_NAME="${IMAGE_DIR}/${ITEM_ID}.jpg"
		IMAGE_URL="https://www.finna.fi/Cover/Show?id=${ITEM_ID}&index=0&size=large&source=Solr"
		LANDING_PAGE="https://finna.fi/Record/${ITEM_ID}"
		
		echo -e "${ITEM_ID}\t${TITLE}\t${FILE_NAME}\t${IMAGE_URL}\t${LANDING_PAGE}" >> "${METADATA_TSV}"
	done < "${IDS_FILE}"
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
	while read -r ITEM_ID; do
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

get_ids() {
	echo "Retrieving record IDs"

	echo -n > "${IDS_FILE}"
	PAGE=1
	while true; do
		echo "Getting page ${PAGE}"
	
		RESULT_TEMP="${TMP_DIR}/result_${PAGE}.json"
	
		curl -s -G \
			--data-urlencode 'lookfor=Setälä Vilho' \
			--data-urlencode 'filter[]=~topic_facet:"liiviläiset"' \
			--data-urlencode 'field[]=id' \
			--data-urlencode 'field[]=images' \
			--data-urlencode "page=${PAGE}" \
			"${SEARCH_URL}" > "${RESULT_TEMP}"
	
		if jq -e '.records' < "${RESULT_TEMP}" > /dev/null; then
			echo "Result count: $(jq '.resultCount' < "${RESULT_TEMP}")"
			jq -r '.records|.[].id' < "${RESULT_TEMP}" >> "${IDS_FILE}"
			PAGE="$((PAGE+1))"
		else
			echo "End of results"
			break	
		fi
	done

	echo 'done'
}

main
