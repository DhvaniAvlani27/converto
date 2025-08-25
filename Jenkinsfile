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
                        // Force clean build without cache
                        sh "docker build --no-cache -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    } else {
                        // Force clean build without cache
                        bat "docker build --no-cache -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    echo '📦 Pushing to Docker Registry...'
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
            steps {
                script {
                    echo '🚀 Deploying to staging environment...'
                    if (isUnix()) {
                        // Deploy to staging with Kubernetes
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl rollout status deployment/converto-saas"
                        sh "echo '✅ Staging deployment completed!'"
                    } else {
                        // Deploy to staging with Docker
                        bat "docker run -d --name converto-staging --restart unless-stopped -p 3001:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        bat "echo '✅ Staging deployment completed on port 3001!'"
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            steps {
                script {
                    echo '🚀 Deploying to production environment...'
                    if (isUnix()) {
                        // Force stop and remove previous production container
                        sh "docker stop converto-prod || true"
                        sh "docker rm converto-prod || true"
                        
                        // Run production container on port 4000
                        sh "docker run -d --name converto-prod --restart unless-stopped -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Wait for container to be ready
                        sh "sleep 10"
                        sh "docker logs converto-prod"
                        sh "echo '✅ Production deployment completed on port 4000!'"
                    } else {
                        // Force stop and remove previous production container
                        bat "docker stop converto-prod || exit 0"
                        bat "docker rm converto-prod || exit 0"
                        
                        // Run production container on port 4000
                        bat "docker run -d --name converto-prod --restart unless-stopped -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Wait for container to be ready
                        bat "timeout /t 10 /nobreak"
                        bat "docker logs converto-prod"
                        bat "echo '✅ Production deployment completed on port 4000!'"
                    }
                }
            }
        }
        
        stage('Deploy with ngrok') {
            steps {
                script {
                    echo '🌐 Deploying with ngrok for public access...'
                    
                    // Force stop and remove previous ngrok container
                    if (isUnix()) {
                        sh "docker stop converto-live || true"
                        sh "docker rm converto-live || true"
                        
                        // Run new container with restart policy
                        sh "docker run -d --name converto-live --restart unless-stopped -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Wait for container to be ready
                        sh "sleep 10"
                        sh "docker logs converto-live"
                        
                        // Start ngrok tunnel
                        sh "chmod +x scripts/ngrok-deploy.sh"
                        sh "./scripts/ngrok-deploy.sh"
                        
                        // Get live URL and display prominently
                        sh "echo '🌐 Live URL:' && cat .ngrok_url || echo 'Failed to get ngrok URL'"
                        sh "echo '🚀 DISPLAYING LIVE URL:' && ./scripts/display-url.sh || echo 'Display script not available'"
                    } else {
                        bat "docker stop converto-live || exit 0"
                        bat "docker rm converto-live || exit 0"
                        
                        // Run new container with restart policy
                        bat "docker run -d --name converto-live --restart unless-stopped -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Wait for container to be ready
                        bat "timeout /t 10 /nobreak"
                        bat "docker logs converto-live"
                        
                        // Start ngrok tunnel (PowerShell)
                        bat "powershell -ExecutionPolicy Bypass -File scripts\\ngrok-deploy.ps1"
                        
                        // Get live URL and display prominently
                        bat "type .ngrok_url || echo Failed to get ngrok URL"
                        bat "echo 🚀 DISPLAYING LIVE URL: && powershell -ExecutionPolicy Bypass -File scripts\\display-url.ps1 || echo Display script not available"
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up Docker 
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
