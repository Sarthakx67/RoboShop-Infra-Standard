module "vpc" {
  source = "git::https://github.com/Sarthakx67/Terraform-AWS-VPC-Advanced.git"
  # creating vpc
  cidr_block = var.cidr_block 
  common_tags = var.common_tags
  project_name = var.project_name
  vpc_tags = var.vpc_tags
  env = var.env
  # creating internet gateway
  igw_tags = var.igw_tags
  # creating public subnet
  public_subnet_cidr_block = var.public_subnet_cidr_block
  # creating private subnet
  private_subnet_cidr_block = var.private_subnet_cidr_block
  #creating database subnet
  database_subnet_cidr_block = var.database_subnet_cidr_block
  #peering
  is_peering_required = true
  requestor_vpc_id = data.aws_vpc.default.id
  default_route_table_id = data.aws_vpc.default.main_route_table_id
  default_vpc_cidr = data.aws_vpc.default.cidr_block
}

