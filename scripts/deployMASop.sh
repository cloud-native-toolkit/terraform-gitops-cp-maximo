#!/usr/bin/env bash

DEST_DIR="$1"
VERSION="$2"
NAMESP="$3"

mkdir -p "${DEST_DIR}"

# Install MAS operator

echo "adding mas subscription chart..."

cat > "${DEST_DIR}/ibm-mas-op.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-mas-operator
  namespace: ${NAMESP}
  annotations:
    argocd.argoproj.io/sync-wave: "3"
spec:
  channel: ${VERSION}
  installPlanApproval: Automatic
  name: ibm-mas
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace  
EOL

