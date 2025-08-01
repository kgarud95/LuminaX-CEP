#!/bin/bash

# LuminaX Service Verification Script
# Verifies all 68 microservices are running and healthy

echo "🔍 Starting LuminaX Enterprise Service Verification..."
echo "=================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Service definitions (Domain:Service:Port)
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

# Counters
TOTAL_SERVICES=${#SERVICES[@]}
RUNNING_SERVICES=0
MISSING_SERVICES=0
FAILED_SERVICES=0

# Arrays to store results
RUNNING_LIST=()
MISSING_LIST=()
FAILED_LIST=()

echo -e "${BLUE}Total services to verify: $TOTAL_SERVICES${NC}"
echo ""

# Function to check service health
check_service_health() {
    local domain=$1
    local service=$2
    local port=$3
    
    # Try to connect to service health endpoint
    if curl -f -s --connect-timeout 5 "http://localhost:$port/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $service${NC} (${domain}:$port) - ${GREEN}RUNNING${NC}"
        RUNNING_LIST+=("$domain:$service:$port")
        ((RUNNING_SERVICES++))
    elif curl -f -s --connect-timeout 5 "http://localhost:$port" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  $service${NC} (${domain}:$port) - ${YELLOW}RUNNING (No health endpoint)${NC}"
        RUNNING_LIST+=("$domain:$service:$port")
        ((RUNNING_SERVICES++))
    else
        echo -e "${RED}❌ $service${NC} (${domain}:$port) - ${RED}NOT RUNNING${NC}"
        MISSING_LIST+=("$domain:$service:$port")
        ((MISSING_SERVICES++))
    fi
}

# Check all services
echo "🔍 Checking service health..."
echo "================================"

for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r domain service port <<< "$service_info"
    check_service_health "$domain" "$service" "$port"
done

echo ""
echo "📊 VERIFICATION SUMMARY"
echo "======================="
echo -e "Total Services: ${BLUE}$TOTAL_SERVICES${NC}"
echo -e "Running: ${GREEN}$RUNNING_SERVICES${NC}"
echo -e "Missing: ${RED}$MISSING_SERVICES${NC}"
echo -e "Success Rate: ${BLUE}$(( RUNNING_SERVICES * 100 / TOTAL_SERVICES ))%${NC}"

if [ $MISSING_SERVICES -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ MISSING SERVICES:${NC}"
    echo "===================="
    for missing in "${MISSING_LIST[@]}"; do
        IFS=':' read -r domain service port <<< "$missing"
        echo -e "${RED}  • $service${NC} (${domain} domain, port $port)"
    done
    
    echo ""
    echo -e "${YELLOW}💡 To create missing services, run:${NC}"
    echo -e "${BLUE}  ./scripts/create-missing-services.sh${NC}"
fi

if [ $RUNNING_SERVICES -eq $TOTAL_SERVICES ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL SERVICES ARE RUNNING! LuminaX is fully operational.${NC}"
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  Some services are missing. Run the creation script to set them up.${NC}"
    exit 1
fi