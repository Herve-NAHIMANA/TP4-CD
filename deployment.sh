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
    apt-get update &&  apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
    apt update
    apt-get install terraform
fi

# 2- Vérifier et installer Ansible si nécessaire
if ! command -v ansible &> /dev/null; then
     apt update
     apt install -y ansible
fi

/google-cloud-sdk/bin/gcloud services enable compute.googleapis.com --project=$PROJET
/google-cloud-sdk/bin/gcloud services enable cloudresourcemanager.googleapis.com --project=$PROJET
/google-cloud-sdk/bin/gcloud services enable iam.googleapis.com --project=$PROJET
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
