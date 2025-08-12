variable "cidr_block" {
    default = "10.0.0.0/16"
}
variable "common_tags" {
  default = {
    Project = "roboshop-vpc",
    Environment = "DEV"
    Terraform = true
  }
}
variable "env" {
  default = "dev"
}
variable "project_name" {
  default = "roboshop"
}
variable "vpc_tags" {
    default = "roboshop-vpc"
}
variable "igw_tags" {
    default = "roboshop-igw"
}
variable "public_subnet_cidr_block" {
  default = ["10.0.1.0/24","10.0.2.0/24"]
}
variable "private_subnet_cidr_block" {
  default = ["10.0.11.0/24","10.0.12.0/24"]
}
variable "database_subnet_cidr_block" {
  default = ["10.0.21.0/24","10.0.22.0/24"]
}