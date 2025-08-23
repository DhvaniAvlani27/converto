# Docker build and run script for Converto SaaS (PowerShell)

param(
    [string]$ImageName = "converto-saas",
    [string]$ContainerName = "converto-saas-container",
    [int]$Port = 3000
)

Write-Host "🐳 Building Docker image..." -ForegroundColor Green
docker build -t $ImageName .

Write-Host "🧹 Cleaning up old containers..." -ForegroundColor Yellow
docker rm -f $ContainerName 2>$null

Write-Host "🚀 Starting container..." -ForegroundColor Green
docker run -d `
  --name $ContainerName `
  -p "${Port}:3000" `
  -e "NODE_ENV=production" `
  -e "PORT=3000" `
  $ImageName

Write-Host "✅ Container started successfully!" -ForegroundColor Green
Write-Host "🌐 Application is running at: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "📊 Container logs: docker logs $ContainerName" -ForegroundColor White
Write-Host "🛑 Stop container: docker stop $ContainerName" -ForegroundColor White
Write-Host "🗑️  Remove container: docker rm $ContainerName" -ForegroundColor White
