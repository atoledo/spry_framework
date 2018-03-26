#!/usr/bin/env bash

function yml_writer() {

  YML_FILE=${1:-"/tmp/tmp.yml"}

  YML_LEVEL=${2:-"0"}

  YML_DATA=${3:-}

  YML_LINE_IDENTATION=""

  for (( i=1; i <= ${YML_LEVEL}; ++i )); do

    YML_LINE_IDENTATION="${YML_LINE_IDENTATION}  "

  done

  echo "${YML_LINE_IDENTATION}${YML_DATA}" >> "${YML_FILE}"

}
