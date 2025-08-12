data "aws_vpc" "default" {
  default = true
}
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}
data "aws_ssm_parameter" "roboshop-vpc-id" {
  name  = "/${var.project_name}/${var.env}/vpc_id"
}