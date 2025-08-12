data "aws_ssm_parameter" "mongodb_sg_id" {
  name  = "/${var.project_name}/${var.env}/mongodb_sg_id"
}
data "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project_name}/${var.env}/database_subnet_ids"
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