# AWS Specialized Agents Usage Guide

Complete guide for using the specialized AWS infrastructure agents for efficient development workflows.

## 🎯 Agent Overview

### 🏗️ aws-terraform-architect
**Purpose**: Production-ready AWS infrastructure with Terraform IaC
**Best for**: Scalable web applications, microservices, enterprise systems
**Expertise**: VPC design, Auto Scaling, RDS/Aurora, Security Groups, Cost optimization

### 💰 cost-optimized-environment-manager
**Purpose**: Cost-efficient development and testing environments  
**Best for**: Dev/test environments, demo systems, prototype development
**Expertise**: Auto-scheduling, Spot instances, Serverless, Cost monitoring

## 🚀 Quick Start Scenarios

### Scenario 1: New AWS Project Setup
```bash
# Step 1: Create production infrastructure
@agent:aws-terraform-architect
"Create a 3-tier web application infrastructure on AWS with:
- Auto Scaling web tier
- Application tier with load balancer
- RDS Aurora database
- Multi-AZ deployment
- Security best practices"

# Step 2: Create cost-optimized development environment
@agent:cost-optimized-environment-manager
"Create a development environment that:
- Mirrors production but cost-optimized
- Auto-starts at 9 AM, stops at 7 PM
- Uses spot instances where possible
- Includes cost monitoring alerts"
```

### Scenario 2: Existing Infrastructure Optimization
```bash
# Step 1: Review current infrastructure
@agent:aws-terraform-architect
"Review and optimize existing AWS infrastructure:
- Improve security posture
- Add monitoring and alerting
- Implement disaster recovery
- Optimize for performance"

# Step 2: Optimize development costs
@agent:cost-optimized-environment-manager
"Optimize development environment costs:
- Implement auto-scheduling
- Convert to spot instances
- Add serverless components
- Set up cost alerts and budgets"
```

## 📋 Detailed Usage Patterns

### aws-terraform-architect Usage

#### 1. Production Web Application
```terraform
# Request: "Create production infrastructure for a Node.js web application"
# Output: Complete Terraform modules with:

module "production_infrastructure" {
  source = "./modules/aws-foundation"
  
  project_name = "webapp"
  environment = "prod"
  vpc_cidr = "10.0.0.0/16"
  
  # Multi-AZ deployment
  az_count = 3
  
  # Auto Scaling configuration
  min_size = 2
  max_size = 10
  desired_capacity = 3
  
  # Database configuration
  db_engine = "aurora-postgresql"
  db_instance_class = "db.r6g.large"
  backup_retention_period = 30
  
  # Security settings
  enable_deletion_protection = true
  encryption_enabled = true
}
```

#### 2. Microservices Architecture
```terraform
# Request: "Design microservices infrastructure with ECS"
# Output: ECS-based microservices platform

module "microservices_platform" {
  source = "./modules/ecs-microservices"
  
  cluster_name = "microservices-cluster"
  
  services = {
    user_service = {
      cpu = 256
      memory = 512
      desired_count = 2
    }
    order_service = {
      cpu = 512
      memory = 1024
      desired_count = 3
    }
  }
  
  load_balancer_config = {
    enable_https = true
    certificate_arn = aws_acm_certificate.main.arn
  }
}
```

#### 3. Database-Heavy Application
```terraform
# Request: "Create infrastructure for data-intensive application"
# Output: Optimized database infrastructure

module "data_platform" {
  source = "./modules/data-infrastructure"
  
  # Primary database
  primary_db = {
    engine = "aurora-postgresql"
    instance_class = "db.r6g.2xlarge"
    storage_encrypted = true
  }
  
  # Read replicas
  read_replicas = 3
  
  # Caching layer
  elasticache_config = {
    node_type = "cache.r6g.large"
    num_cache_nodes = 3
  }
  
  # Data warehouse
  redshift_config = {
    node_type = "dc2.large"
    cluster_type = "multi-node"
    number_of_nodes = 3
  }
}
```

### cost-optimized-environment-manager Usage

#### 1. Development Environment Setup
```python
# Request: "Create cost-optimized development environment"
# Output: Scheduled, spot-instance based environment

{
  "environment_config": {
    "name": "development",
    "schedule_profile": "business-hours",
    "cost_optimization": {
      "spot_instance_percentage": 90,
      "auto_shutdown": True,
      "daily_cost_limit": 50
    }
  },
  
  "schedule": {
    "start_time": "09:00",  # 9 AM
    "stop_time": "19:00",   # 7 PM  
    "days": "MON-FRI",      # Weekdays only
    "timezone": "UTC"
  },
  
  "notifications": {
    "cost_alerts": True,
    "schedule_notifications": True,
    "slack_webhook": "your-webhook-url"
  }
}
```

#### 2. Testing Environment (Ephemeral)
```yaml
# Request: "Create ephemeral testing environment"
# Output: On-demand, auto-cleanup environment

testing_environment:
  lifecycle:
    auto_destroy_after: "24h"
    max_idle_time: "2h"
  
  compute:
    instance_types:
      - "t3.micro"   # Primary choice
      - "t3.small"   # Fallback
    spot_allocation: "diversified"
    spot_percentage: 100  # 100% spot instances
  
  storage:
    lifecycle_policy:
      transition_to_ia: 1    # 1 day
      transition_to_glacier: 7  # 7 days
      delete_after: 30       # 30 days
  
  monitoring:
    cost_tracking: True
    idle_detection: True
    auto_cleanup: True
```

#### 3. Staging Environment (Hybrid)
```hcl
# Request: "Create staging environment that balances cost and reliability"
# Output: Mixed on-demand/spot configuration

module "staging_environment" {
  source = "./modules/hybrid-environment"
  
  environment = "staging"
  
  compute_mix = {
    on_demand_percentage = 20  # 20% on-demand for reliability
    spot_percentage = 80       # 80% spot for cost savings
  }
  
  schedule_config = {
    business_hours = {
      start = "08:00"
      end = "20:00"
      days = "MON-FRI"
    }
    maintenance_window = {
      day = "SUN"
      time = "02:00-04:00"
    }
  }
  
  cost_controls = {
    daily_budget = 100
    monthly_budget = 2000
    auto_scale_down_threshold = 80  # Scale down at 80% of budget
  }
}
```

## 🎨 Advanced Use Cases

### Multi-Environment Management
```bash
# Create complete environment pipeline
@agent:aws-terraform-architect
"Design a multi-environment pipeline (dev/staging/prod) with:
- Shared networking and security
- Environment-specific configurations
- Automated promotion process"

@agent:cost-optimized-environment-manager  
"Optimize non-production environments with:
- Different scheduling for dev vs staging
- Graduated cost controls
- Automated cleanup policies"
```

### Disaster Recovery Setup
```bash
@agent:aws-terraform-architect
"Implement disaster recovery for production environment:
- Multi-region deployment
- Automated failover
- Data replication
- Recovery time objective: 1 hour"
```

### Compliance and Security
```bash
@agent:aws-terraform-architect
"Enhance infrastructure for SOC2 compliance:
- Comprehensive logging
- Encryption at rest and in transit
- Network segmentation
- Access controls and monitoring"
```

## 💡 Best Practices

### When to Use Each Agent

#### Use aws-terraform-architect for:
- ✅ Production infrastructure design
- ✅ Security-critical systems
- ✅ High-availability requirements
- ✅ Complex networking needs
- ✅ Compliance requirements
- ✅ Disaster recovery planning

#### Use cost-optimized-environment-manager for:
- ✅ Development environments
- ✅ Testing/QA environments
- ✅ Demo environments
- ✅ Prototype development
- ✅ Training environments
- ✅ Personal projects

### Combining Both Agents

#### Scenario: Complete Project Setup
```bash
# Phase 1: Production infrastructure
@agent:aws-terraform-architect
"Create production-ready infrastructure"

# Phase 2: Development environments
@agent:cost-optimized-environment-manager
"Create cost-efficient development pipeline"

# Phase 3: Integration
"Integrate both environments with shared services:
- Shared VPC peering
- Common monitoring
- Unified CI/CD pipeline"
```

## 📊 Cost Comparison Examples

### Traditional vs Optimized Environments

#### Traditional Development Environment
```
Monthly Cost: $1,200
- EC2 instances (24/7): $600
- RDS (24/7): $400  
- Load balancer (24/7): $200
```

#### Cost-Optimized Development Environment
```
Monthly Cost: $360 (70% savings)
- EC2 spot instances (9-5, weekdays): $120
- RDS (scheduled): $150
- Serverless components: $90
```

### Environment Scaling Examples

#### Small Team (5 developers)
```
Traditional: $6,000/month
Optimized: $1,800/month
Savings: $4,200/month (70% reduction)
```

#### Medium Team (15 developers)
```
Traditional: $18,000/month
Optimized: $5,400/month  
Savings: $12,600/month (70% reduction)
```

## 🔧 Implementation Checklist

### Pre-Implementation
- [ ] Define environment requirements
- [ ] Establish cost budgets
- [ ] Choose deployment regions
- [ ] Plan naming conventions
- [ ] Set up monitoring and alerting

### aws-terraform-architect Implementation
- [ ] Design network architecture
- [ ] Configure security groups
- [ ] Set up database infrastructure
- [ ] Implement monitoring
- [ ] Configure backup strategies
- [ ] Test disaster recovery

### cost-optimized-environment-manager Implementation  
- [ ] Define usage schedules
- [ ] Configure spot instance strategies
- [ ] Set up cost monitoring
- [ ] Implement auto-cleanup
- [ ] Configure notifications
- [ ] Test scheduling automation

### Post-Implementation
- [ ] Monitor costs daily
- [ ] Review utilization weekly
- [ ] Optimize based on usage patterns
- [ ] Update budgets and alerts
- [ ] Document lessons learned

## 🚨 Common Pitfalls and Solutions

### aws-terraform-architect Pitfalls
- **Over-engineering**: Start simple, scale gradually
- **Security gaps**: Always use security groups and IAM least privilege
- **Cost blindness**: Include cost monitoring from day one
- **Single AZ**: Always plan for multi-AZ deployment

### cost-optimized-environment-manager Pitfalls
- **Spot instance interruptions**: Have fallback strategies
- **Data persistence**: Use appropriate storage for different data types
- **Schedule conflicts**: Consider time zones and team schedules
- **Cost surprise**: Set up proactive alerts and budgets

## 📈 Success Metrics

### Infrastructure Quality (aws-terraform-architect)
- Security score improvement
- Availability percentage (99.9%+ target)
- Performance benchmarks
- Compliance audit results

### Cost Optimization (cost-optimized-environment-manager)
- Cost reduction percentage (70%+ target)
- Resource utilization efficiency
- Automated cleanup success rate
- Budget variance tracking

---

*For additional support, refer to the individual agent documentation or the main agents registry.*