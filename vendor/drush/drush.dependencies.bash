#!/usr/bin/env bash

function drush_dependencies_1000() {

  _SYSTEM_DEPENDENCIES="drush"

  install_software "php-curl" && true ; install_software "php5-curl" && true

}
