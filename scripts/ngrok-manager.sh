#!/bin/bash

# ngrok Manager Script for Converto SaaS
# Comprehensive management of ngrok tunnels

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to show usage
show_usage() {
    echo "🚀 ngrok Manager for Converto SaaS"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     - Start ngrok tunnel"
    echo "  stop      - Stop ngrok tunnel"
    echo "  restart   - Restart ngrok tunnel"
    echo "  status    - Show tunnel status"
    echo "  health    - Check app health"
    echo "  logs      - Show ngrok logs"
    echo "  url       - Get public URL"
    echo "  help      - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start      # Start tunnel"
    echo "  $0 status     # Check status"
    echo "  $0 health     # Health check"
}

# Function to check if Docker container is running
check_docker_container() {
    if ! docker ps | grep -q "converto-live"; then
        print_error "Docker container 'converto-live' is not running!"
        print_info "Please start the container first:"
        echo "  docker run -d --name converto-live -p 3000:3000 converto-saas:latest"
        return 1
    fi
    return 0
}

# Function to start ngrok
start_ngrok() {
    print_info "Starting ngrok tunnel..."
    
    if ! check_docker_container; then
        exit 1
    fi
    
    # Kill existing ngrok processes
    pkill ngrok || true
    sleep 2
    
    # Start new tunnel
    if [ -f ".ngrok.yml" ]; then
        print_info "Using custom ngrok configuration..."
        ngrok start --config .ngrok.yml converto-app > ngrok.log 2>&1 &
    else
        print_info "Using default ngrok configuration..."
        ngrok http 3000 --log=stdout > ngrok.log 2>&1 &
    fi
    
    NGROK_PID=$!
    echo $NGROK_PID > .ngrok_pid
    
    # Wait for tunnel to be ready
    print_info "Waiting for tunnel to be ready..."
    sleep 5
    
    # Get public URL
    get_public_url
    
    print_status "ngrok tunnel started successfully!"
}

# Function to stop ngrok
stop_ngrok() {
    print_info "Stopping ngrok tunnel..."
    
    if [ -f ".ngrok_pid" ]; then
        PID=$(cat .ngrok_pid)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            print_status "Stopped ngrok process (PID: $PID)"
        else
            print_warning "Process $PID not found"
        fi
    fi
    
    # Kill any remaining ngrok processes
    pkill ngrok || true
    
    # Clean up files
    rm -f .ngrok_pid .ngrok_url
    
    print_status "ngrok tunnel stopped"
}

# Function to restart ngrok
restart_ngrok() {
    print_info "Restarting ngrok tunnel..."
    stop_ngrok
    sleep 2
    start_ngrok
}

# Function to get public URL
get_public_url() {
    print_info "Getting public URL..."
    
    # Try to get URL from ngrok API
    PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")
    
    if [ "$PUBLIC_URL" = "null" ] || [ "$PUBLIC_URL" = "" ]; then
        print_warning "Could not get public URL from ngrok API"
        print_info "Check ngrok.log for details"
        return 1
    fi
    
    echo $PUBLIC_URL > .ngrok_url
    print_status "Public URL: $PUBLIC_URL"
    return 0
}

# Function to show status
show_status() {
    print_info "ngrok Status:"
    
    if [ -f ".ngrok_pid" ]; then
        PID=$(cat .ngrok_pid)
        if kill -0 $PID 2>/dev/null; then
            print_status "ngrok is running (PID: $PID)"
            
            if [ -f ".ngrok_url" ]; then
                URL=$(cat .ngrok_url)
                print_info "Public URL: $URL"
            else
                print_warning "Public URL not available"
            fi
            
            # Check tunnel status
            TUNNEL_STATUS=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | jq -r '.tunnels[0].status' 2>/dev/null || echo "unknown")
            print_info "Tunnel Status: $TUNNEL_STATUS"
            
        else
            print_error "ngrok process $PID not found"
            rm -f .ngrok_pid .ngrok_url
        fi
    else
        print_warning "ngrok is not running"
    fi
    
    # Check Docker container
    if check_docker_container; then
        print_status "Docker container is running"
    fi
}

# Function to check health
check_health() {
    if [ -f ".ngrok_url" ]; then
        URL=$(cat .ngrok_url)
        print_info "Performing health check on: $URL"
        
        if curl -f -s "$URL/api/health" > /dev/null; then
            print_status "Health check passed! App is responding"
        else
            print_error "Health check failed! App is not responding"
        fi
    else
        print_error "No ngrok URL available. Start the tunnel first."
    fi
}

# Function to show logs
show_logs() {
    if [ -f "ngrok.log" ]; then
        print_info "Recent ngrok logs:"
        tail -20 ngrok.log
    else
        print_warning "No ngrok log file found"
    fi
}

# Function to show URL
show_url() {
    if [ -f ".ngrok_url" ]; then
        URL=$(cat .ngrok_url)
        print_status "Your app is live at: $URL"
        echo $URL
    else
        print_error "No ngrok URL available. Start the tunnel first."
        exit 1
    fi
}

# Main execution
case "${1:-help}" in
    start)
        start_ngrok
        ;;
    stop)
        stop_ngrok
        ;;
    restart)
        restart_ngrok
        ;;
    status)
        show_status
        ;;
    health)
        check_health
        ;;
    logs)
        show_logs
        ;;
    url)
        show_url
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
