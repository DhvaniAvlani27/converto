# Jenkins Docker Setup with Docker-in-Docker

This directory contains everything needed to run Jenkins in Docker with full Docker capabilities for building and running containers.

## 🏗️ Architecture

- **Jenkins Master**: Runs in Docker container with Docker CLI access
- **Docker-in-Docker**: Jenkins can build and run Docker containers
- **Persistent Storage**: Jenkins data persists across container restarts
- **Network Access**: Jenkins can communicate with other Docker containers

## 📁 Files Structure

```
jenkins/
├── Dockerfile                    # Custom Jenkins image with Docker CLI
├── docker-compose.yml            # Standard Jenkins setup
├── docker-compose.custom.yml     # Custom Jenkins with Docker capabilities
├── setup.sh                      # Linux/Mac setup script
├── setup.ps1                     # Windows PowerShell setup script
├── plugins.txt                   # Required Jenkins plugins
└── README.md                     # This file
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

#### Linux/Mac:
```bash
chmod +x jenkins/setup.sh
./jenkins/setup.sh
```

#### Windows:
```powershell
.\jenkins\setup.ps1
```

### Option 2: Manual Setup

#### Standard Jenkins:
```bash
cd jenkins
docker-compose up -d
```

#### Custom Jenkins with Docker CLI:
```bash
cd jenkins
docker-compose -f docker-compose.custom.yml up --build -d
```

## 🔧 Configuration

### Ports
- **8080**: Jenkins web interface
- **50000**: Jenkins agent communication

### Volumes
- `jenkins_home`: Persistent Jenkins data
- `/var/run/docker.sock`: Docker socket access
- `/usr/bin/docker`: Docker binary access

### Environment Variables
- `JENKINS_OPTS`: Jenkins startup options
- `DOCKER_HOST`: Docker socket path

## 📋 Initial Setup

1. **Start Jenkins** using one of the methods above
2. **Wait for startup** (check logs: `docker-compose logs -f jenkins`)
3. **Get admin password** from logs
4. **Access Jenkins** at http://localhost:8080
5. **Install suggested plugins** during first run
6. **Create admin user** account

## 🐳 Docker-in-Docker Features

### What Jenkins Can Do:
- ✅ Build Docker images
- ✅ Run Docker containers
- ✅ Push to Docker registries
- ✅ Use Docker Compose
- ✅ Access Docker daemon

### Security Considerations:
- Jenkins runs with privileged access
- Has access to host Docker socket
- Can create/delete containers on host
- **Use in development/testing environments only**

## 🔌 Required Plugins

The `plugins.txt` file includes essential plugins:
- **Pipeline**: Declarative and scripted pipelines
- **Git**: Source code management
- **Docker**: Container integration
- **Blue Ocean**: Modern pipeline visualization
- **Credentials**: Secure credential management

## 📊 Monitoring & Management

### View Logs:
```bash
# Jenkins logs
docker-compose logs -f jenkins

# All services
docker-compose logs -f
```

### Stop Services:
```bash
docker-compose down
```

### Restart Services:
```bash
docker-compose restart
```

### Update Jenkins:
```bash
docker-compose pull
docker-compose up -d
```

## 🚨 Troubleshooting

### Common Issues:

1. **Port 8080 already in use**
   - Change port in docker-compose.yml
   - Kill process using the port

2. **Docker permission denied**
   - Ensure Docker Desktop is running
   - Check Docker socket permissions

3. **Jenkins won't start**
   - Check logs: `docker-compose logs jenkins`
   - Verify Docker is running
   - Check available disk space

4. **Can't build Docker images**
   - Use custom Jenkins image (option 2)
   - Verify Docker socket mounting
   - Check Jenkins user permissions

### Debug Commands:
```bash
# Check container status
docker-compose ps

# Check container resources
docker stats

# Access Jenkins container
docker-compose exec jenkins bash

# Check Docker access from Jenkins
docker-compose exec jenkins docker info
```

## 🔒 Security Notes

⚠️ **Important Security Considerations:**

- **Development Only**: This setup is for development/testing
- **Privileged Access**: Jenkins has full Docker access
- **Host Access**: Can access host Docker daemon
- **Network Access**: Exposed ports for web interface

### Production Recommendations:
- Use Jenkins agents instead of Docker-in-Docker
- Implement proper authentication and authorization
- Use secrets management for credentials
- Restrict network access
- Implement resource limits

## 🎯 Next Steps

After Jenkins is running:

1. **Create Pipeline Job** pointing to your repository
2. **Configure Webhooks** for automatic builds
3. **Set up Credentials** for Docker registry access
4. **Test Pipeline** with your existing Jenkinsfile
5. **Configure Notifications** (Slack, email, etc.)

## 📚 Additional Resources

- [Jenkins Docker Documentation](https://github.com/jenkinsci/docker)
- [Docker-in-Docker Best Practices](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Blue Ocean Documentation](https://jenkins.io/doc/book/blueocean/)

---

**Note**: This setup provides a development environment for Jenkins with Docker capabilities. For production use, consider using Jenkins agents and proper security configurations.
