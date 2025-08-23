#!/bin/bash

# Docker build and run script for Converto SaaS

set -e

IMAGE_NAME="converto-saas"
CONTAINER_NAME="converto-saas-container"
PORT=3000

echo "🐳 Building Docker image..."
docker build -t $IMAGE_NAME .

echo "🧹 Cleaning up old containers..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

echo "🚀 Starting container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  $IMAGE_NAME

echo "✅ Container started successfully!"
echo "🌐 Application is running at: http://localhost:$PORT"
echo "📊 Container logs: docker logs $CONTAINER_NAME"
echo "🛑 Stop container: docker stop $CONTAINER_NAME"
echo "🗑️  Remove container: docker rm $CONTAINER_NAME"
