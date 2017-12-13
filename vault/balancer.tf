# vault service ip
resource "google_compute_address" "vault_service" {
   name = "vault-service"
}

output "vault_service_ip" {
    value = "${google_compute_address.vault_service.address}"
}

resource "null_resource" "vaul_env" {
    # write out a vault.env file for vault client
    # e.g. 
    # $ source vault.env
    # $ vault init

    # Changes to any instance of the cluster requires re-provisioning
    triggers {
        vault_service_address = "${google_compute_address.vault_service.address}"
    }

    provisioner "local-exec" {
        command = <<EOT
echo export VAULT_ADDR=https://${google_compute_address.vault_service.address}:8200 > vault.env
echo export VAULT_CACERT=$PWD/artifacts/certs/rootCA.pem >> vault.env
EOT
    }
}

# vault server pool
resource "google_compute_target_pool" "vault" {
    name = "vault-pool"
    description = "vault server pool"
    instances = ["${formatlist("%s/%s", google_compute_instance.vault.*.zone, google_compute_instance.vault.*.name)}"]

    health_checks = [ "${google_compute_http_health_check.vault.name}" ]
}

# Valt API did not have HEAD endpoint so there is no way to check, well not yet.
resource "google_compute_http_health_check" "vault" {
    name = "vault-health"
    port = "80"
    request_path = "/"
    check_interval_sec = 5
    timeout_sec = 5
}

resource "google_compute_forwarding_rule" "vault-service" {
    name = "vault-service"
    description = "bind the vault web service ip to target pool"
    target = "${google_compute_target_pool.vault.self_link}"
    ip_address = "${google_compute_address.vault_service.address}"
    ip_protocol = "TCP"
    port_range = "8200"
}
