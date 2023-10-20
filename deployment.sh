#!/bin/bash

##############################################################################
#                            Déclaration des variables                       #
##############################################################################
USER="ange.igiraneza2000@gmail.com" # Remplacez "" par le nomutilisateur
# Remplacez "VOTRE_PROJET" par l'ID de votre projet GCP
PROJET="jenkins-cid"
# Remplacez la valeur de la zone
ZONE="us-east1-a"
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
     apt install -y python3-pip
     apt install -y ansible
     yes | pip3 install google-auth
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
if [ -f ~/.ssh/id_rsa ]; then
    rm ~/.ssh/id_rsa
    rm ~/.ssh/id_rsa.pub
fi
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -C "$USER"

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
instances_info=$(./google-cloud-sdk/bin/gcloud compute instances list --format="csv(name,zone)" --zones=$ZONE)
echo $instances_info > './ansible/nom_des_instances.txt'

# 6- Vérifie si des instances sont trouvées
if [ -z "$instances_info" ]; then
    echo "Aucune instance trouvée dans le projet $PROJET."
else
    echo "Liste des noms et des zones d'instance dans le projet $PROJET :"
# Affichage du tableau des instances
    echo "+--------------------------------+------------------------------+"
    printf "| %-30s |%-30s|\n" "Nom d'instance" "Zone"
    echo "+--------------------------------+------------------------------+"
    for instance_info in $instances_info; do
        # Découpe la ligne en nom et zone
        IFS=',' read -r instance_name zone <<< $(echo "$instance_info")

        if [ "$instance_name" != "name" ] || [ "$zone" != "zone" ]; then        
            # Affiche les valeurs dans le tableau
            printf "| %-30s |%-30s|\n" "$instance_name" "$zone"
        fi
    done
    echo "+--------------------------------+------------------------------+"
    # Boucle pour traiter chaque nom d'instance et sa zone
    for instance_info in $instances_info; do
        # Découpe la ligne en nom et zone
        IFS=',' read -r instance_name zone <<< $(echo "$instance_info")

        if [ "$instance_name" != "name" ] || [ "$zone" != "zone" ]; then      
            echo "Traitement de l'instance : $instance_name (zone : $zone)"

            # Exécute la commande gcloud avec le nom d'instance et la zone actuels
            ./google-cloud-sdk/bin/gcloud compute instances add-metadata "$instance_name" --zone "$zone" --metadata-from-file ssh-keys=terraforms/ssh_keys --project $PROJET

            # Vérifie le code de sortie de la commande gcloud
            if [ $? -eq 0 ]; then
                echo "Clé SSH ajoutée à l'instance $instance_name (zone : $zone) avec succès."
            else
                echo "Une erreur s'est produite lors de l'ajout de la clé SSH à l'instance $instance_name (zone : $zone)."
            fi
        fi
    done   
fi
##############################################################################
#                       Fin de d'envoi de la clé                             #
##############################################################################
##############################################################################
#                       Lancement des playbooks                              #
##############################################################################
cd ansible
ansible-playbook playbook_docker.yml -i "gcp_compute.yaml" -e "ansible_user=$USER"