#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0") && pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd -P)

VERSION="$1"
DEST_DIR="$2"

if [[ -z "${DEST_DIR}" ]]; then
  DEST_DIR="${MODULE_DIR}/dest"
fi

mkdir -p "${DEST_DIR}"

sed -E "s/^source: (.*)/source: \1?ref=${VERSION}/g" "${MODULE_DIR}/module.yaml" > "${DEST_DIR}/module.yaml"

cat "${MODULE_DIR}/variables.tf" | \
  tr '\n' ' ' | \
  sed $'s/variable/\\\nvariable/g' | \
  grep variable | \
  while read variable; do
    name=$(echo "$variable" | sed -E "s/variable +\"([^ ]+)\".*/\1/g")
    type=$(echo "$variable" | sed -E "s/.*type += +([^ ]+).*/\1/g")
    description=$(echo "$variable" | sed -E "s/.*description += *\"([^\"]*)\".*/\1/g")
    defaultValue=$(echo "$variable" | grep "default" | sed -E "s/.*default += +(\"[^\"]*\"|true|false).*/\1/g")

    if [[ -z "${type}" ]]; then
      type="string"
    fi

    if [[ -z $(yq r "${DEST_DIR}/module.yaml" "variables(name==${name}).name") ]]; then
      yq w -i "${DEST_DIR}/module.yaml" "variables[+].name" "${name}"
    fi

    yq w -i "${DEST_DIR}/module.yaml" "variables(name==${name}).type" "${type}"
    if [[ -n "${description}" ]]; then
      yq w -i "${DEST_DIR}/module.yaml" "variables(name==${name}).description" "${description}"
    fi
    if [[ -n "${defaultValue}" ]]; then
      yq w -i "${DEST_DIR}/module.yaml" "variables(name==${name}).optional" "true"
    fi
done

cat "${MODULE_DIR}/outputs.tf" | \
  tr '\n' ' ' | \
  sed $'s/output/\\\noutput/g' | \
  grep output | \
  while read output; do
    name=$(echo "$output" | sed -E "s/output +\"([^ ]+)\".*/\1/g")
    description=$(echo "$output" | sed -E "s/.*description += *\"([^\"]*)\".*/\1/g")

    if [[ -z $(yq r "${DEST_DIR}/module.yaml" "outputs(name==${name}).name") ]]; then
      yq w -i "${DEST_DIR}/module.yaml" "outputs[+].name" "${name}"
    fi

    if [[ -n "${description}" ]]; then
      yq w -i "${DEST_DIR}/module.yaml" "outputs(name==${name}).description" "${description}"
    fi
done
