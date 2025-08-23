# Create Desktop Shortcut Script for Converto SaaS
# Creates a clickable shortcut to your live app

param(
    [switch]$Force
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

Write-Host "🚀 Desktop Shortcut Creator for Converto SaaS" -ForegroundColor $Blue
Write-Host "=============================================" -ForegroundColor $Blue

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

# Get desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "🚀 Converto SaaS.lnk"

# Check if shortcut already exists
if (Test-Path $shortcutPath) {
    if (-not $Force) {
        Write-Warning "Desktop shortcut already exists!"
        Write-Info "Use -Force to overwrite existing shortcut"
        Write-Host "  .\scripts\create-shortcut.ps1 -Force" -ForegroundColor $White
        exit 0
    else
        Write-Info "Overwriting existing shortcut..."
    }
}

# Create WScript Shell object
try {
    $WshShell = New-Object -ComObject WScript.Shell
} catch {
    Write-Error "Failed to create WScript Shell object"
    exit 1
}

# Create shortcut
try {
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $publicUrl
    $Shortcut.Description = "Open Converto SaaS - Live App"
    $Shortcut.IconLocation = "C:\Windows\System32\shell32.dll,21"  # Globe icon
    $Shortcut.Save()
    
    Write-Status "Desktop shortcut created successfully!"
    Write-Info "Location: $shortcutPath"
    Write-Info "Target: $publicUrl"
    
} catch {
    Write-Error "Failed to create shortcut: $($_.Exception.Message)"
    exit 1
}

# Also create a batch file for easy access
$batchPath = Join-Path $desktopPath "🚀 Open Converto SaaS.bat"
$batchContent = @"
@echo off
echo 🚀 Opening Converto SaaS...
echo 🌐 URL: $publicUrl
echo.
start "" "$publicUrl"
echo ✅ App opened in browser!
pause
"@

try {
    $batchContent | Out-File -FilePath $batchPath -Encoding ASCII
    Write-Status "Batch file created: $batchPath"
} catch {
    Write-Warning "Could not create batch file: $($_.Exception.Message)"
}

# Create a PowerShell script for advanced users
$psPath = Join-Path $desktopPath "🚀 Converto SaaS.ps1"
$psContent = @"
# Converto SaaS Launcher
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

`$url = "$publicUrl"

Write-Host "🚀 Launching Converto SaaS..." -ForegroundColor Green
Write-Host "🌐 URL: `$url" -ForegroundColor Cyan
Write-Host ""

# Check health
try {
    `$response = Invoke-RestMethod -Uri "`$url/api/health" -Method Get -TimeoutSec 5
    Write-Host "✅ App Status: `$(`$response.status)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Health check failed" -ForegroundColor Yellow
}

# Open in browser
Start-Process `$url
Write-Host "🎉 App opened in browser!" -ForegroundColor Green
"@

try {
    $psContent | Out-File -FilePath $psPath -Encoding UTF8
    Write-Status "PowerShell script created: $psPath"
} catch {
    Write-Warning "Could not create PowerShell script: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "🎉 Desktop shortcuts created successfully!" -ForegroundColor $Green
Write-Host ""
Write-Host "📋 Created Files:" -ForegroundColor $Blue
Write-Host "  • 🚀 Converto SaaS.lnk - Click to open app" -ForegroundColor $White
Write-Host "  • 🚀 Open Converto SaaS.bat - Double-click to run" -ForegroundColor $White
Write-Host "  • 🚀 Converto SaaS.ps1 - PowerShell launcher" -ForegroundColor $White
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor $Yellow
Write-Host "  • Double-click the .lnk file to open your app" -ForegroundColor $White
Write-Host "  • The shortcut will always point to your current live URL" -ForegroundColor $White
Write-Host "  • Re-run this script after each deployment to update the shortcut" -ForegroundColor $White
