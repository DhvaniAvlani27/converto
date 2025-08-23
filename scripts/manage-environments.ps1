# Manage Environments Script for Converto SaaS
# Manages both development (port 3000) and production (port 4000) environments

param(
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status,
    [switch]$Restart,
    [switch]$Production,
    [switch]$Development
)

# Colors for output
$Green = "Green"
$Blue = "Blue"
$Yellow = "Yellow"
$Red = "Red"
$White = "White"
$Cyan = "Cyan"

function Write-Status {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $Blue
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
}

function Write-URL {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor $Cyan
}

function Show-Usage {
    Write-Host "🚀 Environment Management Script for Converto SaaS" -ForegroundColor $Blue
    Write-Host "=================================================" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $White
    Write-Host "  .\scripts\manage-environments.ps1 -Start        # Start both environments" -ForegroundColor $White
    Write-Host "  .\scripts\manage-environments.ps1 -Stop         # Stop both environments" -ForegroundColor $White
    Write-Host "  .\scripts\manage-environments.ps1 -Status       # Show status of both" -ForegroundColor $White
    Write-Host "  .\scripts\manage-environments.ps1 -Restart      # Restart both environments" -ForegroundColor $White
    Write-Host "  .\scripts\manage-environments.ps1 -Production   # Start production only" -ForegroundColor $White
    Write-Host "  .\scripts\manage-environments.ps1 -Development  # Start development only" -ForegroundColor $White
    Write-Host ""
    Write-Host "Ports:" -ForegroundColor $White
    Write-Host "  🔧 Development: http://localhost:3000" -ForegroundColor $Blue
    Write-Host "  📱 Production:  http://localhost:4000" -ForegroundColor $Yellow
            Write-Host "  📱 Production:  http://localhost:4000" -ForegroundColor $Yellow
}

function Start-Development {
    Write-Info "Starting development environment on port 3000..."
    
    # Check if development is already running
    $devContainer = docker ps --filter "name=converto-dev" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($devContainer -like "*converto-dev*") {
        Write-Warning "Development container already running"
        return
    }
    
    # Start development container
    try {
        docker run -d --name converto-dev -p 3000:3000 converto-saas:latest
        Write-Status "Development environment started on port 3000"
        Write-Info "Access at: http://localhost:3000"
    } catch {
        Write-Error "Failed to start development environment: $($_.Exception.Message)"
    }
}

function Start-Production {
    Write-Info "Starting production environment on port 4000..."
    
    # Check if production is already running
    $prodContainer = docker ps --filter "name=converto-live" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($prodContainer -like "*converto-live*") {
        Write-Warning "Production container already running"
        return
    }
    
    # Start production container
    try {
        docker run -d --name converto-live -p 4000:3000 converto-saas:latest
        Write-Status "Production environment started on port 4000"
        Write-Info "Access at: http://localhost:4000"
        
        # Wait for container to be ready
        Start-Sleep -Seconds 10
        
        # Production is now running on localhost:4000
        Write-Status "Production environment started on port 4000"
        Write-Info "Access at: http://localhost:4000"
        Write-Info "No ngrok tunnel needed - app is accessible locally"
    } catch {
        Write-Error "Failed to start production environment: $($_.Exception.Message)"
    }
}

function Stop-Development {
    Write-Info "Stopping development environment..."
    docker stop converto-dev 2>$null
    docker rm converto-dev 2>$null
    Write-Status "Development environment stopped"
}

function Stop-Production {
    Write-Info "Stopping production environment..."
    docker stop converto-live 2>$null
    docker rm converto-live 2>$null
    
            # Production stopped
        Write-Status "Production environment stopped"
    
    Write-Status "Production environment stopped"
}

function Show-Status {
    Write-Host "📊 Environment Status" -ForegroundColor $Blue
    Write-Host "====================" -ForegroundColor $Blue
    Write-Host ""
    
    # Development status
    $devContainer = docker ps --filter "name=converto-dev" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($devContainer -like "*converto-dev*") {
        Write-Status "🔧 Development: Running on port 3000"
        Write-Info "   Local: http://localhost:3000"
    } else {
        Write-Warning "🔧 Development: Not running"
    }
    
    # Production status
    $prodContainer = docker ps --filter "name=converto-live" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($prodContainer -like "*converto-live*") {
        Write-Status "📱 Production: Running on port 4000"
        Write-Info "   Local: http://localhost:4000"
        
        # Production status
        Write-Status "📱 Production: Running on port 4000"
        Write-Info "   Local: http://localhost:4000"
    } else {
        Write-Warning "📱 Production: Not running"
    }
    
    Write-Host ""
    Write-Host "💡 Quick Access:" -ForegroundColor $Yellow
    Write-Host "  Development: http://localhost:3000" -ForegroundColor $White
    Write-Host "  Production:  http://localhost:4000" -ForegroundColor $White
            Write-Host "  Production:  http://localhost:4000" -ForegroundColor $White
}

# Main execution
if ($Start) {
    Start-Development
    Start-Production
} elseif ($Stop) {
    Stop-Development
    Stop-Production
} elseif ($Status) {
    Show-Status
} elseif ($Restart) {
    Stop-Development
    Stop-Production
    Start-Sleep -Seconds 2
    Start-Development
    Start-Production
} elseif ($Production) {
    Start-Production
} elseif ($Development) {
    Start-Development
} else {
    Show-Usage
}
