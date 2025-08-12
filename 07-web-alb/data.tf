data "aws_ssm_parameter" "web_alb_sg_id" {
  name  = "/${var.project_name}/${var.env}/web_alb_sg_id"
}
data "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.env}/public_subnet_ids"
}