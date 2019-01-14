#!/usr/bin/env bash

################################################################################
# @param String List - items from YML structure path until a leaf
#
# Returns the value for the given YML path
################################################################################
function yml_extractor() {

  local _YML_EXTRACTOR_YPATH=""

  for _ARG in $@; do

    _YML_EXTRACTOR_YPATH=$(printf "%s_%s" "${_YML_EXTRACTOR_YPATH:-}" "${_ARG^^}")

  done

  if [ ! -z ${!_YML_EXTRACTOR_YPATH:-} ]; then

    echo ${!_YML_EXTRACTOR_YPATH}

  fi

}

################################################################################
# @param String List - items from YML structure path until a leaf
#
# Returns the value for the given YML path when the leaf has multiple values
################################################################################
function yml_list_extractor() {

  local _YML_EXTRACTOR_YPATH=""

  for _ARG in $@; do

    _YML_EXTRACTOR_YPATH=$(printf "%s_%s" "${_YML_EXTRACTOR_YPATH:-}" "${_ARG^^}")

  done

  _YML_EXTRACTOR_YPATH=$(printf "%s[@]" "${_YML_EXTRACTOR_YPATH}")

  local _YML_LIST_CHECK_SIZE="$(echo ${!_YML_EXTRACTOR_YPATH:-} | wc -w)"

  if [ ${_YML_LIST_CHECK_SIZE} -gt 0 ]; then

    _YML_EXTRACTOR_YPATH=("${!_YML_EXTRACTOR_YPATH}")

    if [ ${#_YML_EXTRACTOR_YPATH[@]} -ge 1 ]; then

      echo ${_YML_EXTRACTOR_YPATH[@]}

    fi

  fi

}
