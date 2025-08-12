# creating application load balancer to distribute traffic between components
resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-${var.common_tags.component}"
  internal           = false # this is a public load balancer so will keep internal as false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.web_alb_sg_id.value]
  subnets            = split(",",data.aws_ssm_parameter.public_subnet_ids.value)
#   enable_deletion_protection = true to prevent accedental deletion
  tags = var.common_tags
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "stallions.space"
  validation_method = "DNS"

  tags = var.common_tags
}

data "aws_route53_zone" "stallions" {
  name         = "stallions.space"
  private_zone = false
}

resource "aws_route53_record" "record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.stallions.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}
resource "aws_lb_listener" "web_alb_certificate_listner" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.cert.arn
  # this will add one certificate
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is Fixed Response as app alb certification"
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
      name    = ""
      type    = "A"
      alias   = {
        name    = aws_lb.web_alb.dns_name
        zone_id = aws_lb.web_alb.zone_id
      }
    }
  ]
}