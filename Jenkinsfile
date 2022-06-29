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
        stage('Cloning git') {
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
        stage('Building trustanchors image') {
            steps {
                script {
                    try {
                        sh "cd iam-voms-aa/trust; docker build -t $trustImage:$BUILD_VERSION ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building hostcert image') {
            steps {
                script {
                    try {
                        sh "cd ../hostcert; docker build -t $hostcertImage:$BUILD_VERSION ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building iam backend v1.6.0 image') {
            steps {
                script {
                    try {
                        sh "cd ../iam-be/IAM_VERSION1; docker build -t $iamBEImage:$IAM_VERSION1 ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building iam backend v1.7.2 image') {
            steps {
                script {
                    try {
                        sh "cd ../IAM_VERSION2; docker build -t $iamBEImage:$IAM_VERSION2 ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building iam backend v1.8.0 image') {
            steps {
                script {
                    try {
                        sh "cd ../IAM_VERSION3; docker build -t $iamBEImage:$IAM_VERSION3 ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building iam nginx image') {
            steps {
                script {
                    try {
                        sh "cd ../../iam; docker build -t $iamImage:$BUILD_VERSION ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building nginx voms image') {
            steps {
                script {
                    try {
                        sh "cd ../nginx-voms; docker build -t $nginxVomsImage:$BUILD_VERSION ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Building voms-aa image') {
            steps {
                script {
                    try {
                        sh "cd ../vomsng; docker build -t $vomsAAImage:$BUILD_VERSION ."
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
        stage('Deploying trustanchors image') {
            steps {
                script {
                    try {
                        sh "docker push $trustImage:$BUILD_VERSION"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying hostcert image') {
            steps {
                script {
                    try {
                        sh "docker push $hostcertImage:$BUILD_VERSION"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying iam backend v1.6.0 image') {
            steps {
                script {
                    try {
                        sh "docker push $iamBEImage:$IAM_VERSION1"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying iam backend v1.7.2 image') {
            steps {
                script {
                    try {
                        sh "docker push $iamBEImage:$IAM_VERSION2"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying iam backend v1.8.0 image') {
            steps {
                script {
                    try {
                        sh "docker push $iamBEImage:$IAM_VERSION3"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying iam nginx image') {
            steps {
                script {
                    try {
                        sh "docker push $iamImage:$BUILD_VERSION"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying nginx voms image') {
            steps {
                script {
                    try {
                        sh "docker push $nginxVomsImage:$BUILD_VERSION"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Deploying voms-aa image') {
            steps {
                script {
                    try {
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
