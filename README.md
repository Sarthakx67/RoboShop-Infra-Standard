# RoboShop Terraform Infrastructure

## Project Overview

This repository contains Terraform infrastructure as code for deploying the RoboShop e-commerce application on AWS. The project is organized into 15 distinct modules that deploy different components of the infrastructure in a specific order.

## Architecture

The RoboShop infrastructure consists of the following components:

- **VPC**: Custom Virtual Private Cloud with public, private, and database subnets
- **Security Groups**: Firewall rules for all components
- **VPN**: Bastion host for secure access
- **Databases**: MongoDB, Redis, MySQL, and RabbitMQ
- **Application Load Balancers**: Internal (app-alb) and External (web-alb)
- **Microservices**: Catalogue, User, Cart, Shipping, Payment services
- **Web Server**: Nginx frontend server

## Module Structure

### 01-vpc
Creates the foundational VPC infrastructure including:
- VPC with CIDR block `10.0.0.0/16`
- Public subnets: `10.0.1.0/24`, `10.0.2.0/24`
- Private subnets: `10.0.11.0/24`, `10.0.12.0/24`
- Database subnets: `10.0.21.0/24`, `10.0.22.0/24`
- Internet Gateway and Route Tables
- VPC Peering with default VPC

**Key Files:**
- `main.tf`: Uses external VPC module from GitHub
- `parameters.tf`: Stores VPC and subnet IDs in AWS SSM Parameter Store
- `data.tf`: References default VPC for peering

### 02-firewall
Configures security groups for all application components with specific ingress rules:

**Security Groups Created:**
- VPN security group (allows all traffic from home IP)
- MongoDB, Redis, MySQL, RabbitMQ (database tier)
- Catalogue, User, Cart, Shipping, Payment (application tier)
- Web server and load balancer security groups

**Key Security Rules:**
- SSH access (port 22) through VPN for all components
- Database-specific ports (MongoDB: 27017, Redis: 6379, MySQL: 3306, RabbitMQ: 5672)
- Application services on port 8080 from ALB
- Web traffic (ports 80/443) from internet to web ALB

### 03-vpn
Deploys a VPN instance for secure access:
- AMI: AlmaLinux OS 8.10.20240820
- Instance type: t2.micro
- Key pair: EC2-key
- Deployed in default VPC for external access

### 04-mongodb
MongoDB database deployment:
- Instance type: t2.micro
- Subnet: First database subnet
- User data script: `02-mongodb.sh` (installs and configures MongoDB)
- DNS record: `mongodb.stallions.space`

### 05-app-alb
Internal Application Load Balancer:
- Type: Application Load Balancer (internal)
- Subnets: Private subnets
- Default response: Fixed response on port 80
- DNS wildcard: `*.app.stallions.space`

### 06-catalogue
Catalogue microservice with auto-scaling:
- Launch template with AlmaLinux AMI
- Auto Scaling Group (min: 1, max: 5, desired: 1)
- Target group on port 8080 with health checks
- ALB listener rule for `catalogue.app.stallions.space`
- CPU-based scaling policy (target: 50%)

### 07-web-alb
External Web Application Load Balancer:
- Type: Application Load Balancer (public)
- SSL/TLS certificate for `stallions.space`
- DNS validation through Route53
- HTTPS listener on port 443
- Root domain routing

### 08-web-server
Nginx web server with auto-scaling:
- Uses external Terraform module
- Target group on port 80
- Health check on root path "/"
- Host header: `stallions.space`
- Listener rule priority: 10

### 09-redis
Redis cache server:
- Instance type: t2.micro
- Database subnet deployment
- User data script: `06-redis.sh`
- DNS record: `redis.stallions.space`

### 10-user
User microservice:
- Similar architecture to catalogue service
- Target group port: 8080
- Host header: `user.app.stallions.space`
- Listener rule priority: 15

### 11-cart
Cart microservice:
- Target group port: 8080
- Host header: `cart.app.stallions.space`
- Listener rule priority: 20

### 12-mysql
MySQL database server:
- Instance type: t2.micro
- User data script: `04-mysql.sh` (configures MySQL with application users)
- Database users: 'roboshop' and 'shipping'
- Password: 'RoboShop@1'
- DNS record: `mysql.stallions.space`

### 13-shipping
Shipping microservice (Java-based):
- Target group port: 8080
- Host header: `shipping.app.stallions.space`
- Listener rule priority: 30
- User data script: `14-shipping.sh` (Maven build process)

### 14-RabbitMQ
RabbitMQ message broker:
- Instance type: t2.micro
- User data script: `05-rabbitmq.sh`
- Application user: 'roboshop' with password 'roboshop123'
- DNS record: `rabbitmq.stallions.space`

### 15-payment
Payment microservice (Python-based):
- Target group port: 8080
- Host header: `payment.app.stallions.space`
- Listener rule priority: 40
- User data script: `16-payments.sh`

## Configuration Details

### Common Configuration
All modules share common configuration:
- **AWS Region**: ap-south-1 (Asia Pacific - Mumbai)
- **Project Name**: roboshop
- **Environment**: dev
- **Terraform Backend**: S3 bucket `sarthak-remote-tfstate` with DynamoDB table `sarthak-tfstate-lock`

### Domain Configuration
- **Primary Domain**: stallions.space
- **Application Subdomains**: *.app.stallions.space
- **Database Services**: Direct DNS records (mongodb.stallions.space, etc.)

### Security Configuration
- **VPN Access**: IP-restricted access for SSH (port 22)
- **Database Security**: Only accessible from respective application services
- **Application Security**: Only accessible through load balancers
- **Web Security**: Public access only through web ALB

## Installation Instructions
Installation instructions were not found in the provided code.

## Usage Instructions

### Quick Start Commands

#### Initialize All Modules
```bash
# Initialize Terraform for all modules in sequence
for i in 01-vpc/ 02-firewall/ 03-vpn/ 04-mongodb/ 05-app-alb/ 06-catalogue/ 07-web-alb/ 08-web-server/ 09-redis/ 10-user/ 11-cart/ 12-mysql/ 13-shipping/ 14-RabbitMQ/ 15-payment/ ; do cd $i ; terraform init ; cd .. ; done
```

#### Deploy All Modules Sequentially
```bash
# Plan all modules
for i in 01-vpc/ 02-firewall/ 03-vpn/ 04-mongodb/ 05-app-alb/ 06-catalogue/ 07-web-alb/ 08-web-server/ 09-redis/ 10-user/ 11-cart/ 12-mysql/ 13-shipping/ 14-RabbitMQ/ 15-payment/ ; do cd $i ; terraform plan ; cd .. ; done

# Apply all modules (use with caution - recommend individual deployment)
for i in 01-vpc/ 02-firewall/ 03-vpn/ 04-mongodb/ 05-app-alb/ 06-catalogue/ 07-web-alb/ 08-web-server/ 09-redis/ 10-user/ 11-cart/ 12-mysql/ 13-shipping/ 14-RabbitMQ/ 15-payment/ ; do cd $i ; terraform apply -auto-approve ; cd .. ; done
```

#### Individual Module Deployment (Recommended)
```bash
# Deploy modules one by one for better control
cd 01-vpc/ && terraform init && terraform plan && terraform apply
cd ../02-firewall/ && terraform init && terraform plan && terraform apply
cd ../03-vpn/ && terraform init && terraform plan && terraform apply
# ... continue for each module
```

### SSH Access Commands

#### Connect to VPN Instance
```bash
# Get VPN instance public IP from AWS console or CLI
ssh -i EC2-key.pem ec2-user@<VPN_PUBLIC_IP>
```

#### Access Internal Servers via VPN
```bash
# From VPN instance, SSH to internal servers using private IPs
# Database servers (in database subnets: 10.0.21.x, 10.0.22.x)
ssh -i EC2-key.pem ec2-user@10.0.21.54  # Example MongoDB server
ssh -i EC2-key.pem ec2-user@10.0.21.55  # Example Redis server
ssh -i EC2-key.pem ec2-user@10.0.21.56  # Example MySQL server
ssh -i EC2-key.pem ec2-user@10.0.21.57  # Example RabbitMQ server

# Application servers (in private subnets: 10.0.11.x, 10.0.12.x)
ssh -i EC2-key.pem ec2-user@10.0.11.10  # Example Catalogue server
ssh -i EC2-key.pem ec2-user@10.0.12.20  # Example User server
```

### Service Debugging Commands

#### Check Service Status
```bash
# Check if services are running
sudo systemctl status mongodb
sudo systemctl status redis
sudo systemctl status mysqld
sudo systemctl status rabbitmq-server
sudo systemctl status catalogue
sudo systemctl status user
sudo systemctl status cart
sudo systemctl status shipping
sudo systemctl status payment
sudo systemctl status nginx
```

#### Monitor Service Logs
```bash
# View real-time logs for debugging
sudo journalctl -u mongodb -f
sudo journalctl -u redis -f
sudo journalctl -u mysqld -f
sudo journalctl -u rabbitmq-server -f
sudo journalctl -u catalogue -f
sudo journalctl -u user -f
sudo journalctl -u cart -f
sudo journalctl -u shipping -f
sudo journalctl -u payment -f
sudo journalctl -u nginx -f

# View last 50 lines of logs
sudo journalctl -u catalogue -n 50
sudo journalctl -u user --since "1 hour ago"
```

#### Application-Specific Debugging
```bash
# Check application processes
ps aux | grep java     # For shipping service
ps aux | grep node     # For Node.js services (catalogue, user, cart)
ps aux | grep python   # For payment service
ps aux | grep nginx    # For web server

# Check listening ports
sudo netstat -tlnp | grep 8080  # Application services
sudo netstat -tlnp | grep 80    # Nginx
sudo netstat -tlnp | grep 27017 # MongoDB
sudo netstat -tlnp | grep 6379  # Redis
sudo netstat -tlnp | grep 3306  # MySQL
sudo netstat -tlnp | grep 5672  # RabbitMQ
```

### Validation Commands

#### Test Database Connectivity
```bash
# Test MongoDB connection
mongo --host mongodb.stallions.space --eval "db.adminCommand('ismaster')"

# Test Redis connection
redis-cli -h redis.stallions.space ping

# Test MySQL connection
mysql -h mysql.stallions.space -u roboshop -p

# Test RabbitMQ management (if management plugin enabled)
curl -u roboshop:roboshop123 http://rabbitmq.stallions.space:15672/api/overview
```

#### Test Application Endpoints
```bash
# Test application health checks
curl -I http://catalogue.app.stallions.space/health
curl -I http://user.app.stallions.space/health
curl -I http://cart.app.stallions.space/health
curl -I http://shipping.app.stallions.space/health
curl -I http://payment.app.stallions.space/health

# Test web server
curl -I http://stallions.space
curl -I https://stallions.space
```

#### DNS Resolution Testing
```bash
# Test internal DNS resolution
nslookup mongodb.stallions.space
nslookup redis.stallions.space
nslookup mysql.stallions.space
nslookup rabbitmq.stallions.space
nslookup catalogue.app.stallions.space
nslookup user.app.stallions.space
```

### Deployment Order
The modules are designed for sequential deployment based on their numbering:
1. **01-vpc**: Foundation network infrastructure
2. **02-firewall**: Security groups and rules
3. **03-vpn**: Bastion host for secure access
4. **04-mongodb**: Document database
5. **05-app-alb**: Internal load balancer
6. **06-catalogue**: First application service
7. **07-web-alb**: External load balancer with SSL
8. **08-web-server**: Frontend web server
9. **09-redis**: Cache server
10. **10-user**: User management service
11. **11-cart**: Shopping cart service
12. **12-mysql**: Relational database
13. **13-shipping**: Shipping service
14. **14-RabbitMQ**: Message queue
15. **15-payment**: Payment processing service

## Dependencies

### External Modules
The project uses several external Terraform modules:
1. **VPC Module**: `git::https://github.com/Sarthakx67/Terraform-AWS-VPC-Advanced.git`
2. **Security Group Module**: `git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git`
3. **Application Module**: `git::https://github.com/Sarthakx67/Terraform-RoboShop-App.git`
4. **Route53 Module**: `terraform-aws-modules/route53/aws//modules/records`

### Provider Requirements
- **AWS Provider**: `~> 6.0`
- **Terraform**: Version constraints not explicitly specified in provider blocks

### External Dependencies
- **Shell Scripts**: Each service deployment references external shell scripts from `https://github.com/Sarthakx67/RoboShop-Shell-Script-For-Alma-Linux.git`
- **Application Artifacts**: Downloaded from `https://roboshop-builds.s3.amazonaws.com/`

## State Management
- **Backend Type**: S3
- **Bucket**: sarthak-remote-tfstate
- **State Locking**: DynamoDB table `sarthak-tfstate-lock`
- **Region**: ap-south-1
- **Individual State Files**: Each module maintains separate state files

## Infrastructure Components

### Network Architecture
- **VPC CIDR**: 10.0.0.0/16
- **Availability Zones**: Multi-AZ deployment across 2 AZs
- **Subnet Types**: Public, Private, and Database tiers
- **Internet Connectivity**: Internet Gateway for public subnets, NAT Gateway implied for private subnets

### Compute Resources
- **Instance Type**: Primarily t2.micro for cost optimization
- **Operating System**: AlmaLinux OS 8.10.20240820
- **Auto Scaling**: Configured for web and application services
- **Load Balancing**: Application and Web load balancers for high availability

### Database Layer
- **MongoDB**: Document database for catalogue and user data
- **Redis**: In-memory cache for session management
- **MySQL**: Relational database for shipping data
- **RabbitMQ**: Message queue for asynchronous processing

### Monitoring and Health Checks
- **ALB Health Checks**: HTTP health checks on application endpoints
- **Auto Scaling Policies**: CPU-based scaling triggers
- **Health Check Paths**: Service-specific health check endpoints

## Security Considerations

The infrastructure implements a multi-layered security approach:
- **Network Security**: Private subnets for application and database tiers
- **Access Control**: VPN-based SSH access with IP restrictions
- **Service Isolation**: Security groups restrict inter-service communication
- **SSL/TLS**: HTTPS termination at web load balancer level

## Troubleshooting Information

### Common Deployment Issues

#### 1. Terraform State Lock Issues
**Problem**: `Error: Error acquiring the state lock`
**Solution**:
```bash
# Check DynamoDB table for stuck locks
aws dynamodb scan --table-name sarthak-tfstate-lock --region ap-south-1

# Force unlock if necessary (use with caution)
terraform force-unlock <LOCK_ID>
```

#### 2. VPC Module Issues
**Problem**: VPC module fails to deploy from GitHub
**Solution**:
- Verify internet connectivity
- Check GitHub repository accessibility
- Ensure proper Git credentials if repository is private
```bash
# Test module source accessibility
git clone https://github.com/Sarthakx67/Terraform-AWS-VPC-Advanced.git
```

#### 3. Security Group Dependency Errors
**Problem**: Security groups fail due to circular dependencies
**Solution**:
- Deploy security groups first before adding rules
- Use `terraform apply -target` for specific resources
```bash
terraform apply -target=module.mongodb_sg
terraform apply -target=module.catalogue_sg
```

#### 4. AMI Not Found Errors
**Problem**: `InvalidAMIID.NotFound` for AlmaLinux AMI
**Solution**:
- Verify AMI availability in ap-south-1 region
- Update AMI ID in data sources if needed
- Check AMI owner ID (679593333241) permissions

#### 5. EC2 Key Pair Issues
**Problem**: Key pair "EC2-key" not found
**Solution**:
```bash
# Create the required key pair
aws ec2 create-key-pair --key-name EC2-key --region ap-south-1 --output text --query 'KeyMaterial' > EC2-key.pem
chmod 400 EC2-key.pem
```

#### 6. Route53 Domain Issues
**Problem**: Domain validation fails for SSL certificate
**Solution**:
- Ensure `stallions.space` domain is properly configured in Route53
- Verify domain ownership and DNS propagation
- Check Route53 hosted zone permissions

#### 7. Application Load Balancer Health Check Failures
**Problem**: Target groups show unhealthy targets
**Solution**:
- Check application startup logs on instances
- Verify security group rules allow ALB health checks
- Ensure application is running on correct port (8080)
```bash
# SSH to instance via VPN and check service status
sudo systemctl status <service-name>
sudo journalctl -u <service-name> -f
```

#### 8. Database Connection Issues
**Problem**: Applications cannot connect to databases
**Solution**:
- Verify DNS resolution for database endpoints
- Check security group rules for database ports
- Confirm database services are running
```bash
# Test DNS resolution
nslookup mongodb.stallions.space
nslookup redis.stallions.space
nslookup mysql.stallions.space
```

#### 9. Auto Scaling Issues
**Problem**: Auto Scaling Groups not launching instances
**Solution**:
- Check IAM roles and permissions for Auto Scaling
- Verify launch template configuration
- Review CloudWatch logs for scaling activities
- Ensure sufficient capacity in target subnets

#### 10. User Data Script Failures
**Problem**: Application installation scripts fail
**Solution**:
- Check `/var/log/cloud-init-output.log` on instances
- Verify script permissions and syntax
- Test script execution manually
- Check external dependencies (GitHub repos, S3 artifacts)

### Debugging Commands

#### Check Terraform State
```bash
# List all resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.mongodb_instance

# Refresh state with actual infrastructure
terraform refresh
```

#### Validate Configuration
```bash
# Validate Terraform syntax
terraform validate

# Plan deployment to see changes
terraform plan

# Apply with detailed logging
TF_LOG=DEBUG terraform apply
```

#### AWS Resource Verification
```bash
# Check VPC and subnets
aws ec2 describe-vpcs --region ap-south-1
aws ec2 describe-subnets --region ap-south-1

# Check security groups
aws ec2 describe-security-groups --region ap-south-1

# Check EC2 instances
aws ec2 describe-instances --region ap-south-1

# Check load balancers
aws elbv2 describe-load-balancers --region ap-south-1
```

### Module-Specific Troubleshooting

#### VPC (01-vpc)
- Ensure no IP conflicts with existing VPCs
- Check default VPC exists for peering
- Verify Internet Gateway attachment

#### Firewall (02-firewall)
- Test IP detection service: `curl https://ipv4.icanhazip.com`
- Verify VPN IP is correctly detected and applied
- Check security group rule limits (60 rules per group)

#### Database Modules (MongoDB, Redis, MySQL, RabbitMQ)
- Monitor instance startup with user data logs
- Check service ports are listening: `netstat -tlnp`
- Verify database initialization scripts completed successfully

#### Application Modules (Catalogue, User, Cart, Shipping, Payment)
- Check application artifact downloads from S3
- Verify environment variables in service files
- Monitor application logs for startup errors

#### Load Balancers (App-ALB, Web-ALB)
- Verify listener rules and target group configurations
- Check SSL certificate validation status
- Monitor target group health check status

### Performance Optimization

#### Cost Management
- Monitor t2.micro instance usage and consider t3.micro for better performance
- Review Auto Scaling policies to prevent unnecessary scaling
- Use AWS Cost Explorer to track infrastructure costs

#### Security Best Practices
- Regularly rotate EC2 key pairs
- Implement least-privilege security group rules
- Enable VPC Flow Logs for network monitoring
- Use AWS Systems Manager Session Manager instead of SSH where possible

### Recovery Procedures

#### Disaster Recovery
```bash
# Backup Terraform state
aws s3 cp s3://sarthak-remote-tfstate/ ./backup/ --recursive

# Restore from backup if needed
aws s3 cp ./backup/ s3://sarthak-remote-tfstate/ --recursive
```

#### Clean Up Resources
```bash
# Destroy specific module
terraform destroy -target=module.catalogue

# Destroy all resources (use with extreme caution)
terraform destroy
```
