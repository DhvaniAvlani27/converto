pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'converto-saas'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'localhost:5000'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm ci'
                    } else {
                        bat 'npm ci'
                    }
                }
            }
        }
        
        stage('Lint') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm run lint'
                    } else {
                        bat 'npm run lint'
                    }
                }
            }
        }
        
        stage('Clean') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'rm -rf .next node_modules/.cache'
                        sh 'npm run build'
                    } else {
                        bat 'if exist .next rmdir /s /q .next'
                        bat 'if exist node_modules\\.cache rmdir /s /q node_modules\\.cache'
                        bat 'npm run build'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    // npm test
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    if (isUnix()) {
                        sh "docker build --no-cache -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    } else {
                        bat "docker build --no-cache -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            steps {
                script {
                    echo '🚀 Deploying to production environment...'
                    if (isUnix()) {
                        sh "docker stop converto-prod || true"
                        sh "docker rm converto-prod || true"
                        sh "docker run -d --name converto-prod --restart unless-stopped -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "sleep 10"
                        sh "docker logs converto-prod"
                        sh "echo '✅ Production deployment completed on port 4000!'"
                    } else {
                        bat "docker stop converto-prod || exit 0"
                        bat "docker rm converto-prod || exit 0"
                        bat "docker run -d --name converto-prod --restart unless-stopped -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        bat "timeout /t 10 /nobreak"
                        bat "docker logs converto-prod"
                        bat "echo '✅ Production deployment completed on port 4000!'"
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                if (isUnix()) {
                    sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
                    sh "docker rmi ${DOCKER_IMAGE}:latest || true"
                } else {
                    bat "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
                    bat "docker rmi ${DOCKER_IMAGE}:latest || true"
                }
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
