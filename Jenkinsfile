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
                sh 'apt-get update'
                sh 'apt-get install -y docker.io'
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
          script{
            sh 'sh deployment.sh'
          }
        }
      }
}
}
