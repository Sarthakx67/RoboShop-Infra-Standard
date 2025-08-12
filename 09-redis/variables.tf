variable "common_tags" {
  default = {
    Project = "roboshop"
    component = "redis"
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
variable "zone_name" {
  default = "stallions.space"
}
