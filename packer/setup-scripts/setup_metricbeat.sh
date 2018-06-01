
install_metricbeat(){
  curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.2.4-amd64.deb
  sudo dpkg -i metricbeat-6.2.4-amd64.deb
  sudo apt-get update
}

setup_metricbeat(){

  sudo bash -c 'cat <<EOF > /etc/metricbeat/metricbeat.yml
metricbeat.modules:
- module: system
  metricsets:
    - cpu
    - filesystem
    - memory
    - network
    - process
    - core
    - diskio
    - fsstat
    - load
    - process_summary
    - raid
    - socket
    - uptime
  enabled: true
  period: 60s
  processes: ['.*']
  cpu_ticks: false

output:
  logstash:
    hosts: ["192.168.1.2:5044"]
    bulk_max_size: 1024

    ssl:
      certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]

shipper:

logging:
  files:
    rotateeverybytes: 10485760 # = 10MB

setup.kibana:
  host: "192.168.1.2:5601"
EOF'

  sudo systemctl start metricbeat
  sudo systemctl enable metricbeat

}
