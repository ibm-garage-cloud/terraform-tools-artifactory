#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAMESPACE="$1"
NAME="$2"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./tmp"
fi

mkdir -p "${TMP_DIR}"

ROUTE_YAML="${TMP_DIR}/artifactory-route.yaml"

cat <<EOL > ${ROUTE_YAML}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${NAME}
  labels:
    app: artifactory
spec:
  to:
    kind: Service
    name: ${NAME}
    weight: 100
  port:
    targetPort: router
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
  wildcardPolicy: None
EOL

kubectl apply -n "${NAMESPACE}" -f ${ROUTE_YAML}