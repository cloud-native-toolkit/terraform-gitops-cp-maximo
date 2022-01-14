#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../charts"; pwd -P)

DEST_DIR="$1"

mkdir -p "${DEST_DIR}"


echo "adding patching sbo..."
#add chart to deployment directory
cp "${CHART_DIR}/sbo.yaml" "${DEST_DIR}/sbo.yaml"

