pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'converto-saas'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'your-registry.com' // Change this to your Docker registry
        BRANCH_NAME = "${env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'main'}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    echo "🔍 Debug Information:"
                    echo "Current branch: ${env.BRANCH_NAME}"
                    echo "Git branch: ${env.GIT_BRANCH}"
                    echo "Build branch: ${env.BUILD_BRANCH}"
                    echo "Workspace: ${env.WORKSPACE}"
                    sh 'git branch -a'
                    sh 'git log --oneline -1'
                }
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
                    
                    // Test Docker functionality
                    echo '🧪 Testing Docker setup...'
                    if (isUnix()) {
                        sh "docker --version"
                        sh "docker ps"
                    } else {
                        bat "docker --version"
                        bat "docker ps"
                    }
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
            steps {
                script {
                    echo '🚀 Deploying to production on localhost:4000...'
                    echo "Current branch detected: ${env.BRANCH_NAME}"
                    echo "Development will continue on port 3000"
                    echo "Production will be deployed on port 4000"
                    
                    // Build Docker image
                    if (isUnix()) {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                        
                        // Stop previous production container
                        sh "docker stop converto-live || true"
                        sh "docker rm converto-live || true"
                        
                        // Run new production container on port 4000
                        sh "docker run -d --name converto-live -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Wait for container to be ready
                        sh "echo '⏳ Waiting for production container to be ready...'"
                        sh "sleep 10"
                        
                        // Display production URL prominently
                        sh "echo ''"
                        sh "echo '🎉 PRODUCTION DEPLOYMENT COMPLETE!'"
                        sh "echo '====================================='"
                        sh "echo '🌐 Production URL: http://localhost:4000'"
                        sh "echo '🔗 Health Check: http://localhost:4000/api/health'"
                        sh "echo '📱 Your app is now running on port 4000!'"
                        sh "echo '====================================='"
                        sh "echo ''"
                    } else {
                        bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                        
                        // Stop previous production container
                        bat "docker stop converto-live || exit 0"
                        bat "docker rm converto-live || exit 0"
                        
                        // Run new production container on port 4000
                        bat "docker run -d --name converto-live -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Wait for container to be ready
                        bat "echo ⏳ Waiting for production container to be ready..."
                        bat "timeout /t 10 /nobreak"
                        
                        // Display production URL prominently
                        bat "echo."
                        bat "echo 🎉 PRODUCTION DEPLOYMENT COMPLETE!"
                        bat "echo =====================================
                        bat "echo 🌐 Production URL: http://localhost:4000
                        bat "echo 🔗 Health Check: http://localhost:4000/api/health
                        bat "echo 📱 Your app is now running on port 4000!
                        bat "echo =====================================
                        bat "echo."
                    }
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
