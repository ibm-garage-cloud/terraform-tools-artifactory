#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

CLUSTER_TYPE="$1"
NAMESPACE="$2"
NAME="$3"

INTERNAL_URL=$(kubectl get secret artifactory-access -n "${NAMESPACE}" -o jsonpath='{.data.ARTIFACTORY_URL}' | base64 -d)

SERVICE_URL="http://artifactory-artifactory.${NAMESPACE}"
if [[ "${INTERNAL_URL}" =~ ${SERVICE_URL} ]]; then
  echo "Internal url found"
else
  echo "Internal url not found"
  exit 1
fi

CONFIG_URLS=$(kubectl get configmap -n "${NAMESPACE}" -l grouping=garage-cloud-native-toolkit -l app.kubernetes.io/component=tools -o json | jq '.items[].data | to_entries | select(.[].key | endswith("_URL")) | .[].value' | sed "s/\"//g")

echo "${CONFIG_URLS}" | while read url; do
  if [[ -n "${url}" ]]; then
    ${SCRIPT_DIR}/waitForEndpoint.sh "${url}" 10 10
  fi
done

ENCRYPT=$(kubectl get secret artifactory-access -n "${NAMESPACE}" -o jsonpath='{.data.ARTIFACTORY_ENCRYPT}')
if [[ -z "${ENCRYPT}" ]]; then
  echo "ENCRPYT password not set"
  exit 1
fi
