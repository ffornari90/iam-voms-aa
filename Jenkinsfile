pipeline {
    environment {
        iamBinariesImage = "ffornari/iam-binaries"
        trustImage = "ffornari/trustanchors"
        hostcertImage = "ffornari/hostcert"
        vomsClientImage = "ffornari/voms-client"
        registryCredential = 'dockerhub'
        gitCredential = 'baltig'
        BUILD_VERSION = "latest"
    }
    
    agent any
    
    stages {
        stage('Initial update status on gitlab') {
            steps {
                echo 'Notify GitLab'
                updateGitlabCommitStatus name: 'build', state: 'pending'
            }
        }
        stage('Cloning git repo') {
            steps {
                script {
                    withCredentials([gitUsernamePassword(credentialsId: 'baltig')]) {
                        try {
                            sh "rm -rf iam-voms-aa; git clone https://baltig.infn.it/fornari/iam-voms-aa.git"
                        } catch (e) {
                            updateGitlabCommitStatus name: 'clone', state: 'failed'
                        }
                    }
                }
            }
        }
        stage('Push docker-compose.yml to apache server') {
            steps {
                script {
                    try {
                        withCredentials([sshUserPrivateKey(credentialsId: "cloudApache", keyFileVariable: 'keyfile')]) {
                            sh "scp -o StrictHostKeyChecking=no -i ${keyfile} iam-voms-aa/compose/docker-compose.yml centos@131.154.97.87:iam-voms-aa.yml"
                            sh "ssh -o StrictHostKeyChecking=no -i ${keyfile} centos@131.154.97.87 sudo cp iam-voms-aa.yml /var/www/html/docker-compose/"
                        }
                    } catch (e) {
                        updateGitlabCommitStatus name: 'scp', state: 'failed'
                    }
                }
            }        
        }
        stage('Building docker images') {
            steps {
                script {
                    try {
                        sh "docker build -f iam-voms-aa/iam-binaries/Dockerfile -t $iamBinariesImage:$BUILD_VERSION iam-voms-aa/iam-binaries"
                        sh "docker build -f iam-voms-aa/trust/Dockerfile -t $trustImage:$BUILD_VERSION iam-voms-aa/trust"
                        sh "docker build -f iam-voms-aa/hostcert/Dockerfile -t $hostcertImage:$BUILD_VERSION iam-voms-aa/hostcert"
                        sh "docker build -f iam-voms-aa/voms-client/Dockerfile -t $vomsClientImage:$BUILD_VERSION iam-voms-aa/voms-client"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Logging into docker hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "$registryCredential", passwordVariable: 'Password', usernameVariable: 'User')]) {
                        try {
                            sh "docker login -u ${env.User} -p ${env.Password}"
                        } catch (e) {
                            updateGitlabCommitStatus name: 'login', state: 'failed'
                        }
                    }
                }
            }
        }
        stage('Deploying docker images') {
            steps {
                script {
                    try {
                        sh "docker push $iamBinariesImage:$BUILD_VERSION"
                        sh "docker push $trustImage:$BUILD_VERSION"
                        sh "docker push $hostcertImage:$BUILD_VERSION"
                        sh "docker push $vomsClientImage:$BUILD_VERSION"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Remove unused docker images') {
            steps {
                script {
                    try {
                        sh "docker rmi $iamBinariesImage:$BUILD_VERSION"
                        sh "docker rmi $trustImage:$BUILD_VERSION"
                        sh "docker rmi $hostcertImage:$BUILD_VERSION"
                        sh "docker rmi $vomsClientImage:$BUILD_VERSION"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'remove', state: 'failed'
                    }
                }
            }
        }
        stage('Final update status on gitlab') {
            steps {
                echo 'Notify GitLab'
                updateGitlabCommitStatus name: 'build', state: 'success'
            }
        }        
    }
}
