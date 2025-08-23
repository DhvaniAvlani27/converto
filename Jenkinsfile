pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'converto-saas'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'your-registry.com' // Change this to your Docker registry
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
        
        stage('Build') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm run build'
                    } else {
                        bat 'npm run build'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    // Add your test commands here
                    echo 'Running tests...'
                    // npm test
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    if (isUnix()) {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    } else {
                        bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                script {
                    if (isUnix()) {
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"
                        sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"
                    } else {
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"
                        bat "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                        bat "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo 'Deploying to staging environment...'
                    // Add your staging deployment logic here
                    // Example: kubectl apply -f k8s/staging/
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Deploying to production environment...'
                    // Add your production deployment logic here
                    // Example: kubectl apply -f k8s/production/
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up Docker images
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
