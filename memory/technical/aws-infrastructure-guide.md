# FoodBeGood AWS Cloud Infrastructure Guide

## Document Information

**Project:** FoodBeGood Mobile Application  
**Version:** 1.0.0  
**Date:** February 4, 2025  
**Cloud Provider:** Amazon Web Services (AWS)  
**Infrastructure as Code:** Terraform  

---

## Table of Contents

1. [Infrastructure Overview](#1-infrastructure-overview)
2. [Architecture Evolution](#2-architecture-evolution)
3. [Phase 1: Minimal Infrastructure](#3-phase-1-minimal-infrastructure)
4. [Phase 2: Production Ready](#4-phase-2-production-ready)
5. [Phase 3: Scaling Up](#5-phase-3-scaling-up)
6. [Phase 4: High Availability](#6-phase-4-high-availability)
7. [AWS Services Reference](#7-aws-services-reference)
8. [Cost Optimization](#8-cost-optimization)
9. [Security Best Practices](#9-security-best-practices)
10. [Monitoring & Observability](#10-monitoring--observability)

---

## 1. Infrastructure Overview

### 1.1 Application Requirements

Based on the FoodBeGood app specifications, the infrastructure must support:

| Component | Requirements |
|-----------|--------------|
| **Mobile App** | Flutter (iOS/Android) |
| **Backend API** | Node.js + Express |
| **Database** | PostgreSQL 15.x |
| **Cache** | Redis 7.x |
| **File Storage** | User images, meal photos, CSV exports |
| **Real-time** | Push notifications (Firebase/FCM) |
| **Authentication** | JWT tokens, refresh tokens |
| **ML Processing** | TensorFlow Lite (on-device) + Cloud fallback |

### 1.2 Traffic Estimates

| Phase | Users | Daily Active | Requests/Day | Peak RPS |
|-------|-------|--------------|--------------|----------|
| **Phase 1** | 100-500 | 50-200 | 5K-20K | 1-5 |
| **Phase 2** | 1K-5K | 500-2K | 50K-200K | 10-50 |
| **Phase 3** | 10K-50K | 5K-20K | 500K-2M | 100-500 |
| **Phase 4** | 50K-200K | 25K-100K | 2.5M-10M | 500-2000 |

### 1.3 Data Storage Estimates

| Data Type | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|-----------|---------|---------|---------|---------|
| **Database** | 1 GB | 10 GB | 100 GB | 500 GB |
| **Images** | 10 GB | 100 GB | 1 TB | 5 TB |
| **Backups** | 5 GB | 50 GB | 500 GB | 2 TB |
| **Logs** | 1 GB | 10 GB | 100 GB | 500 GB |

---

## 2. Architecture Evolution

### 2.1 Infrastructure Maturity Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE EVOLUTION                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 1: Minimal (MVP)                                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Single EC2 + RDS (db.t3.micro)                         │    │
│  │ Cost: ~$50-100/month                                    │    │
│  │ Best for: Development, Testing, <500 users              │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  Phase 2: Production Ready                                       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ECS Fargate + RDS (db.t3.small) + ALB                   │    │
│  │ Cost: ~$200-400/month                                   │    │
│  │ Best for: Production launch, <5K users                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  Phase 3: Scaling                                                │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ECS Fargate (multi-service) + RDS Multi-AZ + ElastiCache│    │
│  │ Cost: ~$800-1500/month                                  │    │
│  │ Best for: Growth, <50K users                            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  Phase 4: High Availability                                      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ EKS + RDS Cluster + Multi-AZ + Auto-scaling + CDN       │    │
│  │ Cost: ~$2000-5000/month                                 │    │
│  │ Best for: Enterprise, >50K users                        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Decision Matrix

| Factor | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|--------|---------|---------|---------|---------|
| **Users** | <500 | <5K | <50K | >50K |
| **Uptime SLA** | 95% | 99% | 99.9% | 99.99% |
| **RTO** | 4 hours | 2 hours | 30 min | 5 min |
| **RPO** | 24 hours | 4 hours | 1 hour | 5 min |
| **Team Size** | 1-2 | 2-5 | 5-10 | 10+ |
| **Budget** | Low | Medium | High | Enterprise |

---

## 3. Phase 1: Minimal Infrastructure

### 3.1 Architecture Overview

**Best for:** Development, testing, proof of concept, <500 users

```
┌─────────────────────────────────────────────────────────────┐
│                      PHASE 1: MINIMAL                        │
│                     (Single Server Setup)                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────┐                                           │
│   │   Users     │                                           │
│   └──────┬──────┘                                           │
│          │ HTTPS                                            │
│          ▼                                                   │
│   ┌─────────────────────────────────────┐                   │
│   │           VPC (10.0.0.0/16)         │                   │
│   │  ┌─────────────────────────────┐    │                   │
│   │  │    Public Subnet            │    │                   │
│   │  │  ┌───────────────────────┐  │    │                   │
│   │  │  │   EC2 (t3.micro)      │  │    │                   │
│   │  │  │   - Node.js API       │  │    │                   │
│   │  │  │   - Redis (container) │  │    │                   │
│   │  │  │   - Nginx (reverse)   │  │    │                   │
│   │  │  └───────────────────────┘  │    │                   │
│   │  └─────────────────────────────┘    │                   │
│   │  ┌─────────────────────────────┐    │                   │
│   │  │    Private Subnet           │    │                   │
│   │  │  ┌───────────────────────┐  │    │                   │
│   │  │  │   RDS (db.t3.micro)   │  │    │                   │
│   │  │  │   PostgreSQL 15       │  │    │                   │
│   │  │  └───────────────────────┘  │    │                   │
│   │  └─────────────────────────────┘    │                   │
│   └─────────────────────────────────────┘                   │
│          │                                                   │
│          ▼                                                   │
│   ┌─────────────────────────────────────┐                   │
│   │   S3 Bucket                         │                   │
│   │   - User uploads                    │                   │
│   │   - Backups                         │                   │
│   └─────────────────────────────────────┘                   │
│                                                              │
│   Monthly Cost: ~$50-100                                     │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 AWS Resources

#### EC2 Instance (Application Server)

```yaml
Instance Type: t3.micro (2 vCPU, 1 GB RAM)
OS: Amazon Linux 2023 / Ubuntu 22.04 LTS
Storage: 20 GB gp3 SSD
Security Group:
  - Inbound:
    - Port 22 (SSH) from your IP only
    - Port 80 (HTTP) from 0.0.0.0/0
    - Port 443 (HTTPS) from 0.0.0.0/0
  - Outbound: All traffic

User Data (CloudInit):
  #!/bin/bash
  yum update -y
  yum install -y docker nginx
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
  
  # Install Node.js 20
  curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
  yum install -y nodejs
  
  # Install PM2
  npm install -g pm2
  
  # Run Redis in Docker
  docker run -d --name redis -p 6379:6379 redis:7-alpine
```

#### RDS Database

```yaml
Engine: PostgreSQL 15.4
Instance Class: db.t3.micro
Storage: 20 GB gp2 (auto-scaling enabled)
Multi-AZ: No
Public Access: No
Backup Retention: 7 days
Maintenance Window: Sun 03:00-04:00 UTC

Parameter Group:
  - max_connections: 100
  - shared_buffers: 256MB
  - effective_cache_size: 768MB
```

#### S3 Bucket

```yaml
Bucket Name: foodbegood-dev-uploads-{account-id}
Versioning: Enabled
Encryption: AES-256 (SSE-S3)
Lifecycle Policy:
  - Transition to IA after 90 days
  - Transition to Glacier after 1 year
CORS Configuration:
  AllowedOrigins: ["https://api.foodbegood.app"]
  AllowedMethods: ["GET", "PUT", "POST", "DELETE"]
  AllowedHeaders: ["*"]
```

### 3.3 Terraform Configuration

```hcl
# infrastructure/phase1/main.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "foodbegood-terraform-state"
    key    = "phase1/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "FoodBeGood"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "foodbegood-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "foodbegood-${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "foodbegood-${var.environment}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  
  tags = {
    Name = "foodbegood-${var.environment}-private-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "ec2" {
  name_prefix = "foodbegood-ec2-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-ec2-sg"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "foodbegood-rds-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-rds-sg"
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.ssh_key_name
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host     = aws_db_instance.main.address
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    redis_host  = "localhost"
  }))
  
  tags = {
    Name = "foodbegood-${var.environment}-app"
  }
}

# RDS Instance
resource "aws_db_subnet_group" "main" {
  name       = "foodbegood-${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
  
  tags = {
    Name = "foodbegood-${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "foodbegood-${var.environment}-db"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = true
  
  db_name  = var.db_name
  username = var.db_user
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Sun:04:00-Sun:05:00"
  
  skip_final_snapshot = var.environment != "production"
  
  tags = {
    Name = "foodbegood-${var.environment}-db"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "uploads" {
  bucket = "foodbegood-${var.environment}-uploads-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name = "foodbegood-${var.environment}-uploads"
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Elastic IP
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"
  
  tags = {
    Name = "foodbegood-${var.environment}-eip"
  }
}

# Data sources
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_caller_identity" "current" {}
```

### 3.4 Cost Breakdown (Phase 1)

| Service | Instance/Type | Monthly Cost |
|---------|---------------|--------------|
| **EC2** | t3.micro | ~$8.50 |
| **EBS** | 20 GB gp3 | ~$1.60 |
| **RDS** | db.t3.micro | ~$13.00 |
| **S3** | 10 GB storage | ~$0.23 |
| **Data Transfer** | 100 GB | ~$9.00 |
| **Elastic IP** | 1 (in use) | Free |
| **Total** | | **~$32-35/month** |

*Note: Costs are estimates for eu-west-1 (Ireland) region. Actual costs may vary.*

---

## 4. Phase 2: Production Ready

### 4.1 Architecture Overview

**Best for:** Production launch, <5K users, 99% uptime SLA

```
┌─────────────────────────────────────────────────────────────────┐
│                 PHASE 2: PRODUCTION READY                        │
│                  (Containerized with Load Balancer)              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────┐                                               │
│   │   Users     │                                               │
│   └──────┬──────┘                                               │
│          │ HTTPS                                                │
│          ▼                                                       │
│   ┌───────────────────────────────────────────────────────┐     │
│   │              Route 53 (DNS)                           │     │
│   └───────────────────────┬───────────────────────────────┘     │
│                           │                                      │
│                           ▼                                      │
│   ┌───────────────────────────────────────────────────────┐     │
│   │              Application Load Balancer                │     │
│   │              (SSL/TLS Termination)                    │     │
│   └───────────────────────┬───────────────────────────────┘     │
│                           │                                      │
│   ┌───────────────────────┴───────────────────────────────┐     │
│   │                   VPC (10.0.0.0/16)                   │     │
│   │                                                       │     │
│   │  ┌───────────────────────────────────────────────┐   │     │
│   │  │         Public Subnets (2 AZs)                │   │     │
│   │  │  ┌───────────────────────────────────────┐    │   │     │
│   │  │  │     ECS Fargate Service               │    │   │     │
│   │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐  │    │   │     │
│   │  │  │  │ API Task│ │ API Task│ │ API Task│  │    │   │     │
│   │  │  │  │ (256MB) │ │ (256MB) │ │ (256MB) │  │    │   │     │
│   │  │  │  └─────────┘ └─────────┘ └─────────┘  │    │   │     │
│   │  │  │       Min: 2, Max: 4 instances         │    │   │     │
│   │  │  └───────────────────────────────────────┘    │   │     │
│   │  └───────────────────────────────────────────────┘   │     │
│   │                                                       │     │
│   │  ┌───────────────────────────────────────────────┐   │     │
│   │  │         Private Subnets (2 AZs)               │   │     │
│   │  │  ┌───────────────────────────────────────┐    │   │     │
│   │  │  │     RDS PostgreSQL (Multi-AZ)         │    │   │     │
│   │  │  │     db.t3.small                       │    │   │     │
│   │  │  └───────────────────────────────────────┘    │   │     │
│   │  │                                               │   │     │
│   │  │  ┌───────────────────────────────────────┐    │   │     │
│   │  │  │     ElastiCache Redis                 │    │   │     │
│   │  │  │     cache.t3.micro                    │    │   │     │
│   │  │  └───────────────────────────────────────┘    │   │     │
│   │  └───────────────────────────────────────────────┘   │     │
│   └───────────────────────────────────────────────────────┘     │
│                                                                  │
│   ┌───────────────────────────────────────────────────────┐     │
│   │   S3 + CloudFront CDN                                 │     │
│   │   - Static assets                                     │     │
│   │   - User uploads                                      │     │
│   └───────────────────────────────────────────────────────┘     │
│                                                                  │
│   Monthly Cost: ~$200-400/month                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 AWS Resources

#### ECS Fargate (Container Orchestration)

```yaml
Cluster: foodbegood-production-cluster
Service: api-service
Launch Type: FARGATE
Task Definition:
  CPU: 256 (0.25 vCPU)
  Memory: 512 MB
  Container:
    - Name: api
    - Image: foodbegood/api:latest
    - Port: 3000
    - Environment Variables:
      - NODE_ENV: production
      - DB_HOST: from Secrets Manager
      - REDIS_HOST: from Secrets Manager
      - JWT_SECRET: from Secrets Manager

Auto Scaling:
  Min: 2
  Max: 4
  Target CPU: 70%
  Target Memory: 70%
```

#### Application Load Balancer

```yaml
Type: Application Load Balancer
Scheme: Internet-facing
Listeners:
  - Port 80: Redirect to HTTPS
  - Port 443: Forward to ECS target group
Health Check:
  Path: /health
  Interval: 30s
  Timeout: 5s
  Healthy Threshold: 2
  Unhealthy Threshold: 3
SSL/TLS:
  Certificate: ACM (AWS Certificate Manager)
  Policy: ELBSecurityPolicy-TLS13-1-2-2021-06
```

#### RDS Multi-AZ

```yaml
Engine: PostgreSQL 15.4
Instance Class: db.t3.small (2 vCPU, 2 GB RAM)
Multi-AZ: Yes (standby in different AZ)
Storage: 50 GB gp3
IOPS: 3000 (baseline)
Backup:
  Retention: 14 days
  Window: 03:00-04:00 UTC
  Cross-Region: Yes (to eu-central-1)
Encryption: AWS KMS
```

#### ElastiCache Redis

```yaml
Engine: Redis 7.0
Node Type: cache.t3.micro
Nodes: 1 (single node for Phase 2)
Parameter Group:
  - maxmemory-policy: allkeys-lru
  - timeout: 300
Security: Encryption in transit (TLS)
```

### 4.3 Terraform Configuration

```hcl
# infrastructure/phase2/main.tf

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "foodbegood-${var.environment}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/foodbegood-${var.environment}-api"
  retention_in_days = 14
  
  tags = {
    Name = "foodbegood-${var.environment}-api-logs"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "api" {
  family                   = "foodbegood-${var.environment}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([
    {
      name  = "api"
      image = "${aws_ecr_repository.api.repository_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "PORT", value = "3000" },
        { name = "DB_HOST", value = aws_db_instance.main.address },
        { name = "DB_PORT", value = "5432" },
        { name = "DB_NAME", value = var.db_name },
        { name = "REDIS_HOST", value = aws_elasticache_cluster.redis.cache_nodes[0].address },
        { name = "REDIS_PORT", value = "6379" },
        { name = "S3_BUCKET", value = aws_s3_bucket.uploads.id }
      ]
      
      secrets = [
        { name = "DB_PASSWORD", valueFrom = aws_secretsmanager_secret.db_password.arn },
        { name = "JWT_SECRET", valueFrom = aws_secretsmanager_secret.jwt_secret.arn },
        { name = "AWS_ACCESS_KEY_ID", valueFrom = aws_secretsmanager_secret.aws_access_key.arn },
        { name = "AWS_SECRET_ACCESS_KEY", valueFrom = aws_secretsmanager_secret.aws_secret_key.arn }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
  
  tags = {
    Name = "foodbegood-${var.environment}-api-task"
  }
}

# ECS Service
resource "aws_ecs_service" "api" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 3000
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  depends_on = [aws_lb_listener.https]
  
  tags = {
    Name = "foodbegood-${var.environment}-api-service"
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "api" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "foodbegood-${var.environment}-api-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "api_memory" {
  name               = "foodbegood-${var.environment}-api-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "foodbegood-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = var.environment == "production"
  
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-logs"
    enabled = true
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "api" {
  name     = "foodbegood-${var.environment}-api-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-api-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.main.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# ElastiCache Redis
resource "aws_elasticache_subnet_group" "redis" {
  name       = "foodbegood-${var.environment}-redis-subnet"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "foodbegood-${var.environment}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  tags = {
    Name = "foodbegood-${var.environment}-redis"
  }
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "foodbegood/${var.environment}/db-password"
  description             = "Database password for FoodBeGood"
  recovery_window_in_days = var.environment == "production" ? 30 : 7
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "foodbegood/${var.environment}/jwt-secret"
  description             = "JWT secret for FoodBeGood"
  recovery_window_in_days = var.environment == "production" ? 30 : 7
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.jwt_secret
}

# ECR Repository
resource "aws_ecr_repository" "api" {
  name                 = "foodbegood/${var.environment}/api"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  encryption_configuration {
    encryption_type = "AES256"
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-api-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

### 4.4 Cost Breakdown (Phase 2)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| **ECS Fargate** | 2 tasks × 0.25 vCPU, 0.5 GB | ~$18.00 |
| **ALB** | 1 ALB + LCU | ~$22.00 |
| **RDS Multi-AZ** | db.t3.small | ~$26.00 |
| **ElastiCache** | cache.t3.micro | ~$12.50 |
| **S3** | 50 GB + requests | ~$1.15 |
| **CloudFront** | 100 GB transfer | ~$8.50 |
| **Data Transfer** | 500 GB | ~$45.00 |
| **CloudWatch** | Logs, metrics | ~$10.00 |
| **Secrets Manager** | 5 secrets | ~$2.00 |
| **Total** | | **~$145-165/month** |

---

## 5. Phase 3: Scaling Up

### 5.1 Architecture Overview

**Best for:** Growth phase, <50K users, 99.9% uptime SLA

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PHASE 3: SCALING UP                               │
│              (Multi-Service Architecture with Caching)               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────┐                                                   │
│   │   Users     │                                                   │
│   └──────┬──────┘                                                   │
│          │ HTTPS                                                    │
│          ▼                                                           │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │              CloudFront CDN                               │     │
│   │   - Static assets caching                                 │     │
│   │   - API response caching                                  │     │
│   │   - DDoS protection                                       │     │
│   └───────────────────────┬───────────────────────────────────┘     │
│                           │                                          │
│                           ▼                                          │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │              WAF (Web Application Firewall)               │     │
│   └───────────────────────┬───────────────────────────────────┘     │
│                           │                                          │
│                           ▼                                          │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │              Application Load Balancer                    │     │
│   └───────────────────────┬───────────────────────────────────┘     │
│                           │                                          │
│   ┌───────────────────────┴───────────────────────────────────┐     │
│   │                   VPC (10.0.0.0/16)                       │     │
│   │                                                           │     │
│   │  ┌─────────────────────────────────────────────────────┐ │     │
│   │  │         Public Subnets (3 AZs)                      │ │     │
│   │  │                                                     │ │     │
│   │  │  ┌─────────────────────────────────────────────┐   │ │     │
│   │  │  │     ECS Fargate - API Service               │   │ │     │
│   │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │ │     │
│   │  │  │  │ API (1) │ │ API (2) │ │ API (3) │ ...   │   │ │     │
│   │  │  │  │512MB/1CPU│ │512MB/1CPU│ │512MB/1CPU│      │   │ │     │
│   │  │  │  └─────────┘ └─────────┘ └─────────┘       │   │ │     │
│   │  │  │       Min: 3, Max: 10 instances             │   │ │     │
│   │  │  └─────────────────────────────────────────────┘   │ │     │
│   │  │                                                     │ │     │
│   │  │  ┌─────────────────────────────────────────────┐   │ │     │
│   │  │  │     ECS Fargate - Worker Service            │   │ │     │
│   │  │  │  ┌─────────┐ ┌─────────┐                     │   │ │     │
│   │  │  │  │ Worker  │ │ Worker  │                     │   │ │     │
│   │  │  │  │(256MB)  │ │(256MB)  │                     │   │ │     │
│   │  │  │  └─────────┘ └─────────┘                     │   │ │     │
│   │  │  └─────────────────────────────────────────────┘   │ │     │
│   │  └─────────────────────────────────────────────────────┘ │     │
│   │                                                           │     │
│   │  ┌─────────────────────────────────────────────────────┐ │     │
│   │  │         Private Subnets (3 AZs)                     │ │     │
│   │  │                                                     │ │     │
│   │  │  ┌─────────────────────────────────────────────┐   │ │     │
│   │  │  │     RDS PostgreSQL (Multi-AZ)               │   │ │     │
│   │  │  │     db.t3.medium (2 vCPU, 4 GB)             │   │ │     │
│   │  │  │     Read Replica in separate region         │   │ │     │
│   │  │  └─────────────────────────────────────────────┘   │ │     │
│   │  │                                                     │ │     │
│   │  │  ┌─────────────────────────────────────────────┐   │ │     │
│   │  │  │     ElastiCache Redis Cluster               │   │ │     │
│   │  │  │     2 nodes (cache.t3.small)                │   │ │     │
│   │  │  │     Cluster mode enabled                    │   │ │     │
│   │  │  └─────────────────────────────────────────────┘   │ │     │
│   │  └─────────────────────────────────────────────────────┘ │     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │   S3 + S3 Glacier (Lifecycle)                             │     │
│   │   - User uploads (Standard)                               │     │
│   │   - Backups (Standard-IA)                                 │     │
│   │   - Archives (Glacier)                                    │     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │   Additional Services:                                    │     │
│   │   - SNS (Push notifications)                              │     │
│   │   - SQS (Background jobs)                                 │     │
│   │   - Lambda (Image processing)                             │     │
│   │   - EventBridge (Scheduled tasks)                         │     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
│   Monthly Cost: ~$800-1500/month                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Key Improvements from Phase 2

| Feature | Phase 2 | Phase 3 | Benefit |
|---------|---------|---------|---------|
| **API Instances** | 2-4 | 3-10 | Handle traffic spikes |
| **Worker Service** | None | Separate ECS service | Background jobs |
| **Database** | db.t3.small | db.t3.medium + Read Replica | Better performance |
| **Cache** | Single node | 2-node cluster | High availability |
| **CDN** | CloudFront | CloudFront + WAF | Security + caching |
| **Regions** | Single | Multi-region read | Disaster recovery |
| **AZs** | 2 | 3 | Better fault tolerance |

### 5.3 Auto-Scaling Configuration

```hcl
# infrastructure/phase3/autoscaling.tf

# API Service Auto Scaling
resource "aws_appautoscaling_target" "api" {
  max_capacity       = 10
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling
resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "foodbegood-${var.environment}-api-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 65.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Request count-based scaling
resource "aws_appautoscaling_policy" "api_requests" {
  name               = "foodbegood-${var.environment}-api-requests"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.api.arn_suffix}"
    }
    target_value       = 1000.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Step scaling for rapid scale-out
resource "aws_appautoscaling_policy" "api_step_scale_out" {
  name               = "foodbegood-${var.environment}-api-step-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"
    
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 20
      scaling_adjustment          = 1
    }
    
    step_adjustment {
      metric_interval_lower_bound = 20
      metric_interval_upper_bound = 50
      scaling_adjustment          = 2
    }
    
    step_adjustment {
      metric_interval_lower_bound = 50
      scaling_adjustment          = 3
    }
  }
}

# Scheduled scaling for known peak times
resource "aws_appautoscaling_scheduled_action" "api_lunch_peak" {
  name               = "foodbegood-${var.environment}-api-lunch-peak"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  schedule           = "cron(0 11 * * ? *)"  # 11:00 AM UTC daily
  
  scalable_target_action {
    min_capacity = 5
    max_capacity = 15
  }
}

resource "aws_appautoscaling_scheduled_action" "api_lunch_end" {
  name               = "foodbegood-${var.environment}-api-lunch-end"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  schedule           = "cron(0 14 * * ? *)"  # 2:00 PM UTC daily
  
  scalable_target_action {
    min_capacity = 3
    max_capacity = 10
  }
}
```

### 5.4 Cost Breakdown (Phase 3)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| **ECS Fargate** | 3-10 tasks × 1 vCPU, 1 GB | ~$90-300 |
| **ALB** | 1 ALB + LCU | ~$35.00 |
| **RDS Multi-AZ** | db.t3.medium | ~$52.00 |
| **RDS Read Replica** | db.t3.small | ~$26.00 |
| **ElastiCache** | 2 × cache.t3.small | ~$50.00 |
| **CloudFront** | 1 TB transfer | ~$85.00 |
| **WAF** | 1 Web ACL + rules | ~$35.00 |
| **S3** | 200 GB + lifecycle | ~$5.00 |
| **SQS** | 1M requests/day | ~$10.00 |
| **Lambda** | 1M invocations | ~$2.00 |
| **CloudWatch** | Logs, metrics, alarms | ~$50.00 |
| **Data Transfer** | 2 TB | ~$180.00 |
| **Total** | | **~$620-830/month** |

---

## 6. Phase 4: High Availability

### 6.1 Architecture Overview

**Best for:** Enterprise scale, >50K users, 99.99% uptime SLA

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 PHASE 4: HIGH AVAILABILITY                               │
│           (Multi-Region, Kubernetes, Full Observability)                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────┐                                                       │
│   │   Users     │                                                       │
│   └──────┬──────┘                                                       │
│          │ HTTPS                                                        │
│          ▼                                                               │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │              Route 53 (Latency-based Routing)                 │     │
│   │   ┌─────────────────┐     ┌─────────────────┐                 │     │
│   │   │  eu-west-1      │     │  eu-central-1   │                 │     │
│   │   │  (Primary)      │     │  (Secondary)    │                 │     │
│   │   └────────┬────────┘     └────────┬────────┘                 │     │
│   └────────────┼───────────────────────┼──────────────────────────┘     │
│                │                       │                                 │
│   ┌────────────┴───────────────────────┴──────────────────────────┐     │
│   │              CloudFront (Global CDN)                         │     │
│   └───────────────────────┬──────────────────────────────────────┘     │
│                           │                                             │
│   ┌───────────────────────┴──────────────────────────────────────┐     │
│   │              AWS Shield Advanced (DDoS Protection)           │     │
│   └───────────────────────┬──────────────────────────────────────┘     │
│                           │                                             │
│                           ▼                                             │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │              WAF v2 + Bot Control                             │     │
│   └───────────────────────┬───────────────────────────────────────┘     │
│                           │                                             │
│                           ▼                                             │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │              Application Load Balancer (2 per region)         │     │
│   └───────────────────────┬───────────────────────────────────────┘     │
│                           │                                             │
│   ┌───────────────────────┴───────────────────────────────────────┐     │
│   │                   EKS Cluster (Kubernetes)                    │     │
│   │                                                               │     │
│   │  ┌───────────────────────────────────────────────────────┐   │     │
│   │  │         Managed Node Groups (3 AZs)                   │   │     │
│   │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐     │   │     │
│   │  │  │ Node 1  │ │ Node 2  │ │ Node 3  │ │ Node 4+ │ ... │   │     │
│   │  │  │(t3.large)│ │(t3.large)│ │(t3.large)│ │(t3.large)│     │   │     │
│   │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘     │   │     │
│   │  │       Min: 3, Max: 20 nodes                          │   │     │
│   │  └───────────────────────────────────────────────────────┘   │     │
│   │                                                               │     │
│   │  ┌───────────────────────────────────────────────────────┐   │     │
│   │  │         Kubernetes Workloads                          │   │     │
│   │  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │   │     │
│   │  │  │ API Pods     │ │ Worker Pods  │ │ ML Pods      │  │   │     │
│   │  │  │ (HPA: 5-50)  │ │ (HPA: 2-20)  │ │ (HPA: 1-10)  │  │   │     │
│   │  │  └──────────────┘ └──────────────┘ └──────────────┘  │   │     │
│   │  │  ┌──────────────┐ ┌──────────────┐                    │   │     │
│   │  │  │ WebSocket    │ │ CronJobs     │                    │   │     │
│   │  │  │ (HPA: 2-10)  │ │ (Scheduled)  │                    │   │     │
│   │  │  └──────────────┘ └──────────────┘                    │   │     │
│   │  └───────────────────────────────────────────────────────┘   │     │
│   └───────────────────────────────────────────────────────────────┘     │
│                                                                          │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │         Data Layer (Multi-AZ + Multi-Region)                  │     │
│   │                                                               │     │
│   │  ┌───────────────────────────────────────────────────────┐   │     │
│   │  │     Aurora PostgreSQL (Global Database)               │   │     │
│   │  │  ┌─────────────────┐     ┌─────────────────┐         │   │     │
│   │  │  │ Primary Cluster │◄────│ Secondary Clstr │         │   │     │
│   │  │  │ (2 instances)   │     │ (1 instance)    │         │   │     │
│   │  │  └─────────────────┘     └─────────────────┘         │   │     │
│   │  │       RPO: < 1 second, RTO: < 1 minute                │   │     │
│   │  └───────────────────────────────────────────────────────┘   │     │
│   │                                                               │     │
│   │  ┌───────────────────────────────────────────────────────┐   │     │
│   │  │     ElastiCache Redis (Cluster Mode)                  │   │     │
│   │  │     3 shards × 2 replicas = 6 nodes                   │   │     │
│   │  └───────────────────────────────────────────────────────┘   │     │
│   │                                                               │     │
│   │  ┌───────────────────────────────────────────────────────┐   │     │
│   │  │     OpenSearch (Search & Analytics)                   │   │     │
│   │  │     3 nodes (m6g.large)                               │   │     │
│   │  └───────────────────────────────────────────────────────┘   │     │
│   └───────────────────────────────────────────────────────────────┘     │
│                                                                          │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │         Event-Driven Architecture                             │     │
│   │                                                               │     │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │     │
│   │  │ SNS      │  │ SQS      │  │ EventBr. │  │ Kinesis  │      │     │
│   │  │ (Push)   │  │ (Queue)  │  │ (Sched.) │  │ (Stream) │      │     │
│   │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘      │     │
│   │       └─────────────┴─────────────┴─────────────┘            │     │
│   │                         │                                     │     │
│   │                         ▼                                     │     │
│   │  ┌───────────────────────────────────────────────────────┐   │     │
│   │  │     Lambda Functions (Serverless)                     │   │     │
│   │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │   │     │
│   │  │  │ Image    │ │ Notif.   │ │ Report   │ │ ML       │  │   │     │
│   │  │  │ Process  │ │ Handler  │ │ Gen.     │ │ Infer.   │  │   │     │
│   │  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │   │     │
│   │  └───────────────────────────────────────────────────────┘   │     │
│   └───────────────────────────────────────────────────────────────┘     │
│                                                                          │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │         Observability Stack                                   │     │
│   │                                                               │     │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │     │
│   │  │ CloudWatch│  │ X-Ray    │  │ Grafana  │  │ PagerDuty│      │     │
│   │  │ (Metrics)│  │ (Traces) │  │ (Dash.)  │  │ (Alerts) │      │     │
│   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘      │     │
│   └───────────────────────────────────────────────────────────────┘     │
│                                                                          │
│   Monthly Cost: ~$2000-5000/month (per region)                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 6.2 EKS Configuration

```hcl
# infrastructure/phase4/eks.tf

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "foodbegood-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"
  
  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-eks"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.eks,
  ]
}

# Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "foodbegood-${var.environment}-nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.private[*].id
  
  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]
  
  scaling_config {
    desired_size = 3
    max_size     = 20
    min_size     = 3
  }
  
  update_config {
    max_unavailable_percentage = 25
  }
  
  labels = {
    workload = "general"
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-node-group"
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/foodbegood-${var.environment}" = "owned"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# Cluster Autoscaler IAM Policy
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "foodbegood-${var.environment}-cluster-autoscaler"
  description = "Policy for cluster autoscaler"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

# Fargate Profile for Serverless Workloads
resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "foodbegood-${var.environment}-fargate"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = aws_subnet.private[*].id
  
  selector {
    namespace = "serverless"
  }
  
  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }
  
  tags = {
    Name = "foodbegood-${var.environment}-fargate"
  }
}

# AWS Load Balancer Controller IAM Policy
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name   = "foodbegood-${var.environment}-aws-load-balancer-controller"
  policy = file("${path.module}/policies/aws-load-balancer-controller.json")
}
```

### 6.3 Kubernetes Manifests

```yaml
# infrastructure/phase4/k8s/api-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: foodbegood-api
  namespace: production
  labels:
    app: foodbegood-api
    version: v1
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: foodbegood-api
  template:
    metadata:
      labels:
        app: foodbegood-api
        version: v1
    spec:
      serviceAccountName: foodbegood-api
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - foodbegood-api
                topologyKey: kubernetes.io/hostname
      containers:
        - name: api
          image: foodbegood/api:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 3000
              name: http
              protocol: TCP
          env:
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "3000"
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: foodbegood-secrets
                  key: db-host
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: foodbegood-secrets
                  key: db-password
            - name: REDIS_HOST
              valueFrom:
                secretKeyRef:
                  name: foodbegood-secrets
                  key: redis-host
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: foodbegood-secrets
                  key: jwt-secret
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
      terminationGracePeriodSeconds: 30

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: foodbegood-api-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: foodbegood-api
  minReplicas: 5
  maxReplicas: 50
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: "1000"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
        - type: Pods
          value: 4
          periodSeconds: 15
      selectPolicy: Max

---
apiVersion: v1
kind: Service
metadata:
  name: foodbegood-api
  namespace: production
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /health/ready
spec:
  type: ClusterIP
  selector:
    app: foodbegood-api
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
      name: http

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foodbegood-api
  namespace: production
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/id
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
    alb.ingress.kubernetes.io/healthcheck-path: /health/ready
    alb.ingress.kubernetes.io/success-codes: "200"
    alb.ingress.kubernetes.io/healthy-threshold-count: "2"
    alb.ingress.kubernetes.io/unhealthy-threshold-count: "3"
spec:
  rules:
    - host: api.foodbegood.app
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: foodbegood-api
                port:
                  number: 80
```

### 6.4 Aurora Global Database

```hcl
# infrastructure/phase4/aurora.tf

# Aurora Global Cluster
resource "aws_rds_global_cluster" "main" {
  global_cluster_identifier = "foodbegood-${var.environment}-global"
  engine                    = "aurora-postgresql"
  engine_version            = "15.4"
  database_name             = var.db_name
  storage_encrypted         = true
}

# Primary Cluster (eu-west-1)
resource "aws_rds_cluster" "primary" {
  cluster_identifier        = "foodbegood-${var.environment}-primary"
  global_cluster_identifier = aws_rds_global_cluster.main.id
  engine                    = "aurora-postgresql"
  engine_version            = "15.4"
  engine_mode               = "provisioned"
  
  database_name   = var.db_name
  master_username = var.db_user
  master_password = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.aurora.id]
  
  backup_retention_period = 35
  preferred_backup_window = "03:00-04:00"
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  deletion_protection = var.environment == "production"
  skip_final_snapshot = var.environment != "production"
  
  tags = {
    Name = "foodbegood-${var.environment}-aurora-primary"
  }
}

resource "aws_rds_cluster_instance" "primary" {
  count              = 2
  identifier         = "foodbegood-${var.environment}-primary-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class     = "db.r6g.large"
  engine             = "aurora-postgresql"
  
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn
  
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  
  tags = {
    Name = "foodbegood-${var.environment}-aurora-primary-${count.index + 1}"
  }
}

# Secondary Cluster (eu-central-1)
resource "aws_rds_cluster" "secondary" {
  provider = aws.secondary
  
  cluster_identifier        = "foodbegood-${var.environment}-secondary"
  global_cluster_identifier = aws_rds_global_cluster.main.id
  engine                    = "aurora-postgresql"
  engine_version            = "15.4"
  
  db_subnet_group_name   = aws_db_subnet_group.secondary.name
  vpc_security_group_ids = [aws_security_group.aurora_secondary.id]
  
  depends_on = [aws_rds_cluster_instance.primary]
  
  tags = {
    Name = "foodbegood-${var.environment}-aurora-secondary"
  }
}

resource "aws_rds_cluster_instance" "secondary" {
  provider = aws.secondary
  
  count              = 1
  identifier         = "foodbegood-${var.environment}-secondary-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.secondary.id
  instance_class     = "db.r6g.large"
  engine             = "aurora-postgresql"
  
  tags = {
    Name = "foodbegood-${var.environment}-aurora-secondary-${count.index + 1}"
  }
}
```

### 6.5 Cost Breakdown (Phase 4)

| Service | Configuration | Monthly Cost (Primary) | Monthly Cost (Secondary) |
|---------|---------------|------------------------|--------------------------|
| **EKS** | Control plane + 3-20 nodes | ~$250-1500 | ~$0 (control plane shared) |
| **Aurora** | 2 × db.r6g.large | ~$350 | ~$175 |
| **ElastiCache** | 6 nodes (cluster mode) | ~$200 | ~$100 |
| **ALB** | 2 ALBs | ~$44 | ~$22 |
| **CloudFront** | 5 TB transfer | ~$200 | ~$100 |
| **Shield Advanced** | 1 subscription | ~$3000 | Included |
| **WAF** | 2 Web ACLs + Bot Control | ~$150 | ~$75 |
| **OpenSearch** | 3 × m6g.large | ~$250 | ~$125 |
| **S3** | 1 TB + lifecycle | ~$25 | ~$12 |
| **Data Transfer** | 10 TB | ~$900 | ~$450 |
| **CloudWatch** | Logs, metrics, alarms | ~$200 | ~$100 |
| **KMS** | Key management | ~$10 | ~$5 |
| **Total** | | **~$5980** | **~$1164** |

**Combined Monthly Cost: ~$7144**

---

## 7. AWS Services Reference

### 7.1 Compute Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **EC2** | Single server deployment | Phase 1 |
| **ECS Fargate** | Containerized applications | Phase 2-3 |
| **EKS** | Kubernetes orchestration | Phase 4 |
| **Lambda** | Serverless functions, event processing | Phase 3-4 |

### 7.2 Database Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **RDS PostgreSQL** | Relational database | Phase 1-3 |
| **Aurora PostgreSQL** | High-performance, global database | Phase 4 |
| **ElastiCache** | Session cache, rate limiting | Phase 2-4 |
| **DynamoDB** | NoSQL for high-throughput data | Optional |

### 7.3 Storage Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **S3** | File uploads, backups, logs | All phases |
| **S3 Glacier** | Long-term archival | Phase 3-4 |
| **EFS** | Shared file system for containers | Phase 4 |

### 7.4 Networking Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **VPC** | Network isolation | All phases |
| **ALB** | HTTP/HTTPS load balancing | Phase 2-4 |
| **NLB** | TCP/UDP load balancing | Phase 4 |
| **CloudFront** | CDN, edge caching | Phase 2-4 |
| **Route 53** | DNS, health checks | Phase 2-4 |
| **API Gateway** | API management, throttling | Optional |

### 7.5 Security Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **WAF** | Web application firewall | Phase 3-4 |
| **Shield** | DDoS protection | Phase 4 |
| **Secrets Manager** | Credential storage | Phase 2-4 |
| **KMS** | Encryption key management | Phase 2-4 |
| **IAM** | Access control | All phases |
| **Cognito** | User authentication (optional) | Optional |

### 7.6 Messaging Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **SNS** | Push notifications | Phase 3-4 |
| **SQS** | Message queuing | Phase 3-4 |
| **EventBridge** | Event routing, scheduling | Phase 3-4 |
| **Kinesis** | Real-time data streaming | Phase 4 |

### 7.7 Observability Services

| Service | Use Case | Phase |
|---------|----------|-------|
| **CloudWatch** | Metrics, logs, alarms | All phases |
| **X-Ray** | Distributed tracing | Phase 3-4 |
| **CloudTrail** | API audit logging | Phase 2-4 |
| **OpenSearch** | Log analytics, search | Phase 4 |

---

## 8. Cost Optimization

### 8.1 Reserved Instances & Savings Plans

| Service | On-Demand | Reserved (1-year) | Savings |
|---------|-----------|-------------------|---------|
| **EC2 t3.micro** | $8.50/mo | $5.10/mo | 40% |
| **RDS db.t3.small** | $26.00/mo | $16.00/mo | 38% |
| **ElastiCache t3.micro** | $12.50/mo | $7.80/mo | 38% |
| **Compute Savings Plan** | - | - | 20-30% |

### 8.2 Spot Instances

```yaml
# Use Spot for non-critical workloads
EKS Node Group:
  capacity_type: SPOT
  instance_types: ["t3.large", "t3a.large", "m5.large"]
  # Up to 90% savings vs On-Demand

ECS Fargate:
  capacity_provider_strategy:
    - capacity_provider: FARGATE_SPOT
      weight: 4
    - capacity_provider: FARGATE
      weight: 1
      base: 1
```

### 8.3 Right-Sizing Recommendations

| Current | Recommendation | Savings |
|---------|----------------|---------|
| t3.micro (1 GB) | t4g.micro (1 GB) | 20% |
| db.t3.small | db.t4g.small | 20% |
| cache.t3.micro | cache.t4g.micro | 20% |
| m5.large | m6g.large (Graviton) | 20% |

### 8.4 Cost Monitoring

```hcl
# infrastructure/common/budgets.tf

resource "aws_budgets_budget" "monthly" {
  name              = "foodbegood-${var.environment}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget
  limit_unit        = "USD"
  time_period_start = "2025-02-01_00:00"
  time_unit         = "MONTHLY"
  
  cost_filter {
    name = "TagKeyValue"
    values = [
      "user:Project$FoodBeGood",
      "user:Environment$${var.environment}"
    ]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 120
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }
}
```

---

## 9. Security Best Practices

### 9.1 Network Security

```hcl
# VPC Flow Logs
resource "aws_flow_log" "main" {
  vpc_id                   = aws_vpc.main.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow.arn
  iam_role_arn             = aws_iam_role.vpc_flow.arn
  max_aggregation_interval = 60
}

# Security Group Rules - Principle of Least Privilege
resource "aws_security_group" "api" {
  name_prefix = "foodbegood-api-"
  vpc_id      = aws_vpc.main.id
  
  # Only allow traffic from ALB
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow API traffic from ALB only"
  }
  
  # No direct internet access
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound for AWS services"
  }
}
```

### 9.2 Data Encryption

```hcl
# KMS Key for application data
resource "aws_kms_key" "app" {
  description             = "KMS key for FoodBeGood application data"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow ECS Task Execution"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_execution.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### 9.3 Secrets Management

```hcl
# Rotate secrets automatically
resource "aws_secretsmanager_secret_rotation" "db" {
  secret_id           = aws_secretsmanager_secret.db_password.id
  rotation_lambda_arn = aws_lambda_function.rotate_secrets.arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}

# Reference secrets in ECS
resource "aws_ecs_task_definition" "api" {
  # ... other configuration ...
  
  container_definitions = jsonencode([
    {
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_password.arn
        },
        {
          name      = "JWT_SECRET"
          valueFrom = aws_secretsmanager_secret.jwt_secret.arn
        }
      ]
    }
  ])
}
```

### 9.4 Compliance Checklist

| Control | Implementation | Phase |
|---------|----------------|-------|
| **Encryption at Rest** | KMS, S3 SSE, RDS encryption | Phase 2+ |
| **Encryption in Transit** | TLS 1.3, ACM certificates | Phase 2+ |
| **Network Segmentation** | VPC, private subnets, security groups | All phases |
| **Access Logging** | CloudTrail, VPC Flow Logs | Phase 2+ |
| **Vulnerability Scanning** | ECR image scanning, Inspector | Phase 2+ |
| **DDoS Protection** | Shield Standard/Advanced | Phase 3-4 |
| **WAF Rules** | OWASP Top 10, rate limiting | Phase 3-4 |
| **Secrets Rotation** | 30-day rotation | Phase 2+ |
| **Backup Encryption** | Encrypted snapshots | All phases |

---

## 10. Monitoring & Observability

### 10.1 CloudWatch Dashboard

```hcl
# infrastructure/common/monitoring.tf

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "foodbegood-${var.environment}"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "API Requests"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum" }]
          ]
          period = 60
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Response Time (p99)"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "p99" }]
          ]
          period = 60
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "CPU Utilization"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.api.name, "ClusterName", aws_ecs_cluster.main.name]
          ]
          period = 60
          annotations = {
            horizontal = [
              {
                value = 70
                label = "Scale Up"
                color = "#ff0000"
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Memory Utilization"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", aws_ecs_service.api.name, "ClusterName", aws_ecs_cluster.main.name]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Database Connections"
          region = var.aws_region
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.main.id]
          ]
          period = 60
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          title  = "Error Logs"
          region = var.aws_region
          query  = "SOURCE '/ecs/foodbegood-${var.environment}-api' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 100"
        }
      }
    ]
  })
}
```

### 10.2 Alarms

```hcl
# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "foodbegood-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    ServiceName = aws_ecs_service.api.name
    ClusterName = aws_ecs_cluster.main.name
  }
}

# High Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "foodbegood-${var.environment}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 5
  alarm_description   = "Error rate exceeds 5%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  metric_query {
    id          = "error_rate"
    expression  = "errors / total * 100"
    label       = "Error Rate"
    return_data = true
  }
  
  metric_query {
    id = "errors"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = aws_lb.main.arn_suffix
      }
    }
  }
  
  metric_query {
    id = "total"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = aws_lb.main.arn_suffix
      }
    }
  }
}

# Database Connection Alarm
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "foodbegood-${var.environment}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Database connections approaching limit"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}
```

### 10.3 Distributed Tracing (X-Ray)

```hcl
# Enable X-Ray for ECS
resource "aws_ecs_task_definition" "api" {
  # ... other configuration ...
  
  container_definitions = jsonencode([
    {
      name  = "api"
      image = "${aws_ecr_repository.api.repository_url}:latest"
      
      # Enable X-Ray sidecar
      dependsOn = [
        {
          containerName = "xray-daemon"
          condition     = "START"
        }
      ]
    },
    {
      name  = "xray-daemon"
      image = "amazon/aws-xray-daemon"
      essential = false
      portMappings = [
        {
          containerPort = 2000
          protocol      = "udp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.xray.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "xray"
        }
      }
    }
  ])
}
```

### 10.4 Log Aggregation

```hcl
# CloudWatch Logs Insights Queries

# Find slow requests
fields @timestamp, @message
| filter @message like /response_time/
| parse @message /response_time:(?<response_time>\d+)ms/
| filter response_time > 1000
| sort response_time desc
| limit 100

# Error analysis
fields @timestamp, @message, @logStream
| filter @message like /ERROR/
| stats count() as error_count by bin(5m)
| sort error_count desc

# User activity
fields @timestamp, @message
| filter @message like /user_id/
| parse @message /user_id:(?<user_id>\d+)/
| stats count() as requests by user_id
| sort requests desc
| limit 20
```

---

## Appendix A: Terraform Module Structure

```
infrastructure/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── ecs/
│   ├── eks/
│   ├── rds/
│   ├── elasticache/
│   └── alb/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── production/
├── global/
│   ├── iam/
│   ├── route53/
│   └── s3-state/
└── scripts/
    ├── deploy.sh
    ├── destroy.sh
    └── plan.sh
```

## Appendix B: Deployment Scripts

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=$1
PHASE=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$PHASE" ]; then
  echo "Usage: ./deploy.sh <environment> <phase>"
  echo "Example: ./deploy.sh production phase2"
  exit 1
fi

cd "infrastructure/environments/${ENVIRONMENT}"

echo "Initializing Terraform..."
terraform init

echo "Planning changes..."
terraform plan -var="environment=${ENVIRONMENT}" -out=tfplan

echo "Applying changes..."
terraform apply tfplan

echo "Deployment complete!"
```

## Appendix C: Migration Guide

### Phase 1 → Phase 2
1. Create ECR repository and push Docker image
2. Set up ECS cluster and task definitions
3. Create ALB and target groups
4. Update Route 53 to point to ALB
5. Migrate data from EC2 to RDS Multi-AZ
6. Decommission EC2 instance

### Phase 2 → Phase 3
1. Increase ECS task count and add auto-scaling
2. Upgrade RDS instance class
3. Add ElastiCache cluster mode
4. Enable CloudFront with WAF
5. Add SQS for background jobs
6. Implement Lambda for image processing

### Phase 3 → Phase 4
1. Create EKS cluster
2. Deploy workloads to Kubernetes
3. Set up Aurora Global Database
4. Configure multi-region deployment
5. Implement advanced observability
6. Add Shield Advanced and WAF Bot Control

---

*Document Version: 1.0.0*  
*Last Updated: February 4, 2025*  
*Next Review: March 4, 2025*
