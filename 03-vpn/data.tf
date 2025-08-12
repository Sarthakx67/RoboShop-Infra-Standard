# data "aws_vpc" "default" {
#   default = true
# }
# data "aws_subnets" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }
data "aws_ssm_parameter" "vpn_sg_id" {
  name  = "/${var.project_name}/${var.env}/vpn_sg_id"
}
data "aws_ami" "roboshop-ami" {
  most_recent      = true
  name_regex       = "AlmaLinux OS 8.10.20240820 x86_64-c076b20a-2305-4771-823f-944909847a05"
  owners           = ["679593333241"]

  filter {
    name   = "name"
    values = ["AlmaLinux OS 8.10.20240820 x86_64-c076b20a-2305-4771-823f-944909847a05"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}