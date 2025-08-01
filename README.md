# LuminaX Enterprise Learning Platform

🚀 **AI-Driven Online Learning Platform with 68 Microservices Architecture**

## 🏗️ Architecture Overview

LuminaX is built using a comprehensive microservices architecture with 68 specialized services organized into 8 domains:

### 🔐 Identity Domain (8 Services)
- Authentication Service (Port: 3001)
- Authorization Service (Port: 3002) 
- User Profile Service (Port: 3003)
- Session Management Service (Port: 3004)
- OAuth Provider Service (Port: 3005)
- Identity Verification Service (Port: 3006)
- Account Recovery Service (Port: 3007)
- Audit Logging Service (Port: 3008)

### 📚 Content Domain (10 Services)
- Course Catalog Service (Port: 3011)
- Lesson Content Service (Port: 3012)
- Video Processing Service (Port: 3013)
- File Storage Service (Port: 3014)
- Content Versioning Service (Port: 3015)
- Metadata Service (Port: 3016)
- Content Moderation Service (Port: 3017)
- Media Streaming Service (Port: 3018)
- Content Search Service (Port: 3019)
- Content Analytics Service (Port: 3020)

### 🎓 Learning Domain (9 Services)
- Progress Tracking Service (Port: 3021)
- Quiz Engine Service (Port: 3022)
- Certificate Service (Port: 3023)
- Learning Path Service (Port: 3024)
- Gamification Service (Port: 3025)
- Study Analytics Service (Port: 3026)
- Assignment Service (Port: 3027)
- Discussion Forum Service (Port: 3028)
- Live Session Service (Port: 3029)

### 💰 Commerce Domain (8 Services)
- Pricing Service (Port: 3031)
- Payment Processing Service (Port: 3032)
- Subscription Service (Port: 3033)
- Invoice Service (Port: 3034)
- Refund Service (Port: 3035)
- Financial Reporting Service (Port: 3036)
- Coupon Service (Port: 3037)
- Revenue Analytics Service (Port: 3038)

### 🤖 AI/ML Domain (10 Services)
- Recommendation Engine Service (Port: 3041)
- Chatbot Service (Port: 3042)
- Content Analysis Service (Port: 3043)
- Learning Optimization Service (Port: 3044)
- Predictive Analytics Service (Port: 3045)
- Personalization Service (Port: 3046)
- NLP Processing Service (Port: 3047)
- Skill Assessment Service (Port: 3048)
- Adaptive Learning Service (Port: 3049)
- AI Content Generator Service (Port: 3050)

### 📊 Analytics Domain (8 Services)
- User Behavior Analytics Service (Port: 3051)
- Course Performance Analytics Service (Port: 3052)
- Business Intelligence Service (Port: 3053)
- Real-time Metrics Service (Port: 3054)
- Reporting Service (Port: 3055)
- Dashboard Service (Port: 3056)
- Data Pipeline Service (Port: 3057)
- Metrics Aggregation Service (Port: 3058)

### 🔔 Communication Domain (7 Services)
- Email Service (Port: 3061)
- Push Notification Service (Port: 3062)
- SMS Service (Port: 3063)
- In-app Messaging Service (Port: 3064)
- Notification Orchestrator Service (Port: 3065)
- Communication Template Service (Port: 3066)
- Delivery Tracking Service (Port: 3067)

### 🛠️ Platform Domain (8 Services)
- API Gateway Service (Port: 3071)
- Service Discovery Service (Port: 3072)
- Configuration Service (Port: 3073)
- Logging Aggregation Service (Port: 3074)
- Monitoring Service (Port: 3075)
- Health Check Service (Port: 3076)
- Backup Service (Port: 3077)
- Admin Panel Service (Port: 3078)

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Git

### 1. Clone & Setup
```bash
git clone https://github.com/your-org/luminax-cep.git
cd luminax-cep
```

### 2. Verify All Services
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Verify existing services
./scripts/verify-services.sh
```

### 3. Create Missing Services
```bash
# Create all 68 microservices
./scripts/create-missing-services.sh
```

### 4. Start the Platform
```bash
# Start all services and infrastructure
docker-compose up -d

# Check health status
./scripts/health-check.sh
```

### 5. Access the Platform
- **Frontend**: http://localhost:5173
- **API Gateway**: http://localhost:8080
- **Admin Dashboard**: http://localhost:3000 (admin/luminax123)
- **Service Discovery**: http://localhost:8500
- **Monitoring**: http://localhost:9090

## 🏗️ Infrastructure Components

### Databases
- **MongoDB**: Primary database for most services
- **PostgreSQL**: Analytics and reporting data
- **Redis**: Caching and session management
- **Elasticsearch**: Search and logging

### Message Queues
- **Apache Kafka**: Event streaming and async processing
- **RabbitMQ**: Immediate messaging and notifications

### Monitoring & Observability
- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization
- **Jaeger**: Distributed tracing
- **ELK Stack**: Centralized logging

## 📊 Service Health Monitoring

### Real-time Health Checks
```bash
# Check all services
./scripts/health-check.sh

# Check specific domain
curl http://localhost:8080/health

# View service metrics
curl http://localhost:9090/metrics
```

### Monitoring Dashboards
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Jaeger**: http://localhost:16686

## 🔧 Development

### Running Individual Services
```bash
# Start specific service
cd services/identity/authentication-service
npm install
npm run dev
```

### Testing
```bash
# Run all tests
npm test

# Run specific service tests
cd services/identity/authentication-service
npm test
```

### API Documentation
Each service provides OpenAPI documentation at `/docs` endpoint:
- Authentication: http://localhost:3001/docs
- Course Catalog: http://localhost:3011/docs
- etc.

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f [service-name]

# Restart specific service
docker-compose restart [service-name]

# Scale service
docker-compose up -d --scale authentication-service=3

# Stop all services
docker-compose down

# Clean up volumes
docker-compose down -v
```

## ☸️ Kubernetes Deployment

```bash
# Create namespaces
kubectl create namespace luminax-identity
kubectl create namespace luminax-content
kubectl create namespace luminax-learning
# ... etc for all domains

# Deploy all services
find services -name "deployment.yaml" -exec kubectl apply -f {} \;

# Check deployments
kubectl get pods --all-namespaces
```

## 🔐 Security

- JWT-based authentication
- Role-based access control (RBAC)
- API rate limiting
- Input validation and sanitization
- HTTPS/TLS encryption
- Container security scanning

## 📈 Performance & Scaling

- Horizontal pod autoscaling
- Load balancing with NGINX
- Database connection pooling
- Redis caching strategies
- CDN integration for static assets
- Microservice circuit breakers

## 🛠️ Troubleshooting

### Common Issues

1. **Service not starting**
   ```bash
   docker-compose logs [service-name]
   ```

2. **Database connection issues**
   ```bash
   # Check database status
   docker-compose ps
   
   # Restart databases
   docker-compose restart mongodb-primary redis-master
   ```

3. **Port conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep [port]
   
   # Kill process using port
   sudo kill -9 $(lsof -t -i:[port])
   ```

### Health Check Endpoints
All services provide health checks at `/health`:
```bash
curl http://localhost:3001/health  # Authentication service
curl http://localhost:3011/health  # Course catalog service
# etc.
```

## 📚 Documentation

- [API Documentation](./docs/api/)
- [Architecture Guide](./docs/architecture/)
- [Deployment Guide](./docs/deployment/)
- [Development Guide](./docs/development/)
- [Troubleshooting](./docs/troubleshooting/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [docs.luminax.com](https://docs.luminax.com)
- **Issues**: [GitHub Issues](https://github.com/your-org/luminax-cep/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/luminax-cep/discussions)
- **Email**: support@luminax.com

---

**Built with ❤️ by the LuminaX Team**