# Test ngrok Script for Jenkins
# Simple test to verify ngrok works

Write-Host "🧪 Testing ngrok functionality..." -ForegroundColor Blue

# Check if ngrok is available
try {
    $ngrokVersion = ngrok version 2>$null
    if ($ngrokVersion) {
        Write-Host "✅ ngrok is available: $ngrokVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ ngrok version not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ngrok command failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if scripts directory exists
if (Test-Path "scripts") {
    Write-Host "✅ scripts directory exists" -ForegroundColor Green
    Get-ChildItem "scripts" | ForEach-Object {
        Write-Host "  📁 $($_.Name)" -ForegroundColor White
    }
} else {
    Write-Host "❌ scripts directory not found" -ForegroundColor Red
}

# Check if ngrok-deploy.ps1 exists
if (Test-Path "scripts\ngrok-deploy.ps1") {
    Write-Host "✅ ngrok-deploy.ps1 found" -ForegroundColor Green
} else {
    Write-Host "❌ ngrok-deploy.ps1 not found" -ForegroundColor Red
}

# Check if display-url.ps1 exists
if (Test-Path "scripts\display-url.ps1") {
    Write-Host "✅ display-url.ps1 found" -ForegroundColor Green
} else {
    Write-Host "❌ display-url.ps1 not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Test completed!" -ForegroundColor Blue
