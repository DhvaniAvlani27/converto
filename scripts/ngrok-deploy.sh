#!/bin/bash

# ngrok Deployment Script for Converto SaaS
# This script manages ngrok tunnels for live deployment

set -e

echo "🚀 Starting ngrok deployment..."

# Kill existing ngrok processes
echo "🔄 Stopping existing ngrok tunnels..."
pkill ngrok || true
sleep 2

# Check if Docker container is running
if ! docker ps | grep -q "converto-live"; then
    echo "❌ Docker container 'converto-live' is not running!"
    echo "Please ensure the container is running on port 3000"
    exit 1
fi

# Start new ngrok tunnel
echo "🌐 Starting new ngrok tunnel..."
ngrok http 3000 --log=stdout > ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for tunnel to be ready
echo "⏳ Waiting for ngrok tunnel to be ready..."
sleep 5

# Get public URL
echo "🔍 Getting public URL..."
PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "https://tunnel.ngrok.io")

if [ "$PUBLIC_URL" = "null" ] || [ "$PUBLIC_URL" = "" ]; then
    echo "❌ Failed to get ngrok URL. Check ngrok.log for details"
    cat ngrok.log
    exit 1
fi

echo "✅ ngrok tunnel established successfully!"
echo "🌐 Public URL: $PUBLIC_URL"
echo $PUBLIC_URL > .ngrok_url

# Save ngrok process ID
echo $NGROK_PID > .ngrok_pid

# Display tunnel info
echo "📊 Tunnel Information:"
echo "   - Public URL: $PUBLIC_URL"
echo "   - Local Port: 3000"
echo "   - Process ID: $NGROK_PID"
echo "   - Log File: ngrok.log"
echo "   - Status: Active"

# Optional: Health check
echo "🏥 Performing health check..."
sleep 3
if curl -f -s "$PUBLIC_URL/api/health" > /dev/null; then
    echo "✅ Health check passed! App is responding"
else
    echo "⚠️  Health check failed. App might not be ready yet"
fi

echo "🎉 ngrok deployment completed successfully!"
echo "Your app is now live at: $PUBLIC_URL"
