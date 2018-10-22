variable "project_name" {
  description = "Product Name"
}

variable "region" {
  description = "Google Compute Region"
}

variable "private_ip_cidr_range" {
  description = "Google compute private network cidr notation"
}

variable "public_ip_cidr_range" {
  description = "Google compute public network cidr notation"
}

variable "environment" {
  description = "Product deployment environment"
}

variable "auto_create_subnetworks" {
  default = false
}
