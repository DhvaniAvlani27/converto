# Show Production URL Script for Converto SaaS
# Displays the production URL after Jenkins deployment

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

# Check if production container is running
$prodContainer = docker ps --filter "name=converto-live" --format "table {{.Names}}\t{{.Status}}" 2>$null

if ($prodContainer -like "*converto-live*") {
    Write-Host ""
    Write-Host "🎉" -ForegroundColor $Green -NoNewline
    Write-Host " ==========================================" -ForegroundColor $White
    Write-Host "🚀 PRODUCTION DEPLOYMENT SUCCESSFUL!" -ForegroundColor $Green
    Write-Host "🎉 ==========================================" -ForegroundColor $White
    Write-Host ""
    
    Write-URL "🌐 Production URL: http://localhost:4000"
    Write-Info "🔗 Health Check: http://localhost:4000/api/health"
    Write-Info "📱 Your app is now running on port 4000!"
    Write-Host ""
    
    Write-Host "💡 Quick Actions:" -ForegroundColor $Blue
    Write-Host "  • Click the URL above to open your app" -ForegroundColor $White
    Write-Host "  • Open in browser: Start-Process 'http://localhost:4000'" -ForegroundColor $White
    Write-Host "  • Check health: Start-Process 'http://localhost:4000/api/health'" -ForegroundColor $White
    Write-Host ""
    
    Write-Host "🔍 Container Status:" -ForegroundColor $Blue
    Write-Host "  • Name: converto-live" -ForegroundColor $White
    Write-Host "  • Port: 4000:3000" -ForegroundColor $White
    Write-Host "  • Status: Running" -ForegroundColor $White
    Write-Host ""
    
    Write-Host "🎯 Your Converto SaaS app is now running in production!" -ForegroundColor $Green
} else {
    Write-Error "Production container 'converto-live' is not running!"
    Write-Info "Please run the Jenkins pipeline first to deploy to production."
    Write-Host ""
    Write-Host "💡 To start production manually:" -ForegroundColor $Blue
    Write-Host "  .\scripts\manage-environments.ps1 -Production" -ForegroundColor $White
}
