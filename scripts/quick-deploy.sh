#!/bin/bash

# Quick Deploy Script for Converto SaaS
# Builds, runs, and exposes your app with ngrok in one command

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo "🚀 Quick Deploy - Converto SaaS"
echo "================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if ngrok is available
if ! command -v ngrok &> /dev/null; then
    print_error "ngrok is not installed. Please install ngrok first:"
    echo "  npm install -g ngrok"
    exit 1
fi

# Step 1: Build Docker image
print_info "Step 1: Building Docker image..."
docker build -t converto-saas:latest .

if [ $? -eq 0 ]; then
    print_status "Docker image built successfully!"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Step 2: Stop existing container
print_info "Step 2: Stopping existing container..."
docker stop converto-live 2>/dev/null || true
docker rm converto-live 2>/dev/null || true

# Step 3: Run new container
print_info "Step 3: Starting new container..."
docker run -d --name converto-live -p 3000:3000 converto-saas:latest

if [ $? -eq 0 ]; then
    print_status "Container started successfully!"
else
    print_error "Failed to start container"
    exit 1
fi

# Step 4: Wait for container to be ready
print_info "Step 4: Waiting for container to be ready..."
sleep 10

# Step 5: Health check
print_info "Step 5: Performing health check..."
if curl -f -s http://localhost:3000/api/health > /dev/null; then
    print_status "Health check passed! App is responding"
else
    print_warning "Health check failed. App might not be ready yet"
fi

# Step 6: Start ngrok tunnel
print_info "Step 6: Starting ngrok tunnel..."
if [ -f "scripts/ngrok-deploy.sh" ]; then
    chmod +x scripts/ngrok-deploy.sh
    ./scripts/ngrok-deploy.sh
else
    print_warning "ngrok-deploy.sh not found, starting basic ngrok..."
    pkill ngrok || true
    sleep 2
    ngrok http 3000 --log=stdout > ngrok.log 2>&1 &
    sleep 5
    
    # Get public URL
    PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")
    if [ "$PUBLIC_URL" != "null" ] && [ "$PUBLIC_URL" != "" ]; then
        echo $PUBLIC_URL > .ngrok_url
        print_status "ngrok tunnel started!"
        print_status "Public URL: $PUBLIC_URL"
    else
        print_error "Failed to get ngrok URL"
    fi
fi

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
print_status "Your app is now running locally on: http://localhost:3000"

if [ -f ".ngrok_url" ]; then
    PUBLIC_URL=$(cat .ngrok_url)
    print_status "Your app is now live on the internet at: $PUBLIC_URL"
    echo ""
    echo "🌐 Share this URL with anyone to access your app!"
    echo "📱 The app is accessible from any device with internet access"
    echo "🔒 HTTPS is automatically enabled"
else
    print_warning "ngrok URL not available. Check ngrok.log for details"
fi

echo ""
echo "📋 Useful Commands:"
echo "  View logs: docker logs -f converto-live"
echo "  Stop app: docker stop converto-live"
echo "  Restart: ./scripts/quick-deploy.sh"
echo "  ngrok status: ./scripts/ngrok-manager.sh status"
echo "  ngrok health: ./scripts/ngrok-manager.sh health"
