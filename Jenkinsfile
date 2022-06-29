pipeline {
    environment {
        trustImage = "ffornari/trustanchors"
        hostcertImage = "ffornari/hostcert"
        iamBEImage = "ffornari/iam-login-service"
        iamImage = "ffornari/nginx"
        nginxVomsImage = "ffornari/ngx-voms"
        vomsAAImage = "ffornari/voms-aa"
        registryCredential = 'dockerhub'
        gitCredential = 'baltig'
        BUILD_VERSION = "latest"
        IAM_VERSION1 = "v1.6.0"
        IAM_VERSION2 = "v1.7.2"
        IAM_VERSION3 = "v1.8.0"
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
        stage('Building docker images') {
            steps {
                script {
                    try {
                        sh "docker build -f iam-voms-aa/trust/Dockerfile -t $trustImage:$BUILD_VERSION iam-voms-aa/trust"
                        sh "docker build -f iam-voms-aa/hostcert/Dockerfile -t $hostcertImage:$BUILD_VERSION iam-voms-aa/hostcert"
                        sh "docker build -f iam-voms-aa/iam-be/$IAM_VERSION1/Dockerfile -t $iamBEImage:$IAM_VERSION1 iam-voms-aa/iam-be/$IAM_VERSION1"
                        sh "docker build -f iam-voms-aa/iam-be/$IAM_VERSION2/Dockerfile -t $iamBEImage:$IAM_VERSION2 iam-voms-aa/iam-be/$IAM_VERSION2"
                        sh "docker build -f iam-voms-aa/iam-be/$IAM_VERSION3/Dockerfile -t $iamBEImage:$IAM_VERSION3 iam-voms-aa/iam-be/$IAM_VERSION3"
                        sh "docker build -f iam-voms-aa/iam/Dockerfile -t $iamImage:$BUILD_VERSION iam-voms-aa/iam"
                        sh "docker build -f iam-voms-aa/nginx-voms/Dockerfile -t $nginxVomsImage:$BUILD_VERSION iam-voms-aa/nginx-voms"
                        sh "docker build -f iam-voms-aa/vomsng/Dockerfile -t $vomsAAImage:$BUILD_VERSION iam-voms-aa/vomsng"
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
                        sh "docker push $trustImage:$BUILD_VERSION"
                        sh "docker push $hostcertImage:$BUILD_VERSION"
                        sh "docker push $iamBEImage:$IAM_VERSION1"
                        sh "docker push $iamBEImage:$IAM_VERSION2"
                        sh "docker push $iamBEImage:$IAM_VERSION3"
                        sh "docker push $iamImage:$BUILD_VERSION"
                        sh "docker push $nginxVomsImage:$BUILD_VERSION"
                        sh "docker push $vomsAAImage:$BUILD_VERSION"
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
                        sh "docker rmi $trustImage:$BUILD_VERSION"
                        sh "docker rmi $hostcertImage:$BUILD_VERSION"
                        sh "docker rmi $iamBEImage:$IAM_VERSION1"
                        sh "docker rmi $iamBEImage:$IAM_VERSION2"
                        sh "docker rmi $iamBEImage:$IAM_VERSION3"
                        sh "docker rmi $iamImage:$BUILD_VERSION"
                        sh "docker rmi $nginxVomsImage:$BUILD_VERSION"
                        sh "docker rmi $vomsAAImage:$BUILD_VERSION"
                        sh "docker rmi \$(docker images -f \"reference=indigoiam/*\" -q)"
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
