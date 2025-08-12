# creating application load balancer to distribute traffic between components
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-${var.common_tags.component}"
  internal           = true # this is a private load balancer so will keep internal as true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",",data.aws_ssm_parameter.private_subnet_ids.value)
#   enable_deletion_protection = true to prevent accedental deletion
  tags = var.common_tags
}

# this will create listners
resource "aws_lb_listener" "app_alb_listner" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"
  # this will add one listner on port no 80 and one default rule
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is Fixed Response as app alb"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = "stallions.space"

  records = [
    {
      name    = "*.app"
      type    = "A"
      alias   = {
        name    = aws_lb.app_alb.dns_name
        zone_id = aws_lb.app_alb.zone_id
      }
    }
  ]
}