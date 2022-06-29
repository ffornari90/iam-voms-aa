pipeline {
    environment {
        registry = "ffornari/voms-aa"
        registryCredential = 'dockerhub'
        gitCredential = 'baltig'
        BUILD_NUMBER = "latest"
    }
    
    agent any
    
    stages {
        stage('Cloning git') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'baltig')]) {
                    sh 'git clone https://baltig.infn.it/fornari/iam-voms-aa.git'
                }
            }
        }
        stage('Building image') {
            steps {
                script {
                    sh "cd iam-voms-aa/vomsng; docker build -t $registry:$BUILD_NUMBER ."
                }
            }
        }
        stage('Deploy image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$registryCredential", passwordVariable: 'Password', usernameVariable: 'User')]) {
                    sh "docker login -u ${env.User} -p ${env.Password}"
                    sh "docker push $registry:$BUILD_NUMBER"
                }
            }
        }
        stage('Remove unused docker image') {
            steps {
                sh "docker rmi $registry:$BUILD_NUMBER"
            }
        }
    }
}
