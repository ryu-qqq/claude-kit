#!/bin/bash

# Test script for verifying all service connections
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Service Connection Test Suite${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to test a connection
test_connection() {
    local service_name=$1
    local test_command=$2
    local description=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing $service_name... "
    
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓ PASSED${NC} - $description"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} - $description"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 1. MySQL Database
echo -e "${YELLOW}Database Services:${NC}"
test_connection "MySQL" \
    "mysql -h${MYSQL_HOST:-mysql} -P${MYSQL_PORT:-3306} -u${MYSQL_USER:-devuser} -p${MYSQL_PASSWORD:-devpass} -e 'SELECT VERSION()'" \
    "MySQL 8.4 on port 3306"

# Test database creation
test_connection "MySQL Database" \
    "mysql -h${MYSQL_HOST:-mysql} -P${MYSQL_PORT:-3306} -u${MYSQL_USER:-devuser} -p${MYSQL_PASSWORD:-devpass} ${MYSQL_DATABASE:-devdb} -e 'SHOW TABLES'" \
    "Database '${MYSQL_DATABASE:-devdb}' accessible"

echo ""

# 2. AWS Services
echo -e "${YELLOW}AWS Services:${NC}"
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    test_connection "AWS Credentials" \
        "aws sts get-caller-identity --profile ${AWS_PROFILE:-dev-readonly}" \
        "AWS credentials valid"
    
    test_connection "AWS S3" \
        "aws s3 ls --profile ${AWS_PROFILE:-dev-readonly} 2>&1 | head -n 1" \
        "S3 access (read-only)"
else
    echo -e "${YELLOW}⚠ AWS credentials not configured${NC}"
fi

# LocalStack (if running)
test_connection "LocalStack" \
    "curl -s http://localhost:4566/_localstack/health | grep '\"services\":'" \
    "LocalStack AWS emulator (optional)"

echo ""

# 3. Development Tools
echo -e "${YELLOW}Development Tools:${NC}"
test_connection "Java 21" \
    "java -version 2>&1 | grep '21'" \
    "Eclipse Temurin JDK 21"

test_connection "Gradle" \
    "gradle --version | grep '8.5'" \
    "Gradle 8.5 build tool"

test_connection "Spring Boot CLI" \
    "spring --version" \
    "Spring Boot 3.3 CLI"

test_connection "Terraform" \
    "terraform version | grep '1.7.5'" \
    "Terraform 1.7.5"

test_connection "Claude Code" \
    "claude --version" \
    "Claude Code CLI"

echo ""

# 4. External APIs
echo -e "${YELLOW}External APIs:${NC}"
test_connection "GitHub API" \
    "curl -s https://api.github.com/zen" \
    "GitHub API accessible"

test_connection "Maven Central" \
    "curl -s -o /dev/null -w '%{http_code}' https://repo.maven.apache.org/maven2/ | grep '200'" \
    "Maven Central repository"

test_connection "Gradle Plugins" \
    "curl -s -o /dev/null -w '%{http_code}' https://plugins.gradle.org/ | grep '200'" \
    "Gradle Plugin Portal"

test_connection "Spring Initializr" \
    "curl -s -o /dev/null -w '%{http_code}' https://start.spring.io/ | grep '200'" \
    "Spring Boot Initializr"

test_connection "Terraform Registry" \
    "curl -s -o /dev/null -w '%{http_code}' https://registry.terraform.io/ | grep '200'" \
    "Terraform Module Registry"

if [ -n "$OPENAI_API_KEY" ]; then
    test_connection "OpenAI API" \
        "curl -s -o /dev/null -w '%{http_code}' -H 'Authorization: Bearer $OPENAI_API_KEY' https://api.openai.com/v1/models | grep '200'" \
        "OpenAI API authenticated"
else
    echo -e "${YELLOW}⚠ OpenAI API key not configured (optional)${NC}"
fi

echo ""

# 5. Network & Firewall
echo -e "${YELLOW}Network & Security:${NC}"
test_connection "Firewall (Block Test)" \
    "! curl -s --connect-timeout 2 https://example.com" \
    "Firewall blocking non-whitelisted domains"

test_connection "DNS Resolution" \
    "nslookup github.com" \
    "DNS resolver working"

echo ""

# 6. File System & Permissions
echo -e "${YELLOW}File System:${NC}"
test_connection "Workspace Mount" \
    "[ -d /workspace ] && [ -w /workspace ]" \
    "Workspace mounted and writable"

test_connection "Claude Agents" \
    "[ -d /workspace/.claude/agents ] && [ -r /workspace/.claude/agents ]" \
    "Claude agents directory accessible"

test_connection "Gradle Cache" \
    "[ -d /home/developer/.gradle ] && [ -w /home/developer/.gradle ]" \
    "Gradle cache directory"

test_connection "Terraform Cache" \
    "[ -d /home/developer/.terraform.d ] && [ -w /home/developer/.terraform.d ]" \
    "Terraform plugin cache"

echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! Environment is fully operational.${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠ Some tests failed. Please check the configuration.${NC}"
    echo "Run 'docker-compose logs' to investigate issues."
fi

echo ""
echo "For detailed MySQL test: /workspace/test-mysql.sh"
echo "For Claude help: claude-help"