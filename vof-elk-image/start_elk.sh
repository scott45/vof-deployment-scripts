#exit when there's an error
set -ex
set -o pipefail

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

BUCKET_NAME="$(get_var "bucketName")"

configure_logstash_ssl(){
    
    sudo mkdir -p /etc/pki/tls/certs
    sudo mkdir /etc/pki/tls/private

    IP_ADDR=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    sudo sed -i "224a subjectAltName = IP: ${IP_ADDR}" /etc/ssl/openssl.cnf

    cd /etc/pki/tls
    sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
    gsutil cp /etc/pki/tls/certs/logstash-forwarder.crt gs://${BUCKET_NAME}/elk-ssl/logstash-forwarder.crt

    sudo service logstash start
    sudo systemctl enable logstash
}

create_logstash_input_config() {

  sudo bash -c 'cat <<EOF > /etc/logstash/conf.d/02-beats-input.conf
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
EOF'
}

create_logstash_filter_config() {

  sudo bash -c 'cat <<EOF > /etc/logstash/conf.d/10-syslog-filter.conf
filter {
  json {
    source => "message"
  }
}
EOF'
}

create_logstash_output_config() {

  sudo bash -c 'cat <<EOF > /etc/logstash/conf.d/30-elasticsearch-output.conf
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    sniffing => true
    manage_template => false
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
}
EOF'
}

create_curator_cronjob() {
  cat > /home/elk/curator/curator_cron.yml <<'EOF'
0 0 15 * * curator --config /home/elk/curator/curator_config.yml /home/elk/curator/curator_action.yml
EOF
}

update_crontab() {
  cat /home/elk/curator/curator_cron.yml | crontab
  rm /home/elk/curator/curator_cron.yml
}

main() {

  configure_logstash_ssl
  
  create_logstash_input_config
  create_logstash_filter_config
  create_logstash_output_config

  create_curator_cronjob
  update_crontab
}

main "$@"
