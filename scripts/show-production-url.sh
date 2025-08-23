#!/bin/bash

# Show Production URL Script for Converto SaaS (Linux/Mac)
# Displays the production URL after Jenkins deployment

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

# Check if production container is running
if docker ps | grep -q "converto-live"; then
    echo ""
    echo -e "${GREEN}🎉${NC}${WHITE} ==========================================${NC}"
    echo -e "${GREEN}🚀 PRODUCTION DEPLOYMENT SUCCESSFUL!${NC}"
    echo -e "${GREEN}🎉${NC}${WHITE} ==========================================${NC}"
    echo ""
    
    print_url "🌐 Production URL: http://localhost:4000"
    print_info "🔗 Health Check: http://localhost:4000/api/health"
    print_info "📱 Your app is now running on port 4000!"
    echo ""
    
    echo -e "${BLUE}💡 Quick Actions:${NC}"
    echo -e "${WHITE}  • Click the URL above to open your app${NC}"
    echo -e "${WHITE}  • Open in browser: xdg-open http://localhost:4000${NC}"
    echo -e "${WHITE}  • Check health: curl http://localhost:4000/api/health${NC}"
    echo ""
    
    echo -e "${BLUE}🔍 Container Status:${NC}"
    echo -e "${WHITE}  • Name: converto-live${NC}"
    echo -e "${WHITE}  • Port: 4000:3000${NC}"
    echo -e "${WHITE}  • Status: Running${NC}"
    echo ""
    
    echo -e "${GREEN}🎯 Your Converto SaaS app is now running in production!${NC}"
else
    print_error "Production container 'converto-live' is not running!"
    print_info "Please run the Jenkins pipeline first to deploy to production."
    echo ""
    echo -e "${BLUE}💡 To start production manually:${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --production${NC}"
fi
