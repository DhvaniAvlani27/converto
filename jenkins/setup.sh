#!/bin/bash

echo "🚀 Setting up Jenkins with Docker capabilities..."

# Create jenkins directory if it doesn't exist
mkdir -p jenkins

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"

# Build and start Jenkins
echo "🐳 Building and starting Jenkins..."
cd jenkins

# Choose which compose file to use
echo "Choose Jenkins setup:"
echo "1) Standard Jenkins (faster startup)"
echo "2) Custom Jenkins with Docker CLI (recommended for Docker builds)"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "2" ]; then
    echo "🔧 Building custom Jenkins image..."
    docker-compose -f docker-compose.custom.yml up --build -d
    echo "✅ Custom Jenkins is starting up..."
else
    echo "🚀 Starting standard Jenkins..."
    docker-compose up -d
    echo "✅ Standard Jenkins is starting up..."
fi

echo ""
echo "🌐 Jenkins will be available at: http://localhost:8080"
echo "📋 Initial admin password will be displayed in the logs"
echo ""
echo "To view logs: docker-compose logs -f jenkins"
echo "To stop: docker-compose down"
echo ""
echo "⏳ Waiting for Jenkins to start up (this may take a few minutes)..."
echo "Check the logs for the initial admin password"
