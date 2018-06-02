install_filebeat(){
  curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.2.4-amd64.deb
  sudo dpkg -i filebeat-6.2.4-amd64.deb
  sudo apt-get update
  
}

create_filebeat_config_file(){

  sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat_old.yml
  sudo bash -c "cat <<EOF > /etc/filebeat/filebeat.yml
filebeat:
  prospectors:
    -
      paths:
        - /home/vof/app/log/logstash_*.log

      exclude_lines: ['/health{1}']
      #  - /var/log/*.log

      input_type: log
      
      document_type: syslog

  registry_file: /var/lib/filebeat/registry

output:
  logstash:
    hosts: ['192.168.1.2:5044']
    bulk_max_size: 1024

    ssl:
      certificate_authorities: ['/etc/pki/tls/certs/logstash-forwarder.crt']

shipper:

logging:
  files:
    rotateeverybytes: 10485760 # = 10MB
EOF"

}

setup_filebeat(){
  sudo mkdir -p /etc/pki/tls/certs
  sudo gsutil cp gs://${BUCKET_NAME}/elk-ssl/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
  create_filebeat_config_file
  sudo systemctl restart filebeat
  sudo systemctl enable filebeat
}
