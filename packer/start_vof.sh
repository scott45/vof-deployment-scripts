#!/bin/bash

set -ex
set -o pipefail

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

export PORT="${PORT:-8080}"
export RAILS_ENV="$(get_var "railsEnv")"

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

create_vof_supervisord_conf() {
  sudo cat <<EOF > /etc/supervisor/conf.d/vof.conf
[program:vof]
command=/usr/bin/env RAILS_ENV=${RAILS_ENV} PORT=${PORT} /usr/bin/nohup /usr/local/bin/bundle exec puma -C config/puma.rb
directory=/home/vof/app
autostart=true
autorestart=true
startretries=3
stderr_logfile=/var/log/vof/vof.err.log
stdout_logfile=/var/log/vof/vof.out.log
user=vof
EOF
}

authenticate_service_account() {
  if gcloud auth activate-service-account --key-file=/home/vof/account.json; then
    echo "Service account authentication successful"
  fi
}

get_database_dump_file() {
  if [[ "$RAILS_ENV" == "production" || "$RAILS_ENV" == "staging" || "$RAILS_ENV" == "prod" ]]; then
    if gsutil cp gs://vof-database-backup/vof_${RAILS_ENV}.sql /home/vof/vof_${RAILS_ENV}.sql; then
      echo "Database dump file created succesfully"
    fi
  fi
}

start_app() {
  local app_root="/home/vof/app"

  sudo -u vof bash -c "mkdir -p /home/vof/app/log"

  if [[ "$RAILS_ENV" == "production" || "$RAILS_ENV" == "staging" || "$RAILS_ENV" == "prod" ]]; then
    # One time actions
    # Check if the database was already imported
    if export PGPASSWORD=$(get_var "databasePassword"); psql -h $(get_var "databaseHost") -p 5432 -U $(get_var "databaseUser") -d $(get_var "databaseName") -c 'SELECT key FROM ar_internal_metadata' 2>/dev/null | grep environment >/dev/null; then
      sudo -u vof bash -c "cd ${app_root} && env RAILS_ENV=${RAILS_ENV} bundle exec rake db:migrate"
    else
      # Import database dump.
      sudo -u postgres bash -c "export PGPASSWORD=$(get_var "databasePassword"); psql -h  $(get_var "databaseHost") -p 5432 -U $(get_var "databaseUser") -d $(get_var "databaseName") < /home/vof/vof_${RAILS_ENV}.sql"
    fi
  else
    sudo -u vof bash -c "cd ${app_root} && env RAILS_ENV=${RAILS_ENV} bundle exec rake db:setup"
    sudo -u vof bash -c "cd ${app_root} && env RAILS_ENV=${RAILS_ENV} bundle exec rake db:seed"
  fi

  supervisorctl update && supervisorctl reload
}

main() {
  echo "startup script invoked at $(date)" >> /tmp/script.log

  create_log_files
  create_application_yml
  create_secrets_yml
  create_vof_supervisord_conf

  authenticate_service_account
  get_database_dump_file

  start_app

  # Setup Vault
  # source /home/vof/vault_token.sh
}

main "$@"