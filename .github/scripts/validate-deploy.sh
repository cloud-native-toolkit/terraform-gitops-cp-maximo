#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
#COMPONENT_NAME=$(jq -r '.name // "my-module"' gitops-output.json)
#BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
#SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
#LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
#TYPE=$(jq -r '.type // "base"' gitops-output.json)

BRANCH="main"
SERVER_NAME="default"
TYPE="base"
LAYER="2-services"

COMPONENT_NAME="maximo"


mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

if [[ ! -f "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/ibm-mas-op.yaml" ]]; then
  echo "Application values not found - payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/ibm-mas-op.yaml"
  exit 1
fi

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/ibm-mas-op.yaml"
cat "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/ibm-mas-op.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi
#wait for deployment
sleep 5m

# deplopyment check for mas operator

count=0
until kubectl get deployment ibm-mas-operator -n ${NAMESPACE} || [[ $count -eq 20 ]]; do
  echo "Waiting for deployment/ibm-mas-operator in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

kubectl rollout status "deployment/ibm-mas-operator" -n "${NAMESPACE}" || exit 1

# instance check

count=0
until kubectl get deployment mas8-coreidp-login -n ${NAMESPACE} || [[ $count -eq 20 ]]; do
  echo "Waiting for deployment/mas8-coreidp-login in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

kubectl rollout status "deployment/mas8-coreidp-login" -n "${NAMESPACE}" || exit 1

cd ..
rm -rf .testrepo

#remove suite cr
$(kubectl patch -n mas-mas8-core "suite/mas8" --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]')

