module "payment" {
  source = "git::https://github.com/Sarthakx67/Terraform-RoboShop-App.git"
  project_name = var.project_name
  env = var.env
  common_tags = var.common_tags
  #target group
  # health_check = var.health_check
  target_group_port = var.target_group_port
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  #launch template
  image_id = data.aws_ami.roboshop-ami.id
  key_name = "EC2-key"
  security_group_id = data.aws_ssm_parameter.payment_sg_id.value
  user_data = filebase64("16-payments.sh")
  
  launch_template_tags = var.launch_template_tags

  #autoscaling
  vpc_zone_identifier = split(",",data.aws_ssm_parameter.private_subnet_ids.value)
  tag = var.autoscaling_tags

  #autoscalingpolicy, we can give if we want

  #listener rule
  alb_listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  rule_priority = 40
  host_header = "payment.app.stallions.space"

}