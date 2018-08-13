#!/bin/bash

set -e
set -o pipefail

create_vof_user() {
  if ! id -u vof; then
    sudo useradd -m -s /bin/bash vof
  fi
}

setup_vof_code() {
  sudo chown -R vof:vof /home/vof
  cd /home/vof/app && bundle install
}

start_supervisor_service() {
  sudo service supervisor start
}

main() {
  create_vof_user

  setup_vof_code
  start_supervisor_service
}

main "$@"
