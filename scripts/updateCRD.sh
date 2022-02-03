#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MAS_DIR=$(cd "${SCRIPT_DIR}/../charts/mas"; pwd -P)


ICR_CPOPEN="${ICR_CPOPEN:-icr.io/cpopen}"
ICR_CP="${ICR_CP:-cp.icr.io/cp}"

DEST_DIR="$1"
INSTANCE_ID="$2"
DOMAIN="$3"

mkdir -p "${DEST_DIR}"

echo "update core suite crd..."

sed -e "s|{{INSTANCE_ID}}|${INSTANCE_ID}|g" \
    -e "s|{{DOMAIN}}|${DOMAIN}|g" \
    -e "s|{{ICR_CP}}|${ICR_CP}|g" \
    -e "s|{{ICR_CPOPEN}}|${ICR_CPOPEN}|g" \
    ${MAS_DIR}/core_v1_suite.yaml > ${DEST_DIR}/my_core_v1_suite_cr.yaml
