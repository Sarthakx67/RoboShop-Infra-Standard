resource "aws_instance" "rabbitmq_instance" {
  ami           = data.aws_ami.roboshop-ami.id
  instance_type = "t2.micro"
  key_name = "EC2-key"
  user_data = filebase64("05-rabbitmq.sh")
  vpc_security_group_ids = [data.aws_ssm_parameter.rabbitmq_sg_id.value]
  subnet_id = element(split(",", data.aws_ssm_parameter.database_subnet_ids.value),0)
  tags = {
    Name = "rabbitmq"
  }
}

module "records" {
  source = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
      name = "rabbitmq"
      type = "A"
      ttl = 1
      records = [
        aws_instance.rabbitmq_instance.private_ip
      ]
    }
  ]
}