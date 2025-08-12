resource "aws_lb_target_group" "catalogue_tg" {
  name     = "${var.project_name}-${var.common_tags.component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    enabled = true # enable health check
    healthy_threshold   = 2 # threshold to pass health check when healthy_threshold = 2
    interval            = 15 # frequency of health check
    unhealthy_threshold = 3 # fail criteria
    timeout             = 5 # max time to wait
    path                = "/health" # path to health check
    port                = 8080 
    matcher             = "200-299" # range of acceptable output 
    protocol            = "HTTP" 
  }
}   

resource "aws_launch_template" "catalogue" {
  name     = "${var.project_name}-${var.common_tags.component}"
  
  image_id = data.aws_ami.roboshop-ami.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = "EC2-key"
  user_data = filebase64("08-catalogue.sh")

  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Catalogue"
    }
  }
}

resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project_name}-${var.common_tags.component}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.catalogue_tg.arn] # to map arn of catalogue with autoscaling
  launch_template {
    id    = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  vpc_zone_identifier       = split(",",data.aws_ssm_parameter.private_subnet_ids.value)

  tag {
    key                 = "Name"
    value               = "Catalogue"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_policy" "Catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  name                   = "cpu"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue_tg.arn
  }

  condition {
    host_header {
      values = ["catalogue.app.stallions.space"]
    }
  }
}