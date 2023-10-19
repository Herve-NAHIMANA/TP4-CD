#!/bin/bash

##############################################################################
#                            Déclaration des variables                       #
##############################################################################
USER="root" # Remplacez "" par le nomutilisateur
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
   # terraform_url=$(curl -s https://releases.hashicorp.com/terraform/ | grep -o 'https://releases.hashicorp.com/terraform/[0-9.]\+/terraform_[0-9.]\+_linux_amd64.zip' | head -n 1)
    curl -o terraform.zip https://releases.hashicorp.com/terraform/1.6.2/terraform_1.6.2_linux_amd64.zip #à change à fonction de la version de terraform
    unzip terraform.zip
    mv terraform /usr/local/bin/
fi

# 2- Vérifier et installer Ansible si nécessaire
if ! command -v ansible &> /dev/null; then
     apt update
     apt install -y ansible
fi
./google-cloud-sdk/bin/gcloud services enable compute.googleapis.com --project=$PROJET
./google-cloud-sdk/bin/gcloud services enable cloudresourcemanager.googleapis.com --project=$PROJET
./google-cloud-sdk/bin/gcloud services enable iam.googleapis.com --project=$PROJET
# Vérification de la présence des fichiers Terraform et exécution de terraform init
if [ ! -d "terraforms" ]; then
    git clone https://github.com/Herve-NAHIMANA/TP4-CD.git
    cd TP4-CD/terraforms
else
    cd terraforms
fi
terraform init

# 3- Application de la création avec Terraform
terraform apply -auto-approve

##############################################################################
#                         Début création de la clé ssh                        #
##############################################################################
# 4- Vérifier si une clé SSH est présente sur la VM, sinon en créer une
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -C "$USER"
fi

# Lire le contenu du fichier dans une variable
contenu=$(cat ~/.ssh/id_rsa.pub)

# Exporter la variable d'environnement
export VARIABLE_CONTENU="$contenu"

# Afficher le contenu exporté
echo "$USER:$VARIABLE_CONTENU" > ssh_keys
##############################################################################
#                       Fin de création de la clé ssh                        #
##############################################################################

##############################################################################
#                    Début envoi de de la clé ssh sur les VM                  #
##############################################################################
echo "Début d'envoi de la clé ssh sur tous les vms "
# 5- Récupère la liste des noms et des zones d'instance à l'aide de gcloud
cd ..
instances_info=$(./google-cloud-sdk/bin/gcloud compute instances list --format="table(name)" --zones=$ZONE)
echo $instances_info > './ansible/nom_des_instances.txt'