#!/usr/bin/env bash

function python3_install_virtualenv() {

  out_warning "Checking for Python virtual environment" 1
  ${_LS} venv &> /dev/null && true

  if [ $? -ne 0 ]; then
    out_warning "Virtual environment not found. Creating it."
    ${_PYTHON3} -m venv venv
  fi

  source venv/bin/activate
  pip install -r requirements.txt

}
