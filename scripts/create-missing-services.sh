#!/bin/bash

# LuminaX Missing Services Creation Script
# Creates all missing microservices with proper structure

echo "🚀 Creating Missing LuminaX Services..."
echo "======================================"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Base directory for services
SERVICES_DIR="./services"

# Create services directory if it doesn't exist
mkdir -p "$SERVICES_DIR"

# Function to create a microservice
create_microservice() {
    local domain=$1
    local service_name=$2
    local port=$3
    
    echo -e "${BLUE}Creating $service_name in $domain domain (port $port)...${NC}"
    
    # Create service directory
    local service_dir="$SERVICES_DIR/$domain/$service_name"
    mkdir -p "$service_dir"
    
    # Create directory structure
    mkdir -p "$service_dir/src/controllers"
    mkdir -p "$service_dir/src/services"
    mkdir -p "$service_dir/src/models"
    mkdir -p "$service_dir/src/routes"
    mkdir -p "$service_dir/src/middleware"
    mkdir -p "$service_dir/src/config"
    mkdir -p "$service_dir/src/utils"
    mkdir -p "$service_dir/tests/unit"
    mkdir -p "$service_dir/tests/integration"
    mkdir -p "$service_dir/deployment/k8s"
    mkdir -p "$service_dir/docs"
    
    # Create package.json
    cat > "$service_dir/package.json" << EOF
{
  "name": "@luminax/$service_name",
  "version": "1.0.0",
  "description": "LuminaX $service_name microservice",
  "main": "dist/index.js",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "joi": "^17.9.2",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "mongoose": "^7.5.0",
    "redis": "^4.6.7",
    "axios": "^1.5.0",
    "winston": "^3.10.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/morgan": "^1.9.4",
    "@types/node": "^20.5.0",
    "@types/jest": "^29.5.4",
    "@types/jsonwebtoken": "^9.0.2",
    "@types/bcryptjs": "^2.4.2",
    "typescript": "^5.1.6",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.6.2",
    "ts-jest": "^29.1.1",
    "eslint": "^8.47.0",
    "@typescript-eslint/eslint-plugin": "^6.4.0",
    "@typescript-eslint/parser": "^6.4.0"
  },
  "keywords": ["luminax", "microservice", "$domain", "enterprise"],
  "author": "LuminaX Team",
  "license": "MIT"
}
EOF

    # Create TypeScript config
    cat > "$service_dir/tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF

    # Create main index.ts
    cat > "$service_dir/src/index.ts" << EOF
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { errorHandler } from './middleware/error.middleware';
import { authMiddleware } from './middleware/auth.middleware';
import routes from './routes';
import { connectDatabase } from './config/database';
import { connectRedis } from './config/redis';
import logger from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || $port;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    service: '$service_name',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// Routes
app.use('/api/v1', routes);

// Error handling
app.use(errorHandler);

// Start server
async function startServer() {
  try {
    await connectDatabase();
    await connectRedis();
    
    app.listen(PORT, () => {
      logger.info(\`🚀 \${process.env.npm_package_name} running on port \${PORT}\`);
      logger.info(\`📊 Health check: http://localhost:\${PORT}/health\`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

export default app;
EOF

    # Create controller
    cat > "$service_dir/src/controllers/${service_name}.controller.ts" << EOF
import { Request, Response, NextFunction } from 'express';
import { ${service_name}Service } from '../services/${service_name}.service';
import logger from '../utils/logger';

export class ${service_name}Controller {
  private ${service_name}Service: ${service_name}Service;

  constructor() {
    this.${service_name}Service = new ${service_name}Service();
  }

  // GET /api/v1/${service_name}
  public getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.${service_name}Service.getAll(req.query);
      res.status(200).json({
        success: true,
        data: result,
        message: 'Data retrieved successfully'
      });
    } catch (error) {
      logger.error('Error in getAll:', error);
      next(error);
    }
  };

  // GET /api/v1/${service_name}/:id
  public getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await this.${service_name}Service.getById(id);
      
      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Resource not found'
        });
      }

      res.status(200).json({
        success: true,
        data: result,
        message: 'Data retrieved successfully'
      });
    } catch (error) {
      logger.error('Error in getById:', error);
      next(error);
    }
  };

  // POST /api/v1/${service_name}
  public create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.${service_name}Service.create(req.body);
      res.status(201).json({
        success: true,
        data: result,
        message: 'Resource created successfully'
      });
    } catch (error) {
      logger.error('Error in create:', error);
      next(error);
    }
  };

  // PUT /api/v1/${service_name}/:id
  public update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await this.${service_name}Service.update(id, req.body);
      
      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Resource not found'
        });
      }

      res.status(200).json({
        success: true,
        data: result,
        message: 'Resource updated successfully'
      });
    } catch (error) {
      logger.error('Error in update:', error);
      next(error);
    }
  };

  // DELETE /api/v1/${service_name}/:id
  public delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await this.${service_name}Service.delete(id);
      
      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Resource not found'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Resource deleted successfully'
      });
    } catch (error) {
      logger.error('Error in delete:', error);
      next(error);
    }
  };
}
EOF

    # Create service
    cat > "$service_dir/src/services/${service_name}.service.ts" << EOF
import logger from '../utils/logger';

export class ${service_name}Service {
  
  public async getAll(query: any): Promise<any[]> {
    try {
      logger.info('Getting all records with query:', query);
      // TODO: Implement actual database query
      return [];
    } catch (error) {
      logger.error('Error in getAll service:', error);
      throw error;
    }
  }

  public async getById(id: string): Promise<any | null> {
    try {
      logger.info('Getting record by id:', id);
      // TODO: Implement actual database query
      return null;
    } catch (error) {
      logger.error('Error in getById service:', error);
      throw error;
    }
  }

  public async create(data: any): Promise<any> {
    try {
      logger.info('Creating new record:', data);
      // TODO: Implement actual database creation
      return { id: 'generated-id', ...data };
    } catch (error) {
      logger.error('Error in create service:', error);
      throw error;
    }
  }

  public async update(id: string, data: any): Promise<any | null> {
    try {
      logger.info('Updating record:', { id, data });
      // TODO: Implement actual database update
      return { id, ...data };
    } catch (error) {
      logger.error('Error in update service:', error);
      throw error;
    }
  }

  public async delete(id: string): Promise<boolean> {
    try {
      logger.info('Deleting record:', id);
      // TODO: Implement actual database deletion
      return true;
    } catch (error) {
      logger.error('Error in delete service:', error);
      throw error;
    }
  }
}
EOF

    # Create routes
    cat > "$service_dir/src/routes/index.ts" << EOF
import { Router } from 'express';
import { ${service_name}Controller } from '../controllers/${service_name}.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { validationMiddleware } from '../middleware/validation.middleware';

const router = Router();
const ${service_name}Controller = new ${service_name}Controller();

// ${service_name} routes
router.get('/${service_name}', authMiddleware, ${service_name}Controller.getAll);
router.get('/${service_name}/:id', authMiddleware, ${service_name}Controller.getById);
router.post('/${service_name}', authMiddleware, validationMiddleware, ${service_name}Controller.create);
router.put('/${service_name}/:id', authMiddleware, validationMiddleware, ${service_name}Controller.update);
router.delete('/${service_name}/:id', authMiddleware, ${service_name}Controller.delete);

export default router;
EOF

    # Create middleware files
    cat > "$service_dir/src/middleware/auth.middleware.ts" << EOF
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import logger from '../utils/logger';

export interface AuthRequest extends Request {
  user?: any;
}

export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret');
    req.user = decoded;
    next();
  } catch (error) {
    logger.error('Auth middleware error:', error);
    res.status(401).json({
      success: false,
      message: 'Invalid token.'
    });
  }
};
EOF

    cat > "$service_dir/src/middleware/validation.middleware.ts" << EOF
import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import logger from '../utils/logger';

export const validationMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // TODO: Implement specific validation schemas for this service
  next();
};
EOF

    cat > "$service_dir/src/middleware/error.middleware.ts" << EOF
import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

export const errorHandler = (error: any, req: Request, res: Response, next: NextFunction) => {
  logger.error('Error occurred:', {
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    body: req.body
  });

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
};
EOF

    # Create config files
    cat > "$service_dir/src/config/database.ts" << EOF
import mongoose from 'mongoose';
import logger from '../utils/logger';

export const connectDatabase = async (): Promise<void> => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/luminax-$domain';
    
    await mongoose.connect(mongoUri, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    
    logger.info('✅ MongoDB connected successfully');
  } catch (error) {
    logger.error('❌ MongoDB connection failed:', error);
    throw error;
  }
};

mongoose.connection.on('disconnected', () => {
  logger.warn('MongoDB disconnected');
});

mongoose.connection.on('error', (error) => {
  logger.error('MongoDB error:', error);
});
EOF

    cat > "$service_dir/src/config/redis.ts" << EOF
import { createClient } from 'redis';
import logger from '../utils/logger';

const redisClient = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

export const connectRedis = async (): Promise<void> => {
  try {
    await redisClient.connect();
    logger.info('✅ Redis connected successfully');
  } catch (error) {
    logger.error('❌ Redis connection failed:', error);
    throw error;
  }
};

redisClient.on('error', (error) => {
  logger.error('Redis error:', error);
});

export { redisClient };
EOF

    # Create utils
    cat > "$service_dir/src/utils/logger.ts" << EOF
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: '$service_name' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

export default logger;
EOF

    # Create Dockerfile
    cat > "$service_dir/Dockerfile" << EOF
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Create logs directory
RUN mkdir -p logs

# Expose port
EXPOSE $port

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:$port/health || exit 1

CMD ["npm", "start"]
EOF

    # Create docker-compose.yml
    cat > "$service_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  $service_name:
    build: .
    ports:
      - "$port:$port"
    environment:
      - NODE_ENV=development
      - PORT=$port
      - MONGODB_URI=mongodb://mongo:27017/luminax-$domain
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=your-jwt-secret-here
    depends_on:
      - mongo
      - redis
    volumes:
      - ./logs:/app/logs
    networks:
      - luminax-network

  mongo:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    networks:
      - luminax-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - luminax-network

volumes:
  mongo-data:

networks:
  luminax-network:
    driver: bridge
EOF

    # Create Kubernetes deployment
    cat > "$service_dir/deployment/k8s/deployment.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $service_name
  namespace: luminax-$domain
  labels:
    app: $service_name
    domain: $domain
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: $service_name
  template:
    metadata:
      labels:
        app: $service_name
        domain: $domain
        version: v1
    spec:
      containers:
      - name: $service_name
        image: luminax/$service_name:latest
        ports:
        - containerPort: $port
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "$port"
        - name: MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: uri
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: $port
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: $port
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: $service_name-service
  namespace: luminax-$domain
  labels:
    app: $service_name
spec:
  selector:
    app: $service_name
  ports:
  - port: 80
    targetPort: $port
    protocol: TCP
  type: ClusterIP
EOF

    # Create README
    cat > "$service_dir/README.md" << EOF
# $service_name

LuminaX $service_name microservice - part of the $domain domain.

## Overview

This service handles [describe the service functionality here].

## API Endpoints

- \`GET /api/v1/$service_name\` - Get all records
- \`GET /api/v1/$service_name/:id\` - Get record by ID
- \`POST /api/v1/$service_name\` - Create new record
- \`PUT /api/v1/$service_name/:id\` - Update record
- \`DELETE /api/v1/$service_name/:id\` - Delete record
- \`GET /health\` - Health check

## Environment Variables

- \`PORT\` - Service port (default: $port)
- \`NODE_ENV\` - Environment (development/production)
- \`MONGODB_URI\` - MongoDB connection string
- \`REDIS_URL\` - Redis connection string
- \`JWT_SECRET\` - JWT signing secret

## Development

\`\`\`bash
# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Build for production
npm run build

# Start production server
npm start
\`\`\`

## Docker

\`\`\`bash
# Build image
docker build -t luminax/$service_name .

# Run container
docker run -p $port:$port luminax/$service_name

# Run with docker-compose
docker-compose up
\`\`\`

## Kubernetes

\`\`\`bash
# Deploy to Kubernetes
kubectl apply -f deployment/k8s/
\`\`\`

## Health Check

The service provides a health check endpoint at \`/health\` that returns:

\`\`\`json
{
  "service": "$service_name",
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "version": "1.0.0"
}
\`\`\`
EOF

    # Create .env.example
    cat > "$service_dir/.env.example" << EOF
# Server Configuration
PORT=$port
NODE_ENV=development

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/luminax-$domain
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=your-super-secret-jwt-key-here

# Logging
LOG_LEVEL=info

# External Services (if needed)
# API_KEY=your-api-key-here
# WEBHOOK_URL=https://your-webhook-url.com
EOF

    echo -e "${GREEN}✅ Created $service_name successfully!${NC}"
}

# Service definitions (same as verification script)
SERVICES=(
    # IDENTITY DOMAIN (8 Services)
    "identity:authentication-service:3001"
    "identity:authorization-service:3002"
    "identity:user-profile-service:3003"
    "identity:session-management-service:3004"
    "identity:oauth-provider-service:3005"
    "identity:identity-verification-service:3006"
    "identity:account-recovery-service:3007"
    "identity:audit-logging-service:3008"
    
    # CONTENT DOMAIN (10 Services)
    "content:course-catalog-service:3011"
    "content:lesson-content-service:3012"
    "content:video-processing-service:3013"
    "content:file-storage-service:3014"
    "content:content-versioning-service:3015"
    "content:metadata-service:3016"
    "content:content-moderation-service:3017"
    "content:media-streaming-service:3018"
    "content:content-search-service:3019"
    "content:content-analytics-service:3020"
    
    # LEARNING DOMAIN (9 Services)
    "learning:progress-tracking-service:3021"
    "learning:quiz-engine-service:3022"
    "learning:certificate-service:3023"
    "learning:learning-path-service:3024"
    "learning:gamification-service:3025"
    "learning:study-analytics-service:3026"
    "learning:assignment-service:3027"
    "learning:discussion-forum-service:3028"
    "learning:live-session-service:3029"
    
    # COMMERCE DOMAIN (8 Services)
    "commerce:pricing-service:3031"
    "commerce:payment-processing-service:3032"
    "commerce:subscription-service:3033"
    "commerce:invoice-service:3034"
    "commerce:refund-service:3035"
    "commerce:financial-reporting-service:3036"
    "commerce:coupon-service:3037"
    "commerce:revenue-analytics-service:3038"
    
    # AI/ML DOMAIN (10 Services)
    "ai:recommendation-engine-service:3041"
    "ai:chatbot-service:3042"
    "ai:content-analysis-service:3043"
    "ai:learning-optimization-service:3044"
    "ai:predictive-analytics-service:3045"
    "ai:personalization-service:3046"
    "ai:nlp-processing-service:3047"
    "ai:skill-assessment-service:3048"
    "ai:adaptive-learning-service:3049"
    "ai:ai-content-generator-service:3050"
    
    # ANALYTICS DOMAIN (8 Services)
    "analytics:user-behavior-analytics-service:3051"
    "analytics:course-performance-analytics-service:3052"
    "analytics:business-intelligence-service:3053"
    "analytics:real-time-metrics-service:3054"
    "analytics:reporting-service:3055"
    "analytics:dashboard-service:3056"
    "analytics:data-pipeline-service:3057"
    "analytics:metrics-aggregation-service:3058"
    
    # COMMUNICATION DOMAIN (7 Services)
    "communication:email-service:3061"
    "communication:push-notification-service:3062"
    "communication:sms-service:3063"
    "communication:in-app-messaging-service:3064"
    "communication:notification-orchestrator-service:3065"
    "communication:communication-template-service:3066"
    "communication:delivery-tracking-service:3067"
    
    # PLATFORM DOMAIN (8 Services)
    "platform:api-gateway-service:3071"
    "platform:service-discovery-service:3072"
    "platform:configuration-service:3073"
    "platform:logging-aggregation-service:3074"
    "platform:monitoring-service:3075"
    "platform:health-check-service:3076"
    "platform:backup-service:3077"
    "platform:admin-panel-service:3078"
)

echo -e "${BLUE}Creating all 68 LuminaX microservices...${NC}"
echo ""

# Create all services
for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r domain service port <<< "$service_info"
    create_microservice "$domain" "$service" "$port"
done

echo ""
echo -e "${GREEN}🎉 All services created successfully!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "${BLUE}1. Review and customize each service according to your needs${NC}"
echo -e "${BLUE}2. Set up your databases (MongoDB, Redis, etc.)${NC}"
echo -e "${BLUE}3. Configure environment variables${NC}"
echo -e "${BLUE}4. Run: ./scripts/verify-services.sh to check all services${NC}"
echo -e "${BLUE}5. Start services: docker-compose up -d${NC}"