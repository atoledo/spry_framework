#!/usr/bin/env bash

function php_builtin_server() {

  _PHP_BUILTIN_SERVER_ROOT=${1:-}
  _PHP_BUILTIN_SERVER_HOST=${2:-}
  _PHP_BUILTIN_SERVER_PORT=${3:-}

  ${_PHP} -S ${_PHP_BUILTIN_SERVER_HOST}:${_PHP_BUILTIN_SERVER_PORT} -t ${_PHP_BUILTIN_SERVER_ROOT} &

}
