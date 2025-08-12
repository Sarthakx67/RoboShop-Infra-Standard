resource "aws_instance" "vpn_instance" {
  ami           = data.aws_ami.roboshop-ami.id
  instance_type = "t2.micro"
  key_name = "EC2-key"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value] 
  # subnet_id = data.aws_subnets.default.ids[0]

  tags = {
    Name = "Roboshop-vpn"
  }
}