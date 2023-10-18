#!/bin/bash

##############################################################################
#                            Déclaration des variables                       #
##############################################################################
USER="" # Remplacez "" par le nomutilisateur

# Remplacez "VOTRE_PROJET" par l'ID de votre projet GCP
PROJET=""

# Remplacez la valeur de la zone
ZONE="us-east1-b"
# Séparateur par défaut en bash (utilisé pour les boucles)
    IFS=$'\n'
# 1- Vérifier et installer Terraform si nécessaire
if ! command -v terraform &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install terraform
fi

# 2- Vérifier et installer Ansible si nécessaire
if ! command -v ansible &> /dev/null; then
    sudo apt update
    sudo apt install -y ansible
fi

gcloud services enable compute.googleapis.com --project=$PROJET
gcloud services enable cloudresourcemanager.googleapis.com --project=$PROJET
gcloud services enable iam.googleapis.com --project=$PROJET
# Vérification de la présence des fichiers Terraform et exécution de terraform init
if [ ! -d "terraform" ]; then
    git clone https://github.com/Herve-NAHIMANA/TP1_Deploiement_Wordpress.git
    cd TP1_Deploiement_Wordpress/terraform
else
    cd terraform
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
instances_info=$(gcloud compute instances list --project $PROJET --format="csv(NAME,ZONE)")
echo $instances_info > '../ansible/nom_des_instances.txt'

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
        IFS=',' read -r instance_name zone <<< "$instance_info"

        if [ "$instance_name" != "name" ] || [ "$zone" != "zone" ]; then        
            # Affiche les valeurs dans le tableau
            printf "| %-30s |%-30s|\n" "$instance_name" "$zone"
        fi
    done
    echo "+--------------------------------+------------------------------+"
    # Boucle pour traiter chaque nom d'instance et sa zone
    for instance_info in $instances_info; do
        # Découpe la ligne en nom et zone
        IFS=',' read -r instance_name zone <<< "$instance_info"

        if [ "$instance_name" != "name" ] || [ "$zone" != "zone" ]; then      
            echo "Traitement de l'instance : $instance_name (zone : $zone)"

            # Exécute la commande gcloud avec le nom d'instance et la zone actuels
            gcloud compute instances add-metadata "$instance_name" --zone "$zone" --metadata-from-file ssh-keys=ssh_keys --project $PROJET

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
cd ../ansible

if grep -q "instance-wordpress" nom_des_instances.txt; then
    ansible-playbook playbook_wordpress.yml -i "./gcp_compute.yml"
fi
if grep -q "instance-db" nom_des_instances.txt; then
    ansible-playbook playbook_db.yml -i "./gcp_compute.yml"
fi
# 7- Vérification que l'application fonctionne
wordpress_ip="$(gcloud compute instances describe instance-wordpress --project $PROJET --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')"
echo $wordpress_ip
status_code=$(curl -s -o /dev/null -w "%{http_code}" $wordpress_ip)
if [ $status_code -eq 200 ] || [ $status_code -eq 302 ] || [ $status_code -eq 301 ]; then
  echo "L'application WordPress est fonctionnelle. Code: $status_code"
else
  echo "L'application WordPress n\'est pas fonctionnelle. Code: $status_code"
fi
