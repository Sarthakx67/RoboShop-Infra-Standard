resource "aws_instance" "redis_instance" {
  ami           = data.aws_ami.roboshop-ami.id
  instance_type = "t2.micro"
  key_name = "EC2-key"
  user_data = filebase64("06-redis.sh")
  vpc_security_group_ids = [data.aws_ssm_parameter.redis_sg_id.value]
  subnet_id = element(split(",", data.aws_ssm_parameter.database_subnet_ids.value),0)
  tags = {
    Name = "redis"
  }
}

module "records" {
  source = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
      name = "redis"
      type = "A"
      ttl = 1
      records = [
        aws_instance.redis_instance.private_ip
      ]
    }
  ]
}