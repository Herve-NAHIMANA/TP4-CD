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
  description = "La region pour le vpc"
}