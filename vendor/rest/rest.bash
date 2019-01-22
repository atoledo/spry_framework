#!/usr/bin/env bash

function rest_request() {

  local _REST_URL=${1:-}
  validate_is_empty ${_REST_URL} "api_base_url" "rest_request"

  local _REST_API=${2:-}
  validate_is_empty ${_REST_API} "api_uri" "rest_request"

  local _REST_PARAM=${3:-}
  local _REST_CLIENT_ID=${4:-}
  local _REST_CLIENT_KEY=${5:-}
  local _REST_HEADER=${6:-}

  if [ ! -z "${_REST_CLIENT_ID}" ] && [ ! -z "${_REST_CLIENT_KEY}" ]; then

    _REST_PARAM="${_REST_PARAM} -u ${_REST_CLIENT_ID}:${_REST_CLIENT_KEY}"

  fi

  if [ ! -z "${_REST_HEADER}" ]; then

    for _HEADER_INFO in ${_REST_HEADER}; do

      _REST_PARAM="${_REST_PARAM} -H ${_HEADER_INFO}"

    done

  fi

  ${_CURL} ${_REST_PARAM} ${_REST_URL}${_REST_API}

}
