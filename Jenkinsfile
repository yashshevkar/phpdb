pipeline{
    agent none
    environment{
        BUILD_SERVER_IP='ec2-user@172.31.1.199'
        //DEPLOY_SERVER_IP='ec2-user@13.234.240.74'
        IMAGE_NAME='devopstrainer/java-mvn-privaterepos:php$BUILD_NUMBER'     
        ACM_IP='ec2-user@172.31.8.121'
        AWS_ACCESS_KEY_ID =credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY=credentials("AWS_SECRET_ACCESS_KEY")
        //created a new credential of type secret text to store docker pwd
        DOCKER_REG_PASSWORD=credentials("DOCKER_REG_PASSWORD")
    }
    stages{
        stage('BUILD'){
           agent any
           steps{
            script{
                sshagent(['build-server']) {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                echo "BUILD PHP DOCKERIMAGE AND PUSH TO DOCKERHUB"
                sh "scp -o StrictHostKeyChecking=no -r docker-files ${BUILD_SERVER_IP}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no  ${BUILD_SERVER_IP} 'bash ~/docker-files/docker-script.sh'"
                sh "ssh  ${BUILD_SERVER_IP} sudo docker build -t ${IMAGE_NAME} /home/ec2-user/docker-files/"
                sh "ssh  ${BUILD_SERVER_IP} sudo docker login -u $USERNAME -p $PASSWORD"
                sh "ssh  ${BUILD_SERVER_IP} sudo docker push ${IMAGE_NAME}"
                }
            }
           }

        }
        }
         stage("Provision anisble target server with TF"){
            agent any
                   steps{
                       script{
                           dir('terraform'){
                           sh "terraform init"
                           sh "terraform apply --auto-approve"
                           ANSIBLE_TARGET_PUBLIC_IP = sh(
                            script: "terraform output ec2-ip",
                            returnStdout: true
                           ).trim()
                         echo "${ANSIBLE_TARGET_PUBLIC_IP}"   
                       }
                       }
                   }
        }
//         stage('DEPLOY with Ansible'){
//            agent any
//            steps{
//             script{
//                 sshagent(['ssh-key']) {
//                 withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
//                 echo "DEPLOY DOCKER CONTAINER USING DOCKER_COMPOSE"
//                 sh "scp -o StrictHostKeyChecking=no -r docker-files ${DEPLOY_SERVER_IP}:/home/ec2-user"
//                 sh "ssh -o StrictHostKeyChecking=no  ${DEPLOY_SERVER_IP} 'bash ~/docker-files/docker-script.sh'"
//                 sh "ssh  ${DEPLOY_SERVER_IP} sudo docker login -u $USERNAME -p $PASSWORD"
//                 sh "ssh  ${DEPLOY_SERVER_IP} bash /home/ec2-user/docker-files/docker-compose-script.sh ${IMAGE_NAME}"
                
//             }
//            }
//         }
//     }
// } 
    stage("RUN ansible playbook on ACM"){
    agent any
    steps{
        script{
            echo "copy ansible files on ACM and run the playbook"
            sshagent(['build-server']) {
    //sh "ssh -o StrictHostKeyChecking=no ${ACM_IP} envsubst < ansible/docker-compose-var.yml > ansible/docker-compose.yml" 
    sh "scp -o StrictHostKeyChecking=no ansible/* ${ACM_IP}:/home/ec2-user"
    
    //copy the ansible target key on ACM as private key file
    withCredentials([sshUserPrivateKey(credentialsId: 'Ansible_target',keyFileVariable: 'keyfile',usernameVariable: 'user')]){ 
    sh "scp  $keyfile ${ACM_IP}:/home/ec2-user/.ssh/id_rsa"    
    }
    sh "ssh  ${ACM_IP} bash /home/ec2-user/prepare-ACM.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${DOCKER_REG_PASSWORD} ${IMAGE_NAME}"
      }
        }
        }    
    }
    }
}
