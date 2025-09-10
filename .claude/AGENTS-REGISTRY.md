# Claude Code Agents Registry

A comprehensive collection of specialized AI agents for software development, infrastructure, and DevOps workflows.

## 🚀 Quick Start

### Using Agents
```bash
# Load specific agent
@agent:spring-boot-architect

# Load agent with focus
@agent:cost-optimized-environment-manager --focus development-environment

# Multiple agents for complex tasks
@agent:spring-boot-architect @agent:aws-terraform-architect
```

## 📋 Agent Categories

### ☕ Java Spring Development (9 agents)
**Enterprise Java & Spring Boot**
- **spring-boot-architect** ⭐ - Enterprise Spring Boot applications, REST APIs, Spring Security, JPA
- **aws-java-sdk-specialist** ⭐ **NEW** - AWS Java SDK v2 전문가, 회사 표준 AWS 통합 모듈 구축
- **backend-architect** - Scalable API design and microservices architecture
- **database-architect** - Database design, optimization, and architecture patterns
- **database-optimizer** - Query optimization and performance tuning
- **database-optimization** - Advanced database performance and scaling
- **nosql-specialist** - NoSQL database design and implementation
- **api-documenter** - API documentation and specification generation
- **performance-profiler** - Application performance analysis and optimization

### 🏗️ Infrastructure & DevOps (8 agents)
**Core AWS & Cloud Infrastructure**
- **aws-terraform-architect** ⭐ - AWS infrastructure specialist with Terraform IaC, production-ready architectures
- **cost-optimized-environment-manager** ⭐ - Cost-efficient dev/test environments with auto-scheduling
- **cloud-architect** - Multi-cloud infrastructure design and optimization (AWS/Azure/GCP)  
- **terraform-specialist** - Terraform modules, state management, and IaC best practices
- **devops-engineer** - CI/CD pipelines, automation, and deployment workflows
- **deployment-engineer** - Application deployment strategies and orchestration
- **monitoring-specialist** - Observability, alerting, and system monitoring
- **security-engineer** - Infrastructure security, compliance, and threat modeling

### 🧪 Quality & Testing (4 agents)
**Testing, QA & Code Quality**
- **test-engineer** - Comprehensive testing strategies and automation
- **test-automator** - Test automation frameworks and implementation
- **load-testing-specialist** - Performance and load testing strategies
- **code-reviewer** - Code review and quality assessment
- **debugger** - Advanced debugging techniques and troubleshooting
- **error-detective** - Error analysis and root cause investigation

### 📚 Documentation & Communication (3 agents)
**Writing & Knowledge Management**
- **technical-writer** - Technical documentation and content creation
- **documentation-expert** - Comprehensive documentation strategies
- **changelog-generator** - Release notes and changelog automation

### 🔧 Development Tools (3 agents)
**Development Productivity**
- **fullstack-developer** - End-to-end application development
- **architect-review** - Architecture review and design validation
- **context-manager** - Project context and knowledge management

## ⭐ Featured Specialized Agents

### Java Spring Boot Specialists

#### ☕ spring-boot-architect ⭐ NEW
**Use for**: Enterprise Java applications with Spring Boot
- **Expertise**: REST APIs, Spring Security, JPA/Hibernate, Microservices, Testing
- **Output**: Production-ready Spring Boot applications with clean architecture
- **Best for**: Enterprise web applications, REST APIs, microservices

```java
// Example: REST API with Spring Boot
@RestController
@RequestMapping("/api/v1/users")
@Validated
public class UserController {
    
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<PagedResponse<UserResponse>> getUsers(
            @PageableDefault(size = 20) Pageable pageable) {
        Page<UserResponse> users = userService.getUsers(pageable);
        return ResponseEntity.ok(PagedResponse.of(users));
    }
}
```

### AWS Infrastructure Specialists

#### 🏗️ aws-terraform-architect
**Use for**: Production AWS infrastructure with Terraform
- **Expertise**: VPC design, Auto Scaling, RDS/Aurora, Security Groups, IAM
- **Output**: Production-ready Terraform modules with security best practices
- **Best for**: Scalable, secure AWS architectures

```hcl
# Example: Multi-tier AWS architecture
module "infrastructure" {
  source = "./modules/aws-foundation"
  
  project_name = "myproject"
  environment = "prod"
  vpc_cidr = "10.0.0.0/16"
  az_count = 3
}
```

#### 💰 cost-optimized-environment-manager  
**Use for**: Development and testing environments with cost controls
- **Expertise**: Spot instances, Auto-scheduling, Serverless, Cost monitoring
- **Output**: Self-managing environments that scale to zero
- **Best for**: Dev/test environments, demo environments

```python
# Example: Schedule-based environment control
{
  "start_schedule": "cron(0 9 * * MON-FRI *)",  # 9 AM weekdays
  "stop_schedule": "cron(0 19 * * MON-FRI *)",  # 7 PM weekdays
  "spot_percentage": 90,  # 90% spot instances
  "auto_shutdown": true
}
```

## 🎯 Usage Scenarios

### Scenario 1: Java Spring Boot Application
```bash
# Step 1: Application architecture
@agent:spring-boot-architect "Design REST API for user management with Spring Security"

# Step 2: Database design  
@agent:database-architect "Design PostgreSQL schema for user management"

# Step 3: Testing strategy
@agent:test-engineer "Create comprehensive testing strategy for Spring Boot app"
```

### Scenario 2: AWS Infrastructure Setup
```bash
# Step 1: Production infrastructure
@agent:aws-terraform-architect "Create production-ready AWS infrastructure"

# Step 2: Cost-optimized development
@agent:cost-optimized-environment-manager "Create cost-efficient dev/staging environments"

# Step 3: Security review
@agent:security-engineer "Review infrastructure security and compliance"
```

### Scenario 3: Full Development Workflow
```bash
# Step 1: Application development
@agent:spring-boot-architect "Build Spring Boot microservices"

# Step 2: Infrastructure deployment
@agent:aws-terraform-architect "Deploy to AWS with Terraform"

# Step 3: Cost optimization
@agent:cost-optimized-environment-manager "Optimize non-production costs"
```

## 🔧 Agent Selection Guide

### By Technology Stack

**Java Spring Boot**
- spring-boot-architect (primary)
- database-architect
- test-engineer

**AWS Infrastructure**
- aws-terraform-architect
- cost-optimized-environment-manager  
- security-engineer


### By Project Phase

**Planning & Architecture**
- spring-boot-architect
- aws-terraform-architect
- database-architect
- architect-review

**Development**
- spring-boot-architect
- database-optimizer
- test-engineer

**Testing & QA**
- test-engineer
- test-automator
- load-testing-specialist
- code-reviewer

**Deployment & Operations**
- aws-terraform-architect
- devops-engineer
- cost-optimized-environment-manager
- monitoring-specialist

**Maintenance & Optimization**
- performance-profiler
- database-optimizer
- security-engineer
- error-detective

## 🔄 Agent Combinations

### Enterprise Java Application
```
spring-boot-architect + database-architect + test-engineer
```

### AWS Cloud Infrastructure  
```
aws-terraform-architect + cost-optimized-environment-manager + security-engineer
```

### Complete Development Pipeline
```
spring-boot-architect + aws-terraform-architect + test-engineer
```

### High-Performance Application
```
spring-boot-architect + performance-profiler + database-optimizer + load-testing-specialist
```

## 📖 Best Practices

### Agent Usage
1. **Use spring-boot-architect** for Java application development
2. **Combine AWS agents** for infrastructure needs
3. **Include testing agents** in all development workflows
4. **Add monitoring agents** for production systems

### Development Environment
1. Implement **auto-setup** for new team members
2. Configure **development tools** integration
3. Enable **security isolation** between projects
4. Maintain **performance optimization** settings

### Cost Optimization
1. Use **cost-optimized-environment-manager** for non-production
2. Implement **auto-scheduling** for development resources
3. Prefer **spot instances** when appropriate
4. Monitor costs with **automated alerts**
5. Regular **right-sizing** of resources

### Security Best Practices
1. Always include **security-engineer** for infrastructure reviews
2. Implement **Spring Security** best practices
3. Enable **network isolation** in dev containers
4. Use **least-privilege** access patterns
5. Regular **security audits** and compliance checks

---

*Last updated: 2024-12-09*
*Total agents: 29*
*Featured agents: 4*
*Java Spring focused: ⭐ Primary focus*