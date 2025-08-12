variable "common_tags" {
  default = {
    Project = "roboshop"
    component = "web-alb"
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

