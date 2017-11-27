#!/bin/bash

set -e
set -o pipefail

create_vof_user() {
  if ! id -u vof; then
    sudo useradd -m -s /bin/bash vof
  fi
}

start_supervisor_service() {
  sudo service supervisor start
}

setup_vof_code() {
  sudo chown -R vof:vof /home/vof
  
  cd /home/vof/app && bundle install
}

install_logging_agent(){
  # This installs the logging agent into the VM
  curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
  sudo bash install-logging-agent.sh
}

main() {
  create_vof_user

  setup_vof_code
  install_logging_agent
  start_supervisor_service
}

main "$@"
