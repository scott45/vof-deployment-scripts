#exit when there's an error
set -ex
set -o pipefail

create_elk_user() {
  if ! id -u elk; then
    sudo useradd -m -s /bin/bash elk
  fi
  sudo chown -R elk:elk /home/elk
  chmod 755 /home/elk/start_elk.sh 
}

install_dependancies(){
    # sudo curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
    # sudo mkdir -p /usr/local/gcloud
    # sudo tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz
    # sudo /usr/local/gcloud/google-cloud-sdk/install.sh
    # export PATH=$PATH:/usr/local/gcloud/google-cloud-sdk/bin
    sudo apt-get update && sudo apt-get install google-cloud-sdk supervisor -y
}

install_java(){

    sudo apt-get install -y python-software-properties debconf-utils
    sudo add-apt-repository -y ppa:webupd8team/java
    sudo apt-get update
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
    sudo apt-get install -y oracle-java8-installer
}

install_elastic_search(){

    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
    sudo apt-get update
    sudo apt-get install elasticsearch -y

    # edit elasticsearch configs
    sudo sed -i '55 s/#//' /etc/elasticsearch/elasticsearch.yml
    sudo sed -i '59 s/#//' /etc/elasticsearch/elasticsearch.yml
    sudo sed -i 's/192.168.0.1/localhost/g' /etc/elasticsearch/elasticsearch.yml

    sudo service elasticsearch start
    sudo systemctl enable elasticsearch
}

install_kibana(){

    sudo apt-get install kibana -y
    # edit kibana configs
    sudo sed -i '2 s/#//' /etc/kibana/kibana.yml
    sudo sed -i '7 s/#//' /etc/kibana/kibana.yml
    sudo sed -i '21 s/#//' /etc/kibana/kibana.yml

    sudo service kibana start
    sudo systemctl enable kibana
}

install_logstash(){

    sudo apt-get install logstash -y
}

create_nginx_config(){
    cd ~
    sudo cat <<EOF > ~/elk-nginx
server {
    listen 80;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;        
    }
}
EOF

}

install_nginx(){
    sudo apt-get -y install nginx

    create_nginx_config
    sudo rm -rf /etc/nginx/sites-available/default
    sudo rm -rf /etc/nginx/sites-enabled/default
    sudo mv ~/elk-nginx /etc/nginx/sites-available/elk-nginx
    sudo ln -s /etc/nginx/sites-available/elk-nginx /etc/nginx/sites-enabled/elk-nginx
    sudo nginx -t
    sudo systemctl restart nginx
    sudo ufw allow 'Nginx Full'
}

create_elk_supervisord_conf() {
  sudo bash -c 'cat <<EOF > /etc/supervisor/conf.d/elk.conf
[program:elk]
command=sudo systemctl start kibana elasticsearch logstash
directory=/home/elk/
autostart=true
stderr_logfile=/var/log/elk/elk.err.log
stdout_logfile=/var/log/elk/elk.out.log
user=elk
EOF'
    
    sudo mkdir -p /var/log/elk
    sudo touch /var/log/elk/elk.err.log
    sudo touch /var/log/elk/elk.out.log
    
    sudo service supervisor start
}

main() {

  create_elk_user

  install_dependancies
  install_java
  
  install_elastic_search
  install_kibana
  install_logstash
  
  install_nginx
  create_elk_supervisord_conf
}

main "$@"