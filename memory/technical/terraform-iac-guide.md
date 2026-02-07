# FoodBeGood Terraform Infrastructure as Code (IaC) Guide

## Document Information

**Project:** FoodBeGood Mobile Application  
**Version:** 1.0.0  
**Date:** February 4, 2025  
**Terraform Version:** >= 1.5.0  
**AWS Provider:** ~> 5.0  

---

## Table of Contents

1. [Introduction to IaC](#1-introduction-to-iac)
2. [Terraform Basics](#2-terraform-basics)
3. [Project Structure](#3-project-structure)
4. [Core Modules](#4-core-modules)
5. [Environment Configuration](#5-environment-configuration)
6. [State Management](#6-state-management)
7. [Variable Management](#7-variable-management)
8. [Security Best Practices](#8-security-best-practices)
9. [CI/CD Integration](#9-cicd-integration)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Introduction to IaC

### 1.1 What is Infrastructure as Code?

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through code files rather than manual processes. Terraform is a declarative IaC tool that allows you to define your infrastructure in configuration files.

### 1.2 Benefits of Terraform

| Benefit | Description |
|---------|-------------|
| **Version Control** | Track infrastructure changes in Git |
| **Consistency** | Same configuration across environments |
| **Reproducibility** | Spin up identical environments quickly |
| **Collaboration** | Team members can review infrastructure changes |
| **Documentation** | Code serves as living documentation |
| **Automation** | Integrate with CI/CD pipelines |

### 1.3 Terraform Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    TERRAFORM WORKFLOW                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. WRITE                                                        │
│     ┌─────────────────────────────────────────────────────┐     │
│     │  Create/Edit .tf files                              │     │
│     │  - Define resources                                 │     │
│     │  - Set variables                                    │     │
│     │  - Configure providers                              │     │
│     └──────────────────────┬──────────────────────────────┘     │
│                            │                                     │
│                            ▼                                     │
│  2. INIT                                                       │
│     ┌─────────────────────────────────────────────────────┐     │
│     │  terraform init                                     │     │
│     │  - Download providers                               │     │
│     │  - Initialize modules                               │     │
│     │  - Configure backend                                │     │
│     └──────────────────────┬──────────────────────────────┘     │
│                            │                                     │
│                            ▼                                     │
│  3. PLAN                                                       │
│     ┌─────────────────────────────────────────────────────┐     │
│     │  terraform plan                                     │     │
│     │  - Preview changes                                  │     │
│     │  - Validate syntax                                  │     │
│     │  - Show cost estimates                              │     │
│     └──────────────────────┬──────────────────────────────┘     │
│                            │                                     │
│                            ▼                                     │
│  4. APPLY                                                      │
│     ┌─────────────────────────────────────────────────────┐     │
│     │  terraform apply                                    │     │
│     │  - Create/Update/Delete resources                   │     │
│     │  - Update state file                                │     │
│     │  - Generate outputs                                 │     │
│     └──────────────────────┬──────────────────────────────┘     │
│                            │                                     │
│                            ▼                                     │
│  5. DESTROY (if needed)                                        │
│     ┌─────────────────────────────────────────────────────┐     │
│     │  terraform destroy                                  │     │
│     │  - Remove all resources                             │     │
│     │  - Clean up state                                   │     │
│     └─────────────────────────────────────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Terraform Basics

### 2.1 Core Concepts

#### Providers

Providers are plugins that Terraform uses to interact with cloud providers, SaaS providers, and other APIs.

```hcl
# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
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
```

#### Resources

Resources are the most important element in Terraform. Each resource block describes one or more infrastructure objects.

```hcl
# Create an S3 bucket
resource "aws_s3_bucket" "uploads" {
  bucket = "foodbegood-${var.environment}-uploads"
  
  tags = {
    Name = "FoodBeGood Uploads"
  }
}

# Create an EC2 instance
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "foodbegood-${var.environment}-app"
  }
}
```

#### Data Sources

Data sources allow Terraform to use information defined outside of Terraform, or defined by another separate Terraform configuration.

```hcl
# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Use the AMI in a resource
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
}
```

#### Variables

Variables allow you to parameterize your Terraform configurations.

```hcl
# variables.tf
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 1
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
```

#### Outputs

Outputs allow you to extract information from your Terraform configuration.

```hcl
# outputs.tf
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.uploads.id
}

output "instance_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
  sensitive   = false
}

output "database_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true  # Won't be shown in CLI output
}
```

### 2.2 Terraform Commands Reference

```bash
# Initialize Terraform (download providers, modules)
terraform init

# Initialize and upgrade providers
terraform init -upgrade

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# Show execution plan
terraform plan

# Show plan with variables
terraform plan -var="environment=production" -var="instance_count=3"

# Save plan to file
terraform plan -out=tfplan

# Apply changes
terraform apply

# Apply saved plan
terraform apply tfplan

# Apply without confirmation
terraform apply -auto-approve

# Destroy all resources
terraform destroy

# Destroy specific resource
terraform destroy -target=aws_instance.app

# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.app

# Import existing resource
terraform import aws_s3_bucket.uploads foodbegood-existing-bucket

# Refresh state (reconcile with real infrastructure)
terraform refresh

# Get provider and module info
terraform providers

# Output values
terraform output

# Output specific value
terraform output instance_ip

# Output as JSON
terraform output -json

# Create workspace
terraform workspace new production

# List workspaces
terraform workspace list

# Select workspace
terraform workspace select production

# Show current workspace
terraform workspace show
```

---

## 3. Project Structure

### 3.1 Recommended Directory Structure

```
foodbegood-infrastructure/
├── README.md
├── .gitignore
├── .terraform-version
├── Makefile
├── scripts/
│   ├── init.sh
│   ├── plan.sh
│   ├── apply.sh
│   ├── destroy.sh
│   └── validate.sh
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   ├── ecs/
│   ├── eks/
│   ├── rds/
│   ├── elasticache/
│   ├── alb/
│   ├── s3/
│   ├── iam/
│   ├── cloudwatch/
│   └── security/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   └── versions.tf
│   ├── staging/
│   └── production/
├── global/
│   ├── iam/
│   ├── route53/
│   └── s3-state/
└── policies/
    ├── aws-load-balancer-controller.json
    ├── cluster-autoscaler.json
    └── external-dns.json
```

### 3.2 File Naming Conventions

| File | Purpose |
|------|---------|
| `main.tf` | Primary resource definitions |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output value declarations |
| `versions.tf` | Provider and Terraform version constraints |
| `backend.tf` | State backend configuration |
| `provider.tf` | Provider configurations |
| `terraform.tfvars` | Variable values for environment |
| `locals.tf` | Local value definitions |
| `data.tf` | Data source definitions |

### 3.3 Git Ignore

```gitignore
# .gitignore

# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which are likely to contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore lock files (optional - some teams prefer to commit these)
# .terraform.lock.hcl

# Ignore plan files
*.tfplan

# Ignore generated files
*.pem
*.key
```

---

## 4. Core Modules

### 4.1 VPC Module

```hcl
# modules/vpc/main.tf

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${count.index + 1}"
      Type = "public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 100)
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${count.index + 1}"
      Type = "private"
    }
  )
}

# NAT Gateways (one per AZ for high availability)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-${count.index + 1}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-${count.index + 1}"
    }
  )
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-rt-${count.index + 1}"
    }
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```

```hcl
# modules/vpc/variables.tf

variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateways"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

```hcl
# modules/vpc/outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT gateway IDs"
  value       = aws_nat_gateway.main[*].id
}
```

### 4.2 ECS Module

```hcl
# modules/ecs/main.tf

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
  
  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
  
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  
  capacity_providers = var.capacity_providers
  
  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      base              = lookup(default_capacity_provider_strategy.value, "base", null)
      weight            = default_capacity_provider_strategy.value.weight
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "service" {
  for_each = var.services
  
  name              = "/ecs/${var.cluster_name}/${each.key}"
  retention_in_days = each.value.log_retention_days
  
  tags = var.tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "service" {
  for_each = var.services
  
  family                   = "${var.cluster_name}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([
    {
      name  = each.key
      image = each.value.image
      essential = true
      
      portMappings = [
        for port in each.value.ports : {
          containerPort = port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        for key, value in each.value.environment : {
          name  = key
          value = value
        }
      ]
      
      secrets = [
        for key, value in each.value.secrets : {
          name      = key
          valueFrom = value
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service[each.key].name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
      
      healthCheck = each.value.health_check
      
      mountPoints = each.value.mount_points
      volumesFrom = []
    }
  ])
  
  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "main" {
  for_each = var.services
  
  name            = each.key
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs[each.key].id]
    assign_public_ip = each.value.assign_public_ip
  }
  
  dynamic "load_balancer" {
    for_each = each.value.target_group_arn != null ? [each.value.target_group_arn] : []
    content {
      target_group_arn = load_balancer.value
      container_name   = each.key
      container_port   = each.value.ports[0]
    }
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  propagate_tags = "SERVICE"
  
  tags = var.tags
  
  depends_on = [aws_iam_role_policy_attachment.ecs_execution]
}

# Auto Scaling
resource "aws_appautoscaling_target" "service" {
  for_each = var.services
  
  max_capacity       = each.value.max_count
  min_capacity       = each.value.min_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  for_each = var.services
  
  name               = "${var.cluster_name}-${each.key}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.service[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[each.key].service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = each.value.target_cpu
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Security Groups
resource "aws_security_group" "ecs" {
  for_each = var.services
  
  name_prefix = "${var.cluster_name}-${each.key}-"
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = lookup(ingress.value, "security_groups", null)
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      description     = lookup(ingress.value, "description", null)
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### 4.3 RDS Module

```hcl
# modules/rds/main.tf

# Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-db-subnet-group"
    }
  )
}

# Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.name}-postgres-params"
  family = "postgres15"
  
  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
  
  parameter {
    name  = "shared_buffers"
    value = var.shared_buffers
  }
  
  tags = var.tags
}

# KMS Key for encryption
resource "aws_kms_key" "rds" {
  count = var.storage_encrypted ? 1 : 0
  
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = var.tags
}

resource "aws_kms_alias" "rds" {
  count = var.storage_encrypted ? 1 : 0
  
  name          = "alias/${var.name}-rds"
  target_key_id = aws_kms_key.rds[0].key_id
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.name
  
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.storage_encrypted ? aws_kms_key.rds[0].arn : null
  
  db_name  = var.database_name
  username = var.username
  password = var.password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  
  multi_az               = var.multi_az
  publicly_accessible    = false
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? aws_kms_key.rds[0].arn : null
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring.arn : null
  
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "PostgreSQL access"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-rds"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### 4.4 ALB Module

```hcl
# modules/alb/main.tf

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids
  
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  idle_timeout              = var.idle_timeout
  
  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [var.access_logs_bucket] : []
    content {
      bucket  = access_logs.value
      prefix  = "alb-logs"
      enabled = true
    }
  }
  
  tags = var.tags
}

# Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Target Groups
resource "aws_lb_target_group" "main" {
  for_each = var.target_groups
  
  name     = "${var.name}-${each.key}"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id
  target_type = each.value.target_type
  
  deregistration_delay = each.value.deregistration_delay
  
  health_check {
    enabled             = true
    healthy_threshold   = each.value.health_check.healthy_threshold
    interval            = each.value.health_check.interval
    matcher             = each.value.health_check.matcher
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    timeout             = each.value.health_check.timeout
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }
  
  dynamic "stickiness" {
    for_each = each.value.stickiness_enabled ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = each.value.stickiness_duration
      enabled         = true
    }
  }
  
  tags = var.tags
  
  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener (Redirect to HTTPS)
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

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[var.default_target_group].arn
  }
}

# Listener Rules
resource "aws_lb_listener_rule" "main" {
  for_each = var.listener_rules
  
  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.value.target_group].arn
  }
  
  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
  
  dynamic "condition" {
    for_each = each.value.host_headers != null ? [each.value.host_headers] : []
    content {
      host_header {
        values = condition.value
      }
    }
  }
}
```

---

## 5. Environment Configuration

### 5.1 Development Environment

```hcl
# environments/dev/main.tf

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "foodbegood-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "foodbegood-terraform-locks"
  }
}

provider "aws" {
  region = "eu-west-1"
  
  default_tags {
    tags = {
      Project     = "FoodBeGood"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  environment = "dev"
  name        = "foodbegood-dev"
  
  common_tags = {
    Environment = local.environment
    Project     = "FoodBeGood"
  }
}

# VPC
module "vpc" {
  source = "../../modules/vpc"
  
  name               = local.name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  enable_nat_gateway = false  # Save costs in dev
  
  tags = local.common_tags
}

# ECS Cluster
module "ecs" {
  source = "../../modules/ecs"
  
  cluster_name = local.name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  
  services = {
    api = {
      image              = "foodbegood/api:latest"
      cpu                = 256
      memory             = 512
      desired_count      = 1
      min_count          = 1
      max_count          = 2
      target_cpu         = 70
      ports              = [3000]
      assign_public_ip   = true
      log_retention_days = 7
      
      environment = {
        NODE_ENV = "development"
        PORT     = "3000"
      }
      
      secrets = {}
      
      ingress_rules = [
        {
          from_port   = 3000
          to_port     = 3000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "API access"
        }
      ]
      
      health_check = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      target_group_arn = null
      mount_points     = []
    }
  }
  
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]
  
  tags = local.common_tags
}

# RDS
module "rds" {
  source = "../../modules/rds"
  
  name       = local.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  multi_az          = false
  
  database_name = "foodbegood_dev"
  username      = "foodbegood"
  password      = var.db_password
  
  allowed_security_groups = [module.ecs.security_group_ids["api"]]
  
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  
  tags = local.common_tags
}

# S3 Bucket for uploads
resource "aws_s3_bucket" "uploads" {
  bucket = "${local.name}-uploads-${data.aws_caller_identity.current.account_id}"
  
  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Disabled"  # Save costs in dev
  }
}
```

```hcl
# environments/dev/variables.tf

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

```hcl
# environments/dev/terraform.tfvars

db_password = "changeme-in-dev"
```

### 5.2 Production Environment

```hcl
# environments/production/main.tf

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "foodbegood-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "foodbegood-terraform-locks"
  }
}

provider "aws" {
  region = "eu-west-1"
  
  default_tags {
    tags = {
      Project     = "FoodBeGood"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  environment = "production"
  name        = "foodbegood-production"
  
  common_tags = {
    Environment = local.environment
    Project     = "FoodBeGood"
  }
}

# VPC
module "vpc" {
  source = "../../modules/vpc"
  
  name               = local.name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  enable_nat_gateway = true
  
  tags = local.common_tags
}

# ALB
module "alb" {
  source = "../../modules/alb"
  
  name               = local.name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  internal           = false
  certificate_arn    = data.aws_acm_certificate.main.arn
  access_logs_bucket = aws_s3_bucket.logs.id
  
  target_groups = {
    api = {
      port                = 3000
      protocol            = "HTTP"
      target_type         = "ip"
      deregistration_delay = 30
      health_check = {
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
      stickiness_enabled   = false
      stickiness_duration  = 86400
    }
  }
  
  default_target_group = "api"
  listener_rules       = {}
  
  tags = local.common_tags
}

# ECS
module "ecs" {
  source = "../../modules/ecs"
  
  cluster_name = local.name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
  
  services = {
    api = {
      image              = "foodbegood/api:v1.0.0"
      cpu                = 512
      memory             = 1024
      desired_count      = 3
      min_count          = 3
      max_count          = 10
      target_cpu         = 65
      ports              = [3000]
      assign_public_ip   = false
      log_retention_days = 30
      target_group_arn   = module.alb.target_group_arns["api"]
      
      environment = {
        NODE_ENV = "production"
        PORT     = "3000"
        DB_HOST  = module.rds.endpoint
      }
      
      secrets = {
        DB_PASSWORD = module.rds.password_secret_arn
        JWT_SECRET  = aws_secretsmanager_secret.jwt.arn
      }
      
      ingress_rules = [
        {
          from_port       = 3000
          to_port         = 3000
          protocol        = "tcp"
          security_groups = [module.alb.security_group_id]
          description     = "ALB access"
        }
      ]
      
      health_check = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      mount_points = []
    }
  }
  
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      base              = 1
      weight            = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 3
    }
  ]
  
  tags = local.common_tags
}

# RDS
module "rds" {
  source = "../../modules/rds"
  
  name       = local.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  instance_class    = "db.t3.medium"
  allocated_storage = 100
  multi_az          = true
  storage_encrypted = true
  
  database_name = "foodbegood"
  username      = "foodbegood"
  password      = var.db_password
  
  allowed_security_groups = [module.ecs.security_group_ids["api"]]
  
  backup_retention_period = 35
  deletion_protection     = true
  skip_final_snapshot     = false
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  
  tags = local.common_tags
}

# ElastiCache
module "elasticache" {
  source = "../../modules/elasticache"
  
  name       = local.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  node_type       = "cache.t3.small"
  num_cache_nodes = 2
  
  allowed_security_groups = [module.ecs.security_group_ids["api"]]
  
  tags = local.common_tags
}

# CloudFront
module "cloudfront" {
  source = "../../modules/cloudfront"
  
  enabled         = true
  price_class     = "PriceClass_100"
  aliases         = ["api.foodbegood.app"]
  certificate_arn = data.aws_acm_certificate.us_east_1.arn
  
  origin = {
    domain_name = module.alb.dns_name
    origin_id   = "ALB"
    
    custom_origin_config = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ALB"
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values = {
      query_string = true
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      cookies = {
        forward = "all"
      }
    }
    
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }
  
  tags = local.common_tags
}
```

---

## 6. State Management

### 6.1 S3 Backend Configuration

```hcl
# global/s3-state/main.tf

resource "aws_s3_bucket" "terraform_state" {
  bucket = "foodbegood-terraform-state"
  
  tags = {
    Name = "FoodBeGood Terraform State"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "foodbegood-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name = "FoodBeGood Terraform Locks"
  }
}
```

### 6.2 State Management Best Practices

```bash
# Enable state locking
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

# Use workspaces for environment separation
terraform workspace new production
terraform workspace select production

# State operations
terraform state list                                    # List resources
terraform state show aws_instance.app                   # Show resource details
terraform state pull > terraform.tfstate.backup        # Backup state
terraform state rm aws_instance.app                     # Remove from state
terraform state mv aws_instance.old aws_instance.new    # Rename resource
terraform import aws_instance.app i-1234567890abcdef0   # Import existing
```

---

## 7. Variable Management

### 7.1 Variable Types

```hcl
# Simple types
variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

# Collection types
variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Complex types
variable "services" {
  type = map(object({
    image         = string
    cpu           = number
    memory        = number
    desired_count = number
    ports         = list(number)
    environment   = map(string)
    secrets       = map(string)
  }))
}

# Optional attributes
variable "backup_config" {
  type = object({
    retention_days = optional(number, 7)
    enabled        = optional(bool, true)
  })
  default = {}
}
```

### 7.2 Sensitive Variables

```hcl
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true  # Won't be shown in logs or CLI
}

# Usage with validation
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 12
    error_message = "Password must be at least 12 characters."
  }
  
  validation {
    condition     = can(regex("[A-Z]", var.db_password))
    error_message = "Password must contain at least one uppercase letter."
  }
}
```

### 7.3 Variable Sources (Precedence)

```
1. Environment variables (TF_VAR_name)
2. terraform.tfvars file
3. terraform.tfvars.json file
4. *.auto.tfvars or *.auto.tfvars.json files
5. -var or -var-file command line flags
```

```bash
# Environment variable
export TF_VAR_db_password="supersecret123"

# Command line
terraform apply -var="db_password=supersecret123"

# Var file
terraform apply -var-file="production.tfvars"
```

---

## 8. Security Best Practices

### 8.1 Least Privilege IAM

```hcl
# modules/iam/ecs-execution-role.tf

resource "aws_iam_role" "ecs_execution" {
  name = "${var.name}-ecs-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution" {
  name = "${var.name}-ecs-execution-policy"
  role = aws_iam_role.ecs_execution.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.service.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_password.arn,
          aws_secretsmanager_secret.jwt_secret.arn
        ]
      }
    ]
  })
}
```

### 8.2 Encryption

```hcl
# Encrypt all the things

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

# RDS Encryption
resource "aws_db_instance" "main" {
  storage_encrypted = true
  kms_key_id       = aws_kms_key.rds.arn
}

# EBS Encryption
resource "aws_ebs_encryption_by_default" "main" {
  enabled = true
}

# Secrets Manager
resource "aws_secretsmanager_secret" "main" {
  name                    = "foodbegood-secret"
  kms_key_id             = aws_kms_key.secrets.arn
  recovery_window_in_days = 30
}
```

### 8.3 Security Groups

```hcl
# Principle: Explicit allow, implicit deny

resource "aws_security_group" "app" {
  name_prefix = "foodbegood-app-"
  vpc_id      = var.vpc_id
  
  # Only allow from ALB
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Application port from ALB"
  }
  
  # No outbound internet (use VPC endpoints)
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
    description     = "S3 via VPC endpoint"
  }
  
  tags = {
    Name = "foodbegood-app"
  }
}
```

---

## 9. CI/CD Integration

### 9.1 GitHub Actions Workflow

```yaml
# .github/workflows/terraform.yml

name: Terraform

on:
  push:
    branches: [main]
    paths:
      - 'infrastructure/**'
  pull_request:
    branches: [main]
    paths:
      - 'infrastructure/**'

env:
  TF_VERSION: '1.5.0'
  AWS_REGION: 'eu-west-1'

jobs:
  validate:
    name: Validate
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: infrastructure
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Format
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Terraform Validate
        run: terraform validate

  plan:
    name: Plan
    needs: validate
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    defaults:
      run:
        working-directory: infrastructure/environments/dev
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan -no-color -input=false
        continue-on-error: true
      
      - name: Update PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
            #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
            #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
            #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
            
            <details><summary>Show Plan</summary>
            
            \`\`\`terraform
            ${{ steps.plan.outputs.stdout }}
            \`\`\`
            
            </details>
            
            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

  apply:
    name: Apply
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    defaults:
      run:
        working-directory: infrastructure/environments/production
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan -out=tfplan -input=false
      
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
```

### 9.2 Makefile for Local Development

```makefile
# Makefile

.PHONY: init plan apply destroy fmt validate clean

ENVIRONMENT ?= dev
TF_DIR = environments/$(ENVIRONMENT)

init:
	cd $(TF_DIR) && terraform init

plan:
	cd $(TF_DIR) && terraform plan -out=tfplan

apply:
	cd $(TF_DIR) && terraform apply tfplan

destroy:
	cd $(TF_DIR) && terraform destroy

fmt:
	terraform fmt -recursive

validate:
	cd $(TF_DIR) && terraform validate

clean:
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name "*.tfstate*" -delete
	find . -type f -name "*.tfplan" -delete

dev-init:
	$(MAKE) init ENVIRONMENT=dev

dev-plan:
	$(MAKE) plan ENVIRONMENT=dev

dev-apply:
	$(MAKE) apply ENVIRONMENT=dev

prod-init:
	$(MAKE) init ENVIRONMENT=production

prod-plan:
	$(MAKE) plan ENVIRONMENT=production

prod-apply:
	$(MAKE) apply ENVIRONMENT=production
```

---

## 10. Troubleshooting

### 10.1 Common Issues

#### State Lock Issues

```bash
# If state is locked (e.g., after interrupted apply)
terraform force-unlock <LOCK_ID>

# Find lock ID in error message or DynamoDB
aws dynamodb scan --table-name foodbegood-terraform-locks
```

#### Provider Authentication Issues

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Set credentials explicitly
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_REGION="eu-west-1"

# Or use AWS profiles
export AWS_PROFILE="foodbegood-prod"
```

#### Resource Conflicts

```bash
# Import existing resource
terraform import aws_s3_bucket.uploads foodbegood-existing-bucket

# Taint resource (force recreation)
terraform taint aws_instance.app

# Replace resource
terraform apply -replace=aws_instance.app
```

### 10.2 Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log

# Trace level (very verbose)
export TF_LOG=TRACE

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

### 10.3 Drift Detection

```bash
# Detect drift
terraform plan -detailed-exitcode

# Exit codes:
# 0 - Succeeded, no changes
# 1 - Error
# 2 - Succeeded, changes present

# Refresh state (reconcile with real infrastructure)
terraform refresh

# Show differences
terraform show -json | jq '.values.root_module.resources[]'
```

### 10.4 Performance Optimization

```bash
# Parallelism (default: 10)
terraform apply -parallelism=20

# Plugin cache (set in ~/.terraformrc)
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"

# Partial configuration
terraform apply -target=module.vpc

# Skip refresh (faster, but risky)
terraform plan -refresh=false
```

---

## Appendix: Useful Resources

### Terraform Documentation
- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### AWS Services
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
- [Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
- [Pricing Calculator](https://calculator.aws/)

### Community Modules
- [Terraform Registry](https://registry.terraform.io/)
- [Terraform AWS Modules](https://github.com/terraform-aws-modules)

---

*Document Version: 1.0.0*  
*Last Updated: February 4, 2025*  
*Terraform Version: >= 1.5.0*
