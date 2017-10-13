#!/bin/bash

set -ex
set -o pipefail

export PORT="${PORT:-8080}"
export RAILS_ENV="${RAILS_ENV:-staging}"

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

create_application_yml() {
  cat <<EOF > /home/vof/app/config/application.yml
API_URL: 'https://api-staging.andela.com/'
LOGIN_URL: 'https://api-staging.andela.com/login?redirect_url='
LOGOUT_URL: 'https://api-staging.andela.com/logout?redirect_url='
POSTGRES_USER: '$(get_var "databaseUser")'
POSTGRES_PASSWORD: '$(get_var "databasePassword")'
POSTGRES_HOST: '$(get_var "databaseHost")'
POSTGRES_DB: '$(get_var "databaseName")'
EOF
}

create_secrets_yml() {
  cat <<EOF > /home/vof/app/config/secrets.yml
production:
  secret_key_base: "$(openssl rand -hex 64)"
staging:
  secret_key_base: "$(openssl rand -hex 64)"
development:
  secret_key_base: "$(openssl rand -hex 64)"
EOF
}

create_log_files() {
  mkdir -p /var/log/vof
  touch /var/log/vof/vof.out.log /var/log/vof/vof.err.log
  sudo chown -R vof:vof /var/log/vof/vof.out.log /var/log/vof/vof.err.log
}

start_app() {
  local app_root="/home/vof/app"

  sudo -u vof bash -c "mkdir -p /home/vof/app/log"
  sudo -u vof bash -c "cd ${app_root} && env RAILS_ENV=${RAILS_ENV} bundle exec rake db:setup"
  sudo -u vof bash -c "cd ${app_root} && env RAILS_ENV=${RAILS_ENV} bundle exec rake db:seed"
  sudo -u vof bash -c "cd ${app_root} && env RAILS_ENV=${RAILS_ENV} PORT=${PORT} nohup bundle exec puma -C config/puma.rb 1> /var/log/vof/vof.out.log 2> /var/log/vof/vof.err.log &"
}

main() {
  echo "startup script invoked at $(date)" >> /tmp/script.log

  create_application_yml
  create_secrets_yml
  create_log_files
  start_app
}

main "$@"