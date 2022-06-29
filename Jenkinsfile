pipeline {
    environment {
        registry = "ffornari/voms-aa"
        registryCredential = 'dockerhub'
        gitCredential = 'baltig'
        BUILD_NUMBER = "latest"
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
                withCredentials([gitUsernamePassword(credentialsId: 'baltig')]) {
                    try {
                        sh "rm -rf iam-voms-aa; git clone https://baltig.infn.it/fornari/iam-voms-aa.git"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'clone', state: 'failed'
                    }
                }
            }
        }
        stage('Building image') {
            steps {
                script {
                    try {
                        sh "cd iam-voms-aa/vomsng; docker build -t $registry:$BUILD_NUMBER ."
                    } catch (e) {
                        updateGitlabCommitStatus name: 'build', state: 'failed'
                    }
                }
            }
        }
        stage('Deploy image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$registryCredential", passwordVariable: 'Password', usernameVariable: 'User')]) {
                    try {
                        sh "docker login -u ${env.User} -p ${env.Password}"
                        sh "docker push $registry:$BUILD_NUMBER"
                    } catch (e) {
                        updateGitlabCommitStatus name: 'push', state: 'failed'
                    }
                }
            }
        }
        stage('Remove unused docker image') {
            steps {
                try {
                    sh "docker rmi $registry:$BUILD_NUMBER"
                } catch (e) {
                    updateGitlabCommitStatus name: 'remove', state: 'failed'
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
