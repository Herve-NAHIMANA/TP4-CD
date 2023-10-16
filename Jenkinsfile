pipeline {
      agent any
      options {
        skipStagesAfterUnstable()
    }
    environment {
          //DOCKER_ACCOUNT = credentials('docker')
          imagename = "hizzo/my-image-python"
        }
      stages {
        stage('Prerequis') { // Compile and do unit testing
             steps {
                sh 'apt install -y docker.io'
                /* sh 'cd ./app'
                sh 'apt update'
                sh 'apt install -y python3'
                sh 'apt install -y python3-pip'
                sh 'apt install -y python3.11-venv'
                sh 'python3 -m venv venv'                  // Créer l'environnement virtuel
                sh '. venv/bin/activate'
                sh 'pip install pylint --break-system-packages'
                sh 'pip install pylint-json2html --break-system-packages'
                sh 'pip install radon --break-system-packages'
                sh 'pip install json2tree --break-system-packages'
                sh 'pip install html-testRunner --break-system-packages'
                sh ' if [ ! -d "./app/reports" ]; then mkdir ./app/reports/; fi' */
           }
      }
/*       stage('login'){
        steps{
          sh 'echo $DOCKER_ACCOUNT_PSW | docker login -u $DOCKER_ACCOUNT_USR --password-stdin'
        }
      } */
      stage('Pull Images'){
         steps {
                script {
                    sh 'docker pull $imagename:latest'
                }
            }
      }
      stage('Test de vulnérabilités'){
         steps {
                script {
                    sh 'docker scout cves  $imagename:latest'
                }
            }
      }
 }
 /* post {
  always {
    sh 'docker logout'
  }
 } */
}
