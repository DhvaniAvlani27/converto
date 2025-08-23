#!/bin/bash

# Manage Environments Script for Converto SaaS (Linux/Mac)
# Manages both development (port 3000) and production (port 4000) environments

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

show_usage() {
    echo -e "${BLUE}🚀 Environment Management Script for Converto SaaS${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
    echo -e "${WHITE}Usage:${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --start        # Start both environments${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --stop         # Stop both environments${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --status       # Show status of both${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --restart      # Restart both environments${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --production   # Start production only${NC}"
    echo -e "${WHITE}  ./scripts/manage-environments.sh --development  # Start development only${NC}"
    echo ""
    echo -e "${WHITE}Ports:${NC}"
    echo -e "${BLUE}  🔧 Development: http://localhost:3000${NC}"
    echo -e "${YELLOW}  📱 Production:  http://localhost:4000${NC}"
    echo -e "${CYAN}  🌐 ngrok:       Check .ngrok_url file${NC}"
}

start_development() {
    print_info "Starting development environment on port 3000..."
    
    # Check if development is already running
    if docker ps | grep -q "converto-dev"; then
        print_warning "Development container already running"
        return
    fi
    
    # Start development container
    if docker run -d --name converto-dev -p 3000:3000 converto-saas:latest; then
        print_status "Development environment started on port 3000"
        print_info "Access at: http://localhost:3000"
    else
        print_error "Failed to start development environment"
    fi
}

start_production() {
    print_info "Starting production environment on port 4000..."
    
    # Check if production is already running
    if docker ps | grep -q "converto-live"; then
        print_warning "Production container already running"
        return
    fi
    
    # Start production container
    if docker run -d --name converto-live -p 4000:3000 converto-saas:latest; then
        print_status "Production environment started on port 4000"
        print_info "Access at: http://localhost:4000"
        
        # Wait for container to be ready
        echo "⏳ Waiting for container to be ready..."
        sleep 10
        
        # Start ngrok tunnel
        print_info "Starting ngrok tunnel to production..."
        if [ -f "scripts/ngrok-deploy.sh" ]; then
            chmod +x scripts/ngrok-deploy.sh
            ./scripts/ngrok-deploy.sh --port 4000
            
            if [ -f ".ngrok_url" ]; then
                public_url=$(cat .ngrok_url)
                print_status "ngrok tunnel established!"
                print_url "Public URL: $public_url"
            fi
        fi
    else
        print_error "Failed to start production environment"
    fi
}

stop_development() {
    print_info "Stopping development environment..."
    docker stop converto-dev 2>/dev/null || true
    docker rm converto-dev 2>/dev/null || true
    print_status "Development environment stopped"
}

stop_production() {
    print_info "Stopping production environment..."
    docker stop converto-live 2>/dev/null || true
    docker rm converto-live 2>/dev/null || true
    
    # Stop ngrok
    pkill ngrok || true
    
    # Clean up files
    rm -f .ngrok_pid .ngrok_url
    
    print_status "Production environment stopped"
}

show_status() {
    echo -e "${BLUE}📊 Environment Status${NC}"
    echo -e "${BLUE}====================${NC}"
    echo ""
    
    # Development status
    if docker ps | grep -q "converto-dev"; then
        print_status "🔧 Development: Running on port 3000"
        print_info "   Local: http://localhost:3000"
    else
        print_warning "🔧 Development: Not running"
    fi
    
    # Production status
    if docker ps | grep -q "converto-live"; then
        print_status "📱 Production: Running on port 4000"
        print_info "   Local: http://localhost:4000"
        
        # ngrok status
        if [ -f ".ngrok_url" ]; then
            public_url=$(cat .ngrok_url)
            print_status "🌐 ngrok: Active"
            print_url "   Public: $public_url"
        else
            print_warning "🌐 ngrok: Not active"
        fi
    else
        print_warning "📱 Production: Not running"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Quick Access:${NC}"
    echo -e "${WHITE}  Development: http://localhost:3000${NC}"
    echo -e "${WHITE}  Production:  http://localhost:4000${NC}"
    if [ -f ".ngrok_url" ]; then
        public_url=$(cat .ngrok_url)
        echo -e "${WHITE}  Live URL:   $public_url${NC}"
    fi
}

# Parse command line arguments
case "${1:-}" in
    --start|-s)
        start_development
        start_production
        ;;
    --stop)
        stop_development
        stop_production
        ;;
    --status)
        show_status
        ;;
    --restart|-r)
        stop_development
        stop_production
        sleep 2
        start_development
        start_production
        ;;
    --production|-p)
        start_production
        ;;
    --development|-d)
        start_development
        ;;
    --help|-h|"")
        show_usage
        ;;
    *)
        print_error "Unknown option: $1"
        show_usage
        exit 1
        ;;
esac
