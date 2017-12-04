#!/bin/bash

set -e
set -o pipefail

RUBY_VERSION="${RUBY_VERSION:-2.4.1}"

create_vof_user() {
  if ! id -u vof; then
    sudo useradd -m -s /bin/bash vof
  fi
}

install_system_dependencies() {
  sudo apt-get update -y

  sudo apt-get install -y --no-install-recommends git-core curl zlib1g-dev logrotate     \
    build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev wget nodejs unattended-upgrades     \
    python-software-properties libffi-dev libpq-dev sudo vim less supervisor jq \
    postgresql postgresql-contrib
}

install_ruby(){
  if ! which ruby; then
    install_system_dependencies

    sudo chgrp -R vof  /usr/local
    sudo chmod -R g+rw /usr/local

    curl -k -O -L "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%\.*}/ruby-${RUBY_VERSION}.tar.gz"
    tar zxf ruby-*

    pushd ruby-$RUBY_VERSION
      ./configure
      make && make install
    popd
  fi
}

install_vof_ruby_dependencies() {
  if ! which bundler; then
    curl -O -L -k https://rubygems.org/rubygems/rubygems-2.6.12.tgz

    tar zxf rubygems-2.6.12.tgz
    pushd rubygems-2.6.12
      ruby setup.rb
    popd

    gem install bundler --no-ri --no-rdoc
    gem install stackdriver --no-ri --no-rdoc
  fi
}

install_logging_agent(){
  # This installs the logging agent into the VM
  curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
  sudo bash install-logging-agent.sh
}

start_supervisor_service() {
  sudo service supervisor start
}

main() {
  create_vof_user

  mkdir -p /tmp/workdir
  pushd /tmp/workdir
    install_ruby
    install_vof_ruby_dependencies
    install_logging_agent
  popd
  rm -r /tmp/workdir

  start_supervisor_service
}

main "$@"
