# 🚀 Production Deployment Guide for Converto SaaS

This guide explains how to deploy your Converto SaaS application to production on localhost:4000.

## 🌐 What is This Setup?

**Dual Environment Setup** runs your application in two separate environments:
- ✅ **Development**: `http://localhost:3000` (for development work)
- ✅ **Production**: `http://localhost:4000` (production build)
- ✅ **No External Dependencies** - Everything runs locally
- ✅ **Easy Access** - Direct URLs, no tunneling complexity

## 📋 Prerequisites

1. **Docker** - For running your application
2. **Node.js** - For building the application
3. **Local Network** - For accessing localhost:4000

## 🚀 Quick Start

### **Option 1: One-Command Deployment (Recommended)**

#### **Windows:**
```powershell
# Start both environments:
.\scripts\manage-environments.ps1 -Start

# Or start individually:
.\scripts\manage-environments.ps1 -Development   # Port 3000
.\scripts\manage-environments.ps1 -Production    # Port 4000

# Check status:
.\scripts\manage-environments.ps1 -Status

# After deployment, easily access your app:
.\scripts\show-production-url.ps1    # Show production URL
Start-Process 'http://localhost:4000' # Open in browser
```

#### **Linux/Mac:**
```bash
chmod +x scripts/quick-deploy.sh
./scripts/quick-deploy.sh
```

This single command will:
1. 🐳 Build your Docker image
2. 🚀 Start the container
3. 📱 Deploy to port 4000
4. 🔗 Give you a local production URL

### **Option 2: Manual Step-by-Step**

#### **Step 1: Build and Run Docker**
```bash
# Build image
docker build -t converto-saas:latest .

# Run container
docker run -d --name converto-live -p 3000:3000 converto-saas:latest
```

#### **Step 2: Access Production**
```bash
# Access production
curl http://localhost:4000

# Or open in browser
open http://localhost:4000  # Mac
xdg-open http://localhost:4000  # Linux
```

#### **Step 3: Check Health**
```bash
# Health check
curl http://localhost:4000/api/health
```

## 📁 Scripts Overview

### **Core Scripts**

| Script | Purpose | Platform |
|--------|---------|----------|
| `manage-environments.sh/.ps1` | Environment management | Linux/Mac/Windows |
| `show-production-url.sh/.ps1` | Display production URL | Linux/Mac/Windows |
| `quick-deploy.sh/.ps1` | One-command deployment | Linux/Mac/Windows |

### **Environment Management Script**
The environment management script handles both environments:
- ✅ Starts development on port 3000
- ✅ Starts production on port 4000
- ✅ Manages Docker containers
- ✅ Provides easy access URLs

### **Production URL Script**
Easy access to your production app:
```bash
./scripts/show-production-url.sh     # Show production URL
./scripts/show-production-url.sh     # Check container status
Start-Process 'http://localhost:4000' # Open in browser (Windows)
open http://localhost:4000           # Open in browser (Mac)
xdg-open http://localhost:4000       # Open in browser (Linux)
```

### **Quick Access Commands**
Easy access to your production app:
```bash
# Windows
Start-Process 'http://localhost:4000'     # Open in browser
.\scripts\show-production-url.ps1         # Show URL info

# Linux/Mac
xdg-open http://localhost:4000            # Open in browser
./scripts/show-production-url.sh          # Show URL info
```

## 🔧 Configuration

### **Docker Configuration**
Your app runs in Docker containers:
```bash
# Development container
docker run -d --name converto-dev -p 3000:3000 converto-saas:latest

# Production container
docker run -d --name converto-live -p 4000:3000 converto-saas:latest
```

### **Port Configuration**
```bash
# Development: http://localhost:3000
# Production:  http://localhost:4000
# Health Check: http://localhost:4000/api/health
```

## 🎯 Jenkins Integration

### **Updated Jenkinsfile**
Your Jenkins pipeline now deploys to production:
```yaml
stage('Deploy to Production') {
    steps {
        script {
            // Build Docker image
            sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            
            // Run container on port 4000
            sh "docker run -d --name converto-live -p 4000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
            
            // Display production URL
            sh "echo '🌐 Production URL: http://localhost:4000'"
        }
    }
}
```

### **Jenkins Output**
After successful deployment, you'll see:
```
🎉 PRODUCTION DEPLOYMENT COMPLETE!
=====================================
🌐 Production URL: http://localhost:4000
🔗 Health Check: http://localhost:4000/api/health
📱 Your app is now running on port 4000!
=====================================
```

## 🌐 Accessing Your App

### **Dual Environment Setup**
- **🔧 Development**: `http://localhost:3000` (for development work)
- **📱 Production**: `http://localhost:4000` (production build)
- **🚀 No External Dependencies** - Everything runs locally

### **Local Access**
- **Development**: `http://localhost:3000`
- **Production**: `http://localhost:4000`
- **Health Check**: `http://localhost:4000/api/health`

### **Quick Access**
- **Production App**: `http://localhost:4000`
- **Health Status**: `http://localhost:4000/api/health`
- **Container Status**: Check with `docker ps`

## 📱 Features

### **What Works**
- ✅ **Image Upload** - Drag & drop or click to upload
- ✅ **PDF Generation** - Convert multiple images to PDF
- ✅ **Mobile Responsive** - Works on all devices
- ✅ **Local Production** - Runs on localhost:4000
- ✅ **Easy Access** - Direct URLs, no tunneling

### **Benefits**
- ✅ **No External Dependencies** - Everything runs locally
- ✅ **Consistent URLs** - Always localhost:4000
- ✅ **Fast Access** - No network latency
- ✅ **Secure** - Only accessible from your machine

## 🔍 Troubleshooting

### **Common Issues**

#### **1. Production Container Not Starting**
```bash
# Check if Docker is running
docker --version

# Check if port 4000 is available
netstat -an | grep 4000

# Check Docker container
docker ps | grep converto-live
```

#### **2. Production Not Accessible**
```bash
# Check container status
docker ps -a | grep converto-live

# Check container logs
docker logs converto-live

# Restart container
docker restart converto-live
```

#### **3. Health Check Failing**
```bash
# Check container logs
docker logs converto-live

# Check local health
curl http://localhost:4000/api/health

# Check container status
docker ps | grep converto-live
```

### **Debug Commands**
```bash
# Check Docker containers
docker ps -a

# Check container logs
docker logs converto-live

# Check network ports
netstat -tulpn | grep 4000

# Check container resources
docker stats converto-live
```

## 🚀 Advanced Usage

### **Multiple Production Instances**
```bash
# Run multiple production containers
docker run -d --name converto-live-1 -p 4001:3000 converto-saas:latest
docker run -d --name converto-live-2 -p 4002:3000 converto-saas:latest

# Access multiple instances
# Instance 1: http://localhost:4001
# Instance 2: http://localhost:4002
```

### **Custom Ports**
```bash
# Deploy to custom port
docker run -d --name converto-live -p 5000:3000 converto-saas:latest

# Access at: http://localhost:5000
```

### **Load Balancing**
```bash
# Use nginx for load balancing between multiple containers
# Configure nginx to proxy to localhost:4001, localhost:4002, etc.
```

## 📊 Monitoring

### **Health Checks**
```bash
# Manual health check
curl http://localhost:4000/api/health

# Automated monitoring
watch -n 30 'curl http://localhost:4000/api/health'
```

### **Logs**
```bash
# View Docker logs
docker logs -f converto-live

# View application logs
docker exec converto-live tail -f /app/.next/logs/*

# Check container status
docker ps | grep converto-live
```

## 🔒 Security Considerations

### **Local Deployment Benefits**
- **No External Exposure**: Only accessible from your machine
- **No Network Dependencies**: Works offline
- **Consistent Security**: Same security as localhost
- **No Rate Limits**: Unlimited local access

### **Security Best Practices**
- ✅ **Local Access Only**: App runs on localhost
- ✅ **Regular Updates**: Restart containers periodically
- ✅ **Monitor Containers**: Check Docker status
- ✅ **Port Management**: Use dedicated ports (3000, 4000)

## 🎉 Success!

Once deployed, your app will be:
- 📱 **Running in production** on localhost:4000
- 🔧 **Development available** on localhost:3000
- 🚀 **Ready for testing** and demos
- 🔒 **Secure and local** - no external dependencies

### **Access Your App**
- **Production**: http://localhost:4000
- **Development**: http://localhost:3000
- **Health Check**: http://localhost:4000/api/health
- **Demo Ready**: Perfect for local presentations and testing

## 📚 Next Steps

1. **Test Your Deployment** - Visit http://localhost:4000
2. **Start Development** - Work on http://localhost:3000
3. **Monitor Production** - Use the management scripts
4. **Scale Up** - Add more production instances if needed

---

**🎯 Your Converto SaaS app is now running in production on localhost:4000!** 🎉
