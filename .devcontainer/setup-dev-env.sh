#!/bin/bash
set -e

echo "🚀 Java Spring + Terraform Development Environment Initialization"
echo "================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Check Claude Code agents
print_info "📦 Checking Claude Code agents..."
if [ -d "/workspace/.claude/agents" ]; then
    AGENT_COUNT=$(ls -1 /workspace/.claude/agents/*.md 2>/dev/null | wc -l)
    print_success "Found $AGENT_COUNT Claude agents ready to use"
    
    # List key agents
    echo "  Key agents available:"
    echo "    - spring-boot-architect (Spring Boot development)"
    echo "    - aws-terraform-architect (AWS infrastructure)"
    echo "    - aws-java-sdk-specialist (AWS SDK integration)"
    echo "    - database-architect (Database design)"
    echo "    - test-engineer (Testing strategies)"
else
    print_warning "Claude agents directory not found at /workspace/.claude/agents"
fi

# 2. Java and Spring Boot setup
print_info "☕ Setting up Java and Spring Boot environment..."
java -version 2>&1 | head -n 1
gradle --version | head -n 1
spring --version 2>/dev/null || print_warning "Spring Boot CLI not available"

# Create Spring Boot project template
mkdir -p /workspace/templates/spring-boot
cat > /workspace/templates/spring-boot/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.5'
    id 'io.spring.dependency-management' version '1.1.6'
}

group = 'com.company'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
    maven { url 'https://repo.spring.io/milestone' }
}

dependencies {
    // Spring Boot Starters
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    // MySQL
    runtimeOnly 'com.mysql:mysql-connector-j:8.4.0'
    
    // AWS SDK v2
    implementation platform('software.amazon.awssdk:bom:2.25.0')
    implementation 'software.amazon.awssdk:s3'
    implementation 'software.amazon.awssdk:dynamodb'
    implementation 'software.amazon.awssdk:sqs'
    
    // OpenAI (if needed)
    implementation 'com.theokanning.openai-gpt3-java:service:0.18.2'
    
    // Development tools
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    // Testing
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.testcontainers:mysql:1.19.3'
    testImplementation 'org.testcontainers:localstack:1.19.3'
}

tasks.named('test') {
    useJUnitPlatform()
}
EOF

print_success "Spring Boot template created at /workspace/templates/spring-boot/"

# 3. Terraform setup
print_info "🏗️ Setting up Terraform environment..."
terraform version | head -n 1

# Create Terraform template structure
mkdir -p /workspace/templates/terraform/{modules,environments}
cat > /workspace/templates/terraform/environments/dev/main.tf << 'EOF'
terraform {
  required_version = ">= 1.7.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend configuration for state management
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "claude-dev"
}
EOF

print_success "Terraform templates created at /workspace/templates/terraform/"

# 4. AWS CLI configuration
print_info "☁️ Configuring AWS CLI..."
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile dev-readonly
    aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile dev-readonly
    aws configure set region ap-northeast-2 --profile dev-readonly
    aws configure set output json --profile dev-readonly
    print_success "AWS CLI configured with dev-readonly profile"
else
    print_warning "AWS credentials not set. Please configure AWS CLI manually."
fi

# 5. MySQL connection test script
print_info "🗄️ Creating MySQL utilities..."
cat > /workspace/test-mysql.sh << 'EOF'
#!/bin/bash
echo "Testing MySQL connection..."
mysql -h${MYSQL_HOST:-mysql} -P${MYSQL_PORT:-3306} -u${MYSQL_USER:-devuser} -p${MYSQL_PASSWORD:-devpass} ${MYSQL_DATABASE:-devdb} -e "SELECT VERSION();" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ MySQL connection successful!"
else
    echo "❌ MySQL connection failed. Please check your credentials."
fi
EOF
chmod +x /workspace/test-mysql.sh

# 6. OpenAI API test (if configured)
if [ -n "$OPENAI_API_KEY" ]; then
    print_info "🤖 Testing OpenAI API connection..."
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        https://api.openai.com/v1/models)
    
    if [ "$response" = "200" ]; then
        print_success "OpenAI API key is valid"
    else
        print_warning "OpenAI API key validation failed (HTTP $response)"
    fi
else
    print_info "OpenAI API key not configured (optional)"
fi

# 7. Create quick start scripts
print_info "📝 Creating quick start scripts..."

# Spring Boot quick start
cat > /workspace/create-spring-app.sh << 'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./create-spring-app.sh <app-name>"
    exit 1
fi

APP_NAME=$1
echo "Creating Spring Boot application: $APP_NAME"

spring init \
    --build=gradle \
    --java-version=21 \
    --boot-version=3.3.5 \
    --dependencies=web,data-jpa,mysql,actuator,devtools,lombok \
    --group-id=com.company \
    --artifact-id=$APP_NAME \
    --name=$APP_NAME \
    --description="$APP_NAME Spring Boot Application" \
    --package-name=com.company.$APP_NAME \
    $APP_NAME

echo "✅ Spring Boot app created at ./$APP_NAME"
echo "To run: cd $APP_NAME && ./gradlew bootRun"
EOF
chmod +x /workspace/create-spring-app.sh

# Terraform project quick start
cat > /workspace/create-terraform-project.sh << 'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./create-terraform-project.sh <project-name>"
    exit 1
fi

PROJECT_NAME=$1
mkdir -p $PROJECT_NAME/{modules,environments/{dev,staging,prod}}
cd $PROJECT_NAME

echo "Creating Terraform project structure for: $PROJECT_NAME"
cp -r /workspace/templates/terraform/* .
terraform init

echo "✅ Terraform project created at ./$PROJECT_NAME"
echo "To plan: cd $PROJECT_NAME && terraform plan"
EOF
chmod +x /workspace/create-terraform-project.sh

# 8. Git configuration
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    print_info "📧 Configuring Git..."
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    print_success "Git configured"
fi

# 9. Final summary
echo ""
echo "=============================================================="
print_success "✨ Development environment ready!"
echo ""
echo "📚 Available Tools:"
echo "  - Java 21 (java -version)"
echo "  - Gradle 8.5 (gradle -v)"
echo "  - Spring Boot 3.3 (spring --version)"
echo "  - Terraform 1.7.5 (terraform version)"
echo "  - AWS CLI v2 (aws --version)"
echo "  - MySQL Client 8.4 (mysql --version)"
echo "  - Claude Code (claude --version)"
echo ""
echo "🚀 Quick Start Commands:"
echo "  - Create Spring app: ./create-spring-app.sh <app-name>"
echo "  - Create Terraform project: ./create-terraform-project.sh <project-name>"
echo "  - Test MySQL: ./test-mysql.sh"
echo "  - Load Claude agent: @agent:spring-boot-architect"
echo ""
echo "📖 For more help, type: claude-help"
echo "=============================================================="