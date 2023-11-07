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
          CLUSTER_NAME = 'jenkins-cluster'
          LOCATION = 'europe-west9'
          CREDENTIALS_ID = 'secret_json'
          PROJECT_ID = "jenkins-cid"
          SERVICE_ACCOUNT = "service_account"
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
      stage('Analyze image') {
          steps {
              // Install Docker Scout
              sh 'curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh -s -- -b /usr/local/bin'
              
              // Log into Docker Hub
              sh 'echo $DOCKER_ACCOUNT_PSW | docker login -u $DOCKER_ACCOUNT_USR --password-stdin'

              // Analyze and fail on critical or high vulnerabilities
              sh 'docker-scout cves --format sarif --output report.json $imagename'
          }
      }
      stage('Deploiement Kubernetes'){
        steps{
          script{
              sh 'if [ ! command  -v ./google-cloud-sdk/bin/gcloud &> /dev/null]; then curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-451.0.0-linux-x86.tar.gz;fi'
              sh 'tar -xf google-cloud-cli-451.0.0-linux-x86.tar.gz;'
              sh './google-cloud-sdk/bin/gcloud auth activate-service-account $SERVICE_ACCOUNT --key-file=$CREDENTIALS_ID --project=$PROJECT_ID'
          }
          echo "Start deployment of deployment.yaml"
          step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: './kubernetes/python-app-deployment.yml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
}
        }
      } 
}
