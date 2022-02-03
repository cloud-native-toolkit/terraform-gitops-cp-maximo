#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../charts"; pwd -P)

DEST_DIR="$1"

mkdir -p "${DEST_DIR}"


echo "adding patching sbo..."

#create operator
cat > "${DEST_DIR}/sbo.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rh-service-binding-operator
  namespace: openshift-operators
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  channel: preview
  name: rh-service-binding-operator
  source: redhat-operators 
  sourceNamespace: openshift-marketplace
  installPlanApproval: Manual
  startingCSV: service-binding-operator.v0.8.0

EOL

echo "adding job to approve chart..."
$(mv ${CHART_DIR}/approve-job.yaml ${DEST_DIR}/approve-job.yaml)
