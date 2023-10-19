#!/bin/bash

##############################################################################
#                            Déclaration des variables                       #
##############################################################################
USER="jenkins" # Remplacez "" par le nomutilisateur

# Remplacez "VOTRE_PROJET" par l'ID de votre projet GCP
PROJET="jenkins-cid"
# Remplacez la valeur de la zone
ZONE="us-east1-b"
# Séparateur par défaut en bash (utilisé pour les boucles)
    IFS=$'\n'
# 1- Vérifier et installer Terraform si nécessaire
if ! command -v terraform &> /dev/null; then
    apt-get update
    apt install unzip
    terraform_url=$(curl -s https://releases.hashicorp.com/terraform/ | grep -o 'https://releases.hashicorp.com/terraform/[0-9.]\+/terraform_[0-9.]\+_linux_amd64.zip' | head -n 1)
    curl -o terraform.zip $terraform_url
    unzip terraform.zip
    mv terraform /usr/local/bin/
fi

# 2- Vérifier et installer Ansible si nécessaire
if ! command -v ansible &> /dev/null; then
     apt update
     apt install -y ansible
fi

# /google-cloud-sdk/bin/gcloud services enable compute.googleapis.com --project=$PROJET
# /google-cloud-sdk/bin/gcloud services enable cloudresourcemanager.googleapis.com --project=$PROJET
# /google-cloud-sdk/bin/gcloud services enable iam.googleapis.com --project=$PROJET
# Vérification de la présence des fichiers Terraform et exécution de terraform init
if [ ! -d "terraform" ]; then
    git clone https://github.com/Herve-NAHIMANA/TP4-CD.git
    cd TP4-CD/terraform
else
    cd terraform
fi
terraform init

# 3- Application de la création avec Terraform
terraform apply -auto-approve