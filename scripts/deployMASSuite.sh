#!/usr/bin/env bash

DEST_DIR="$1"

INSTID="$2"
NAMESP="$3"
DOMAIN="$4"
CERTNMSP="$5"

mkdir -p "${DEST_DIR}"

# Install MAS operator

echo "adding mas core suite chart..."

cat > "${DEST_DIR}/ibm-mas-suite.yaml" << EOL
apiVersion: core.mas.ibm.com/v1
kind: Suite
metadata:
  name: ${INSTID}
  namespace: ${NAMESP}
  labels:
    mas.ibm.com/instanceId: ${INSTID}
  annotations:
    argocd.argoproj.io/sync-wave: "4"
spec:
  certManagerNamespace: ${CERTNMSP}
  domain: ${DOMAIN}
  settings:
    icr:
      cp: cp.icr.io/cp
      cpopen: icr.io/cpopen
  license:
    accept: true
EOL

