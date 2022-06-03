#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

source "${SCRIPT_DIR}/validation-functions.sh"

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  exit 1
fi

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
COMPONENT_NAME=$(jq -r '.name // "my-module"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)


mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"


validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "values.yaml"
check_k8s_namespace "${NAMESPACE}"

## check operator deployment
check_k8s_resource "${NAMESPACE}" deployment "ibm-mas-operator"

## check mas suite deployment  
check_k8s_resource "${NAMESPACE}" deployment "mas8-coreidp-login"


kubectl get deployments -n ${NAMESPACE}

cd ..
rm -rf .testrepo
