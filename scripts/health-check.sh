#!/bin/bash

# LuminaX Health Check Script
# Performs comprehensive health checks on all services and infrastructure

echo "🏥 LuminaX Health Check Dashboard"
echo "================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Health check function
check_health() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" 2>/dev/null)
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✅ $service_name${NC} - Healthy"
        return 0
    else
        echo -e "${RED}❌ $service_name${NC} - Unhealthy (HTTP $response)"
        return 1
    fi
}

# Check database connectivity
check_database() {
    local db_name=$1
    local connection_string=$2
    
    case $db_name in
        "MongoDB")
            if docker exec luminax-mongodb-primary-1 mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ $db_name${NC} - Connected"
                return 0
            else
                echo -e "${RED}❌ $db_name${NC} - Connection failed"
                return 1
            fi
            ;;
        "Redis")
            if docker exec luminax-redis-master-1 redis-cli ping | grep -q "PONG"; then
                echo -e "${GREEN}✅ $db_name${NC} - Connected"
                return 0
            else
                echo -e "${RED}❌ $db_name${NC} - Connection failed"
                return 1
            fi
            ;;
        "PostgreSQL")
            if docker exec luminax-postgres-analytics-1 pg_isready -U luminax >/dev/null 2>&1; then
                echo -e "${GREEN}✅ $db_name${NC} - Connected"
                return 0
            else
                echo -e "${RED}❌ $db_name${NC} - Connection failed"
                return 1
            fi
            ;;
        "Elasticsearch")
            if check_health "Elasticsearch" "http://localhost:9200/_cluster/health" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ $db_name${NC} - Connected"
                return 0
            else
                echo -e "${RED}❌ $db_name${NC} - Connection failed"
                return 1
            fi
            ;;
    esac
}

# Counters
total_services=0
healthy_services=0
total_infrastructure=0
healthy_infrastructure=0

echo ""
echo -e "${BLUE}🗄️  INFRASTRUCTURE HEALTH${NC}"
echo "=========================="

# Check databases
databases=("MongoDB" "Redis" "PostgreSQL" "Elasticsearch")
for db in "${databases[@]}"; do
    ((total_infrastructure++))
    if check_database "$db"; then
        ((healthy_infrastructure++))
    fi
done

# Check message queues
echo ""
if check_health "Kafka" "http://localhost:9092" 0; then
    ((healthy_infrastructure++))
fi
((total_infrastructure++))

if check_health "RabbitMQ Management" "http://localhost:15672"; then
    ((healthy_infrastructure++))
fi
((total_infrastructure++))

echo ""
echo -e "${PURPLE}🚀 MICROSERVICES HEALTH${NC}"
echo "========================"

# Identity Domain Services
echo -e "${CYAN}🔐 Identity Domain${NC}"
identity_services=(
    "Authentication Service:http://localhost:3001/health"
    "Authorization Service:http://localhost:3002/health"
    "User Profile Service:http://localhost:3003/health"
    "Session Management Service:http://localhost:3004/health"
    "OAuth Provider Service:http://localhost:3005/health"
    "Identity Verification Service:http://localhost:3006/health"
    "Account Recovery Service:http://localhost:3007/health"
    "Audit Logging Service:http://localhost:3008/health"
)

for service in "${identity_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}📚 Content Domain${NC}"
content_services=(
    "Course Catalog Service:http://localhost:3011/health"
    "Lesson Content Service:http://localhost:3012/health"
    "Video Processing Service:http://localhost:3013/health"
    "File Storage Service:http://localhost:3014/health"
    "Content Versioning Service:http://localhost:3015/health"
    "Metadata Service:http://localhost:3016/health"
    "Content Moderation Service:http://localhost:3017/health"
    "Media Streaming Service:http://localhost:3018/health"
    "Content Search Service:http://localhost:3019/health"
    "Content Analytics Service:http://localhost:3020/health"
)

for service in "${content_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}🎓 Learning Domain${NC}"
learning_services=(
    "Progress Tracking Service:http://localhost:3021/health"
    "Quiz Engine Service:http://localhost:3022/health"
    "Certificate Service:http://localhost:3023/health"
    "Learning Path Service:http://localhost:3024/health"
    "Gamification Service:http://localhost:3025/health"
    "Study Analytics Service:http://localhost:3026/health"
    "Assignment Service:http://localhost:3027/health"
    "Discussion Forum Service:http://localhost:3028/health"
    "Live Session Service:http://localhost:3029/health"
)

for service in "${learning_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}💰 Commerce Domain${NC}"
commerce_services=(
    "Pricing Service:http://localhost:3031/health"
    "Payment Processing Service:http://localhost:3032/health"
    "Subscription Service:http://localhost:3033/health"
    "Invoice Service:http://localhost:3034/health"
    "Refund Service:http://localhost:3035/health"
    "Financial Reporting Service:http://localhost:3036/health"
    "Coupon Service:http://localhost:3037/health"
    "Revenue Analytics Service:http://localhost:3038/health"
)

for service in "${commerce_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}🤖 AI/ML Domain${NC}"
ai_services=(
    "Recommendation Engine Service:http://localhost:3041/health"
    "Chatbot Service:http://localhost:3042/health"
    "Content Analysis Service:http://localhost:3043/health"
    "Learning Optimization Service:http://localhost:3044/health"
    "Predictive Analytics Service:http://localhost:3045/health"
    "Personalization Service:http://localhost:3046/health"
    "NLP Processing Service:http://localhost:3047/health"
    "Skill Assessment Service:http://localhost:3048/health"
    "Adaptive Learning Service:http://localhost:3049/health"
    "AI Content Generator Service:http://localhost:3050/health"
)

for service in "${ai_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}📊 Analytics Domain${NC}"
analytics_services=(
    "User Behavior Analytics Service:http://localhost:3051/health"
    "Course Performance Analytics Service:http://localhost:3052/health"
    "Business Intelligence Service:http://localhost:3053/health"
    "Real-time Metrics Service:http://localhost:3054/health"
    "Reporting Service:http://localhost:3055/health"
    "Dashboard Service:http://localhost:3056/health"
    "Data Pipeline Service:http://localhost:3057/health"
    "Metrics Aggregation Service:http://localhost:3058/health"
)

for service in "${analytics_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}🔔 Communication Domain${NC}"
communication_services=(
    "Email Service:http://localhost:3061/health"
    "Push Notification Service:http://localhost:3062/health"
    "SMS Service:http://localhost:3063/health"
    "In-app Messaging Service:http://localhost:3064/health"
    "Notification Orchestrator Service:http://localhost:3065/health"
    "Communication Template Service:http://localhost:3066/health"
    "Delivery Tracking Service:http://localhost:3067/health"
)

for service in "${communication_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${CYAN}🛠️  Platform Domain${NC}"
platform_services=(
    "API Gateway Service:http://localhost:3071/health"
    "Service Discovery Service:http://localhost:3072/health"
    "Configuration Service:http://localhost:3073/health"
    "Logging Aggregation Service:http://localhost:3074/health"
    "Monitoring Service:http://localhost:3075/health"
    "Health Check Service:http://localhost:3076/health"
    "Backup Service:http://localhost:3077/health"
    "Admin Panel Service:http://localhost:3078/health"
)

for service in "${platform_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    ((total_services++))
    if check_health "$name" "$url"; then
        ((healthy_services++))
    fi
done

echo ""
echo -e "${BLUE}🔍 MONITORING & OBSERVABILITY${NC}"
echo "=============================="

monitoring_services=(
    "Prometheus:http://localhost:9090/-/healthy"
    "Grafana:http://localhost:3000/api/health"
    "Jaeger:http://localhost:16686"
)

for service in "${monitoring_services[@]}"; do
    IFS=':' read -r name url <<< "$service"
    if check_health "$name" "$url"; then
        ((healthy_infrastructure++))
    fi
    ((total_infrastructure++))
done

# Calculate percentages
service_health_percentage=$((healthy_services * 100 / total_services))
infrastructure_health_percentage=$((healthy_infrastructure * 100 / total_infrastructure))
overall_health_percentage=$(((healthy_services + healthy_infrastructure) * 100 / (total_services + total_infrastructure)))

echo ""
echo "📊 HEALTH SUMMARY"
echo "================="
echo -e "Infrastructure: ${BLUE}$healthy_infrastructure/$total_infrastructure${NC} (${BLUE}$infrastructure_health_percentage%${NC})"
echo -e "Microservices: ${BLUE}$healthy_services/$total_services${NC} (${BLUE}$service_health_percentage%${NC})"
echo -e "Overall Health: ${BLUE}$((healthy_services + healthy_infrastructure))/$((total_services + total_infrastructure))${NC} (${BLUE}$overall_health_percentage%${NC})"

echo ""
if [ $overall_health_percentage -eq 100 ]; then
    echo -e "${GREEN}🎉 ALL SYSTEMS OPERATIONAL! LuminaX is running perfectly.${NC}"
elif [ $overall_health_percentage -ge 80 ]; then
    echo -e "${YELLOW}⚠️  Most systems are operational. Some services may need attention.${NC}"
else
    echo -e "${RED}🚨 CRITICAL: Multiple systems are down. Immediate attention required.${NC}"
fi

echo ""
echo -e "${BLUE}🔗 Quick Links:${NC}"
echo "=============="
echo -e "• API Gateway: ${CYAN}http://localhost:8080${NC}"
echo -e "• Service Discovery: ${CYAN}http://localhost:8500${NC}"
echo -e "• Grafana Dashboard: ${CYAN}http://localhost:3000${NC} (admin/luminax123)"
echo -e "• Prometheus: ${CYAN}http://localhost:9090${NC}"
echo -e "• Jaeger Tracing: ${CYAN}http://localhost:16686${NC}"
echo -e "• RabbitMQ Management: ${CYAN}http://localhost:15672${NC} (luminax/luminax123)"
echo -e "• Elasticsearch: ${CYAN}http://localhost:9200${NC}"

echo ""
echo -e "${YELLOW}💡 Troubleshooting:${NC}"
echo "=================="
echo -e "• Check logs: ${CYAN}docker-compose logs [service-name]${NC}"
echo -e "• Restart service: ${CYAN}docker-compose restart [service-name]${NC}"
echo -e "• View all containers: ${CYAN}docker-compose ps${NC}"
echo -e "• Full system restart: ${CYAN}docker-compose down && docker-compose up -d${NC}"

# Exit with appropriate code
if [ $overall_health_percentage -eq 100 ]; then
    exit 0
elif [ $overall_health_percentage -ge 80 ]; then
    exit 1
else
    exit 2
fi