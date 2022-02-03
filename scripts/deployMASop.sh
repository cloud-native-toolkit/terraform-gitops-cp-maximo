#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MAS_DIR=$(cd "${SCRIPT_DIR}/../charts/mas"; pwd -P)

ICR_CPOPEN="${ICR_CPOPEN:-icr.io/cpopen}"

DEST_DIR="$1"
INSTANCE_ID="$2"
VERSION="$3"

mkdir -p "${DEST_DIR}"


# Install MAS operator
if [[ "$3" == "destroy" ]]; then
    echo "remove ibm-mas operator..."
    kubectl delete -f $MAS_DIR/my-ibm-mas-${VERSION}.yaml

else 
    echo "Installing ibm-mas operator..."
    sed -e "s|icr.io/cpopen|${ICR_CPOPEN}|g" \
        -e "s/{{INSTANCE_ID}}/${INSTANCE_ID}/g" \
        $MAS_DIR/ibm-mas-${VERSION}.yaml > $DEST_DIR/my-ibm-mas-${VERSION}.yaml

fi

