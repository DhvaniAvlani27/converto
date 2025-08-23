# Quick Deploy Script for Converto SaaS (Windows PowerShell)
# Builds, runs, and exposes your app with ngrok in one command

param(
    [switch]$Stop,
    [switch]$Status
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$White = "White"

function Write-Status {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $Blue
}

function Stop-App {
    Write-Info "Stopping Converto app..."
    
    # Stop Docker container
    docker stop converto-live 2>$null
    docker rm converto-live 2>$null
    
    # Stop ngrok
    Get-Process -Name "ngrok" -ErrorAction SilentlyContinue | Stop-Process -Force
    
    # Clean up files
    if (Test-Path ".ngrok_pid") { Remove-Item ".ngrok_pid" -Force }
    if (Test-Path ".ngrok_url") { Remove-Item ".ngrok_url" -Force }
    
    Write-Status "App stopped successfully!"
}

function Show-Status {
    Write-Info "Current Status:"
    
    # Check Docker container
    $containerStatus = docker ps --filter "name=converto-live" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($containerStatus -like "*converto-live*") {
        Write-Status "Docker container is running"
    } else {
        Write-Warning "Docker container is not running"
    }
    
    # Check ngrok
    $ngrokProcesses = Get-Process -Name "ngrok" -ErrorAction SilentlyContinue
    if ($ngrokProcesses) {
        Write-Status "ngrok is running"
        if (Test-Path ".ngrok_url") {
            $url = Get-Content ".ngrok_url"
            Write-Info "Public URL: $url"
        }
    } else {
        Write-Warning "ngrok is not running"
    }
}

if ($Stop) {
    Stop-App
    exit 0
}

if ($Status) {
    Show-Status
    exit 0
}

# Main deployment
Write-Host "🚀 Quick Deploy - Converto SaaS" -ForegroundColor $Blue
Write-Host "================================" -ForegroundColor $Blue

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Error "Docker is not running. Please start Docker first."
    exit 1
}

# Check if ngrok is available
if (-not (Get-Command ngrok -ErrorAction SilentlyContinue)) {
    Write-Error "ngrok is not installed. Please install ngrok first:"
    Write-Host "  npm install -g ngrok" -ForegroundColor $White
    exit 1
}

# Step 1: Build Docker image
Write-Info "Step 1: Building Docker image..."
docker build -t converto-saas:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Status "Docker image built successfully!"
} else {
    Write-Error "Failed to build Docker image"
    exit 1
}

# Step 2: Stop existing container
Write-Info "Step 2: Stopping existing container..."
docker stop converto-live 2>$null
docker rm converto-live 2>$null

# Step 3: Run new container
Write-Info "Step 3: Starting new container..."
docker run -d --name converto-live -p 3000:3000 converto-saas:latest

if ($LASTEXITCODE -eq 0) {
    Write-Status "Container started successfully!"
} else {
    Write-Error "Failed to start container"
    exit 1
}

# Step 4: Wait for container to be ready
Write-Info "Step 4: Waiting for container to be ready..."
Start-Sleep -Seconds 10

# Step 5: Health check
Write-Info "Step 5: Performing health check..."
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/health" -Method Get -ErrorAction Stop
    Write-Status "Health check passed! App is responding"
} catch {
    Write-Warning "Health check failed. App might not be ready yet"
}

# Step 6: Start ngrok tunnel
Write-Info "Step 6: Starting ngrok tunnel..."
if (Test-Path "scripts\ngrok-deploy.ps1") {
    & "scripts\ngrok-deploy.ps1"
} else {
    Write-Warning "ngrok-deploy.ps1 not found, starting basic ngrok..."
    
    # Stop existing ngrok
    Get-Process -Name "ngrok" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
    
    # Start ngrok
    Start-Process -FilePath "ngrok" -ArgumentList "http 3000" -WindowStyle Hidden
    Start-Sleep -Seconds 5
    
    # Get public URL
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get -ErrorAction Stop
        $publicUrl = $response.tunnels[0].public_url
        
        if ($publicUrl) {
            $publicUrl | Out-File -FilePath ".ngrok_url" -Encoding UTF8
            Write-Status "ngrok tunnel started!"
            Write-Status "Public URL: $publicUrl"
        } else {
            Write-Error "Failed to get ngrok URL"
        }
    } catch {
        Write-Error "Failed to get ngrok URL: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "🎉 Deployment Complete!" -ForegroundColor $Green
Write-Host "======================" -ForegroundColor $Green
Write-Status "Your app is now running locally on: http://localhost:3000"

if (Test-Path ".ngrok_url") {
    $publicUrl = Get-Content ".ngrok_url"
    Write-Status "Your app is now live on the internet at: $publicUrl"
    Write-Host ""
    Write-Host "🌐 Share this URL with anyone to access your app!" -ForegroundColor $White
    Write-Host "📱 The app is accessible from any device with internet access" -ForegroundColor $White
    Write-Host "🔒 HTTPS is automatically enabled" -ForegroundColor $White
} else {
    Write-Warning "ngrok URL not available. Check ngrok.log for details"
}

Write-Host ""
Write-Host "📋 Useful Commands:" -ForegroundColor $Blue
Write-Host "  View logs: docker logs -f converto-live" -ForegroundColor $White
Write-Host "  Stop app: docker stop converto-live" -ForegroundColor $White
Write-Host "  Restart: .\scripts\quick-deploy.ps1" -ForegroundColor $White
Write-Host "  Stop: .\scripts\quick-deploy.ps1 -Stop" -ForegroundColor $White
Write-Host "  Status: .\scripts\quick-deploy.ps1 -Status" -ForegroundColor $White
