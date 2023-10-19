pipeline {
      agent any
      options {
        skipStagesAfterUnstable()
    }
    environment {
          DOCKER_ACCOUNT = credentials('docker')
          imagename = "hizzo/my-image-python"
          gcloud_path = "./google-cloud-sdk/bin/"
          GCP_CREDENTIALS = 'gcp'
        }
      stages {
        stage('Prerequis') { // Compile and do unit testing
             steps {
                sh 'apt update'
                sh 'apt install -y docker.io'
           }
      }
      stage('Pull Images'){
         steps {
                script {
                    sh 'docker pull $imagename:latest'
                }
            }
      }
      stage('Création des vms'){
        steps{
          /* script{
            withCredentials([file(credentialsId: 'fa99b800-8b33-4947-b105-d032368ffb47', variable: 'GCP_CREDENTIALS')]) {
            sh 'cd terraform'
            sh 'terrafom init'
            sh 'terraform plan'
          }*/
          script{
              sh 'if [ ! command  -v ./google-cloud-sdk/bin/gcloud &> /dev/null]; then curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-451.0.0-linux-x86.tar.gz;fi'
              sh 'if [ -d  "./google-cloud-cli-451.0.0-linux-x86.tar.gz"]; then tar -xf google-cloud-cli-451.0.0-linux-x86.tar.gz; fi'
              //sh './google-cloud-sdk/bin/gcloud auth login --cred-file=cred.json'
              sh 'sh ./deployment.sh'
          }
        }
      } 
}
}
