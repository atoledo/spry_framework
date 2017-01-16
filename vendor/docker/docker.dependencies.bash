#!/usr/bin/env bash

function docker_dependencies_1000() {

  if [ $(program_is_installed 'docker-engine') == 1 ]; then

    wget -qO- https://get.docker.com/ | sudo bash
    sudo usermod -aG docker $USER
    sudo chown $USER:docker /var/run/docker.sock

  fi

}
