variable "gcp_project" {
  type        = string
  default     = "jenkins-cid"
  description = "The GCP project to deploy the runner into."
}
variable "gcp_zone" {
  type        = string
  default     = "us-east1-a"
  description = "The GCP zone to deploy the runner into."
}

variable "gcp_region" {
  type        = string
  default     = "us-east1"
  description = "The GCP region to deploy the runner into."
}
# Variables pour le VPC à remplacer si nécessaire
variable "vpc_name" {
  type        = string
  default     = "test-network"
  description = "Le réseau vpc"
}
variable "subnet_name" {
  type        = string
  default     = "test-subnetwork"
  description = "Le sous-réseau vpc"
}

# Variables pour instances à remplacer si nécessaire

variable "instance_name" {
  type = string
  default = "test-vm"
}
variable "image_disk" {
  type        = string
  default     = "debian-cloud/debian-11"
  description = "L'image de l'OS à utiliser"
}
variable "machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Le type des instances"
}
# Variables pour le service account à remplacer si nécessaire
variable "account" {
  type        = string
  default     = "jenkins-test"
}
variable "key_type" {
  type        = string
  default     = "TYPE_X509_PEM_FILE"
}
variable "file_name" {
    type = string
    default = "service_account.json"
}

