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
      /* Need to install statesite for this to work 
      telemetry {
        statsite_address = "0.0.0.0:8125"
        disable_hostname = true
      }
      */