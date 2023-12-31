pipeline {
    environment {
        cloudApacheIP = "131.154.97.87"
        sidecarImage = "ffornari/sidecar"
        opensslImage = "ffornari/openssl"
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
                            sh "scp -o StrictHostKeyChecking=no -i ${keyfile} iam-voms-aa/compose/docker-compose.yml centos@$cloudApacheIP:iam-voms-aa.yml"
                            sh "ssh -o StrictHostKeyChecking=no -i ${keyfile} centos@$cloudApacheIP sudo cp iam-voms-aa.yml /var/www/html/docker-compose/"
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
                        sh "docker build -f iam-voms-aa/sidecar/Dockerfile -t $sidecarImage:$BUILD_VERSION iam-voms-aa/sidecar"
                        sh "docker build -f iam-voms-aa/openssl/Dockerfile -t $opensslImage:$BUILD_VERSION iam-voms-aa/openssl"
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
                        sh "docker push $sidecarImage:$BUILD_VERSION"
                        sh "docker push $opensslImage:$BUILD_VERSION"
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
                        sh "docker rmi $sidecarImage:$BUILD_VERSION"
                        sh "docker rmi $opensslImage:$BUILD_VERSION"
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
