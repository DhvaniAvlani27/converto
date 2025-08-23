# ngrok Deployment Script for Converto SaaS (Windows PowerShell)
# This script manages ngrok tunnels for live deployment

param(
    [switch]$Stop,
    [switch]$Status,
    [switch]$Health
)

Write-Host "🚀 ngrok Deployment Script for Windows" -ForegroundColor Green

# Function to get ngrok status
function Get-NgrokStatus {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get -ErrorAction Stop
        $tunnel = $response.tunnels[0]
        return @{
            PublicUrl = $tunnel.public_url
            LocalUrl = $tunnel.local_url
            Status = "Active"
        }
    }
    catch {
        return @{
            PublicUrl = $null
            LocalUrl = $null
            Status = "Inactive"
        }
    }
}

# Function to stop ngrok
function Stop-Ngrok {
    Write-Host "🔄 Stopping existing ngrok tunnels..." -ForegroundColor Yellow
    $processes = Get-Process -Name "ngrok" -ErrorAction SilentlyContinue
    if ($processes) {
        $processes | Stop-Process -Force
        Write-Host "✅ Stopped ngrok processes" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No ngrok processes found" -ForegroundColor Blue
    }
    
    # Clean up PID file
    if (Test-Path ".ngrok_pid") {
        Remove-Item ".ngrok_pid" -Force
    }
    
    if (Test-Path ".ngrok_url") {
        Remove-Item ".ngrok_url" -Force
    }
}

# Function to start ngrok
function Start-Ngrok {
    Write-Host "🌐 Starting new ngrok tunnel..." -ForegroundColor Yellow
    
    # Check if Docker container is running
    $containerStatus = docker ps --filter "name=converto-live" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($containerStatus -notlike "*converto-live*") {
        Write-Host "❌ Docker container 'converto-live' is not running!" -ForegroundColor Red
        Write-Host "Please ensure the container is running on port 3000" -ForegroundColor Yellow
        exit 1
    }
    
    # Start ngrok
    Start-Process -FilePath "ngrok" -ArgumentList "http 3000" -WindowStyle Hidden
    $ngrokProcess = Get-Process -Name "ngrok" | Select-Object -First 1
    
    # Wait for tunnel to be ready
    Write-Host "⏳ Waiting for ngrok tunnel to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Get public URL
    Write-Host "🔍 Getting public URL..." -ForegroundColor Yellow
    $tunnelInfo = Get-NgrokStatus
    
    if (-not $tunnelInfo.PublicUrl) {
        Write-Host "❌ Failed to get ngrok URL. Please check if ngrok is running" -ForegroundColor Red
        exit 1
    }
    
    # Save information
    $tunnelInfo.PublicUrl | Out-File -FilePath ".ngrok_url" -Encoding UTF8
    $ngrokProcess.Id | Out-File -FilePath ".ngrok_pid" -Encoding UTF8
    
    Write-Host "✅ ngrok tunnel established successfully!" -ForegroundColor Green
    Write-Host "🌐 Public URL: $($tunnelInfo.PublicUrl)" -ForegroundColor Cyan
    
    # Display tunnel info
    Write-Host "📊 Tunnel Information:" -ForegroundColor Blue
    Write-Host "   - Public URL: $($tunnelInfo.PublicUrl)" -ForegroundColor White
    Write-Host "   - Local Port: 3000" -ForegroundColor White
    Write-Host "   - Process ID: $($ngrokProcess.Id)" -ForegroundColor White
    Write-Host "   - Status: Active" -ForegroundColor White
    
    # Health check
    Write-Host "🏥 Performing health check..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    try {
        $healthResponse = Invoke-RestMethod -Uri "$($tunnelInfo.PublicUrl)/api/health" -Method Get -ErrorAction Stop
        Write-Host "✅ Health check passed! App is responding" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Health check failed. App might not be ready yet" -ForegroundColor Yellow
    }
    
    Write-Host "🎉 ngrok deployment completed successfully!" -ForegroundColor Green
    Write-Host "Your app is now live at: $($tunnelInfo.PublicUrl)" -ForegroundColor Cyan
}

# Function to show status
function Show-Status {
    $tunnelInfo = Get-NgrokStatus
    if ($tunnelInfo.Status -eq "Active") {
        Write-Host "📊 Current ngrok Status:" -ForegroundColor Green
        Write-Host "   - Public URL: $($tunnelInfo.PublicUrl)" -ForegroundColor White
        Write-Host "   - Local URL: $($tunnelInfo.LocalUrl)" -ForegroundColor White
        Write-Host "   - Status: $($tunnelInfo.Status)" -ForegroundColor White
        
        if (Test-Path ".ngrok_pid") {
            $pid = Get-Content ".ngrok_pid"
            Write-Host "   - Process ID: $pid" -ForegroundColor White
        }
    } else {
        Write-Host "❌ ngrok is not currently running" -ForegroundColor Red
    }
}

# Function to perform health check
function Test-Health {
    $tunnelInfo = Get-NgrokStatus
    if ($tunnelInfo.Status -eq "Active") {
        Write-Host "🏥 Performing health check..." -ForegroundColor Yellow
        try {
            $healthResponse = Invoke-RestMethod -Uri "$($tunnelInfo.PublicUrl)/api/health" -Method Get -ErrorAction Stop
            Write-Host "✅ Health check passed!" -ForegroundColor Green
            Write-Host "   Status: $($healthResponse.status)" -ForegroundColor White
            Write-Host "   Service: $($healthResponse.service)" -ForegroundColor White
        }
        catch {
            Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Cannot perform health check - ngrok is not running" -ForegroundColor Red
    }
}

# Main execution
if ($Stop) {
    Stop-Ngrok
}
elseif ($Status) {
    Show-Status
}
elseif ($Health) {
    Test-Health
}
else {
    # Default: start ngrok
    Start-Ngrok
}
