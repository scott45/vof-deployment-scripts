variable "google_project_id" { 
    default = "vof-migration-test"
}

variable "account_file" {
    default = "../../shared/account.json"
}

variable "region" {
    default = "us-central1"
}

variable "zones" {
    type = "map"
    
    default = {
        zone0 = "us-central1-a"
        zone1 = "us-central1-b"
        zone2 = "us-central1-c"
        zone3 = "us-central1-f"
        zone4 = "us-central1-a"
        zone5 = "us-central1-b"
        zone6 = "us-central1-c"
        zone7 = "us-central1-f"
        zone8 = "us-central1-a"
        zone9 = "us-central1-b"
    }
}

variable "cluster_name" {
    default = "vault"
}

variable "cloud_config_template" {
    default = "artifacts/cloud_config.yaml.tpl"
}

variable "discovery_url_file" {
    default = "artifacts/discovery_url.txt"
}

variable "image" {
    default = "coreos-stable-1520-6-0-v20171012"
}

variable "machine_type" {
    default = "n1-standard-1"
}

variable "node_count" {
    default = 3
}

variable "vault_release_url" {
    default = "https://releases.hashicorp.com/vault/0.8.3/vault_0.8.3_linux_amd64.zip"
}

variable "vault_conf_file" {
    default = "artifacts/vault.hcl"
}

