resource "aws_instance" "mysql_instance" {
  ami           = data.aws_ami.roboshop-ami.id
  instance_type = "t2.micro"
  key_name = "EC2-key"
  user_data = filebase64("04-mysql.sh")
  vpc_security_group_ids = [data.aws_ssm_parameter.mysql_sg_id.value]
  subnet_id = element(split(",", data.aws_ssm_parameter.database_subnet_ids.value),0)
  tags = {
    Name = "mysql"
  }
}

module "records" {
  source = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
      name = "mysql"
      type = "A"
      ttl = 1
      records = [
        aws_instance.mysql_instance.private_ip
      ]
    }
  ]
}