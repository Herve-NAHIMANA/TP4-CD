pipeline {
      agent any
      options {
        skipStagesAfterUnstable()
    }
    environment {
          DOCKER_ACCOUNT = credentials('docker')
          imagename = "hizzo/my-image-python"
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
            withCredentials(jenkins-cid) {
              sh 'sh ./deployment.sh'
            }
          }
        }
      } 
}
}
