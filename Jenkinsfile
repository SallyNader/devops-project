pipeline {
    agent any
    environment {
        SONARQUBE_TOKEN = credentials('sonarqube_token')
        SONARQUBE_URL = 'http://localhost:9095'
    }
    stages {
      stage('terraform init') {
        steps {
          dir('terraform/IAC') {
            sh '''
                terraform init
              '''
          }
        }
      }

      stage('build infrastructure') {
        steps {
          withCredentials([usernamePassword(credentialsId: 'aws', passwordVariable: 'aws_secret_key', usernameVariable: 'aws_access_key')]) {
            dir('terraform/IAC') {
              sh '''
                  terraform apply -var='aws_access_key=${aws_access_key}' -var='aws_secret_key=${aws_secret_key}' -auto-approve
                '''
            }
          }
          script {
            dir('terraform/IAC') {
              BASTION_HOST_IP = sh (
                  script: 'terraform output bastion-host-public_ip',
                  returnStdout: true
              ).trim()

              KUBERNATES_IP = sh (
                  script: 'terraform output kubernetes-private-ip',
                  returnStdout: true
              ).trim()

              echo "Kubernetes host ip: ${KUBERNATES_IP}"
              echo "Bastion host ip: ${BASTION_HOST_IP}"
            }
          }
        }
      }
      stage('deploy code') {
        steps {
          dir('terraform/IAC') {
            sh '''
                chmod 400 mykey.pem
                scp -o StrictHostKeyChecking=no -rp -i mykey.pem $WORKSPACE ec2-user@${BASTION_HOST_IP}:/home/ec2-user/project

              '''
          }
        }
      }
      stage('sonarqube analysis') {
        steps {
          dir('kubernetes-automation') {
            sh " sed -i -e 's|URL|${SONARQUBE_URL}|; s|TOKEN|${SONARQUBE_TOKEN}|' sonar-project.properties"

            nodejs(nodeJSInstallationName: 'nodejs') {
              sh 'npm install'
              withSonarQubeEnv('sonar') {
                sh '''
                    npm set strict-ssl false
                    npm install sonar-scanner
                    npm run sonar
                  '''
              }
            }
          }
        }
      }
    }
}

