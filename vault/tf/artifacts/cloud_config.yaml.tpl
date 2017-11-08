#cloud-config

coreos:
  etcd2:
    # Discovery is populated by Terraform
    discovery: ${etcd_discovery_url}
    # $public_ipv4 and $private_ipv4 are populated by the cloud provider
    # for vault, we only allows internal etcd clients
    advertise-client-urls: http://$private_ipv4:2379
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379
    listen-peer-urls: http://$private_ipv4:2380
  units:
    - name: etcd2.service
      command: start
    - name: install-vault.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=Install Vault and server cert
        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/bin/bash -c "[ -x /opt/bin/vault ] || \
          (mkdir -p /opt/bin; cd /tmp;  \
          curl -s -L -O ${vault_release_url} \
          && unzip -o $(basename ${vault_release_url}) -d /opt/bin/ \
          && chmod 755 /opt/bin/vault \
          && rm $(basename ${vault_release_url}) \
          && (cd /var/lib/apps/vault/certs; ./gen.sh))"
    - name: vault.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=vault
        Wants=install-vault.service
        After=install-vault.service
        [Service]
        ExecStart=/opt/bin/vault server -config /var/lib/apps/vault/vault.hcl
        RestartSec=5
        Restart=always
    - name: nodeapp.service
      command: start
      enable: true
      content: |
        [Unit]
        Description=nodeapp
        Require=docker.service
        After=docker.service
        [Service]
        ExecStartPre=-/usr/bin/docker rm -f nodeapp
        ExecStart=/bin/bash -c "docker run --rm --name nodeapp -p 80:8000 \
          -e COREOS_PUBLIC_IPV4=$public_ipv4 \
          -e INSTANCE_ID=%H \
          xueshanf/docker-nodeapp:latest"
        ExecStop=-/usr/bin/docker stop nodeapp
        RestartSec=5
        Restart=always

write_files:
  - path: /var/lib/apps/vault/vault.hcl
    permissions: 0644
    owner: root
    content: |
      backend "etcd" {
        address = "http://127.0.0.1:2379"
        advertise_addr = "https://$public_ipv4:8200"
        path = "vault"
        sync = "yes"
      }
      listener "tcp" {
        address = "0.0.0.0:8200"
        tls_disable = 0
        tls_cert_file = "/var/lib/apps/vault/certs/vault.crt"
        tls_key_file = "/var/lib/apps/vault/certs/vault.key"
      }
      # if mlock is not supported
      # disable_mlock = true
      /* Need to install statesite for this to work 
      telemetry {
        statsite_address = "0.0.0.0:8125"
        disable_hostname = true
      }
      */
  - path: /var/lib/apps/vault/certs/vault.cnf
    permissions: 0644
    owner: root
    content: |
      [ req ]
      default_bits       = 2048
      default_md         = sha512
      default_keyfile    = vault.key
      distinguished_name = req_distinguished_name
      x509_extensions    = v3_req
      prompt             = no
      encrypt_key        = no

      [req_distinguished_name]
      C = US
      ST = CA
      L =  city
      O = company
      CN = *

      [v3_req]
      subjectKeyIdentifier = hash
      authorityKeyIdentifier = keyid,issuer
      basicConstraints = CA:TRUE
      subjectAltName = @alt_names

      [alt_names]
      DNS.1 = *
      DNS.2 = *.*
      DNS.3 = *.*.*
      DNS.4 = *.*.*.*
      DNS.5 = *.*.*.*.*
      DNS.6 = *.*.*.*.*.*
      DNS.7 = *.*.*.*.*.*.*
      IP.1 = $private_ipv4
      IP.2 = $public_ipv4
      IP.3 = 127.0.0.1
      IP.4 = ${vault_service_address}
  - path: /var/lib/apps/vault/certs/gen.sh
    permissions: 0700
    owner: root
    content: |      
      #!/bin/sh
      echo "creating the vault.key and vault.csr...."
      openssl req -new -out vault.csr -config vault.cnf
      echo "signing vault.csr..."
      openssl x509 -req -days 9999 -in vault.csr -CA ca.pem -CAkey ca.key \
              -CAcreateserial -extensions v3_req -out vault.crt -extfile vault.cnf
  - path: /var/lib/apps/vault/certs/ca.pem
    permissions: 0644
    owner: root
    content: |
      -----BEGIN CERTIFICATE-----
      MIID2jCCAsICCQDFuc3c4hwfyjANBgkqhkiG9w0BAQ0FADCBrjELMAkGA1UEBhMC
      VVMxCzAJBgNVBAgMAkNBMRYwFAYDVQQHDA1IYWxmIE1vb24gQmF5MQ4wDAYDVQQR
      DAU5NDAxOTESMBAGA1UECgwJRG9ja2VyYWdlMRYwFAYDVQQLDA1JVCBEZXBhcnRt
      ZW50MRgwFgYDVQQDDA9jYS5kb2NrZXIubG9jYWwxJDAiBgkqhkiG9w0BCQEWFWFk
      bWluQGNhLmRvY2tlci5sb2NhbDAeFw0xNjAzMDEwNjQzNTVaFw00MzA3MTcwNjQz
      NTVaMIGuMQswCQYDVQQGEwJVUzELMAkGA1UECAwCQ0ExFjAUBgNVBAcMDUhhbGYg
      TW9vbiBCYXkxDjAMBgNVBBEMBTk0MDE5MRIwEAYDVQQKDAlEb2NrZXJhZ2UxFjAU
      BgNVBAsMDUlUIERlcGFydG1lbnQxGDAWBgNVBAMMD2NhLmRvY2tlci5sb2NhbDEk
      MCIGCSqGSIb3DQEJARYVYWRtaW5AY2EuZG9ja2VyLmxvY2FsMIIBIjANBgkqhkiG
      9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnBnvGi9GoysVZHhbHh1aEQbO8g7EqkiElDQz
      RmLT7UZh3FaoSgdWKYdu1C8779trwzjPltjthxmrGuFIjPXZ3gBe3k6s/etf9na+
      QFa0lXmKmUX3LJAnwupmfC+fDFnVVN3beol8lW35eV/KGh8SXrbHrHpadcNdQURy
      /MnavNQXSFxcW8vyUUlkoaI8qIeKu/70wv98Nfb0I8HMDmuaJjqBaOXevD4CBUFr
      vrEQKWCF2DHomjDsCaQjxyoXAd85Ow8ZLxi6j4JmL2bFhR2bCfO0O8cpCHoU/W5g
      dZhgjbld/TdcMagOd409krolG69ReR4uibju1/xlsMtvdCnaFQIDAQABMA0GCSqG
      SIb3DQEBDQUAA4IBAQA6nkGIotTMZVZNiL3I9ZqGpSvN9AzENRt2ZvvJ9T2CGNX6
      e8H8H8lD/AAfGdiitYxSgTL47dYhQ3MgECSRqX7jEeW3wHxhTTxVuFUu2PNXUCio
      vbIm9kKqxspKSTN//BKDCAwHFUqYGiS8cw15HobpCnav9zmT7edRvdOEptM4VRJd
      2hIBkPEAW4OAF2D59Y6sZxHuUorkLhTRqOutl6h7sPbdUQeIfOqHMaX6T2xl6VtJ
      3I+Yza5TkVCPck88Q2PCECaXRSDN8UR5xTtXVBL1ikwdMsyEv7aD2ZzsET+djyZc
      jsZnSW1rVS7qOLwmOmOH2LMxknD0AOobvGkugZTA
      -----END CERTIFICATE-----
  - path: /var/lib/apps/vault/certs/ca.key
    permissions: 0600
    owner: root
    content: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpQIBAAKCAQEAnBnvGi9GoysVZHhbHh1aEQbO8g7EqkiElDQzRmLT7UZh3Fao
      SgdWKYdu1C8779trwzjPltjthxmrGuFIjPXZ3gBe3k6s/etf9na+QFa0lXmKmUX3
      LJAnwupmfC+fDFnVVN3beol8lW35eV/KGh8SXrbHrHpadcNdQURy/MnavNQXSFxc
      W8vyUUlkoaI8qIeKu/70wv98Nfb0I8HMDmuaJjqBaOXevD4CBUFrvrEQKWCF2DHo
      mjDsCaQjxyoXAd85Ow8ZLxi6j4JmL2bFhR2bCfO0O8cpCHoU/W5gdZhgjbld/Tdc
      MagOd409krolG69ReR4uibju1/xlsMtvdCnaFQIDAQABAoIBAG+GP8MvX4IXt9Lu
      AftD8SMVACkD0BHweXgAy1lQJiTxEd1/tAAfubk130KM9H9q/lSddAJLvXe2KP6t
      UU4UH7FyBlVBVGqdDRRixY3l5GKeUR0sVWlrHF0vZkT3KOSEEdvuHW4wZ+fCiGfk
      vdlntZIheAqL57EXALsukhB0jmg06TjsPS8zbbnOJPbU3ZjDUjxMgfMB8xvj8LxX
      kB9MB04ABkss47a7Ep5iHhhSQFu14udFiYOMvrrYbqp7l1zvzLYnsidrEGZIVcLr
      xW52UfDtR4AROofSWBNpPCxv4u5OvH1NYTE1OPo21lqXhRSYiEAtO4NiZEPdH8gp
      Az/XrsECgYEAyuDsdo0NwUuv3ByWEh+u3hOXAGa7LngwsdrlK7bUgqOfMukc6O+a
      ZRYPvTMm+h6K3gbcE6M2XdWNuPF+uwkJuDI35ZXQBCBOlovx1cOMV4g/VzrXbA34
      Tj61QytaZw/zQG+HwswfV12JH8L+HNpJ9EWtwJoWDzHWpg1Fp9+ErrkCgYEAxPl/
      zrzcXfrfiP7akACzQp931LH54+FRiPTH3n3+QrQRyT0CXTxkDR6rgaHr6DxWDSKo
      HRuvq73A1N3bucqrvr28krSgOge1kOAge76/X+BRlbdfXuNGsed4hgFyf71XTnGb
      AX6xeuKvkxqNe84nXmZgm69T7LQ8MHAA2H4R+D0CgYEAtXzeq/LlAiz2Bf8glNf4
      87sskvRTsG9eiExcRG3Kz48VxFJbRVnKkXFZ5RQUYx3ddl9Gkt6nrOt0W6TVjPW5
      1yg9bslFC9vm0bAhR+wl6Mv+dccynPwmS8C3IH5w4c+X+OWM2ksGIn6PQ3WJI0B3
      dei7VZfB8hfQgD1ROaqvpCkCgYEAo8HdrK2883D/aHCgmnnKjofvYuf4HakUVS1U
      ATh0K1ZzNv++uG7dqz6lTWelrfSDgfYfF9wNp1VhPFeaNhM1x6UMYldCohwIqgJ7
      XwWNKxNeIH9MDaIcAwmyXI5Vd7edHv055ftDaCuP1leL6rLQbh3lEWmo9zA8nfRv
      74yYOe0CgYEAo8f33HogLL5/xtKkovlmTN/M+8NPMtu550gr9OKxxgYbvmQ895qy
      hpSQnWoQ3z+Ry5sSXln4Ot5A5PfrlSCL35X7js/BOhjR3t45b9vT9KhAxmPRQiHO
      dpiWS6BVt6AA13lV4LXIMRZ+ITJ+BC2yvPprmSTrLrt0FPyC35PJBYU=
      -----END RSA PRIVATE KEY-----
  - path: /etc/profile.d/path.sh
    content: |
        export VAULT_CACERT=/var/lib/apps/vault/certs/ca.pem
        #export VAULT_ADDR=<vault-service-endpoint-ip>
        #export VAULT_CLIENT_CERT=/var/lib/apps/vault/certs/client.crt
        #export VAULT_CLIENT_KEY=/var/lib/apps/vault/certs/client.key
  - path: /var/log/vault/vault_audit.log
    permission: 0644
    content: |
        echo "Vault Audit Logs"
  - path: /artifacts/vault/acl.hcl
    permission: 0664
    owner: core
    content: |
        path "secret/*" {
          capabilities = ["create", "read"]
        }
  - path: /etc/profile.d/alias.sh
    content: |
        alias lal="ls -al"
        alias ll="ls -l"
        alias sd="sudo systemctl"
        alias sdl="sd list-units"
        alias sds="sd status"
        alias sdcat="sd cat"
        alias j="sudo journalctl"
        alias jfu="j -f -u"
        alias e="etcdctl"
        alias els="e ls --recursive"
        alias eget="e get"
        alias eset="e set"
        alias eok='e cluster-health'
        alias f="fleetctl -strict-host-key-checking=false"
        alias fcat="f cat"
        alias fss="f status"
        alias fst="f start"
        alias fdy="f destroy"
        alias flm="f list-machines"
        alias dk="docker "
        alias dkc="dk ps"
        alias dkm="dk images"
        alias dki="dk inspect"
        alias dkb="dk build"
        alias dke="dk exec"
        function dkip() { docker inspect --format "{{ .NetworkSettings.IPAddress }}" $1 ; }
        function dkid() { docker inspect --format "{{ .ID }}" $1 ; }
# end of files




