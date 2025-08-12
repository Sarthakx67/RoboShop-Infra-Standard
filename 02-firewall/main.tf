# creating vpn security group
module "vpn_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "roboshop-vpn"
  sg_description = "allowing all ports from home ip"
  project_name = var.project_name
  vpc_id = data.aws_vpc.default.id
  common_tags  = merge(
    var.common_tags,
    {
        component = "vpn_sg"
        Name = "Vpn-sg"
    }
  )
}
# creating mongodb security group
module "mongodb_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "mongodb"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "mongodb_sg"
    }
  )
}
# creating catalogue security group
module "catalogue_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "catalogue_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "catalogue_sg"
    }
  )
}
module "user_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "user_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "user_sg"
    }
  )
}
module "redis_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "redis_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "redis_sg"
    }
  )
}
module "cart_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "cart_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "cart_sg"
    }
  )
}

module "mysql_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "mysql_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "mysql_sg"
    }
  )
}

module "shipping_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "shipping_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "shipping_sg"
    }
  )
}

module "rabbitmq_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "rabbitmq_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "rabbitmq_sg"
    }
  )
}

module "payment_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "payment_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "payment_sg"
    }
  )
}

# creating application alb security group to distribute traffic betting applications

module "app_alb_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "app_alb_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "app_alb_sg"
    }
  )

# creating web server security group
}
module "web_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "web_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "web_sg"
    }
  )
}

# creating web alb security group to distribute traffic between multiple web
module "web_alb_sg" {
  source = "git::https://github.com/Sarthakx67/RoboShop-Security-Group-Module.git"
  sg_name = "web_alb_sg"
  sg_description = "allowing traffic"
  project_name = var.project_name
  vpc_id = data.aws_ssm_parameter.roboshop-vpc-id.value
  common_tags  = merge(
    var.common_tags,
    {
        component = "web_alb_sg"
    }
  )
}

# creating aws security group for vpn which should only enable access from my ip
resource "aws_security_group_rule" "vpn" {
  security_group_id = module.vpn_sg.security_group_id
  type = "ingress"
  cidr_blocks   = ["${chomp(data.http.myip.response_body)}/32"]
  from_port   = 0
  protocol = "tcp"
  to_port     = 65535
}

# creating security group rule for mongodb sg only enabling port 22 for ssh by vpn
resource "aws_security_group_rule" "mongodb_vpn" {
  # providing mongodb sg 
  security_group_id = module.mongodb_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}


# creating security group rule for catalogue to only connect with vpn on port 22 by ssh
resource "aws_security_group_rule" "catalogue_vpn" {
  # providing sg 
  security_group_id = module.catalogue_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}


# creating security group rule for catalogue to only connect with vpn on port 22 by ssh
resource "aws_security_group_rule" "user_vpn" {
  # providing sg 
  security_group_id = module.user_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}


# creating security group rule for catalogue to only connect with vpn on port 22 by ssh
resource "aws_security_group_rule" "redis_vpn" {
  # providing sg 
  security_group_id = module.redis_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

# creating security group rule for catalogue to only connect with vpn on port 22 by ssh
resource "aws_security_group_rule" "cart_vpn" {
  # providing sg 
  security_group_id = module.cart_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "mysql_vpn" {
  # providing sg 
  security_group_id = module.mysql_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "shipping_vpn" {
  # providing sg 
  security_group_id = module.shipping_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "rabbitmq_vpn" {
  # providing sg 
  security_group_id = module.rabbitmq_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "payment_vpn" {
  # providing sg 
  security_group_id = module.payment_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

# creating security group rule for mongodb to only connect with catalogue by allowing poet 27107
resource "aws_security_group_rule" "mongodb_catalogue" {
  # providing mongodb sg 
  security_group_id = module.mongodb_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.catalogue_sg.security_group_id 
  from_port   = 27017
  protocol = "tcp"
  to_port     = 27017
}
resource "aws_security_group_rule" "mongodb_user" {
  # providing mongodb sg 
  security_group_id = module.mongodb_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.user_sg.security_group_id 
  from_port   = 27017
  protocol = "tcp"
  to_port     = 27017
}
resource "aws_security_group_rule" "redis_user" {
  # providing mongodb sg 
  security_group_id = module.redis_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.user_sg.security_group_id 
  from_port   = 6379
  protocol = "tcp"
  to_port     = 6379
}
resource "aws_security_group_rule" "redis_cart" {
  # providing mongodb sg 
  security_group_id = module.redis_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.cart_sg.security_group_id 
  from_port   = 6379
  protocol = "tcp"
  to_port     = 6379
}
resource "aws_security_group_rule" "mysql_shipping" {
  # providing mongodb sg 
  security_group_id = module.mysql_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.shipping_sg.security_group_id 
  from_port   = 3306
  protocol = "tcp"
  to_port     = 3306
}
resource "aws_security_group_rule" "rabbitmq_payment" {
  # providing mongodb sg 
  security_group_id = module.rabbitmq_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect mongodb sg to access connection from
  source_security_group_id = module.payment_sg.security_group_id 
  from_port   = 5672
  protocol = "tcp"
  to_port     = 5672
}
resource "aws_security_group_rule" "catalogue_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.catalogue_sg.security_group_id
}

resource "aws_security_group_rule" "user_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.user_sg.security_group_id
}

resource "aws_security_group_rule" "cart_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.cart_sg.security_group_id
}

resource "aws_security_group_rule" "shipping_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.shipping_sg.security_group_id
}

resource "aws_security_group_rule" "payment_app_alb" {
  type              = "ingress"
  description = "Allowing port number 8080 from APP ALB"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.payment_sg.security_group_id
}

# giving ssh access for vpn to connect with app alb on port 22
resource "aws_security_group_rule" "app_alb_vpn" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

# creating sg rule for allowing connection only from web to app alb on port 80 
resource "aws_security_group_rule" "app_alb_web" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id 
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.web_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}
#############################################################
resource "aws_security_group_rule" "app_alb_catalogue" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id 
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.catalogue_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}
resource "aws_security_group_rule" "app_alb_user" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id 
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.user_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}
resource "aws_security_group_rule" "app_alb_cart" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id 
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.cart_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}

resource "aws_security_group_rule" "app_alb_shipping" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id 
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.shipping_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}

resource "aws_security_group_rule" "app_alb_payment" {
  # providing  sg 
  security_group_id = module.app_alb_sg.security_group_id 
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.payment_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}

# creating sg rule for allowing web-server to only connect with web-alb on port 80
resource "aws_security_group_rule" "web_web_alb" {
  # providing  sg 
  security_group_id = module.web_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.web_alb_sg.security_group_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}

# creating sg rule for allowing vpn connection to web-server on port 22
resource "aws_security_group_rule" "web_vpn" {
  # providing sg 
  security_group_id = module.web_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = module.vpn_sg.security_group_id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

# creating sg rule for connecting web alb with internet on port no 80 
resource "aws_security_group_rule" "web_alb_internet" {
  # providing  sg 
  security_group_id = module.web_alb_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}

# creating sg rule for connecting web alb with internet on port no 443/HTTPS 
resource "aws_security_group_rule" "web_alb_internet_https" {
  # providing  sg 
  security_group_id = module.web_alb_sg.security_group_id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  protocol = "tcp"
  to_port     = 443
}