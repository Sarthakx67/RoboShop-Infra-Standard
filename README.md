# 🛒 RoboShop Terraform Infrastructure

<div align="center">

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

*Scalable, secure, and automated e-commerce infrastructure on AWS*

</div>

---

## 📋 Table of Contents

- [🌟 Project Overview](#-project-overview)
- [🏗️ Architecture](#️-architecture)
- [📁 Module Structure](#-module-structure)
- [🚀 Quick Start](#-quick-start)
- [🔐 SSH Access Guide](#-ssh-access-guide)
- [🐛 Debugging & Monitoring](#-debugging--monitoring)
- [🔧 Troubleshooting](#-troubleshooting)
- [⚙️ Configuration](#️-configuration)
- [📦 Dependencies](#-dependencies)
- [🔒 Security](#-security)

---

## 🌟 Project Overview

This repository contains **Infrastructure as Code (IaC)** for deploying the **RoboShop e-commerce application** on AWS using Terraform. The infrastructure is designed with **high availability**, **scalability**, and **security** best practices.

### ✨ Key Features

- 🏗️ **Modular Architecture**: 15 distinct modules for organized deployment
- 🔒 **Security First**: Multi-layered security with VPN access and security groups  
- 🚀 **Auto Scaling**: Dynamic scaling based on demand
- 🌐 **Load Balancing**: Internal and external load balancers for high availability
- 📊 **Multi-Database**: MongoDB, Redis, MySQL, and RabbitMQ support
- 🔐 **SSL/TLS**: Automated certificate management with Route53 validation

---

## 🏗️ Architecture

<details>
<summary><b>🎯 Infrastructure Components</b></summary>

| Component | Type | Purpose |
|-----------|------|---------|
| **VPC** | Network | Custom Virtual Private Cloud with multi-AZ deployment |
| **Security Groups** | Security | Firewall rules for all components |
| **VPN** | Access | Bastion host for secure administrative access |
| **ALB** | Load Balancing | Internal (app) and External (web) load balancers |
| **Auto Scaling** | Compute | Dynamic scaling for application services |
| **Databases** | Data | MongoDB, Redis, MySQL, RabbitMQ |
| **Microservices** | Application | Catalogue, User, Cart, Shipping, Payment |
| **Web Server** | Frontend | Nginx with SSL termination |

</details>

### 🌐 Network Architecture

```
Internet Gateway
       ↓
┌─────────────────┐    ┌─────────────────┐
│  Public Subnet  │    │  Public Subnet  │
│   10.0.1.0/24   │    │   10.0.2.0/24   │
│      (AZ-1)     │    │      (AZ-2)     │
└─────────────────┘    └─────────────────┘
       ↓                        ↓
┌─────────────────┐    ┌─────────────────┐
│ Private Subnet  │    │ Private Subnet  │
│  10.0.11.0/24   │    │  10.0.12.0/24   │
│ (Applications)  │    │ (Applications)  │
└─────────────────┘    └─────────────────┘
       ↓                        ↓
┌─────────────────┐    ┌─────────────────┐
│Database Subnet  │    │Database Subnet  │
│  10.0.21.0/24   │    │  10.0.22.0/24   │
│   (Databases)   │    │   (Databases)   │
└─────────────────┘    └─────────────────┘
```

---

## 📁 Module Structure

<details>
<summary><b>🗂️ Complete Module Breakdown</b></summary>

### 🔰 Foundation Layer

#### **01-vpc** - Network Foundation
```
📦 VPC Infrastructure
├── 🌐 VPC (10.0.0.0/16)
├── 🌍 Public Subnets (2 AZs)
├── 🔒 Private Subnets (2 AZs)  
├── 💾 Database Subnets (2 AZs)
├── 🚪 Internet Gateway
└── 🔗 VPC Peering (Default VPC)
```

#### **02-firewall** - Security Layer
```
🛡️ Security Groups
├── 🔐 VPN Security Group
├── 💾 Database Security Groups (MongoDB, Redis, MySQL, RabbitMQ)
├── 🚀 Application Security Groups (Catalogue, User, Cart, Shipping, Payment)
└── 🌐 Load Balancer Security Groups (App-ALB, Web-ALB, Web)
```

#### **03-vpn** - Access Layer  
```
🔐 VPN Instance
├── 🖥️ AlmaLinux t2.micro
├── 🔑 EC2-key access
└── 🌐 Default VPC deployment
```

### 💾 Database Layer

#### **04-mongodb** - Document Database
```
🍃 MongoDB Server
├── 📄 Document storage
├── 🌐 DNS: mongodb.stallions.space
└── 📊 Catalogue & User data
```

#### **09-redis** - Cache Layer
```
⚡ Redis Cache
├── 🔄 In-memory caching
├── 🌐 DNS: redis.stallions.space
└── 🛒 Session management
```

#### **12-mysql** - Relational Database
```
🐬 MySQL Server
├── 📊 Relational data
├── 🌐 DNS: mysql.stallions.space
├── 👤 Users: roboshop, shipping
└── 🔐 Password: RoboShop@1
```

#### **14-RabbitMQ** - Message Queue
```
🐰 RabbitMQ Broker
├── 📨 Message queuing
├── 🌐 DNS: rabbitmq.stallions.space
├── 👤 User: roboshop
└── 🔐 Password: roboshop123
```

### ⚖️ Load Balancer Layer

#### **05-app-alb** - Internal Load Balancer
```
⚖️ Application Load Balancer
├── 🔒 Internal (Private)
├── 🎯 Port 80 HTTP
├── 🌐 *.app.stallions.space
└── 📊 Application services routing
```

#### **07-web-alb** - External Load Balancer
```
🌐 Web Load Balancer
├── 🌍 Public facing
├── 🔐 HTTPS (Port 443)
├── 📜 SSL Certificate
├── 🌐 stallions.space
└── 🔄 Route53 validation
```

### 🚀 Application Layer

#### **06-catalogue** - Product Service
```
📚 Catalogue Microservice
├── 🚀 Auto Scaling (1-5 instances)
├── 🎯 Port 8080
├── 🌐 catalogue.app.stallions.space
├── 📊 CPU scaling (50% target)
└── 💾 MongoDB integration
```

#### **10-user** - User Management
```
👥 User Microservice  
├── 🎯 Port 8080
├── 🌐 user.app.stallions.space
├── 💾 MongoDB + Redis
└── 🔄 Priority: 15
```

#### **11-cart** - Shopping Cart
```
🛒 Cart Microservice
├── 🎯 Port 8080  
├── 🌐 cart.app.stallions.space
├── ⚡ Redis integration
└── 🔄 Priority: 20
```

#### **13-shipping** - Logistics
```
📦 Shipping Microservice
├── ☕ Java application
├── 🎯 Port 8080
├── 🌐 shipping.app.stallions.space
├── 🐬 MySQL integration
└── 🔄 Priority: 30
```

#### **15-payment** - Payment Processing
```
💳 Payment Microservice
├── 🐍 Python application
├── 🎯 Port 8080
├── 🌐 payment.app.stallions.space
├── 🐰 RabbitMQ integration
└── 🔄 Priority: 40
```

### 🖥️ Frontend Layer

#### **08-web-server** - Web Frontend
```
🌐 Nginx Web Server
├── 🖥️ Frontend application
├── 🎯 Port 80
├── 🌐 stallions.space
├── 🚀 Auto Scaling
└── 📊 Health checks
```

</details>

---

## 🚀 Quick Start

### ⚡ One-Command Setup

<details>
<summary><b>🔧 Initialize All Modules</b></summary>

```bash
# 🚀 Initialize Terraform for all modules at once
for i in 01-vpc/ 02-firewall/ 03-vpn/ 04-mongodb/ 05-app-alb/ 06-catalogue/ 07-web-alb/ 08-web-server/ 09-redis/ 10-user/ 11-cart/ 12-mysql/ 13-shipping/ 14-RabbitMQ/ 15-payment/ ; do 
  echo "🔧 Initializing $i..."
  cd $i && terraform init && cd ..
done
```

</details>

<details>
<summary><b>📋 Plan All Modules</b></summary>

```bash
# 📋 Plan deployment for all modules
for i in 01-vpc/ 02-firewall/ 03-vpn/ 04-mongodb/ 05-app-alb/ 06-catalogue/ 07-web-alb/ 08-web-server/ 09-redis/ 10-user/ 11-cart/ 12-mysql/ 13-shipping/ 14-RabbitMQ/ 15-payment/ ; do 
  echo "📋 Planning $i..."
  cd $i && terraform plan && cd ..
done
```

</details>

<details>
<summary><b>🚀 Deploy All Modules (Auto-Approve)</b></summary>

```bash
# ⚠️  WARNING: Use with caution in production!
for i in 01-vpc/ 02-firewall/ 03-vpn/ 04-mongodb/ 05-app-alb/ 06-catalogue/ 07-web-alb/ 08-web-server/ 09-redis/ 10-user/ 11-cart/ 12-mysql/ 13-shipping/ 14-RabbitMQ/ 15-payment/ ; do 
  echo "🚀 Deploying $i..."
  cd $i && terraform apply -auto-approve && cd ..
done
```

</details>

### 🎯 Recommended: Step-by-Step Deployment

```bash
# 🏗️ 1. Foundation
cd 01-vpc/ && terraform init && terraform plan && terraform apply
cd ../02-firewall/ && terraform init && terraform plan && terraform apply
cd ../03-vpn/ && terraform init && terraform plan && terraform apply

# 💾 2. Databases  
cd ../04-mongodb/ && terraform init && terraform plan && terraform apply
cd ../09-redis/ && terraform init && terraform plan && terraform apply
cd ../12-mysql/ && terraform init && terraform plan && terraform apply
cd ../14-RabbitMQ/ && terraform init && terraform plan && terraform apply

# ⚖️ 3. Load Balancers
cd ../05-app-alb/ && terraform init && terraform plan && terraform apply
cd ../07-web-alb/ && terraform init && terraform plan && terraform apply

# 🚀 4. Applications
cd ../06-catalogue/ && terraform init && terraform plan && terraform apply
cd ../10-user/ && terraform init && terraform plan && terraform apply
cd ../11-cart/ && terraform init && terraform plan && terraform apply
cd ../13-shipping/ && terraform init && terraform plan && terraform apply
cd ../15-payment/ && terraform init && terraform plan && terraform apply

# 🌐 5. Frontend
cd ../08-web-server/ && terraform init && terraform plan && terraform apply
```

---

## 🔐 SSH Access Guide

### 🚪 VPN Connection

```bash
# 🔑 Connect to VPN instance (replace with actual public IP)
ssh -i EC2-key.pem ec2-user@<VPN_PUBLIC_IP>

# 💡 Get VPN public IP
aws ec2 describe-instances --region ap-south-1 \
  --filters "Name=tag:Name,Values=Roboshop-vpn" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text
```

### 🏠 Internal Server Access

<details>
<summary><b>💾 Database Servers (Database Subnets)</b></summary>

```bash
# 🍃 MongoDB Server
ssh -i EC2-key.pem ec2-user@10.0.21.54

# ⚡ Redis Server  
ssh -i EC2-key.pem ec2-user@10.0.21.55

# 🐬 MySQL Server
ssh -i EC2-key.pem ec2-user@10.0.21.56

# 🐰 RabbitMQ Server
ssh -i EC2-key.pem ec2-user@10.0.21.57
```

</details>

<details>
<summary><b>🚀 Application Servers (Private Subnets)</b></summary>

```bash
# 📚 Catalogue Service
ssh -i EC2-key.pem ec2-user@10.0.11.10

# 👥 User Service
ssh -i EC2-key.pem ec2-user@10.0.12.20

# 🛒 Cart Service  
ssh -i EC2-key.pem ec2-user@10.0.11.30

# 📦 Shipping Service
ssh -i EC2-key.pem ec2-user@10.0.12.40

# 💳 Payment Service
ssh -i EC2-key.pem ec2-user@10.0.11.50

# 🌐 Web Server
ssh -i EC2-key.pem ec2-user@10.0.11.60
```

</details>

---

## 🐛 Debugging & Monitoring

### 📊 Service Status Monitoring

<details>
<summary><b>🔍 System Service Status</b></summary>

```bash
# 📊 Check all service statuses
services=("mongodb" "redis" "mysqld" "rabbitmq-server" "catalogue" "user" "cart" "shipping" "payment" "nginx")

for service in "${services[@]}"; do
  echo "🔍 Checking $service..."
  sudo systemctl status $service --no-pager -l
done
```

</details>

<details>
<summary><b>📝 Real-Time Log Monitoring</b></summary>

```bash
# 📝 Database Services
sudo journalctl -u mongodb -f        # 🍃 MongoDB logs
sudo journalctl -u redis -f          # ⚡ Redis logs  
sudo journalctl -u mysqld -f         # 🐬 MySQL logs
sudo journalctl -u rabbitmq-server -f # 🐰 RabbitMQ logs

# 📝 Application Services  
sudo journalctl -u catalogue -f      # 📚 Catalogue logs
sudo journalctl -u user -f           # 👥 User logs
sudo journalctl -u cart -f           # 🛒 Cart logs
sudo journalctl -u shipping -f       # 📦 Shipping logs
sudo journalctl -u payment -f        # 💳 Payment logs
sudo journalctl -u nginx -f          # 🌐 Nginx logs
```

</details>

<details>
<summary><b>🔍 Historical Log Analysis</b></summary>

```bash
# 📊 Last 50 log entries
sudo journalctl -u catalogue -n 50

# ⏰ Logs from last hour
sudo journalctl -u user --since "1 hour ago"

# 📅 Logs from specific time range
sudo journalctl -u shipping --since "2024-01-01 00:00:00" --until "2024-01-01 23:59:59"

# 🚨 Error logs only
sudo journalctl -u payment -p err
```

</details>

### 🔧 Process & Network Monitoring

<details>
<summary><b>🖥️ Process Monitoring</b></summary>

```bash
# 🔍 Application processes
ps aux | grep java     # ☕ Java applications (Shipping)
ps aux | grep node     # 🟢 Node.js applications (Catalogue, User, Cart)  
ps aux | grep python   # 🐍 Python applications (Payment)
ps aux | grep nginx    # 🌐 Web server

# 📊 Resource usage
top -p $(pgrep -d',' -f catalogue)  # 📚 Catalogue CPU/Memory
htop                                 # 📊 Interactive process viewer
```

</details>

<details>
<summary><b>🌐 Network Monitoring</b></summary>

```bash
# 🔌 Check listening ports
sudo netstat -tlnp | grep 8080  # 🚀 Application services
sudo netstat -tlnp | grep 80    # 🌐 Nginx HTTP
sudo netstat -tlnp | grep 443   # 🔒 Nginx HTTPS
sudo netstat -tlnp | grep 27017 # 🍃 MongoDB
sudo netstat -tlnp | grep 6379  # ⚡ Redis  
sudo netstat -tlnp | grep 3306  # 🐬 MySQL
sudo netstat -tlnp | grep 5672  # 🐰 RabbitMQ

# 📊 Active connections
ss -tuln                         # 📈 Socket statistics
```

</details>

### 🧪 Connectivity Testing

<details>
<summary><b>💾 Database Connectivity</b></summary>

```bash
# 🍃 MongoDB connection test
mongo --host mongodb.stallions.space --eval "db.adminCommand('ismaster')"

# ⚡ Redis connection test  
redis-cli -h redis.stallions.space ping

# 🐬 MySQL connection test
mysql -h mysql.stallions.space -u roboshop -pRoboShop@1 -e "SHOW DATABASES;"

# 🐰 RabbitMQ connection test
curl -u roboshop:roboshop123 http://rabbitmq.stallions.space:15672/api/overview
```

</details>

<details>
<summary><b>🚀 Application Health Checks</b></summary>

```bash
# 🩺 Health endpoint tests
endpoints=("catalogue" "user" "cart" "shipping" "payment")

for endpoint in "${endpoints[@]}"; do
  echo "🩺 Testing $endpoint health..."
  curl -I http://$endpoint.app.stallions.space/health
done

# 🌐 Web server tests
curl -I http://stallions.space      # 📄 HTTP test
curl -I https://stallions.space     # 🔒 HTTPS test
```

</details>

<details>
<summary><b>🌐 DNS Resolution Testing</b></summary>

```bash
# 🔍 Internal DNS resolution
domains=("mongodb" "redis" "mysql" "rabbitmq")

for domain in "${domains[@]}"; do
  echo "🔍 Testing $domain DNS..."
  nslookup $domain.stallions.space
done

# 🚀 Application DNS resolution  
app_domains=("catalogue" "user" "cart" "shipping" "payment")

for domain in "${app_domains[@]}"; do
  echo "🔍 Testing $domain app DNS..."
  nslookup $domain.app.stallions.space
done
```

</details>

---

## 🔧 Troubleshooting

<details>
<summary><b>🚨 Common Issues & Solutions</b></summary>

### 🔒 **Terraform State Lock Issues**
```bash
# 🔍 Problem: Error acquiring the state lock
# 💡 Solution:
aws dynamodb scan --table-name sarthak-tfstate-lock --region ap-south-1

# ⚠️ Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### 🏗️ **VPC Module Issues**  
```bash
# 🔍 Problem: VPC module fails to deploy from GitHub
# 💡 Solution: Test module accessibility
git clone https://github.com/Sarthakx67/Terraform-AWS-VPC-Advanced.git
```

### 🛡️ **Security Group Dependencies**
```bash
# 🔍 Problem: Circular dependency errors
# 💡 Solution: Target specific resources
terraform apply -target=module.mongodb_sg
terraform apply -target=module.catalogue_sg
```

### 🖼️ **AMI Not Found Errors**
```bash
# 🔍 Problem: InvalidAMIID.NotFound for AlmaLinux
# 💡 Solution: Verify AMI in ap-south-1 region
aws ec2 describe-images --owners 679593333241 --region ap-south-1
```

### 🔑 **EC2 Key Pair Issues**
```bash
# 🔍 Problem: Key pair "EC2-key" not found  
# 💡 Solution: Create the key pair
aws ec2 create-key-pair --key-name EC2-key --region ap-south-1 \
  --output text --query 'KeyMaterial' > EC2-key.pem
chmod 400 EC2-key.pem
```

### 🌐 **Route53 Domain Issues**
```bash
# 🔍 Problem: Domain validation fails for SSL
# 💡 Solution: Verify domain configuration
aws route53 list-hosted-zones
aws route53 get-hosted-zone --id <ZONE_ID>
```

</details>

<details>
<summary><b>🔧 Debug Commands</b></summary>

### 📊 **Terraform Debugging**
```bash
# 🔍 List all resources
terraform state list

# 📊 Show resource details  
terraform state show aws_instance.mongodb_instance

# 🔄 Refresh state
terraform refresh  

# 🐛 Debug logging
TF_LOG=DEBUG terraform apply
```

### ☁️ **AWS Resource Verification**
```bash
# 🌐 VPC and networking
aws ec2 describe-vpcs --region ap-south-1
aws ec2 describe-subnets --region ap-south-1
aws ec2 describe-security-groups --region ap-south-1

# 🖥️ Compute resources
aws ec2 describe-instances --region ap-south-1
aws autoscaling describe-auto-scaling-groups --region ap-south-1

# ⚖️ Load balancers  
aws elbv2 describe-load-balancers --region ap-south-1
aws elbv2 describe-target-groups --region ap-south-1
```

</details>

<details>
<summary><b>🧹 Cleanup & Recovery</b></summary>

### 💾 **Backup Procedures**
```bash
# 💾 Backup Terraform state
aws s3 cp s3://sarthak-remote-tfstate/ ./backup/ --recursive

# 🔄 Restore from backup
aws s3 cp ./backup/ s3://sarthak-remote-tfstate/ --recursive
```

### 🗑️ **Resource Cleanup**
```bash
# 🎯 Destroy specific module
terraform destroy -target=module.catalogue

# ⚠️ Destroy all resources (DANGER!)
terraform destroy
```

</details>

---

## ⚙️ Configuration

<details>
<summary><b>🌍 Common Configuration</b></summary>

| Setting | Value | Description |
|---------|-------|-------------|
| **AWS Region** | `ap-south-1` | Asia Pacific (Mumbai) |
| **Project Name** | `roboshop` | Project identifier |
| **Environment** | `dev` | Development environment |
| **Backend Bucket** | `sarthak-remote-tfstate` | Terraform state storage |
| **Lock Table** | `sarthak-tfstate-lock` | State locking mechanism |

</details>

<details>
<summary><b>🌐 Domain Configuration</b></summary>

| Type | Domain | Purpose |
|------|--------|---------|
| **Primary** | `stallions.space` | Main website |
| **App Services** | `*.app.stallions.space` | Microservices |
| **MongoDB** | `mongodb.stallions.space` | Database |
| **Redis** | `redis.stallions.space` | Cache |
| **MySQL** | `mysql.stallions.space` | Database |
| **RabbitMQ** | `rabbitmq.stallions.space` | Message Queue |

</details>

<details>
<summary><b>🔒 Security Configuration</b></summary>

| Layer | Component | Security Measure |
|-------|-----------|------------------|
| **Network** | VPN | IP-restricted SSH access |
| **Database** | Security Groups | Service-specific port access |
| **Application** | ALB | Load balancer only access |
| **Web** | SSL/TLS | HTTPS termination |

</details>

---

## 📦 Dependencies

<details>
<summary><b>🧩 External Modules</b></summary>

| Module | Repository | Purpose |
|--------|------------|---------|
| **VPC Module** | [Terraform-AWS-VPC-Advanced](https://github.com/Sarthakx67/Terraform-AWS-VPC-Advanced.git) | Network infrastructure |
| **Security Group Module** | [RoboShop-Security-Group-Module](https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git) | Security rules |
| **Application Module** | [Terraform-RoboShop-App](https://github.com/Sarthakx67/Terraform-RoboShop-App.git) | Application deployment |
| **Route53 Module** | `terraform-aws-modules/route53/aws` | DNS management |

</details>

<details>
<summary><b>🛠️ Provider Requirements</b></summary>

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

</details>

<details>
<summary><b>🔗 External Dependencies</b></summary>

| Type | Source | Purpose |
|------|--------|---------|
| **Shell Scripts** | [RoboShop-Shell-Scripts](https://github.com/Sarthakx67/RoboShop-Shell-Script-For-Alma-Linux.git) | Service installation |
| **Application Artifacts** | `roboshop-builds.s3.amazonaws.com` | Compiled applications |
| **Base Image** | AlmaLinux OS 8.10.20240820 | Operating system |

</details>

---

## 🔒 Security

<details>
<summary><b>🛡️ Multi-Layer Security</b></summary>

### 🌐 **Network Security**
- ✅ VPC isolation with private subnets
- ✅ Database tier completely isolated  
- ✅ Application tier accessible only via ALB
- ✅ Public access only through Web ALB

### 🔐 **Access Control**  
- ✅ VPN-based SSH access with IP restrictions
- ✅ Security groups with least-privilege rules
- ✅ Service-to-service communication on specific ports only

### 🔒 **Data Protection**
- ✅ SSL/TLS encryption for web traffic
- ✅ Database passwords stored securely  
- ✅ Inter-service communication over private network

### 📊 **Monitoring & Compliance**
- ✅ VPC Flow Logs (can be enabled)
- ✅ CloudTrail integration available
- ✅ Security group rule auditing

</details>

<details>
<summary><b>🎯 Security Best Practices</b></summary>

```bash
# 🔄 Regular Security Maintenance
# 1. Rotate EC2 key pairs regularly
# 2. Review security group rules monthly  
# 3. Monitor VPC Flow Logs
# 4. Enable AWS Config for compliance
# 5. Use AWS Systems Manager Session Manager when possible

# 🔍 Security Audit Commands
aws ec2 describe-security-groups --region ap-south-1 --query 'SecurityGroups[?length(IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]) > `0`]'
```

</details>

---
