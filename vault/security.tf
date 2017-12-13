# Firewalls for vault
resource "google_compute_firewall" "vault-allow-service" {
    name = "default-allow-vault"
    description = "Allow vault from anywhere."
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["8200","80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["vault-server"]
}
