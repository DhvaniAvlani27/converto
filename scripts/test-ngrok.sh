#!/bin/bash

# Test ngrok Script for Jenkins (Linux/Mac)
# Simple test to verify ngrok works

echo -e "\033[0;34m🧪 Testing ngrok functionality...\033[0m"

# Check if ngrok is available
if command -v ngrok >/dev/null 2>&1; then
    ngrok_version=$(ngrok version 2>/dev/null)
    echo -e "\033[0;32m✅ ngrok is available: $ngrok_version\033[0m"
else
    echo -e "\033[0;31m❌ ngrok command not found\033[0m"
fi

# Check if scripts directory exists
if [ -d "scripts" ]; then
    echo -e "\033[0;32m✅ scripts directory exists\033[0m"
    echo "  📁 Contents:"
    for file in scripts/*; do
        if [ -f "$file" ]; then
            echo -e "    📄 $(basename "$file")\033[0m"
        fi
    done
else
    echo -e "\033[0;31m❌ scripts directory not found\033[0m"
fi

# Check if ngrok-deploy.sh exists
if [ -f "scripts/ngrok-deploy.sh" ]; then
    echo -e "\033[0;32m✅ ngrok-deploy.sh found\033[0m"
else
    echo -e "\033[0;31m❌ ngrok-deploy.sh not found\033[0m"
fi

# Check if display-url.sh exists
if [ -f "scripts/display-url.sh" ]; then
    echo -e "\033[0;32m✅ display-url.sh found\033[0m"
else
    echo -e "\033[0;31m❌ display-url.sh not found\033[0m"
fi

echo ""
echo -e "\033[0;34m🎯 Test completed!\033[0m"
