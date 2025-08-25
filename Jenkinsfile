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
                // Stop & remove old container safely
                sh "docker ps -a -q --filter name=converto-prod | xargs -r docker stop"
                sh "docker ps -a -q --filter name=converto-prod | xargs -r docker rm"
                
                // Run container on free port (change 6000 if needed)
                sh "docker run -d --name converto-prod --restart unless-stopped -p 6000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                sh "sleep 10"
                sh "docker logs converto-prod"
                sh "echo '✅ Production deployment completed on port 6000!'"
            } else {
                // Windows PowerShell version
                powershell """
                    # Stop & remove old container if exists
                    \$c = docker ps -a -q -f name=converto-prod
                    if (\$c) { docker stop \$c; docker rm \$c }

                    # Run new container on port 6000
                    docker run -d --name converto-prod --restart unless-stopped -p 6000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}

                    Start-Sleep -Seconds 10
                    docker logs converto-prod
                    Write-Host '✅ Production deployment completed on port 6000!'
                """
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
