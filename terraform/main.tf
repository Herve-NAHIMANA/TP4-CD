terraform {
  required_version = "~>1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.63"
    }
  }
backend "local" {
    path = "./etat.tfstate"
  }
}
provider "google" {
  region = var.gcp_region
  zone   = var.gcp_zone
  project = var.gcp_project
}

module "service_account"{
  source = "./service_account"
  gcp_project = var.gcp_project
  key_type = var.key_type
  file_name = var.file_name
  account = var.account
}
module "vpc" {
  source = "./vpc"
  vpc_name = var.vpc_name
  subnet_name = var.subnet_name
  depends_on = [module.service_account]
}
module "firewall" {
  source = "./firewall"
  vpc_name = var.vpc_name
  depends_on = [module.vpc]
}
module "instances" {
  source     = "./instance"
  instance_name = var.instance_name
  image_disk = var.image_disk
  machine_type = var.machine_type
  vpc_name = var.vpc_name
  subnet_name = var.subnet_name
  depends_on = [module.firewall]
}
