#!/usr/bin/env bash

################################################################################
# @param String _REST_URL - Base API URL, example "http://jsonplaceholder.typicode.com/"
# @param String _REST_API - API URI, example "/posts"
# @param String _REST_CLIENT_ID - user if you need authentication
# @param String _REST_CLIENT_KEY - password or api key if you need authentication
# @param String _REST_HEADER - request header, example "Content-Type:text/html;charset=utf-8"
#
# Will download a file
################################################################################

function rest_get_file_download() {

  local _REST_URL=${1:-}
  local _REST_API=${2:-}
  local _REST_CLIENT_ID=${3:-}
  local _REST_CLIENT_KEY=${4:-}
  local _REST_HEADER=${5:-}

  local _REST_PARAM="-s -O -w '|%{response_code}'" # Curl param to download file

  rest_request ${_REST_URL} ${_REST_API} "${_REST_PARAM}" ${_REST_CLIENT_ID} ${_REST_CLIENT_KEY}

}

################################################################################
# @param String _REST_URL - Base API URL, example "http://jsonplaceholder.typicode.com/"
# @param String _REST_API - API URI, example "/posts"
# @param String _REST_CLIENT_ID - user if you need authentication
# @param String _REST_CLIENT_KEY - password or api key if you need authentication
# @param String _REST_HEADER - request header, example "Content-Type:text/html; charset=utf-8"
#
# Will perform a GET request
################################################################################

function rest_get() {

  local _REST_URL=${1:-}
  local _REST_API=${2:-}
  local _REST_CLIENT_ID=${3:-}
  local _REST_CLIENT_KEY=${4:-}
  local _REST_HEADER=${5:-}

  local _REST_PARAM="-s -X GET"

  rest_request ${_REST_URL} ${_REST_API} "${_REST_PARAM}" ${_REST_CLIENT_ID} ${_REST_CLIENT_KEY}

}

function rest_post() {

  local _REST_URL=${1:-}
  local _REST_API=${2:-}
  local _REST_CLIENT_ID=${3:-}
  local _REST_CLIENT_KEY=${4:-}
  local _REST_PARAM=${5:-}

  _REST_PARAM="${_REST_PARAM} -s -w '|%{response_code}' -X POST"

  rest_request ${_REST_URL} ${_REST_API} "${_REST_PARAM}" ${_REST_CLIENT_ID} ${_REST_CLIENT_KEY}

}
