# CI/CD Setup for Converto SaaS

This project includes a complete CI/CD pipeline using Jenkins and Docker for automated building, testing, and deployment.

## 🏗️ Architecture Overview

- **Frontend**: Next.js 14 with TypeScript
- **Containerization**: Multi-stage Docker build
- **CI/CD**: Jenkins pipeline with Docker integration
- **Deployment**: Kubernetes manifests included
- **Registry**: Docker registry integration ready

## 📁 CI/CD Files Structure

```
converto-saas/
├── Dockerfile                 # Multi-stage Docker build
├── docker-compose.yml         # Local development with Docker Compose
├── Jenkinsfile               # Jenkins pipeline definition
├── .dockerignore             # Docker build optimization
├── k8s/                      # Kubernetes manifests
│   └── deployment.yaml       # K8s deployment and service
├── scripts/                   # Helper scripts
│   ├── docker-build.sh       # Linux/Mac Docker script
│   └── docker-build.ps1      # Windows PowerShell script
└── src/app/api/health/       # Health check endpoint
    └── route.ts
```

## 🚀 Quick Start

### 1. Local Docker Development

```bash
# Build and run with Docker Compose
docker-compose up --build

# Or use the helper script
./scripts/docker-build.sh        # Linux/Mac
./scripts/docker-build.ps1       # Windows
```

### 2. Manual Docker Commands

```bash
# Build the image
docker build -t converto-saas .

# Run the container
docker run -p 3000:3000 converto-saas

# View logs
docker logs <container_id>
```

## 🔧 Jenkins Setup

### Prerequisites
- Jenkins server installed and running
- Docker installed on Jenkins server
- Git repository access configured

### Pipeline Features
1. **Checkout**: Pulls latest code from repository
2. **Install Dependencies**: Runs `npm ci` for clean install
3. **Lint**: Code quality checks with ESLint
4. **Build**: Creates production build with `npm run build`
5. **Test**: Placeholder for test execution
6. **Docker Build**: Creates Docker image with build number tag
7. **Registry Push**: Pushes to Docker registry (main branch only)
8. **Deploy**: Automatic deployment to staging/production

### Jenkins Configuration
1. Create a new Jenkins pipeline job
2. Point to your Git repository
3. Set the Jenkinsfile path to `Jenkinsfile`
4. Configure webhook triggers for automatic builds

## 🐳 Docker Configuration

### Multi-stage Build
- **Base**: Node.js 18 Alpine for minimal size
- **Deps**: Install production dependencies only
- **Builder**: Build the Next.js application
- **Runner**: Production-ready image with standalone output

### Optimization Features
- Alpine Linux base for smaller image size
- Multi-stage build to reduce final image size
- Production-only dependencies
- Non-root user for security
- Health checks for monitoring

## ☸️ Kubernetes Deployment

### Included Manifests
- **Deployment**: 3 replicas with resource limits
- **Service**: LoadBalancer type for external access
- **Health Checks**: Liveness and readiness probes
- **Resource Management**: CPU and memory limits

### Deployment Commands
```bash
# Apply the deployment
kubectl apply -f k8s/deployment.yaml

# Check status
kubectl get pods
kubectl get services

# View logs
kubectl logs -l app=converto-saas
```

## 🔄 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `production` |
| `PORT` | Application port | `3000` |
| `HOSTNAME` | Bind address | `0.0.0.0` |

## 📊 Monitoring & Health Checks

### Health Endpoint
- **URL**: `/api/health`
- **Method**: GET
- **Response**: JSON with status and timestamp
- **Use**: Docker health checks and load balancer health monitoring

### Docker Health Check
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1
```

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Node.js version compatibility
   - Verify all dependencies are in package.json
   - Check Docker daemon is running

2. **Container Won't Start**
   - Verify port 3000 is available
   - Check container logs: `docker logs <container_id>`
   - Ensure health check endpoint is accessible

3. **Jenkins Pipeline Failures**
   - Verify Docker is accessible from Jenkins
   - Check repository permissions
   - Review pipeline logs for specific errors

### Debug Commands
```bash
# Check Docker images
docker images

# Inspect container
docker inspect <container_id>

# View container processes
docker exec -it <container_id> ps aux

# Check network connectivity
docker exec -it <container_id> curl localhost:3000/api/health
```

## 🔒 Security Considerations

- Non-root user in container
- Production-only dependencies
- Resource limits in Kubernetes
- Health check endpoints for monitoring
- Environment variable configuration

## 📈 Scaling & Performance

- **Horizontal Scaling**: Kubernetes replica management
- **Resource Limits**: CPU and memory constraints
- **Load Balancing**: Service type LoadBalancer
- **Health Monitoring**: Automatic pod replacement

## 🎯 Next Steps

1. **Customize Registry**: Update `DOCKER_REGISTRY` in Jenkinsfile
2. **Add Tests**: Implement test suite in the Test stage
3. **Environment Configs**: Create staging/production specific configs
4. **Monitoring**: Add Prometheus/Grafana integration
5. **Backup**: Implement database backup strategies
6. **SSL**: Configure HTTPS with certificates

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Next.js Docker Deployment](https://nextjs.org/docs/deployment#docker-image)

---

**Note**: Remember to update the `DOCKER_REGISTRY` variable in the Jenkinsfile with your actual Docker registry URL before using the pipeline.
