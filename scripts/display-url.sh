#!/bin/bash

# Display URL Script for Converto SaaS (Linux/Mac)
# Shows the ngrok URL after Jenkins pipeline completion

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_url() {
    echo -e "${CYAN}$1${NC}"
}

# Check if ngrok URL exists
if [ ! -f ".ngrok_url" ]; then
    print_error "No ngrok URL found. Please run the deployment first."
    print_info "Run: ./scripts/quick-deploy.sh"
    exit 1
fi

# Read the URL
public_url=$(cat .ngrok_url 2>/dev/null)

if [ -z "$public_url" ]; then
    print_error "ngrok URL file is empty or corrupted."
    exit 1
fi

# Display the URL prominently
echo ""
echo -e "${CYAN}🌐${NC}${WHITE} ==========================================${NC}"
echo -e "${GREEN}🚀 YOUR APP IS NOW LIVE ON THE INTERNET!${NC}"
echo -e "${CYAN}🌐${NC}${WHITE} ==========================================${NC}"
echo -e "${YELLOW}📱 Production: Port 4000 (via ngrok)${NC}"
echo -e "${BLUE}🔧 Development: Port 3000 (local)${NC}"
echo ""

print_url "🔗 Public URL: $public_url"
echo ""

# Save URL to a clickable file
if [ "$1" = "--save" ] || [ "$1" = "-s" ]; then
    cat > LIVE_APP.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Converto SaaS - Live URL</title>
    <meta charset="utf-8">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            margin: 0;
        }
        .container { 
            background: rgba(255,255,255,0.1); 
            padding: 40px; 
            border-radius: 20px; 
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        h1 { 
            font-size: 2.5em; 
            margin-bottom: 20px; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .url { 
            font-size: 1.5em; 
            margin: 30px 0; 
            padding: 20px; 
            background: rgba(255,255,255,0.2); 
            border-radius: 10px; 
            word-break: break-all;
        }
        .btn { 
            display: inline-block; 
            padding: 15px 30px; 
            background: #4CAF50; 
            color: white; 
            text-decoration: none; 
            border-radius: 25px; 
            font-size: 1.2em; 
            margin: 10px; 
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .btn:hover { 
            background: #45a049; 
            transform: translateY(-2px); 
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }
        .info { 
            margin-top: 30px; 
            font-size: 0.9em; 
            opacity: 0.8;
        }
        .timestamp { 
            margin-top: 20px; 
            font-size: 0.8em; 
            opacity: 0.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Converto SaaS</h1>
        <p>Your app is now live on the internet!</p>
        
        <div class="url">
            <strong>🌐 Public URL:</strong><br>
            <a href="$public_url" target="_blank" style="color: #4CAF50;">$public_url</a>
        </div>
        
        <a href="$public_url" target="_blank" class="btn">🚀 Open App Now</a>
        <a href="$public_url/api/health" target="_blank" class="btn">🏥 Health Check</a>
        
        <div class="info">
            <p>✅ HTTPS enabled automatically</p>
            <p>📱 Works on all devices</p>
            <p>🌍 Accessible worldwide</p>
        </div>
        
        <div class="timestamp">
            Generated: $(date '+%Y-%m-%d %H:%M:%S')
        </div>
    </div>
</body>
</html>
EOF
    print_status "Saved clickable HTML file: LIVE_APP.html"
fi

# Copy URL to clipboard (Linux)
if [ "$1" = "--copy" ] || [ "$1" = "-c" ]; then
    if command -v xclip >/dev/null 2>&1; then
        echo "$public_url" | xclip -selection clipboard
        print_status "URL copied to clipboard!"
    elif command -v pbcopy >/dev/null 2>&1; then
        echo "$public_url" | pbcopy
        print_status "URL copied to clipboard!"
    else
        print_warning "Clipboard copy not available. Install xclip (Linux) or use pbcopy (Mac)"
    fi
fi

# Open URL in browser
if [ "$1" = "--open" ] || [ "$1" = "-o" ]; then
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$public_url"
        print_status "Opening app in browser..."
    elif command -v open >/dev/null 2>&1; then
        open "$public_url"
        print_status "Opening app in browser..."
    else
        print_warning "Browser open not available. Install xdg-utils (Linux) or use open (Mac)"
    fi
fi

# Display additional information
echo -e "${BLUE}📋 Quick Actions:${NC}"
echo -e "${WHITE}  • Click the URL above to open your app${NC}"
echo -e "${WHITE}  • Save as HTML: ./scripts/display-url.sh --save${NC}"
echo -e "${WHITE}  • Copy to clipboard: ./scripts/display-url.sh --copy${NC}"
echo -e "${WHITE}  • Open in browser: ./scripts/display-url.sh --open${NC}"

echo ""
echo -e "${BLUE}🔍 Health Check:${NC}"
echo -e "${WHITE}  • Status: $public_url/api/health${NC}"

echo ""
echo -e "${YELLOW}📱 Share this URL with anyone to access your app!${NC}"
echo ""

# Check if app is responding
print_info "Checking if app is responding..."
if curl -f -s "$public_url/api/health" > /dev/null 2>&1; then
    health_response=$(curl -s "$public_url/api/health" 2>/dev/null)
    status=$(echo "$health_response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    print_status "App is responding! Status: $status"
else
    print_warning "App might not be ready yet. Please wait a moment and try again."
fi

echo ""
echo -e "${GREEN}🎉 Your Converto SaaS app is now live and accessible worldwide!${NC}"
