variable "instance_name" {
  type = string
  description = "L'image de l'OS à utiliser"
}
variable "image_disk" {
  type        = string
  description = "L'image de l'OS à utiliser"
}
variable "machine_type" {
  type        = string
  description = "Le type des instances"
}
variable "vpc_name" {
  type        = string
  description = "Le réseau vpc"
}
variable "subnet_name" {
  type        = string
  description = "Le sous-réseau vpc"
}