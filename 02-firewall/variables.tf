variable "common_tags" {
  default = {
    Project = "roboshop"
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