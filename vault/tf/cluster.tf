resource "google_compute_instance" "vault" {
    count = "${var.node_count}"
    name = "vault-${count.index+1}"
    machine_type = "${var.machine_type}"
    zone = "${lookup(var.zones, format("zone%d", count.index))}"
    tags = ["vault-server"]
    can_ip_forward = true

    boot_disk {
        initialize_params {
            image = "${var.image}"
        }
    }

    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }

    metadata {
        "cluster-size" = "${var.node_count}"
        "user-data" = "${data.template_file.cloud_config.rendered}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}

data "template_file" "cloud_config" {

    depends_on = ["null_resource.etcd_discovery_url"]
    template = "${file("${var.cloud_config_template}")}"
    vars {
        "etcd_discovery_url" = "${file(var.discovery_url_file)}"
        "size" = "${var.node_count}"
        "vault_release_url" ="${var.vault_release_url}"
        "vault_service_address" = "${google_compute_address.vault_service.address}"
    }

}

resource "null_resource" "etcd_discovery_url" {
    provisioner "local-exec" {
        command = "curl -s https://discovery.etcd.io/new?size=${var.node_count} > ${var.discovery_url_file}"
    }
}
