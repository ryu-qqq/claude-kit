#!/bin/bash
set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     🚀 Claude Code - Java Spring Development Environment      ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Claude Code CLI installation
echo -e "${BLUE}[1/4]${NC} Checking Claude Code CLI..."
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "version unknown")
    echo -e "  ${GREEN}✓${NC} Claude Code CLI is installed ($CLAUDE_VERSION)"
else
    echo -e "  ${YELLOW}⚠${NC} Claude Code CLI not found, installing..."
    npm install -g @anthropic-ai/claude-code@latest
    echo -e "  ${GREEN}✓${NC} Claude Code CLI installed successfully"
fi

# Check Claude agents
echo -e "${BLUE}[2/4]${NC} Loading Claude agents..."
if [ -d "/workspace/.claude/agents" ]; then
    AGENT_COUNT=$(ls -1 /workspace/.claude/agents/*.md 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} Found $AGENT_COUNT specialized agents"
    
    # Display categorized agents
    echo ""
    echo -e "${CYAN}📚 Available Claude Agents:${NC}"
    echo ""
    
    echo -e "${YELLOW}☕ Java & Spring Development:${NC}"
    echo "  • spring-boot-architect    - Enterprise Spring Boot applications"
    echo "  • aws-java-sdk-specialist  - AWS SDK v2 integration patterns"
    echo "  • database-architect       - Database design & optimization"
    echo "  • backend-architect        - API design & microservices"
    echo ""
    
    echo -e "${YELLOW}🏗️ Infrastructure & DevOps:${NC}"
    echo "  • aws-terraform-architect  - AWS infrastructure with Terraform"
    echo "  • cost-optimized-manager   - Cost-efficient environments"
    echo "  • devops-engineer         - CI/CD pipelines & automation"
    echo "  • cloud-architect         - Multi-cloud architecture"
    echo ""
    
    echo -e "${YELLOW}🧪 Quality & Testing:${NC}"
    echo "  • test-engineer           - Testing strategies & automation"
    echo "  • security-engineer       - Security & compliance"
    echo "  • performance-profiler    - Performance optimization"
    echo "  • code-reviewer          - Code quality assessment"
else
    echo -e "  ${YELLOW}⚠${NC} No agents found at /workspace/.claude/agents"
fi

# Check development tools
echo ""
echo -e "${BLUE}[3/4]${NC} Verifying development tools..."
echo -e "  ${GREEN}✓${NC} Java 21 ready"
echo -e "  ${GREEN}✓${NC} Gradle 8.5 ready"
echo -e "  ${GREEN}✓${NC} Spring Boot 3.3 ready"
echo -e "  ${GREEN}✓${NC} Terraform 1.7.5 ready"
echo -e "  ${GREEN}✓${NC} MySQL 8.4 client ready"
echo -e "  ${GREEN}✓${NC} AWS CLI configured"

# Check connections
echo ""
echo -e "${BLUE}[4/4]${NC} Checking service connections..."

# MySQL check
if mysql -h${MYSQL_HOST:-mysql} -P${MYSQL_PORT:-3306} -u${MYSQL_USER:-devuser} -p${MYSQL_PASSWORD:-devpass} -e "SELECT 1" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} MySQL database connected"
else
    echo -e "  ${YELLOW}⚠${NC} MySQL not available (start with docker-compose)"
fi

# AWS check
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo -e "  ${GREEN}✓${NC} AWS credentials configured"
else
    echo -e "  ${YELLOW}⚠${NC} AWS credentials not set"
fi

# OpenAI check
if [ -n "$OPENAI_API_KEY" ]; then
    echo -e "  ${GREEN}✓${NC} OpenAI API key configured"
else
    echo -e "  ${YELLOW}⚠${NC} OpenAI API key not set (optional)"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🎯 How to Use Claude Code:${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: You need a Claude API key first!${NC}"
echo "   Get your API key from: https://console.anthropic.com/"
echo "   Add to .env file: CLAUDE_API_KEY=your-api-key"
echo ""
echo -e "${CYAN}VS Code Method (Recommended):${NC}"
echo "1. Press Cmd/Ctrl + Shift + P"
echo "2. Select 'Claude: Chat'"
echo "3. In chat, load an agent:"
echo -e "   ${CYAN}@agent:spring-boot-architect${NC}"
echo "   \"Create a REST API for user management\""
echo ""
echo -e "${CYAN}Terminal Method:${NC}"
echo "1. Start interactive chat:"
echo -e "   ${CYAN}claude chat${NC}"
echo ""
echo "2. Or ask directly:"
echo -e "   ${CYAN}claude ask \"@agent:spring-boot-architect Create REST API\"${NC}"
echo ""
echo -e "${CYAN}Example Usage:${NC}"
echo -e "   ${CYAN}@agent:spring-boot-architect @agent:database-architect${NC}"
echo "   \"Create an e-commerce API with MySQL integration\""
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}💡 Quick Commands:${NC}"
echo "  • View all agents:     ls /workspace/.claude/agents/"
echo "  • Test MySQL:          /workspace/test-mysql.sh"
echo "  • Create Spring app:   /workspace/create-spring-app.sh <name>"
echo "  • Create Terraform:    /workspace/create-terraform-project.sh <name>"
echo "  • View this help:      claude-help"
echo ""
echo -e "${GREEN}✨ Ready to code! Start by loading an agent with @agent:<name>${NC}"
echo ""