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
  default = "10.2.0.0/28"
}
variable "gcp_project" {
  type        = string
  description = "Le sous-réseau vpc"
}