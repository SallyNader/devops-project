/* groovylint-disable LineLength */
pipeline {
    agent any
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
                        sh """
                            terraform apply -var='aws_access_key=${aws_access_key}' -var='aws_secret_key=${aws_secret_key}' -auto-approve
                          """
                        
                       
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
                    sh """
                     chmod 400 mykey.pem
                     scp -o StrictHostKeyChecking=no -rp -i mykey.pem $WORKSPACE ec2-user@${BASTION_HOST_IP}:/home/ec2-user/devops-auto
                    chmod 400 mykey.pem
                    ssh -i mykey.pem  ec2-user@${BASTION_HOST_IP} -o StrictHostKeyChecking=no '
                    chmod 777 devops-auto
                        scp -o StrictHostKeyChecking=no -rp -i /home/ec2-user/devops-auto/terraform/IAC/mykey.pem  /home/ec2-user/devops-auto ec2-user@${KUBERNATES_IP}:/home/ec2-user/devops-auto
                        ssh -i /home/ec2-user/devops-auto/terraform/IAC/mykey.pem  ec2-user@${KUBERNATES_IP} -o StrictHostKeyChecking=no '
                       ls -la
                       chmod 777 /home/ec2-user/devops-auto
                       exit
                        '
                    exit
                    '

                """
                    }
                }
        }
    }
}
