variable "vpc_name" {
  type        = string
  description = "Le réseau vpc"
}
variable "subnet_name" {
  type        = string
  description = "Le sous-réseau vpc"
}
variable "gcp_region" {
  type        = string
  description = "Le sous-réseau vpc"
}
variable "gke_master_ipv4_cidr_block" {
  type    = string
  default = "172.23.0.0/28"
}