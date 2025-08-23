# Auto-Open Script for Converto SaaS
# Automatically opens the ngrok URL in browser after deployment

param(
    [switch]$Wait,
    [int]$Delay = 5
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

Write-Host "🚀 Auto-Open Script for Converto SaaS" -ForegroundColor $Blue
Write-Host "=====================================" -ForegroundColor $Blue

# Check if ngrok URL exists
if (-not (Test-Path ".ngrok_url")) {
    Write-Error "No ngrok URL found. Please run the deployment first."
    Write-Info "Run: .\scripts\quick-deploy.ps1"
    exit 1
}

# Read the URL
$publicUrl = Get-Content ".ngrok_url" -ErrorAction SilentlyContinue

if (-not $publicUrl) {
    Write-Error "ngrok URL file is empty or corrupted."
    exit 1
}

Write-Host ""
Write-Host "🌐" -ForegroundColor $Cyan -NoNewline
Write-Host " ==========================================" -ForegroundColor $White
Write-Host "🚀 YOUR APP IS NOW LIVE ON THE INTERNET!" -ForegroundColor $Green
Write-Host "🌐 ==========================================" -ForegroundColor $White
Write-Host ""

Write-URL "🔗 Public URL: $publicUrl"
Write-Host ""

# Wait if specified
if ($Wait) {
    Write-Info "Waiting $Delay seconds before opening..."
    Start-Sleep -Seconds $Delay
fi

# Check if app is responding
Write-Info "Checking if app is responding..."
$retries = 0
$maxRetries = 10

do {
    try {
        $healthResponse = Invoke-RestMethod -Uri "$publicUrl/api/health" -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Status "App is responding! Status: $($healthResponse.status)"
        break
    } catch {
        $retries++
        if ($retries -lt $maxRetries) {
            Write-Warning "App not ready yet. Retrying in 2 seconds... (Attempt $retries/$maxRetries)"
            Start-Sleep -Seconds 2
        } else {
            Write-Warning "App might not be ready yet, but opening anyway..."
            break
        }
    }
} while ($retries -lt $maxRetries)

# Open URL in browser
Write-Info "Opening app in browser..."
try {
    Start-Process $publicUrl
    Write-Status "App opened in browser successfully!"
} catch {
    Write-Error "Failed to open browser: $($_.Exception.Message)"
    Write-Info "Please manually open: $publicUrl"
}

# Also open health check
Write-Info "Opening health check in new tab..."
try {
    Start-Process "$publicUrl/api/health"
} catch {
    Write-Warning "Could not open health check tab"
}

Write-Host ""
Write-Host "🎉 Your Converto SaaS app is now open in your browser!" -ForegroundColor $Green
Write-Host "📱 Share this URL with anyone: $publicUrl" -ForegroundColor $Yellow
Write-Host ""

# Save as HTML file for easy access
Write-Info "Saving clickable HTML file..."
& ".\scripts\display-url.ps1" -Save

Write-Host ""
Write-Host "📋 Quick Actions:" -ForegroundColor $Blue
Write-Host "  • View saved HTML: LIVE_APP.html" -ForegroundColor $White
Write-Host "  • Copy URL: .\scripts\display-url.ps1 -Copy" -ForegroundColor $White
Write-Host "  • Check status: .\scripts\display-url.ps1" -ForegroundColor $White
