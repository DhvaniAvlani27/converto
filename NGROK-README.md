# 🚀 ngrok Deployment Guide for Converto SaaS

This guide explains how to deploy your Converto SaaS application to the internet for free using ngrok tunnels.

## 🌐 What is ngrok?

**ngrok** creates secure tunnels to localhost, making your local development server accessible from anywhere on the internet. It's perfect for:
- ✅ **Free hosting** (with limitations)
- ✅ **Quick demos** and testing
- ✅ **Webhook testing** for APIs
- ✅ **Temporary public URLs**

## 📋 Prerequisites

1. **Docker** - For running your application
2. **ngrok** - For creating public tunnels
3. **Node.js** - For building the application

## 🚀 Quick Start

### **Option 1: One-Command Deployment (Recommended)**

#### **Windows:**
```powershell
.\scripts\quick-deploy.ps1
```

#### **Linux/Mac:**
```bash
chmod +x scripts/quick-deploy.sh
./scripts/quick-deploy.sh
```

This single command will:
1. 🐳 Build your Docker image
2. 🚀 Start the container
3. 🌐 Create ngrok tunnel
4. 🔗 Give you a public URL

### **Option 2: Manual Step-by-Step**

#### **Step 1: Build and Run Docker**
```bash
# Build image
docker build -t converto-saas:latest .

# Run container
docker run -d --name converto-live -p 3000:3000 converto-saas:latest
```

#### **Step 2: Start ngrok Tunnel**
```bash
# Start tunnel
ngrok http 3000

# Or use the management script
./scripts/ngrok-manager.sh start
```

#### **Step 3: Get Public URL**
```bash
# View tunnel info
curl http://localhost:4040/api/tunnels

# Or use the management script
./scripts/ngrok-manager.sh url
```

## 📁 Scripts Overview

### **Core Scripts**

| Script | Purpose | Platform |
|--------|---------|----------|
| `quick-deploy.sh/.ps1` | One-command deployment | Linux/Mac/Windows |
| `ngrok-deploy.sh/.ps1` | Basic ngrok deployment | Linux/Mac/Windows |
| `ngrok-manager.sh` | Advanced ngrok management | Linux/Mac |

### **Quick Deploy Script**
The quick deploy script automates the entire process:
- ✅ Builds Docker image
- ✅ Starts container
- ✅ Creates ngrok tunnel
- ✅ Performs health checks
- ✅ Provides public URL

### **ngrok Manager Script**
Advanced management with commands:
```bash
./scripts/ngrok-manager.sh start     # Start tunnel
./scripts/ngrok-manager.sh stop      # Stop tunnel
./scripts/ngrok-manager.sh restart   # Restart tunnel
./scripts/ngrok-manager.sh status    # Show status
./scripts/ngrok-manager.sh health    # Health check
./scripts/ngrok-manager.sh logs      # Show logs
./scripts/ngrok-manager.sh url       # Get public URL
```

## 🔧 Configuration

### **ngrok Configuration File**
Create `.ngrok.yml` for custom settings:
```yaml
version: "2"
authtoken: YOUR_NGROK_AUTHTOKEN_HERE

tunnels:
  converto-app:
    proto: http
    addr: 3000
    subdomain: converto-saas  # Optional: custom subdomain
    inspect: true
    log: stdout
    log_level: info
```

### **Environment Variables**
```bash
# Optional: Set ngrok authtoken
export NGROK_AUTHTOKEN=your_token_here

# Or create .env file
echo "NGROK_AUTHTOKEN=your_token_here" > .env
```

## 🎯 Jenkins Integration

### **Updated Jenkinsfile**
Your Jenkins pipeline now includes ngrok deployment:
```yaml
stage('Deploy with ngrok') {
    when {
        branch 'main'
    }
    steps {
        script {
            // Build Docker image
            sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            
            // Run container
            sh "docker run -d --name converto-live -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
            
            // Start ngrok tunnel
            sh "./scripts/ngrok-deploy.sh"
        }
    }
}
```

### **Jenkins Commands**
```bash
# Check status
docker exec jenkins ./scripts/ngrok-manager.sh status

# View logs
docker exec jenkins ./scripts/ngrok-manager.sh logs

# Get public URL
docker exec jenkins ./scripts/ngrok-manager.sh url
```

## 🌐 Accessing Your App

### **Local Access**
- **URL**: `http://localhost:3000`
- **Health Check**: `http://localhost:3000/api/health`

### **Public Access**
- **URL**: `https://abc123.ngrok.io` (changes each time)
- **Health Check**: `https://abc123.ngrok.io/api/health`

### **ngrok Dashboard**
- **URL**: `http://localhost:4040`
- **Features**: Tunnel inspection, request logs, replay

## 📱 Features

### **What Works**
- ✅ **Image Upload** - Drag & drop or click to upload
- ✅ **PDF Generation** - Convert multiple images to PDF
- ✅ **Mobile Responsive** - Works on all devices
- ✅ **HTTPS Security** - Automatically enabled
- ✅ **Global Access** - Anyone with internet can use

### **Limitations**
- ❌ **Temporary URLs** - Change on each restart
- ❌ **No Custom Domain** - Random subdomains (free tier)
- ❌ **Session Limits** - Free tier restrictions
- ❌ **Local Dependency** - Your computer must stay on

## 🔍 Troubleshooting

### **Common Issues**

#### **1. ngrok Not Starting**
```bash
# Check if ngrok is installed
ngrok version

# Check if port 3000 is available
netstat -an | grep 3000

# Check Docker container
docker ps | grep converto-live
```

#### **2. Tunnel Not Accessible**
```bash
# Check ngrok status
./scripts/ngrok-manager.sh status

# Check tunnel logs
./scripts/ngrok-manager.sh logs

# Restart tunnel
./scripts/ngrok-manager.sh restart
```

#### **3. Health Check Failing**
```bash
# Check container logs
docker logs converto-live

# Check local health
curl http://localhost:3000/api/health

# Check ngrok tunnel
curl http://localhost:4040/api/tunnels
```

### **Debug Commands**
```bash
# View all processes
ps aux | grep ngrok

# Check Docker status
docker ps -a

# View ngrok logs
tail -f ngrok.log

# Check network
netstat -tulpn | grep 3000
```

## 🚀 Advanced Usage

### **Multiple Tunnels**
```bash
# Start multiple tunnels
ngrok start --config .ngrok.yml converto-app converto-health
```

### **Custom Subdomains**
```yaml
# .ngrok.yml
tunnels:
  converto-app:
    proto: http
    addr: 3000
    subdomain: converto-saas  # Requires paid plan
```

### **Load Balancing**
```bash
# Run multiple containers
docker run -d --name converto-live-1 -p 3001:3000 converto-saas:latest
docker run -d --name converto-live-2 -p 3002:3000 converto-saas:latest

# Use nginx for load balancing
```

## 📊 Monitoring

### **Health Checks**
```bash
# Manual health check
./scripts/ngrok-manager.sh health

# Automated monitoring
watch -n 30 './scripts/ngrok-manager.sh health'
```

### **Logs**
```bash
# View ngrok logs
./scripts/ngrok-manager.sh logs

# View Docker logs
docker logs -f converto-live

# View application logs
docker exec converto-live tail -f /app/.next/logs/*
```

## 🔒 Security Considerations

### **Free Tier Limitations**
- **Session Limits**: 40 connections per minute
- **Tunnel Duration**: 2 hours (auto-restart needed)
- **No Custom Domains**: Random subdomains only

### **Security Best Practices**
- ✅ **HTTPS Only**: Always use HTTPS URLs
- ✅ **Regular Updates**: Restart tunnels periodically
- ✅ **Monitor Access**: Check ngrok dashboard
- ✅ **Limit Exposure**: Use only for demos/testing

## 🎉 Success!

Once deployed, your app will be:
- 🌐 **Live on the internet** with a public URL
- 📱 **Accessible from anywhere** with internet access
- 🔒 **Secure with HTTPS** automatically enabled
- 🚀 **Ready for demos** and testing

### **Share Your App**
- **Public URL**: Share the ngrok URL with anyone
- **Demo Ready**: Perfect for presentations and demos
- **Testing**: Great for webhook testing and API development

## 📚 Next Steps

1. **Test Your Deployment** - Visit the public URL
2. **Share with Others** - Send the URL to friends/colleagues
3. **Monitor Performance** - Use the management scripts
4. **Consider Upgrades** - Paid ngrok plans for production use

---

**🎯 Your Converto SaaS app is now live on the internet for FREE!** 🎉
