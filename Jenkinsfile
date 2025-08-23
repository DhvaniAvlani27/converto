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
                    
                    // Test ngrok functionality
                    echo '🧪 Testing ngrok setup...'
                    if (isUnix()) {
                        sh "chmod +x scripts/test-ngrok.sh"
                        sh "./scripts/test-ngrok.sh"
                    } else {
                        bat "powershell -ExecutionPolicy Bypass -File scripts\\test-ngrok.ps1"
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
        
        stage('Deploy with ngrok') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'mainline'
                    expression { env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master' }
                }
            }
            steps {
                script {
                    echo '🚀 Deploying with ngrok for live access...'
                    
                    // Build Docker image
                    if (isUnix()) {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                        
                        // Stop previous container
                        sh "docker stop converto-live || true"
                        sh "docker rm converto-live || true"
                        
                        // Run new container
                        sh "docker run -d --name converto-live -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Start ngrok tunnel
                        sh "chmod +x scripts/ngrok-deploy.sh"
                        sh "./scripts/ngrok-deploy.sh"
                        
                        // Get live URL and display prominently
                        sh "echo '🌐 Live URL:' && cat .ngrok_url || echo 'Failed to get ngrok URL'"
                        sh "echo '🚀 DISPLAYING LIVE URL:' && ./scripts/display-url.sh || echo 'Display script not available'"
                    } else {
                        bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                        
                        // Stop previous container
                        bat "docker stop converto-live || exit 0"
                        bat "docker rm converto-live || exit 0"
                        
                        // Run new container
                        bat "docker run -d --name converto-live -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        // Start ngrok tunnel (PowerShell)
                        bat "powershell -ExecutionPolicy Bypass -File scripts\\ngrok-deploy.ps1"
                        
                        // Get live URL and display prominently
                        bat "type .ngrok_url || echo Failed to get ngrok URL"
                        bat "echo 🚀 DISPLAYING LIVE URL: && powershell -ExecutionPolicy Bypass -File scripts\\display-url.ps1 || echo Display script not available"
                    }
                }
            }
        }
        
        stage('Always Deploy with ngrok') {
            steps {
                script {
                    echo '🚀 Always deploying with ngrok for live access on port 4000...'
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
                        
                        // Start ngrok tunnel to port 4000
                        sh "chmod +x scripts/ngrok-deploy.sh"
                        sh "./scripts/ngrok-deploy.sh --port 4000"
                        
                        // Get live URL and display prominently
                        sh "echo '🌐 Live URL:' && cat .ngrok_url || echo 'Failed to get ngrok URL'"
                        sh "echo '🚀 DISPLAYING LIVE URL:' && ./scripts/display-url.sh || echo 'Display script not available'"
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
                        
                        // Start ngrok tunnel to port 4000
                        bat "powershell -ExecutionPolicy Bypass -File scripts\\ngrok-deploy.ps1 -Port 4000"
                        
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
