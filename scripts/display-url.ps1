# Display URL Script for Converto SaaS
# Shows the ngrok URL after Jenkins pipeline completion

param(
    [switch]$Save,
    [switch]$Open,
    [switch]$Copy
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

# Display the URL prominently
Write-Host ""
Write-Host "🌐" -ForegroundColor $Cyan -NoNewline
Write-Host " ==========================================" -ForegroundColor $White
Write-Host "🚀 YOUR APP IS NOW LIVE ON THE INTERNET!" -ForegroundColor $Green
Write-Host "🌐 ==========================================" -ForegroundColor $White
Write-Host "📱 Production: Port 4000 (via ngrok)" -ForegroundColor $Yellow
Write-Host "🔧 Development: Port 3000 (local)" -ForegroundColor $Blue
Write-Host ""

Write-URL "🔗 Public URL: $publicUrl"
Write-Host ""

# Save URL to a clickable file
if ($Save) {
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Converto SaaS - Live URL</title>
    <meta charset="utf-8">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            margin: 0;
        }
        .container { 
            background: rgba(255,255,255,0.1); 
            padding: 40px; 
            border-radius: 20px; 
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        h1 { 
            font-size: 2.5em; 
            margin-bottom: 20px; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .url { 
            font-size: 1.5em; 
            margin: 30px 0; 
            padding: 20px; 
            background: rgba(255,255,255,0.2); 
            border-radius: 10px; 
            word-break: break-all;
        }
        .btn { 
            display: inline-block; 
            padding: 15px 30px; 
            background: #4CAF50; 
            color: white; 
            text-decoration: none; 
            border-radius: 25px; 
            font-size: 1.2em; 
            margin: 10px; 
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .btn:hover { 
            background: #45a049; 
            transform: translateY(-2px); 
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }
        .info { 
            margin-top: 30px; 
            font-size: 0.9em; 
            opacity: 0.8;
        }
        .timestamp { 
            margin-top: 20px; 
            font-size: 0.8em; 
            opacity: 0.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Converto SaaS</h1>
        <p>Your app is now live on the internet!</p>
        
        <div class="url">
            <strong>🌐 Public URL:</strong><br>
            <a href="$publicUrl" target="_blank" style="color: #4CAF50;">$publicUrl</a>
        </div>
        
        <a href="$publicUrl" target="_blank" class="btn">🚀 Open App Now</a>
        <a href="$publicUrl/api/health" target="_blank" class="btn">🏥 Health Check</a>
        
        <div class="info">
            <p>✅ HTTPS enabled automatically</p>
            <p>📱 Works on all devices</p>
            <p>🌍 Accessible worldwide</p>
        </div>
        
        <div class="timestamp">
            Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        </div>
    </div>
</body>
</html>
"@

    $htmlContent | Out-File -FilePath "LIVE_APP.html" -Encoding UTF8
    Write-Status "Saved clickable HTML file: LIVE_APP.html"
}

# Copy URL to clipboard
if ($Copy) {
    Set-Clipboard -Value $publicUrl
    Write-Status "URL copied to clipboard!"
}

# Open URL in browser
if ($Open) {
    Start-Process $publicUrl
    Write-Status "Opening app in browser..."
}

# Display additional information
Write-Host "📋 Quick Actions:" -ForegroundColor $Blue
Write-Host "  • Click the URL above to open your app" -ForegroundColor $White
Write-Host "  • Save as HTML: .\scripts\display-url.ps1 -Save" -ForegroundColor $White
Write-Host "  • Copy to clipboard: .\scripts\display-url.ps1 -Copy" -ForegroundColor $White
Write-Host "  • Open in browser: .\scripts\display-url.ps1 -Open" -ForegroundColor $White

Write-Host ""
Write-Host "🔍 Health Check:" -ForegroundColor $Blue
Write-Host "  • Status: $publicUrl/api/health" -ForegroundColor $White

Write-Host ""
Write-Host "📱 Share this URL with anyone to access your app!" -ForegroundColor $Yellow
Write-Host ""

# Check if app is responding
Write-Info "Checking if app is responding..."
try {
    $healthResponse = Invoke-RestMethod -Uri "$publicUrl/api/health" -Method Get -TimeoutSec 10 -ErrorAction Stop
    Write-Status "App is responding! Status: $($healthResponse.status)"
} catch {
    Write-Warning "App might not be ready yet. Please wait a moment and try again."
}

Write-Host ""
Write-Host "🎉 Your Converto SaaS app is now live and accessible worldwide!" -ForegroundColor $Green
