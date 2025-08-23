#!/bin/bash

# Auto-Open Script for Converto SaaS (Linux/Mac)
# Automatically opens the ngrok URL in browser after deployment

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

# Parse command line arguments
WAIT=false
DELAY=5

while [[ $# -gt 0 ]]; do
    case $1 in
        --wait|-w)
            WAIT=true
            shift
            ;;
        --delay|-d)
            DELAY="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🚀 Auto-Open Script for Converto SaaS${NC}"
echo -e "${BLUE}=====================================${NC}"

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

echo ""
echo -e "${CYAN}🌐${NC}${WHITE} ==========================================${NC}"
echo -e "${GREEN}🚀 YOUR APP IS NOW LIVE ON THE INTERNET!${NC}"
echo -e "${CYAN}🌐${NC}${WHITE} ==========================================${NC}"
echo ""

print_url "🔗 Public URL: $public_url"
echo ""

# Wait if specified
if [ "$WAIT" = true ]; then
    print_info "Waiting $DELAY seconds before opening..."
    sleep $DELAY
fi

# Check if app is responding
print_info "Checking if app is responding..."
retries=0
max_retries=10

while [ $retries -lt $max_retries ]; do
    if curl -f -s "$public_url/api/health" > /dev/null 2>&1; then
        health_response=$(curl -s "$public_url/api/health" 2>/dev/null)
        status=$(echo "$health_response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        print_status "App is responding! Status: $status"
        break
    else
        retries=$((retries + 1))
        if [ $retries -lt $max_retries ]; then
            print_warning "App not ready yet. Retrying in 2 seconds... (Attempt $retries/$max_retries)"
            sleep 2
        else
            print_warning "App might not be ready yet, but opening anyway..."
        fi
    fi
done

# Open URL in browser
print_info "Opening app in browser..."

# Try different methods to open browser
if command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open "$public_url" 2>/dev/null &
    print_status "App opened in browser successfully!"
elif command -v open >/dev/null 2>&1; then
    # macOS
    open "$public_url" 2>/dev/null &
    print_status "App opened in browser successfully!"
elif command -v sensible-browser >/dev/null 2>&1; then
    # Debian/Ubuntu
    sensible-browser "$public_url" 2>/dev/null &
    print_status "App opened in browser successfully!"
else
    print_error "Could not automatically open browser"
    print_info "Please manually open: $public_url"
fi

# Also open health check
print_info "Opening health check in new tab..."
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$public_url/api/health" 2>/dev/null &
elif command -v open >/dev/null 2>&1; then
    open "$public_url/api/health" 2>/dev/null &
fi

echo ""
echo -e "${GREEN}🎉 Your Converto SaaS app is now open in your browser!${NC}"
echo -e "${YELLOW}📱 Share this URL with anyone: $public_url${NC}"
echo ""

# Save as HTML file for easy access
print_info "Saving clickable HTML file..."
./scripts/display-url.sh --save

echo ""
echo -e "${BLUE}📋 Quick Actions:${NC}"
echo -e "${WHITE}  • View saved HTML: LIVE_APP.html${NC}"
echo -e "${WHITE}  • Copy URL: ./scripts/display-url.sh --copy${NC}"
echo -e "${WHITE}  • Check status: ./scripts/display-url.sh${NC}"
