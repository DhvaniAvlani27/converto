# Jenkins Setup Script for Windows

Write-Host "🚀 Setting up Jenkins with Docker capabilities..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Create jenkins directory if it doesn't exist
if (!(Test-Path "jenkins")) {
    New-Item -ItemType Directory -Path "jenkins" | Out-Null
}

# Navigate to jenkins directory
Set-Location jenkins

# Choose which compose file to use
Write-Host "Choose Jenkins setup:" -ForegroundColor Yellow
Write-Host "1) Standard Jenkins (faster startup)" -ForegroundColor White
Write-Host "2) Custom Jenkins with Docker CLI (recommended for Docker builds)" -ForegroundColor White

$choice = Read-Host "Enter choice (1 or 2)"

if ($choice -eq "2") {
    Write-Host "🔧 Building custom Jenkins image..." -ForegroundColor Blue
    docker-compose -f docker-compose.custom.yml up --build -d
    Write-Host "✅ Custom Jenkins is starting up..." -ForegroundColor Green
} else {
    Write-Host "🚀 Starting standard Jenkins..." -ForegroundColor Blue
    docker-compose up -d
    Write-Host "✅ Standard Jenkins is starting up..." -ForegroundColor Green
}

Write-Host ""
Write-Host "🌐 Jenkins will be available at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "📋 Initial admin password will be displayed in the logs" -ForegroundColor Yellow
Write-Host ""
Write-Host "To view logs: docker-compose logs -f jenkins" -ForegroundColor White
Write-Host "To stop: docker-compose down" -ForegroundColor White
Write-Host ""
Write-Host "⏳ Waiting for Jenkins to start up (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host "Check the logs for the initial admin password" -ForegroundColor Yellow
