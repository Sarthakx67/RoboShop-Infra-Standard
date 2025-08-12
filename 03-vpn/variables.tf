variable "common_tags" {
  default = {
    Project = "roboshop"
    component = "vpn"
    Environment = "DEV"
    Terraform = "true"
  }
}
variable "project_name" {
  default = "roboshop"
}
variable "env" {
  default = "dev"
}